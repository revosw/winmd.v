// winmd/winrt_metadata.v
module winmd

// Method flags
@[flag]
pub enum MethodFlags {
	static_
	// 0x00000001
	public_
	// 0x00000002
	private_
	// 0x00000004
	protected_
	// 0x00000008
	virtual_
	// 0x00000010
	abstract_
	// 0x00000020
	sealed
	// 0x00000040
	runtime_special_name
	// 0x00000080
}

// Property accessor types
@[flag]
pub enum MethodSemanticsFlag {
	setter
	// 0x0001
	getter
	// 0x0002
	other
	// 0x0004
	add
	// 0x0008
	remove
	// 0x0010
	raise
	// 0x0020
}

pub enum TypeTokenType {
	typedef
	typeref
	typespec
}

// Custom attribute value types
pub enum CustomAttrValueType {
	boolean
	char
	i8
	u8
	i16
	u16
	i32
	u32
	i64
	u64
	f32
	f64
	string
	type_
}

// Factory information
pub struct FactoryInfo {
pub mut:
	interface_name string
	methods        []MethodDef
	guid           GUID
}

// Property definition row structure
pub struct PropertyDef {
pub mut:
	flags       u32
	name_idx    u32
	// String heap index
	type_sig    u32
	// Blob heap index
	parent_type string
	// Fully qualified type name
	row_id      u32

	// Runtime resolved fields
	name string
}

// Keep original MethodSemantic
pub struct MethodSemantic {
pub mut:
	method   &MethodDef
	semantic MethodSemantics
}

// Constants for Windows Runtime specific flags
pub const runtime_special_name = u32(0x00000400)
pub const windows_runtime_type = u32(0x00004000)
pub const sealed_flag = u32(0x00000100)
pub const interface_flag = u32(0x00000020)

// Runtime class information
pub struct RuntimeClassInfo {
mut:
	flags          RuntimeTypeFlags
	type_def_index u32
	name           string
	namespace      string
	extends_type   string
	interfaces     []string
	factories      []FactoryInfo
	composable     []FactoryInfo
	statics        []FactoryInfo
	events         []Event
	default_iface  string
}

// Decode metadata token into table and index
pub fn decode_token(token u32) TokenInfo {
	return TokenInfo{
		token_type: unsafe { TokenType(token >> 24) }
		index:      token & 0x00FFFFFF
	}
}

// Encode table and index into metadata token
pub fn encode_token(table TokenType, index u32) u32 {
	return (u32(table) << 24) | (index & 0x00FFFFFF)
}

// Token types and encoding
pub enum TokenType {
	module                   = 0x00
	type_ref                 = 0x01
	type_def                 = 0x02
	field_def                = 0x04
	method_def               = 0x06
	param                    = 0x08
	interface_impl           = 0x09
	member_ref               = 0x0A
	constant                 = 0x0B
	custom_attribute         = 0x0C
	field_marshal            = 0x0D
	decl_security            = 0x0E
	class_layout             = 0x0F
	field_layout             = 0x10
	standalonesig            = 0x11
	event_map                = 0x12
	event                    = 0x14
	property_map             = 0x15
	property                 = 0x17
	method_semantics         = 0x18
	method_impl              = 0x19
	module_ref               = 0x1A
	type_spec                = 0x1B
	assembly                 = 0x20
	assembly_ref             = 0x23
	file                     = 0x26
	exported_type            = 0x27
	manifest_resource        = 0x28
	nested_class             = 0x29
	generic_param            = 0x2A
	method_spec              = 0x2B
	generic_param_constraint = 0x2C
}

// Well-known Windows Runtime type and attribute GUIDs
const iid_activatable = GUID{
	data1: 0x00000035
	data2: 0x0000
	data3: 0x0000
	data4: [u8(0xC0), u8(0x00), u8(0x00), u8(0x00), u8(0x00), u8(0x00), u8(0x00), u8(0x46)]!
}
const iid_composable = GUID{
	data1: 0x00000037
	data2: 0x0000
	data3: 0x0000
	data4: [u8(0xC0), u8(0x00), u8(0x00), u8(0x00), u8(0x00), u8(0x00), u8(0x00), u8(0x46)]!
}
const iid_static = GUID{
	data1: 0x00000038
	data2: 0x0000
	data3: 0x0000
	data4: [u8(0xC0), u8(0x00), u8(0x00), u8(0x00), u8(0x00), u8(0x00), u8(0x00), u8(0x46)]!
}
const iid_default_interface = GUID{
	data1: 0x00000039
	data2: 0x0000
	data3: 0x0000
	data4: [u8(0xC0), u8(0x00), u8(0x00), u8(0x00), u8(0x00), u8(0x00), u8(0x00), u8(0x46)]!
}

