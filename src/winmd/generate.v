module winmd

import os

// Code generator for V output
pub struct CodeGenerator {
mut:
	collector &MetadataCollector
	out_dir   string
	type_map  map[string]string
	// Maps WinRT types to V types
}

// Create new code generator
pub fn new_code_generator(collector &MetadataCollector, out_dir string) &CodeGenerator {
	mut type_map := map[string]string{}

	// Initialize common type mappings
	type_map['Void'] = ''
	type_map['Boolean'] = 'bool'
	type_map['String'] = 'string'
	type_map['Int32'] = 'int'
	type_map['UInt32'] = 'u32'
	type_map['Int64'] = 'i64'
	type_map['UInt64'] = 'u64'
	type_map['Single'] = 'f32'
	type_map['Double'] = 'f64'
	type_map['Char'] = 'rune'
	type_map['Byte'] = 'u8'
	type_map['SByte'] = 'i8'
	type_map['Int16'] = 'i16'
	type_map['UInt16'] = 'u16'

	return &CodeGenerator{
		collector: collector
		out_dir:   out_dir
		type_map:  type_map
	}
}

// Generate all V code
pub fn (mut g CodeGenerator) generate() ! {
	for fully_qualified, type_info in g.collector.types {
		if !type_info.runtime_class {
			continue
		}

		code := g.generate_type(type_info)!

		// Write to file
		file_name := type_info.name.to_lower()
		file_path := os.join_path(g.out_dir, '${file_name}.v')
		os.write_file(file_path, code)!
	}
}

// Map WinRT type to V type
fn (g &CodeGenerator) map_type(winrt_type string) string {
	if winrt_type in g.type_map {
		return g.type_map[winrt_type]
	}
	return winrt_type
}

// Generate delegate
fn (mut g CodeGenerator) generate_delegate(type_info TypeInfo) !string {
    mut invoke_method := type_info.methods.filter(it.name == 'Invoke')[0] or {
        return error('Delegate type ${type_info.name} has no Invoke method')
    }

    mut result := 'pub type ${type_info.name} = fn ('

    // Generate parameter list
    for i, param in invoke_method.parameters {
        if i > 0 {
            result += ', '
        }
        result += '${to_snake(param.name)} ${g.map_type(param.type_name)}'
    }

    result += ')'

    if invoke_method.signature.ret_type.element_type != .void {
        result += ' ${g.map_complex_type(invoke_method.signature.ret_type)!}'
    }

    return result + '\n'
}

// Generate class
fn (mut g CodeGenerator) generate_class(type_info TypeInfo) !string {
	mut result := 'pub struct ${type_info.name} {'

	// Add base type if any
	if type_info.base_type != '' {
		result += ' ${g.map_type(type_info.base_type)} '
	}

	result += '\npub mut:\n'

	// Generate fields from resolved Field types
	for field in type_info.fields {
		field_name := to_snake(field.name)
		field_type := g.map_type(field.type_name)
		result += '\t${field_name} ${field_type}\n'
	}

	result += '}\n\n'

	// Generate interface implementations from resolved TypeRef
	for interface_ in type_info.interfaces {
		result += g.generate_interface_impl(type_info, interface_)!
	}

	// Generate factory methods if activatable
	if type_info.runtime_flags.has(.activatable) {
		result += g.generate_factory_methods(type_info)!
	}

	return result
}

// Convert PascalCase to snake_case
fn to_snake(s string) string {
	if s.len < 2 {
		return s.to_lower()
	}

	mut result := []string{}
	mut current := s[0].str().to_lower()

	for i := 1; i < s.len; i++ {
		c := s[i]
		if c.is_capital() {
			result << current
			current = c.str().to_lower()
		} else {
			current += c.str()
		}
	}

	result << current
	return result.join('_')
}

// Generate code for a type
fn (mut g CodeGenerator) generate_type(type_info TypeInfo) !string {
	mut result := ''

	if type_info.is_enum {
		result += g.generate_enum(type_info)!
	} else if type_info.is_interface {
		result += g.generate_interface(type_info)!
	} else if type_info.runtime_flags.has(.delegate) {
		result += g.generate_delegate(type_info)!
	} else {
		result += g.generate_class(type_info)!
	}

	return result + '\n'
}

// Generate interface implementation
fn (mut g CodeGenerator) generate_interface_impl(type_info TypeInfo, interface_ TypeRef) !string {
	interface_name := get_full_type_name(interface_.namespace, interface_.name)
	interface_info := g.collector.types[interface_name] or {
		return error('Interface not found: ${interface_name}')
	}

	mut result := '// ${interface_name} implementation\n'

	// Generate methods using resolved MethodDef entries
	for method in interface_info.methods {
		result += '@[inline]\n'
		result += 'pub fn (mut obj ${type_info.name}) ${method.name.to_lower()}'
		result += g.generate_method_params(method)
		result += ' {\n'
		result += g.generate_method_body(type_info, method)!
		result += '}\n\n'
	}

	return result
}

