module winmd

import os

// Previous code remains the same, adding new structures and methods:

// Heap locations and cache
struct Heap {
mut:
	offset u32
	size   u32
	data   []u8
}

// Signature types for blob parsing
pub enum ElementType {
	end          = 0x00
	void         = 0x01
	boolean      = 0x02
	char         = 0x03
	i1           = 0x04
	u1           = 0x05
	i2           = 0x06
	u2           = 0x07
	i4           = 0x08
	u4           = 0x09
	i8           = 0x0a
	u8           = 0x0b
	r4           = 0x0c
	r8           = 0x0d
	string       = 0x0e
	ptr          = 0x0f
	byref        = 0x10
	valuetype    = 0x11
	class        = 0x12
	var          = 0x13
	array        = 0x14
	generic_inst = 0x15
	typed_byref  = 0x16
	i            = 0x18
	u            = 0x19
	fnptr        = 0x1b
	object       = 0x1c
	szarray      = 0x1d
	mvar         = 0x1e
	cmod_reqd    = 0x1f
	cmod_opt     = 0x20
	internal     = 0x21
	modifier     = 0x40
	sentinel     = 0x41
	pinned       = 0x45
	type_end     = 0x50
}

// Cache for resolved types
struct TypeCache {
mut:
	typedefs map[u32]TypeDef
	typerefs map[u32]TypeRef
	methods  map[u32]MethodDef
	fields   map[u32]Field
	params   map[u32]Param
}

// Add to WinMDReader struct
@[heap]
pub struct WinMDReader {
pub mut:
	file            &os.File
	size            u64
	dos_header      DOSHeader
	pe_header       PEHeader
	opt_header      OptionalHeader64
	sections        []SectionHeader
	cli_header      CLIHeader
	metadata_header MetadataHeader
	stream_headers  []StreamHeader
	com_descriptor  ImageDataDirectory
	string_heap     Heap
	blob_heap       Heap
	guid_heap       Heap
	tables_header   TablesHeader
	row_counts      TableRowCounts
	string_heap_big bool
	guid_heap_big   bool
	blob_heap_big   bool
	tables          &MetadataTableInfo = unsafe { nil }
	type_cache      TypeCache
}

fn validate_raw_type_data(raw TypeDefRowRaw) ! {
	if raw.row_id == 0 {
		return error('Invalid row ID: 0')
	}
	if raw.name_idx == 0 {
		return error('Invalid name index: 0')
	}

	// Add more validation as needed
}

pub struct MethodSignatureFlags {
pub mut:
	has_this                   bool
	explicit_this              bool
	default_calling_convention bool
	vararg_calling_convention  bool
	generic                    bool
	param_count                u32
	ret_type                   ElementType
	params                     []ElementType
}

// Initialize heaps
fn (mut r WinMDReader) init_heaps() ! {
	// Initialize string heap
	if strings_stream := r.get_stream_header('#Strings') {
		metadata_offset := r.rva_to_offset(r.cli_header.metadata_directory.virtual_address)!
		r.string_heap.offset = metadata_offset + strings_stream.offset
		r.string_heap.size = strings_stream.size
	}

	// Initialize blob heap
	if blob_stream := r.get_stream_header('#Blob') {
		metadata_offset := r.rva_to_offset(r.cli_header.metadata_directory.virtual_address)!
		r.blob_heap.offset = metadata_offset + blob_stream.offset
		r.blob_heap.size = blob_stream.size
	}

	// Initialize GUID heap
	if guid_stream := r.get_stream_header('#GUID') {
		metadata_offset := r.rva_to_offset(r.cli_header.metadata_directory.virtual_address)!
		r.guid_heap.offset = metadata_offset + guid_stream.offset
		r.guid_heap.size = guid_stream.size
	}
}

// Read compressed unsigned integer from blob heap
fn (mut d SignatureDecoder) read_compressed_uint() !u32 {
	if d.pos >= d.data.len {
		return error('Invalid compressed integer position')
	}

	first := d.data[d.pos]
	d.pos += 1

	if first & 0x80 == 0 {
		return u32(first)
	}

	if first & 0x40 == 0 {
		if d.pos >= d.data.len {
			return error('Invalid compressed integer')
		}
		second := d.data[d.pos]
		d.pos += 1

		value := (u32(first & 0x3F) << 8) | u32(second)
		if value <= 0x7F {
			return error('Invalid compressed integer encoding')
		}
		return value
	}

	if d.pos + 3 > d.data.len {
		return error('Invalid compressed integer')
	}

	second := d.data[d.pos]
	third := d.data[d.pos + 1]
	fourth := d.data[d.pos + 2]
	d.pos += 3

	value := (u32(first & 0x3F) << 24) | (u32(second) << 16) | (u32(third) << 8) | u32(fourth)

	if value <= 0x3FFF {
		return error('Invalid compressed integer encoding')
	}

	return value
}

pub fn (mut d SignatureDecoder) read_u8() !u8 {
	if d.pos >= d.data.len {
		return error('End of data reached')
	}
	value := d.data[d.pos]
	d.pos++
	return value
}

fn (d &SignatureDecoder) remaining() int {
	return d.data.len - d.pos
}

fn (d &SignatureDecoder) peek_byte() !u8 {
	if d.pos >= d.data.len {
		return error('No more data to read')
	}
	return d.data[d.pos]
}