// Token info returned by decode_token
pub struct TokenInfo {
pub:
	token_type TokenType
	index      u32
}

// Method flags
@[flag]
pub enum WinRTMethodFlags {
	static_
	public_
	private_
	protected_
	virtual_
	abstract_
	sealed
	runtime_special_name
}

// Windows Runtime type flags
@[flag]
pub enum RuntimeTypeFlags {
	class_
	// 0x00000000
	unused1
	// 0x00000001
	unused2
	// 0x00000002
	unused3
	// 0x00000004
	unused4
	// 0x00000008
	unused5
	// 0x00000010
	interface_
	// 0x00000020
	unused6
	// 0x00000040
	abstract_
	// 0x00000080
	sealed
	// 0x00000100
	unused7
	// 0x00000200
	unused8
	// 0x00000400
	unused9
	// 0x00000800
	unused10
	// 0x00001000
	unused11
	// 0x00002000
	windows_runtime
	// 0x00004000
	unused12
	// 0x00008000
	activatable
	// 0x00010000
	composable
	// 0x00020000
	delegate
	// 0x00040000
	static_
	// 0x00080000
	marshal_by_ref
	// 0x00100000
	unsealed
	// 0x00200000
}

// Read a custom attribute entry
fn (mut r WinMDReader) read_custom_attribute_entry(row_idx u32) !CustomAttributeRowRaw {
	return CustomAttributeRowRaw{
		parent:    r.read_coded_index(.has_custom_attribute)!
		type_:     r.read_coded_index(.custom_attribute_type)!
		value_idx: r.read_blob_index()!
		row_id:    row_idx
	}
}

fn (mut r WinMDReader) has_constant(field_rid u32) !bool {
	// Search constant table for matching parent
	if const_count := r.row_counts.counts[.constant] {
		for i := u32(0); i < const_count; i++ {
			r.seek_to_constant_row(i + 1)!
			parent := r.read_coded_index(.has_constant)!

			if decode_token(parent).index == field_rid {
				return true
			}
		}
	}
	return false
}

// Get all metadata tables
fn (mut r WinMDReader) get_tables() !&MetadataTableInfo {
	if isnil(r.tables) {
		return error('Tables not initialized')
	}
	unsafe {
		return r.tables
	}
}

// Get COM method slots for a type
pub fn (mut r WinMDReader) get_method_slots(type_def_idx u32) ![]u32 {
	mut slots := []u32{}

	// Use resolved TypeDef
	type_def := r.read_typedef_entry(type_def_idx)!

	// Add IUnknown methods
	slots << 0 // QueryInterface
	slots << 1 // AddRef
	slots << 2 // Release

	// Add type methods using resolved MethodDef entries
	mut method_idx := type_def.method_list

	for method_idx < r.row_counts.counts[.method_def] {
		method := r.read_methoddef_entry(method_idx)!
		slots << method_idx
		method_idx += 1
	}

	return slots
}

fn (mut r WinMDReader) get_method_slot(row_id u32) !u32 {
	// Search through method table
	if method_count := r.row_counts.counts[.method_def] {
		for i := u32(0); i < method_count; i++ {
			method := r.read_methoddef_entry(i + 1)!
			if method.row_id == row_id {
				return i + 1
			}
		}
	}
	return error('Method not found')
}

// Add method to read constants
fn (mut r WinMDReader) read_u8() !u8 {
	bytes := r.read_bytes(1)!
	return bytes[0]
}

// Add method to get method parameters
fn (mut r WinMDReader) get_method_params(method_rid u32) ![]Param {
	mut params := []Param{}

	// Get param range
	if param_count := r.row_counts.counts[.param] {
		for i := u32(0); i < param_count; i++ {
			// Read param entry
			mut param := Param{
				flags:    r.read_u32()!
				sequence: u16(r.read_u16()!)
				name:     r.get_string(r.read_string_index()!)!
				row_id:   i + 1
			}

			params << param
		}
	}

	return params
}

// Helper to build full type name
fn get_full_type_name(namespace string, name string) string {
	if namespace == '' {
		return name
	}
	return '${namespace}.${name}'
}

