module winmd

// Type information
pub struct TypeInfo {
mut:
	name                 string
	namespace            string
	methods              []MethodDef
	properties           []Property
	fields               []Field
	interfaces           []TypeRef
	flags                u32
	guid                 GUID
	is_interface         bool
	is_class             bool
	is_enum              bool
	is_valuetype         bool
	base_type            string
	// Fully qualified base type name
	// Windows Runtime-specific type info
	runtime_class        bool
	factories            []FactoryInfo
	events               []Event
	default_interface    string
	composable_factories []FactoryInfo
	static_factories     []FactoryInfo
	protected_methods    []MethodDef
	runtime_flags        RuntimeTypeFlags
}

// Metadata collector
@[heap]
pub struct MetadataCollector {
mut:
	reader &WinMDReader
	types  map[string]TypeInfo
	// Key: Namespace.TypeName
}

// Create new metadata collector
pub fn new_collector(reader &WinMDReader) &MetadataCollector {
	return &MetadataCollector{
		reader: reader
		types:  map[string]TypeInfo{}
	}
}

// Get fully qualified type name
fn (mut r WinMDReader) get_full_type_name(sig TypeSig) !string {
	mut name := ''

	match sig.element_type {
		.class, .valuetype {
			if type_ref := sig.type_ref {
				name = '${type_ref.namespace}.${type_ref.name}'

				if sig.generic_args.len > 0 {
					name += '<'
					for i, arg in sig.generic_args {
						if i > 0 {
							name += ', '
						}
						name += r.get_full_type_name(arg)!
					}
					name += '>'
				}
			}
		}
		.szarray {
			if base := sig.type_ref {
				sub_name := r.get_full_type_name(TypeSig{
					element_type: .class
					type_ref:     base
				})!
				name = '[]${sub_name}'
			}
		}
		else {
			// Handle primitive types
			name = match sig.element_type {
				.boolean { 'bool' }
				.char { 'u16' }
				.i1 { 'i8' }
				.u1 { 'u8' }
				.i2 { 'i16' }
				.u2 { 'u16' }
				.i4 { 'int' }
				.u4 { 'u32' }
				.i8 { 'i64' }
				.u8 { 'u64' }
				.r4 { 'f32' }
				.r8 { 'f64' }
				.string { 'string' }
				else { 'unknown' }
			}
		}
	}

	return name
}

// Collect all metadata
pub fn (mut c MetadataCollector) collect() ! {
	// First pass: Collect all type definitions
	c.collect_types()!

	// Second pass: Collect type members and resolve references
	c.collect_members()!

	// Third pass: Resolve type relationships
	c.resolve_relationships()!
}

// Collect type definitions
fn (mut c MetadataCollector) collect_types() ! {
    // Use resolved TypeDef entries
    typedefs := c.reader.read_typedef_table()!
    
    for typedef in typedefs {
        mut type_info := TypeInfo{
            name: typedef.name          // Already resolved
            namespace: typedef.namespace // Already resolved
            flags: typedef.flags
        }
        
        // Set type classification flags
        type_info.is_interface = (typedef.flags & 0x00000020) != 0
        type_info.is_class = (typedef.flags & 0x00000000) != 0
        type_info.is_valuetype = (typedef.flags & 0x00000100) != 0
        
        // Get type GUID if available
        if guid := c.reader.get_type_guid(typedef.row_id) {
            type_info.guid = guid
        }
        
        full_name := get_full_type_name(type_info.namespace, type_info.name)
        c.types[full_name] = type_info
    }
}

// Collect members for all types
fn (mut c MetadataCollector) collect_members() ! {
	for full_name, mut type_info in c.types {
		// Collect methods
		c.collect_type_methods(mut type_info)!

		// Collect properties
		c.collect_type_properties(mut type_info)!

		// Collect fields
		c.collect_type_fields(mut type_info)!

		// Update the type info
		c.types[full_name] = type_info
	}
}