// Get string from string heap
pub fn (mut r WinMDReader) get_string(index u32) !string {
	if index == 0 {
		return ''
	}

	if index >= r.string_heap.size {
		return error('String index out of range')
	}

	// Seek to string position
	r.file.seek(i64(r.string_heap.offset + index), .start) or {
		return error('Failed to seek to string')
	}

	// Read until null terminator
	mut bytes := []u8{}
	for {
		b := r.read_bytes(1)!
		if b[0] == 0 {
			break
		}
		bytes << b[0]
	}

	return bytes.str()
}

// Get blob from blob heap
fn (mut r WinMDReader) get_blob(index u32) ![]u8 {
	if index == 0 {
		return []u8{}
	}

	if index >= r.blob_heap.size {
		return error('Blob index out of range')
	}

	// Seek to blob position
	r.file.seek(i64(r.blob_heap.offset + index), .start)!

	// Read compressed length
	mut pos := 0
	initial_bytes := r.read_bytes(4)!
	length := read_compressed_uint(initial_bytes, mut &pos)!

	// Read remaining initial bytes and blob content
	mut content := unsafe { initial_bytes[pos..] }
	if length > content.len {
		remaining := r.read_bytes(int(length - content.len))!
		content << remaining
	}

	return content
}

// Parse method signature flags
fn (mut r WinMDReader) parse_method_signature(blob_index u32) !MethodSignatureFlags {
	mut signature := MethodSignatureFlags{}

	// Get blob data
	blob := r.get_blob(blob_index)!
	if blob.len < 1 {
		return error('Invalid method signature blob')
	}

	mut pos := 0

	// Read flags byte
	flags := blob[pos]
	pos += 1

	// Parse flags
	signature.has_this = (flags & 0x20) != 0
	signature.explicit_this = (flags & 0x40) != 0
	signature.default_calling_convention = (flags & 0x0) != 0
	signature.vararg_calling_convention = (flags & 0x5) != 0
	signature.generic = (flags & 0x10) != 0

	// Read generic parameter count if generic
	if signature.generic {
		signature.param_count = read_compressed_uint(blob, mut &pos)!
	}

	// Read parameter count
	param_count := read_compressed_uint(blob, mut &pos)!

	// Read return type
	if pos < blob.len {
		signature.ret_type = unsafe { ElementType(blob[pos]) }
		pos += 1
	}

	// Read parameter types
	for _ in 0 .. param_count {
		if pos >= blob.len {
			break
		}
		signature.params << unsafe { ElementType(blob[pos]) }
		pos += 1
	}

	return signature
}

// Read TypeDef table
pub fn (mut r WinMDReader) read_typedef_table() ![]TypeDef {
	mut rows := []TypeDef{}

	if typedef_count := r.row_counts.counts[.type_def] {
		for i := u32(0); i < typedef_count; i++ {
			// Read and resolve in one step
			rows << r.read_typedef_entry(i + 1)!
		}
	}

	return rows
}

// Update WinMDReader method
fn (mut r WinMDReader) collect_property_methods(property_rid u32) ![]MethodSemantics {
	mut methods := []MethodSemantics{}

	// Search method semantics table for property methods
	if semantic_count := r.row_counts.counts[.method_semantics] {
		for i := u32(0); i < semantic_count; i++ {
			// Read raw semantic entry
			r.seek_to_methodsemantic_row(i + 1)!
			raw_semantic := MethodSemanticsRowRaw{
				semantic:    r.read_u16()!
				method:      r.read_u32()!
				association: r.read_coded_index(.has_semantics)!
				row_id:      i + 1
			}

			// Check if this semantic is for our property
			token_info := decode_token(raw_semantic.association)
			if token_info.index == property_rid {
				// Resolve the method
				method := r.read_methoddef_entry(raw_semantic.method)!

				// Create resolved MethodSemantics
				methods << MethodSemantics{
					semantic:    unsafe { MethodSemanticsFlag(raw_semantic.semantic) }
					method:      method
					association: raw_semantic.association // Keep original token
					row_id:      raw_semantic.row_id
				}
			}
		}
	}

	return methods
}

// Add helper to resolve type references
fn (mut r WinMDReader) resolve_typedefref(coded_index u32) !TypeRef {
	table_type := coded_index >> 2
	row_index := coded_index & 0x3

	match table_type {
		0 { // TypeDef
			type_def := r.read_typedef_entry(row_index)!
			return TypeRef{
				name:             type_def.name
				namespace:        type_def.namespace
				resolution_scope: 0
			}
		}
		1 { // TypeRef
			type_ref := r.read_typeref_entry(row_index)!
			return TypeRef{
				name:             type_ref.name
				namespace:        type_ref.namespace
				resolution_scope: type_ref.resolution_scope
			}
		}
		2 { // TypeSpec
			// Handle generic instantiations
			blob := r.get_blob(row_index)!
			mut decoder := new_sig_decoder(blob, r)
			sig := decoder.read_type_sig()!

			return TypeRef{
				name:             sig.class_name
				namespace:        sig.namespace
				resolution_scope: 0
			}
		}
		else {
			return error('Unsupported type reference kind: ${table_type}')
		}
	}
}

// Add method to get implemented interfaces
fn (mut r WinMDReader) get_implemented_interfaces(type_name string, type_namespace string) ![]TypeRef {
	mut interfaces := []TypeRef{}

	// Find typedef
	typedef := r.find_typedef(type_name, type_namespace)!

	// Search InterfaceImpl table
	if impl_count := r.row_counts.counts[.interface_impl] {
		for i := u32(0); i < impl_count; i++ {
			class := r.read_coded_index(.type_def_or_ref)!
			if class == typedef.row_id {
				iface := r.read_coded_index(.type_def_or_ref)!
				if iface_ref := r.resolve_typedefref(iface) {
					interfaces << iface_ref
				}
			}
		}
	}

	return interfaces
}