// Find runtime class info for a type
pub fn (mut r WinMDReader) get_runtime_class(type_def_idx u32) !RuntimeClassInfo {
    mut info := RuntimeClassInfo{
        type_def_index: type_def_idx
    }

    // Read type definition using new pattern
    typedef := r.read_typedef_entry(type_def_idx)!

    info.name = typedef.name // Already resolved
    info.namespace = typedef.namespace // Already resolved
    if (typedef.flags & windows_runtime_type) == 0 {
        return error('Not a Windows Runtime type')
    }

    // Set basic flags
    mut flags := RuntimeTypeFlags.windows_runtime
    if (typedef.flags & interface_flag) != 0 {
        flags.set(.interface_)
    }
    if (typedef.flags & sealed_flag) == 0 {
        flags.set(.unsealed)
    }
    info.flags = flags

    // Read attributes in raw form
    if custom_attr_count := r.row_counts.counts[.custom_attribute] {
        for i := u32(0); i < custom_attr_count; i++ {
            raw_attr := r.read_custom_attribute_entry(i)!
            token_info := decode_token(raw_attr.parent)
            
            if token_info.index == type_def_idx && token_info.token_type == .type_def {
                attr_type := decode_token(raw_attr.type_)

                match attr_type.token_type {
                    .type_ref {
                        type_ref := r.read_typeref_entry(attr_type.index)!

                        if guid := r.get_type_guid(attr_type.index) {
                            match guid {
                                iid_activatable {
                                    factory := r.resolve_factory(raw_attr)!
                                    info.factories << factory
                                    info.flags.set(.activatable)
                                }
                                iid_composable {
                                    factory := r.resolve_factory(raw_attr)!
                                    info.composable << factory
                                    info.flags.set(.composable)
                                }
                                iid_static {
                                    factory := r.resolve_factory(raw_attr)!
                                    info.statics << factory
                                    info.flags.set(.static_)
                                }
                                iid_default_interface {
                                    iface := r.parse_default_interface(raw_attr)!
                                    info.default_iface = iface
                                }
                                else {}
                            }
                        }
                    }
                    else {}
                }
            }
        }
    }

    return info
}
// Parse factory attribute
fn (mut r WinMDReader) resolve_factory(attr CustomAttributeRowRaw) !FactoryInfo {
	mut factory := FactoryInfo{
		interface_name: ''
		methods:        []MethodDef{}
	}

	// Get factory type from custom attribute
	attr_type := decode_token(attr.type_)
	if attr_type.token_type != .type_ref {
		return error('Factory attribute must reference a type')
	}

	// Resolve the type reference
	type_ref := r.resolve_typedefref(attr_type.index)!
	factory.interface_name = '${type_ref.namespace}.${type_ref.name}'

	// Get factory interface GUID
	factory.guid = r.get_type_guid(attr_type.index)!

	// Get interface methods
	factory.methods = r.collect_interface_methods(attr_type.index)! // Changed from get_ to collect_
	return factory
}

// Parse default interface attribute
fn (mut r WinMDReader) parse_default_interface(attr CustomAttributeRowRaw) !string {
	values := r.parse_custom_attribute(attr.value_idx)!
	if values.constructor_args.len == 0 {
		return error('Invalid default interface attribute')
	}

	arg0 := values.constructor_args[0]
	if arg0.type_ != ElementType.class {
		return error('Expected type reference')
	}

	// Get interface type using resolved TypeRef
	type_ref := r.read_typeref_entry(arg0.value.u32())!
	return '${type_ref.namespace}.${type_ref.name}'
}

// Get methods for an interface type
fn (mut r WinMDReader) collect_interface_methods(type_idx u32) ![]MethodDef {
	mut methods := []MethodDef{}

	// Get type definition using resolved type
	typedef := r.read_typedef_entry(type_idx)!
	mut method_idx := typedef.method_list

	// Read all methods using resolved MethodDef
	for method_idx < r.row_counts.counts[.method_def] {
		method := r.read_methoddef_entry(method_idx)!

		// Convert to MethodDef
		method_info := MethodDef{
			name:        method.name
			// Already resolved
			signature:   method.signature
			flags:       unsafe { MethodFlags(method.flags) }
			parent_type: '${typedef.namespace}.${typedef.name}'
			is_public:   (u16(method.flags) & 0x0006) == 0x0006
			is_static:   (u16(method.flags) & 0x0010) != 0
			is_virtual:  (u16(method.flags) & 0x0040) != 0
			is_abstract: (u16(method.flags) & 0x0400) != 0
		}

		methods << method_info
		method_idx += 1
	}

	return methods
}

// Get GUID for a type
fn (mut r WinMDReader) get_type_guid(type_idx u32) !GUID {
    // Search CustomAttribute table in raw form
    if custom_attr_count := r.row_counts.counts[.custom_attribute] {
        for i := u32(0); i < custom_attr_count; i++ {
            raw_attr := r.read_custom_attribute_entry(i)!
            token_info := decode_token(raw_attr.parent)
            if token_info.index == type_idx && token_info.token_type == .type_def {
                if is_guid_attribute(raw_attr, mut r)! {
                    return r.parse_guid_attribute(raw_attr)!
                }
            }
        }
    }
    
    return error('No GUID found for type')
}