// Generate method signature
fn (mut g CodeGenerator) generate_method_signature(method MethodDef) !string {
    mut result := '\tfn ${method.name.to_lower()}'
    result += g.generate_method_params(method)
    
    if method.signature.ret_type.element_type != .void {
        result += ' !'
        result += g.map_complex_type(method.signature.ret_type)!
    }
    
    return result
}

// Generate method parameters
fn (g &CodeGenerator) generate_method_params(method MethodDef) string {
	mut result := '('

	// Add self parameter for instance methods
	if !method.is_static {
		result += 'mut self ${g.map_type(method.parent_type)}'
		if method.parameters.len > 0 {
			result += ', '
		}
	}

	// Add other parameters
	for i, param in method.parameters {
		if i > 0 {
			result += ', '
		}

		// Handle ref parameters
		if param.is_out {
			result += 'mut '
		}
		result += '${param.name.to_lower()} '

		if param.is_optional {
			result += '?'
		}

		result += g.map_type(param.type_name)
	}

	result += ')'
	return result
}

// Generate method body with COM interop
fn (mut g CodeGenerator) generate_method_body(type_info TypeInfo, method MethodDef) !string {
	mut result := '\t'

	// Get COM method index
	vtable_index := g.get_vtable_index(type_info, method)!

	// Generate parameter preparation
	for param in method.parameters {
		if param.is_out {
			result += 'mut ${param.name}_ptr := unsafe { nil }\n\t'
		}
	}

	// Generate COM call
	result += 'hr := C.${type_info.name}_${method.name}(mut self'

	for param in method.parameters {
		result += ', '
		if param.is_out {
			result += '&${param.name}_ptr'
		} else {
			result += param.name
		}
	}

	result += ')\n\t'

	// Check HRESULT
	result += 'check_hresult(hr)!\n\t'

	// Handle out parameters and return value
	if method.signature.ret_type.element_type != .void {
		result += 'return '
		if method.signature.ret_type in g.type_map {
			result += g.generate_primitive_return(method.signature.ret_type)
		} else {
			result += g.generate_complex_return(method.signature.ret_type)
		}
		result += '\n'
	}

	return result
}

// Generate factory methods
fn (mut g CodeGenerator) generate_factory_methods(type_info TypeInfo) !string {
	mut result := ''

	// Standard activation using resolved FactoryInfo
	if type_info.factories.len > 0 {
		result += g.generate_activation_factory(type_info)!
	}

	// Composable activation
	if type_info.composable_factories.len > 0 {
		result += g.generate_composable_factory(type_info)!
	}

	// Static factory methods
	if type_info.static_factories.len > 0 {
		result += g.generate_static_factory(type_info)!
	}

	return result
}

// Generate standard activation factory
fn (mut g CodeGenerator) generate_activation_factory(type_info TypeInfo) !string {
	mut result := 'pub fn new_${type_info.name.to_lower()}() !&${type_info.name} {\n'
	result += '\tmut factory := unsafe { nil }\n'
	result += '\thr := C.RoGetActivationFactory(\n'
	result += '\t\tuts16("${type_info.namespace}.${type_info.name}"),\n'
	result += '\t\t&IID_${type_info.name}Factory,\n'
	result += '\t\t&factory\n'
	result += '\t)\n'
	result += '\tcheck_hresult(hr)!\n'
	result += '\tdefer { release(factory) }\n\n'

	result += '\tmut instance := unsafe { nil }\n'
	result += '\thr = factory.CreateInstance(&instance)\n'
	result += '\tcheck_hresult(hr)!\n\n'

	result += '\treturn instance\n'
	result += '}\n\n'

	return result
}

// Generate composable factory
fn (mut g CodeGenerator) generate_composable_factory(type_info TypeInfo) !string {
	mut result := 'pub fn new_${type_info.name.to_lower()}_composable(inner &IInspectable) !&${type_info.name} {\n'
	result += '\tmut factory := unsafe { nil }\n'
	result += '\thr := C.RoGetActivationFactory(\n'
	result += '\t\tuts16("${type_info.namespace}.${type_info.name}"),\n'
	result += '\t\t&IID_${type_info.name}Factory,\n'
	result += '\t\t&factory\n'
	result += '\t)\n'
	result += '\tcheck_hresult(hr)!\n'
	result += '\tdefer { release(factory) }\n\n'

	result += '\tmut outer := unsafe { nil }\n'
	result += '\tmut inner_interface := unsafe { nil }\n'
	result += '\thr = factory.CreateInstanceWithInner(inner, &outer, &inner_interface)\n'
	result += '\tcheck_hresult(hr)!\n\n'

	result += '\treturn outer\n'
	result += '}\n\n'

	return result
}