// Collect methods for a type
fn (mut c MetadataCollector) collect_type_methods(mut type_info TypeInfo) ! {
    // Get method list using resolved MethodDef entries
    method_list := c.reader.collect_type_methods(type_info.name, type_info.namespace)!

    for method in method_list {
        mut method_info := MethodDef{
            name: method.name  // Already resolved
            is_public: (u16(method.flags) & 0x0006) == 0x0006
            is_static: (u16(method.flags) & 0x0010) != 0
            is_virtual: (u16(method.flags) & 0x0040) != 0
            is_abstract: (u16(method.flags) & 0x0400) != 0
            signature: method.signature  // This already contains the return type
            parent_type: get_full_type_name(type_info.namespace, type_info.name)
        }

        // Get parameters using resolved Param entries
        start_idx := method.param_list
        end_idx := c.reader.get_param_list_end(method.row_id)!

        for i := start_idx; i < end_idx; i++ {
            param := c.reader.read_param_entry(i)!
            method_info.parameters << Param{
                name: param.name  // Already resolved
                flags: param.flags
                sequence: param.sequence
                is_in: (param.flags & 0x0001) != 0
                is_out: (param.flags & 0x0002) != 0
                is_optional: (param.flags & 0x0010) != 0
            }
        }

        type_info.methods << method_info
    }
}

// Collect properties for a type
fn (mut c MetadataCollector) collect_type_properties(mut type_info TypeInfo) ! {
	// Get property list using resolved Property entries
	property_list := c.reader.get_type_properties(type_info.name, type_info.namespace)!

	for prop in property_list {
		mut prop_info := Property{
			name:     prop.name
			// Already resolved
			flags:    prop.flags
			type_sig: prop.type_sig
		}

		// Get accessor methods using resolved MethodDef entries
		if method_semantics := c.reader.collect_property_methods(prop.row_id) {
			for ms in method_semantics {
				method := c.reader.read_methoddef_entry(ms.method_rid)!

				match ms.semantic.semantic {
					.getter { prop_info.get_method = &method }
					.setter { prop_info.set_method = &method }
					else {}
				}
			}
		}

		type_info.properties << prop_info
	}
}

// PropertyList and FieldList helper methods for WinMDReader
fn (mut r WinMDReader) get_type_properties(type_name string, type_namespace string) ![]Property {
	mut properties := []Property{}

	// Find the type definition first
	typedef := r.find_typedef(type_name, type_namespace)!

	// Get property map entry for this type
	prop_map_rid := r.find_property_map(typedef.row_id)!

	// If no property map, return empty list
	if prop_map_rid == 0 {
		return properties
	}

	// Get property range
	start_rid := r.get_property_range_start(prop_map_rid)!
	end_rid := r.get_property_range_end(prop_map_rid)!

	// Read all properties in range
	for rid := start_rid; rid < end_rid; rid++ {
		properties << r.read_property_entry(rid)!
	}

	return properties
}

fn (mut r WinMDReader) get_type_fields(type_name string, type_namespace string) ![]Field {
	mut fields := []Field{}

	// Find the type definition
	typedef := r.find_typedef(type_name, type_namespace)!

	// Get field range
	start_rid := typedef.field_list
	end_rid := if typedef.row_id >= r.row_counts.counts[.type_def] {
		r.row_counts.counts[.field_def]
	} else {
		next_typedef := r.read_typedef_entry(typedef.row_id + 1)!
		next_typedef.field_list
	}

	// Read all fields in range
	for rid := start_rid; rid < end_rid; rid++ {
		fields << r.read_field_entry(rid)!
	}

	return fields
}

fn (mut c MetadataCollector) collect_type_fields(mut type_info TypeInfo) ! {
	// Get field list using resolved Field entries
	field_list := c.reader.get_type_fields(type_info.name, type_info.namespace)!

	for field in field_list {
		mut field_info := Field{
			name:         field.name
			// Already resolved
			flags:        field.flags
			signature:    field.signature
			is_static:    (field.flags & 0x0010) != 0
			is_literal:   (field.flags & 0x0040) != 0
			is_init_only: (field.flags & 0x0020) != 0
		}

		// Get constant value if present
		if c.reader.has_constant(field.row_id)! {
			constant := c.reader.read_constant_entry(field.row_id)!
			field_info.constant_value = constant.value
		}

		type_info.fields << field_info
	}
}