// Check if attribute is a GUID attribute
fn is_guid_attribute(attr CustomAttributeRowRaw, mut reader &WinMDReader) !bool {
	type_token := decode_token(attr.type_)
	if type_token.token_type != .type_ref {
		return false
	}

	if guid := reader.get_type_guid(type_token.index) {
		return guid == iid_activatable || guid == iid_composable || guid == iid_static
	}
	return false
}

// Parse GUID from attribute
fn (mut r WinMDReader) parse_guid_attribute(attr CustomAttributeRowRaw) !GUID {
	// Get raw blob data before it's parsed into CustomAttributeValue
	blob := r.get_blob(attr.value_idx)!
	if blob.len < 4 {
		return error('Invalid GUID attribute blob size')
	}

	// Skip prolog
	if unsafe { blob[0] != 0x01 || blob[1] != 0x00 } {
		return error('Invalid attribute prolog')
	}

	mut pos := 2

	// Read string argument length
	arg_len := read_compressed_uint(blob, mut &pos)!
	if arg_len == 0 || pos + int(arg_len) > blob.len {
		return error('Invalid GUID string length')
	}

	// Extract GUID string
	guid_str := unsafe { blob[pos..pos + int(arg_len)].bytestr() }
	return new_guid(guid_str)
}

// Helper to build full type name
fn get_full_type_name(namespace string, name string) string {
	if namespace == '' {
		return name
	}
	return '${namespace}.${name}'
}

fn (mut r WinMDReader) parse_custom_attribute(blob_idx u32) !CustomAttributeValue {
	blob := r.get_blob(blob_idx)!
	if blob.len < 4 {
		return error('Invalid custom attribute blob size')
	}

	unsafe {
		// Verify prolog
		if blob[0] != 0x01 || blob[1] != 0x00 {
			return error('Invalid custom attribute prolog')
		}

		mut pos := 2
		mut result := CustomAttributeValue{
			constructor_args: []string{}
			named_args:       map[string]string{}
		}

		// Read fixed arguments
		num_fixed_args := read_compressed_uint(blob, mut &pos)!
		for _ in 0 .. num_fixed_args {
			if pos >= blob.len {
				break
			}

			arg_value := r.read_attribute_argument(blob, mut &pos)!
			result.constructor_args << arg_value
		}

		// Read named arguments if we haven't reached the end
		if pos < blob.len {
			num_named_args := read_compressed_uint(blob, mut &pos)!
			for _ in 0 .. num_named_args {
				if pos + 2 > blob.len {
					break
				}

				// Read field/property marker
				_ = blob[pos] // Skip marker byte
				pos += 1

				// Read type
				element_type := ElementType(blob[pos])
				pos += 1

				// Read name
				name_len := read_compressed_uint(blob, mut &pos)!
				if pos + int(name_len) > blob.len {
					break
				}
				name := blob[pos..pos + int(name_len)].bytestr()
				pos += int(name_len)

				// Read value
				if value := r.read_attribute_argument(blob, mut &pos) {
					result.named_args[name] = value
				}
			}
		}

		return result
	}
}

fn (mut r WinMDReader) read_attribute_argument(blob []u8, mut pos &int) !string {
	unsafe {
		if *pos >= blob.len {
			return error('Invalid attribute argument position')
		}

		element_type := ElementType(blob[*pos])
		*pos += 1

		match element_type {
			.string {
				// Handle null strings
				if blob[*pos] == 0xFF {
					*pos += 1
					return 'null'
				}
				len := read_compressed_uint(blob, mut pos)!
				if *pos + int(len) > blob.len {
					return error('Invalid string length')
				}
				value := blob[*pos..*pos + int(len)].bytestr()
				*pos += int(len)
				return value
			}
			.class {
				token := read_compressed_uint(blob, mut pos)!
				if token == 0 {
					return 'null'
				}
				type_ref := r.resolve_typedefref(token)!
				return '${type_ref.namespace}.${type_ref.name}'
			}
			.boolean {
				value := blob[*pos]
				*pos += 1
				return if value == 0 { 'false' } else { 'true' }
			}
			.i4 {
				if *pos + 4 > blob.len {
					return error('Invalid I4 argument')
				}
				value := i32(blob[*pos]) | (i32(blob[*pos + 1]) << 8) | (i32(blob[*pos + 2]) << 16) | (i32(blob[
					*pos + 3]) << 24)
				*pos += 4
				return value.str()
			}
			else {
				return error('Unsupported attribute argument type: ${element_type}')
			}
		}
	}
}

// Add support for reading coded tokens
fn (mut r WinMDReader) read_coded_token(index_type CodedIndexType) !u32 {
	size := get_coded_index_size(index_type, &r.row_counts)!
	if size == 2 {
		return u32(r.read_u16()!)
	}
	return r.read_u32()!
}