// Generate static method body
fn (mut g CodeGenerator) generate_static_method_body(type_info TypeInfo, factory FactoryInfo, method MethodDef) !string {
	mut result := '\tmut factory := unsafe { nil }\n'
	result += '\thr := C.RoGetActivationFactory(\n'
	result += '\t\tuts16("${type_info.namespace}.${type_info.name}"),\n'
	result += '\t\t&${factory.guid},\n'
	result += '\t\t&factory\n'
	result += '\t)\n'
	result += '\tcheck_hresult(hr)!\n'
	result += '\tdefer { release(factory) }\n\n'

	// Generate actual method call using resolved method info
	result += '\t'
	if method.signature.ret_type.element_type != .void {
		result += 'mut result := unsafe { nil }\n\t'
	}

	result += 'hr = factory.${method.name}('

	// Add parameters from resolved Param
	for i, param in method.parameters {
		if i > 0 {
			result += ', '
		}
		if param.is_out {
			result += '&'
		}
		result += param.name
	}

	result += ')\n'
	result += '\tcheck_hresult(hr)!\n\n'

	// Handle return value
	if method.signature.ret_type.element_type != .void {
		result += '\treturn result\n'
	}

	return result
}

// Get vtable index for a method
fn (mut g CodeGenerator) get_vtable_index(type_info TypeInfo, method MethodDef) !u32 {
	mut index := u32(3) // Start after IUnknown methods
	if type_info.is_interface {
		for m in type_info.methods {
			if m.name == method.name {
				return index
			}
			index++
		}
	} else {
		// Need to count interface methods in order
		for interface_ in type_info.interfaces {
			iface_name := get_full_type_name(interface_.namespace, interface_.name)
			iface_info := g.collector.types[iface_name] or {
				return error('Interface not found: ${iface_name}')
			}

			for m in iface_info.methods {
				if m.name == method.name {
					return index
				}
				index++
			}
		}
	}

	return error('Method not found in vtable')
}

// Generate primitive type return
fn (g &CodeGenerator) generate_primitive_return(type_name string) string {
	match type_name {
		'Boolean' { return 'result != 0' }
		'Int32', 'UInt32' { return 'int(result)' }
		'Int64', 'UInt64' { return 'i64(result)' }
		'Single' { return 'f32(result)' }
		'Double' { return 'f64(result)' }
		'String' { return 'string(result)' }
		else { return 'result' }
	}
}

// Generate complex type return
fn (g &CodeGenerator) generate_complex_return(type_name string) string {
	return '&${type_name}{raw: result}'
}

// Generate enum
fn (mut g CodeGenerator) generate_enum(type_info TypeInfo) !string {
	mut result := 'pub enum ${type_info.name} {\n'

	for field in type_info.fields {
		name := to_snake(field.name)
		if constant_value := field.constant_value {
			result += '\t${name} = ${constant_value}\n'
		} else {
			result += '\t${name}\n'
		}
	}

	result += '}\n'
	return result
}

// Generate interface
fn (mut g CodeGenerator) generate_interface(type_info TypeInfo) !string {
	mut result := 'pub interface ${type_info.name}'

	// Add base interfaces
	if type_info.interfaces.len > 0 {
		result += ' {'
		for i, interface_ in type_info.interfaces {
			if i > 0 {
				result += ', '
			}
			iface_name := get_full_type_name(interface_.namespace, interface_.name)
			result += g.map_type(iface_name)
		}
		result += '}'
	}

	result += ' {\n'

	// Generate methods
	for method in type_info.methods {
		result += g.generate_method_signature(method)!
		result += '\n'
	}

	// Generate properties
	for prop in type_info.properties {
		if method := prop.get_method {
			result += g.generate_method_signature(method)!
			result += '\n'
		}
		if method := prop.set_method {
			result += g.generate_method_signature(method)!
			result += '\n'
		}
	}

	// Generate events
	for event in type_info.events {
		result += g.generate_method_signature(event.add_method)!
		result += '\n'
		result += g.generate_method_signature(event.remove_method)!
		result += '\n'
	}

	result += '}\n'
	return result
}