fn (mut c MetadataCollector) collect_runtime_features(mut type_info TypeInfo) ! {
    // Get custom attributes in raw form
    typedef := c.reader.find_typedef(type_info.name, type_info.namespace)!  // Keep this
    
    if custom_attr_count := c.reader.row_counts.counts[.custom_attribute] {
        for i := u32(0); i < custom_attr_count; i++ {
            raw_attr := c.reader.read_custom_attribute_entry(i)!
            token_info := decode_token(raw_attr.parent)
            
            // Use typedef.row_id instead of type_info.row_id
            if token_info.index == typedef.row_id && token_info.token_type == .type_def {
                if guid := c.reader.get_type_guid(decode_token(raw_attr.type_).index) {
                    match guid {
                        iid_activatable {
                            mut factory := c.reader.resolve_factory(raw_attr)!
                            type_info.factories << factory
                            type_info.runtime_flags.set(.activatable)
                        }
                        iid_composable {
                            mut factory := c.reader.resolve_factory(raw_attr)!
                            type_info.composable_factories << factory
                            type_info.runtime_flags.set(.composable)
                        }
                        iid_static {
                            mut factory := c.reader.resolve_factory(raw_attr)!
                            type_info.static_factories << factory 
                            type_info.runtime_flags.set(.static_)
                        }
                        iid_default_interface {
                            type_info.default_interface = c.reader.parse_default_interface(raw_attr)!
                        }
                        else {}
                    }
                }
            }
        }
    }
}

fn is_activatable_attribute(attr CustomAttributeRowRaw, mut reader &WinMDReader) !bool {
	type_token := decode_token(attr.type_)
	if guid := reader.get_type_guid(type_token.index) {
		return guid == iid_activatable
	}
	return false
}

fn is_composable_attribute(attr CustomAttributeRowRaw, mut reader &WinMDReader) !bool {
	type_token := decode_token(attr.type_)
	if guid := reader.get_type_guid(type_token.index) {
		return guid == iid_composable
	}
	return false
}

fn is_static_attribute(attr CustomAttributeRowRaw, mut reader &WinMDReader) !bool {
	type_token := decode_token(attr.type_)
	if guid := reader.get_type_guid(type_token.index) {
		return guid == iid_static
	}
	return false
}

// Resolve type relationships
fn (mut c MetadataCollector) resolve_relationships() ! {
    for _, mut type_info in c.types {
        // Get the TypeDef once since we'll need it multiple times
        typedef := c.reader.find_typedef(type_info.name, type_info.namespace)!

        // Resolve base type using resolved TypeRef
        base := c.reader.resolve_base_type(type_info.name, type_info.namespace) or {
            // No base type is fine - not every type has one
            continue
        }
        type_info.base_type = get_full_type_name(base.namespace, base.name)

        // Resolve interfaces using resolved TypeRef entries
        interfaces := c.reader.get_implemented_interfaces(type_info.name, type_info.namespace)!
        type_info.interfaces = interfaces

        // For Windows Runtime types, collect additional metadata
        if (type_info.flags & windows_runtime_type) != 0 {
            // Use the TypeDef's row_id for get_runtime_class
            runtime_class := c.reader.get_runtime_class(typedef.row_id)!
            type_info.runtime_class = true
            type_info.factories = runtime_class.factories
            type_info.events = runtime_class.events
            type_info.default_interface = runtime_class.default_iface
            type_info.composable_factories = runtime_class.composable
            type_info.static_factories = runtime_class.statics
            type_info.runtime_flags = runtime_class.flags
        }
    }
}

// Helper function to get V type name from metadata type
fn get_v_type_name(type_name string) string {
	return match type_name {
		'Int32' { 'int' }
		'UInt32' { 'u32' }
		'Int64' { 'i64' }
		'UInt64' { 'u64' }
		'Single' { 'f32' }
		'Double' { 'f64' }
		'Boolean' { 'bool' }
		'String' { 'string' }
		'Void' { '' }
		else { type_name }
	}
}

// Start of code generation structures
pub struct VCodeGenerator {
mut:
	collector &MetadataCollector
	out_dir   string
}

pub fn new_code_generator(collector &MetadataCollector, out_dir string) &VCodeGenerator {
	return &VCodeGenerator{
		collector: collector
		out_dir:   out_dir
	}
}

// Resolve type signature into string
fn (mut c MetadataCollector) resolve_type_signature(sig_blob u32) !string {
	blob := c.reader.get_blob(sig_blob)!
	mut decoder := new_sig_decoder(blob, c.reader)
	type_sig := decoder.read_type_sig()!

	return c.get_type_name(type_sig)!
}

// Convert type signature to name
fn (mut c MetadataCollector) get_type_name(sig TypeSig) !string {
	if sig.namespace == '' {
		// Handle primitive types
		match sig.element_type {
			.void { return 'void' }
			.boolean { return 'bool' }
			.char { return 'u16' } // Unicode character
			.i1 { return 'i8' }
			.u1 { return 'u8' }
			.i2 { return 'i16' }
			.u2 { return 'u16' }
			.i4 { return 'int' }
			.u4 { return 'u32' }
			.i8 { return 'i64' }
			.u8 { return 'u64' }
			.r4 { return 'f32' }
			.r8 { return 'f64' }
			.string { return 'string' }
			else { return error('Unknown primitive type: ${sig.element_type}') }
		}
	}

	mut name := ''
	if sig.is_by_ref {
		name += '&'
	}

	if sig.array_rank > 0 {
		name += '[]'.repeat(sig.array_rank)
	}

	name += get_full_type_name(sig.namespace, sig.class_name)

	if sig.generic_args.len > 0 {
		name += '<'
		for i, arg in sig.generic_args {
			if i > 0 {
				name += ', '
			}
			name += c.get_type_name(arg)!
		}
		name += '>'
	}

	return name
}

// Find method by name
fn (mut c MetadataCollector) find_method(type_info TypeInfo, name string) ?MethodDef {
	for method in type_info.methods {
		if method.name == name {
			return method
		}
	}
	return none
}

fn (mut c MetadataCollector) find_property_method(prop_row PropertyDef, semantic MethodSemantics) !&MethodDef {
	// Get all method semantics for this property
	method_semantics := c.reader.collect_property_methods(prop_row.row_id)!

	// Find method with matching semantic
	for ms in method_semantics {
		if ms.semantic == semantic {
			// Get method definition
			method := c.reader.read_methoddef_entry(ms.method_rid)!
			if found := c.find_method_by_rid(method.row_id) {
				return found
			}
		}
	}

	return error('Property method not found')
}

// Find field constant value
fn (mut c MetadataCollector) find_field_constant(field_row FieldRowRaw) !string {
	if constant := c.reader.get_field_constant(field_row.row_id)! {
		return constant
	}
	return error('Field constant not found')
}

// Collect type method parameters
fn (mut c MetadataCollector) collect_method_parameters(method_row MethodDef) ![]Param {
    mut params := []Param{}

    // Get parameter list range
    start_idx := method_row.param_list
    end_idx := c.reader.get_param_list_end(method_row.row_id)!

    // Read parameters
    for i := start_idx; i < end_idx; i++ {
        param_row := c.reader.read_param_entry(i)!
        
        // Parameters are 1-based in metadata
        param_idx := param_row.sequence - 1
        if param_idx >= method_row.signature.params.len {
            return error('Parameter index out of range')
        }
        
        param_sig := method_row.signature.params[param_idx]
        mut param := Param{
            name: param_row.name
            flags: param_row.flags
            sequence: param_row.sequence
            is_in: (param_row.flags & 0x0001) != 0
            is_out: (param_row.flags & 0x0002) != 0
            is_optional: (param_row.flags & 0x0010) != 0
            type_name: c.get_type_name(param_sig)! // Get type name from already resolved signature
        }

        params << param
    }

    return params
}

fn (mut r WinMDReader) get_param_list_end(method_rid u32) !u32 {
	if method_count := r.row_counts.counts[.method_def] {
		for i := method_rid; i < method_count; i++ {
			next_method := r.read_methoddef_entry(i + 1)!
			if next_method.param_list > 0 {
				return next_method.param_list
			}
		}

		// If no next method found, return total param count
		return r.row_counts.counts[.param]
	}
	return error('Method not found')
}

// Helper to find method by row ID
fn (mut c MetadataCollector) find_method_by_rid(row_id u32) !&MethodDef {
	// Search all loaded types
	for _, mut typ in c.types {
		for i, method in typ.methods {
			if methoddef := c.reader.read_methoddef_entry(row_id) {
				if method.signature == methoddef.signature && method.name == methoddef.name {
					return &typ.methods[i]
				}
			}
		}
	}
	return error('Method not found')
}