// Generate static factory methods
fn (mut g CodeGenerator) generate_static_factory(type_info TypeInfo) !string {
    mut result := ''

    // Generate methods for each resolved factory
    for factory in type_info.static_factories {
        for method in factory.methods {
            method_name := to_snake(method.name)
            result += 'pub fn ${type_info.name}_${method_name}'
            result += g.generate_method_params(method)

            if method.signature.ret_type.element_type != .void {
                result += ' !'
                result += g.map_complex_type(method.signature.ret_type)!  // Changed to map_complex_type
            }

            result += ' {\n'
            result += g.generate_static_method_body(type_info, factory, method)!
            result += '}\n\n'
        }
    }

    return result
}

// Add to generator.v
pub enum MarshalType {
	none
	bstr
	lpstr
	lpwstr
	interface
	struct
	array
	safearray
	variant
	bool
	i1
	u1
	i2
	u2
	i4
	u4
	i8
	u8
	r4
	r8
}

struct MarshalInfo {
pub mut:
	type_        MarshalType
	element_type ?MarshalType
	// For arrays
	iid          ?GUID
	// For interfaces
	value_type   bool
	// For structs
	array_size   int
	// Fixed size arrays
}

// Get marshalling info for a type
fn (mut g CodeGenerator) get_marshal_info(sig TypeSig) !MarshalInfo {
	mut info := MarshalInfo{}

	match sig.element_type {
		.class, .valuetype {
			if type_ref := sig.type_ref {
				if type_ref.namespace == 'System' {
					match type_ref.name {
						'String' { info.type_ = .bstr }
						'Boolean' { info.type_ = .bool }
						'Byte' { info.type_ = .u1 }
						'SByte' { info.type_ = .i1 }
						'Int16' { info.type_ = .i2 }
						'UInt16' { info.type_ = .u2 }
						'Int32' { info.type_ = .i4 }
						'UInt32' { info.type_ = .u4 }
						'Int64' { info.type_ = .i8 }
						'UInt64' { info.type_ = .u8 }
						'Single' { info.type_ = .r4 }
						'Double' { info.type_ = .r8 }
						else { info.type_ = .struct }
					}
				} else {
					// Check if it's an interface
					if type_def := g.collector.find_type(type_ref.namespace, type_ref.name) {
						if type_def.is_interface {
							info.type_ = .interface
							info.iid = type_def.guid
						} else {
							info.type_ = .struct
							info.value_type = type_def.is_valuetype
						}
					}
				}
			}
		}
		.array {
			info.type_ = .array
			if elem := sig.element_sig {
				elem_info := g.get_marshal_info(elem)!
				info.element_type = elem_info.type_
			}
			info.array_size = sig.array_rank
		}
		.szarray {
			info.type_ = .safearray
			if elem := sig.element_sig {
				elem_info := g.get_marshal_info(elem)!
				info.element_type = elem_info.type_
			}
		}
		else {
			// Map primitive types
			info.type_ = match sig.element_type {
				.boolean { .bool }
				.char { .u2 }
				.i1 { .i1 }
				.u1 { .u1 }
				.i2 { .i2 }
				.u2 { .u2 }
				.i4 { .i4 }
				.u4 { .u4 }
				.i8 { .i8 }
				.u8 { .u8 }
				.r4 { .r4 }
				.r8 { .r8 }
				.string { .bstr }
				else { .variant }
			}
		}
	}

	return info
}

// Generate marshalling code
fn (mut g CodeGenerator) generate_marshal_in(name string, info MarshalInfo) string {
	match info.type_ {
		.bstr {
			return 'bstr_from_str(${name})'
		}
		.interface {
			if iid := info.iid {
				return 'query_interface(${name}, &${iid})!'
			}
			return name
		}
		.struct {
			if info.value_type {
				return '&${name}'
			}
			return name
		}
		.array {
			if size := info.array_size {
				return 'fixed_array_to_ptr(${name}, ${size})'
			}
			return 'array_to_ptr(${name})'
		}
		.safearray {
			if elem := info.element_type {
				return 'create_safearray(${name}, ${int(elem)})'
			}
			return 'create_variant_array(${name})'
		}
		else {
			return name
		}
	}
}

fn (mut g CodeGenerator) generate_marshal_out(name string, info MarshalInfo) string {
	match info.type_ {
		.bstr {
			return 'str_from_bstr(${name})'
		}
		.interface {
			if iid := info.iid {
				type_name := g.get_type_name(iid)
				return 'new_com_object[${type_name}](${name})'
			}
			return name
		}
		.struct {
			if info.value_type {
				return '*${name}'
			}
			return name
		}
		.array {
			if size := info.array_size {
				return 'ptr_to_fixed_array(${name}, ${size})'
			}
			return 'ptr_to_array(${name})'
		}
		.safearray {
			if elem := info.element_type {
				return 'array_from_safearray(${name}, ${int(elem)})'
			}
			return 'variant_array_from_safearray(${name})'
		}
		else {
			return name
		}
	}
}
