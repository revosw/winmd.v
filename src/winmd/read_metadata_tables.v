module winmd

import arrays

const property_map_row_size = 8
// 2 * u32 (Parent + PropertyList)
const property_row_size = 6
// Flags(u16) + Name(idx) + Type(blob)
const field_row_size = 8
// Flags(u32) + Name(idx) + Signature(blob)
const constant_row_size = 8
// Type(u8) + Padding(u8) + Parent(idx) + Value(blob)
const methodsemantic_row_size = 6
// Semantics(u16) + Method(u32)

// Add missing MetadataTableInfo structure
pub struct MetadataTableInfo {
pub mut:
	module                   &TableInfo
	type_ref                 &TableInfo
	type_def                 &TableInfo
	field_def                &TableInfo
	method_def               &TableInfo
	param                    &TableInfo
	interface_impl           &TableInfo
	member_ref               &TableInfo
	constant                 &TableInfo
	custom_attribute         &TableInfo
	field_marshal            &TableInfo
	decl_security            &TableInfo
	class_layout             &TableInfo
	field_layout             &TableInfo
	standalonesig            &TableInfo
	event_map                &TableInfo
	event                    &TableInfo
	property_map             &TableInfo
	property                 &TableInfo
	method_semantics         &TableInfo
	method_impl              &TableInfo
	module_ref               &TableInfo
	type_spec                &TableInfo
	assembly                 &TableInfo
	assembly_ref             &TableInfo
	file                     &TableInfo
	exported_type            &TableInfo
	manifest_resource        &TableInfo
	nested_class             &TableInfo
	generic_param            &TableInfo
	method_spec              &TableInfo
	generic_param_constraint &TableInfo
}

// Table info structure
pub struct TableInfo {
pub mut:
	row_count u32
	data      []u8
}

// Metadata Tables Header
struct TablesHeader {
mut:
	reserved1     u32
	major_version u8
	minor_version u8
	heap_sizes    u8
	reserved2     u8
	valid_tables  u64
	sorted_tables u64
	table_rows    []u32
}

// Table Row Counts indexed by TokenType
pub struct TableRowCounts {
mut:
	counts map[TokenType]u32
}

// Common coded index types
pub enum CodedIndexType {
	type_def_or_ref
	has_constant
	has_custom_attribute
	has_field_marshal
	has_decl_security
	member_ref_parent
	has_semantics
	method_def_or_ref
	member_forwarded
	implementation
	custom_attribute_type
	resolution_scope
	type_or_method_def
}

// Signature decoder for blob content
pub struct SignatureDecoder {
pub mut:
	data   []u8
	pos    int
	reader &WinMDReader
}

pub fn new_sig_decoder(data []u8, reader &WinMDReader) &SignatureDecoder {
	unsafe {
		return &SignatureDecoder{
			data:   data.clone()
			pos:    0
			reader: reader
		}
	}
}

// Read a type signature from blob
fn (mut d SignatureDecoder) read_type_sig() !TypeSig {
	// Check for valid position
	if d.pos >= d.data.len {
		return error('Invalid signature: unexpected end of data')
	}

	// Read element type
	mut sig := TypeSig{}
	sig.element_type = unsafe { ElementType(d.data[d.pos]) }
	d.pos++

	match sig.element_type {
		.class, .valuetype {
			// Read type reference token
			coded_index := d.read_compressed_uint()!
			type_ref := d.reader.resolve_typedefref(coded_index)!
			sig.namespace = type_ref.namespace
			sig.class_name = type_ref.name
		}
		.byref {
			sig.is_by_ref = true

			// Read inner type
			inner := d.read_type_sig()!
			sig.namespace = inner.namespace
			sig.class_name = inner.class_name
			sig.element_type = inner.element_type
		}
		.szarray {
			sig.array_rank = 1

			// Read element type
			inner := d.read_type_sig()!
			sig.namespace = inner.namespace
			sig.class_name = inner.class_name
			sig.element_type = inner.element_type
		}
		.array {
			// Read rank
			rank := d.read_compressed_uint()!
			sig.array_rank = int(rank)

			// Read element type
			inner := d.read_type_sig()!
			sig.namespace = inner.namespace
			sig.class_name = inner.class_name
			sig.element_type = inner.element_type

			// Read sizes if present
			if d.pos < d.data.len {
				num_sizes := d.read_compressed_uint()!
				for _ in 0 .. num_sizes {
					_ = d.read_compressed_uint()! // Size
				}

				num_bounds := d.read_compressed_uint()!
				for _ in 0 .. num_bounds {
					_ = d.read_compressed_uint()! // Bound
				}
			}
		}
		.generic_inst {
			base := d.read_type_sig()!
			sig.namespace = base.namespace
			sig.class_name = base.class_name

			// Read number of generic arguments
			num_args := d.read_compressed_uint()!
			for _ in 0 .. num_args {
				arg := d.read_type_sig()!
				sig.generic_args << arg
			}
		}
		.var, .mvar {
			// Generic parameter
			number := d.read_compressed_uint()!
			sig.class_name = 'T${number}' // Use Tx for generic params
		}
		.ptr {
			// Read pointed-to type
			inner := d.read_type_sig()!
			sig.namespace = inner.namespace
			sig.class_name = inner.class_name
			sig.element_type = inner.element_type
		}
		.fnptr {
			// Skip function pointer signature
			calling_conv := d.data[d.pos]
			d.pos++

			if (calling_conv & 0x10) != 0 {
				_ = d.read_compressed_uint()! // Generic param count
			}

			param_count := d.read_compressed_uint()!
			_ = d.read_type_sig()! // Return type
			for _ in 0 .. param_count {
				_ = d.read_type_sig()! // Parameter type
			}

			sig.class_name = 'FnPtr'
		}
		else {}
	}

	return sig
}

pub fn (mut d SignatureDecoder) read_method_sig() !MethodSig {
	mut sig := MethodSig{}

	// Read calling convention
	if d.pos >= d.data.len {
		return error('Invalid method signature: no data')
	}

	sig.calling_conv = d.data[d.pos]
	d.pos++

	// Handle generic methods
	if (sig.calling_conv & 0x10) != 0 {
		sig.generic_count = d.read_compressed_uint()!
	}

	// Read parameter count
	sig.param_count = d.read_compressed_uint()!

	// Read return type
	sig.ret_type = d.read_type_sig()!

	// Read parameters
	for _ in 0 .. sig.param_count {
		// Handle param modifiers (optional, byref etc)
		mut has_custom_mod := true
		for has_custom_mod {
			if d.pos >= d.data.len {
				break
			}

			match unsafe { ElementType(d.peek_byte()!) } {
				.cmod_opt, .cmod_reqd {
					// Skip custom modifier
					d.pos++
					_ = d.read_compressed_uint()!
				}
				else {
					has_custom_mod = false
				}
			}
		}
		sig.params << d.read_type_sig()!
	}

	return sig
}

pub fn (mut d SignatureDecoder) read_property_sig() !PropertySig {
	mut sig := PropertySig{}

	if d.pos >= d.data.len {
		return error('Invalid property signature: no data')
	}

	// Read calling convention
	sig.has_this = (d.data[d.pos] & 0x20) != 0
	d.pos++

	// Read parameter count
	sig.param_count = d.read_compressed_uint()!

	// Read return type
	sig.ret_type = d.read_type_sig()!

	// Read parameters
	for _ in 0 .. sig.param_count {
		sig.params << d.read_type_sig()!
	}

	return sig
}

pub fn (mut d SignatureDecoder) read_field_sig() !TypeSig {
	if d.pos >= d.data.len {
		return error('Invalid field signature: no data')
	}

	// Skip field calling convention (always 0x06)
	if d.data[d.pos] != 0x06 {
		return error('Invalid field signature calling convention')
	}
	d.pos++

	// Read field type
	return d.read_type_sig()
}

fn (mut d SignatureDecoder) skip_custom_modifiers() ! {
	for d.pos < d.data.len {
		match unsafe { ElementType(d.peek_byte()!) } {
			.cmod_opt, .cmod_reqd {
				d.pos++
				_ = d.read_compressed_uint()!
			}
			else {
				break
			}
		}
	}
}

pub fn (mut d SignatureDecoder) read_locals_sig() ![]TypeSig {
	mut locals := []TypeSig{}

	if d.pos >= d.data.len {
		return error('Invalid locals signature: no data')
	}

	// Skip calling convention (always 0x07)
	if d.data[d.pos] != 0x07 {
		return error('Invalid locals signature calling convention')
	}
	d.pos++

	// Read count
	count := d.read_compressed_uint()!

	// Read local variable types
	for _ in 0 .. count {
		d.skip_custom_modifiers()!
		locals << d.read_type_sig()!
	}

	return locals
}

pub fn (mut d SignatureDecoder) read_generic_inst_sig() !TypeSig {
	mut sig := TypeSig{}

	if d.pos >= d.data.len {
		return error('Invalid generic instantiation signature: no data')
	}

	// Read element type
	sig.element_type = ElementType.generic_inst

	// Read type kind (class/valuetype)
	kind := d.data[d.pos]
	d.pos++

	if kind != u8(ElementType.class) && kind != u8(ElementType.valuetype) {
		return error('Invalid generic instantiation kind')
	}

	// Read generic type definition
	type_token := d.read_compressed_uint()!
	base_type := d.reader.resolve_typedefref(type_token)!
	sig.namespace = base_type.namespace
	sig.class_name = base_type.name

	// Read number of generic arguments
	arg_count := d.read_compressed_uint()!

	// Read generic arguments
	for _ in 0 .. arg_count {
		sig.generic_args << d.read_type_sig()!
	}

	return sig
}

pub fn (mut r WinMDReader) resolve_method_signature(blob_idx u32) !MethodSig {
	blob := r.get_blob(blob_idx)!
	mut decoder := new_sig_decoder(blob, r)
	return decoder.read_method_sig()!
}

pub fn (mut r WinMDReader) resolve_property_signature(blob_idx u32) !PropertySig {
	blob := r.get_blob(blob_idx)!
	mut decoder := new_sig_decoder(blob, r)
	return decoder.read_property_sig()!
}

pub fn (mut r WinMDReader) resolve_field_signature(blob_idx u32) !TypeSig {
	blob := r.get_blob(blob_idx)!
	mut decoder := new_sig_decoder(blob, r)
	return decoder.read_field_sig()!
}

pub fn (mut r WinMDReader) resolve_locals_signature(blob_idx u32) ![]TypeSig {
	blob := r.get_blob(blob_idx)!
	mut decoder := new_sig_decoder(blob, r)
	return decoder.read_locals_sig()!
}

// Heap Sizes flags
const heap_string_big = u8(0x01)
const heap_guid_big = u8(0x02)
const heap_blob_big = u8(0x04)

// Get number of bits needed for coded index
fn get_coded_index_size(index_type CodedIndexType, row_counts &TableRowCounts) !int {
	mut max_rows := u32(0)

	match index_type {
		.type_def_or_ref {
			// TypeDef, TypeRef, TypeSpec
			// TODO: refactor to
			max_rows = arrays.max([
				u32(row_counts.counts[.type_def]),
				row_counts.counts[.type_ref],
				row_counts.counts[.type_spec],
			])!
			return if max_rows < (1 << 14) { 2 } else { 4 }
		}
		.has_constant {
			// Field, Param, Property
			max_rows = arrays.max([
				u32(row_counts.counts[.field_def]),
				row_counts.counts[.param],
				row_counts.counts[.property],
			])!
			return if max_rows < (1 << 14) { 2 } else { 4 }
		}
		.member_ref_parent {
			// TypeDef, TypeRef, ModuleRef, MethodDef, TypeSpec
			max_rows = arrays.max([
				u32(row_counts.counts[.type_def]),
				row_counts.counts[.type_ref],
				row_counts.counts[.module_ref],
				row_counts.counts[.method_def],
				row_counts.counts[.type_spec],
			])!
			return if max_rows < (1 << 11) { 2 } else { 4 }
		}
		// ... add other coded index types as needed
		else {
			return 4
		} // Default to 4 bytes for safety
	}
}

// Read tables header and initialize row counts
pub fn (mut r WinMDReader) read_tables_header() !bool {
	// Find #~ stream
	tables_stream := r.get_stream_header('#~') or { return error('Could not find #~ stream') }

	// Calculate absolute offset
	metadata_offset := r.rva_to_offset(r.cli_header.metadata_directory.virtual_address)!
	tables_abs_offset := metadata_offset + tables_stream.offset

	// Seek to tables stream
	r.file.seek(i64(tables_abs_offset), .start) or {
		return error('Failed to seek to tables header')
	}

	// Read header fields
	r.tables_header.reserved1 = r.read_u32()!
	r.tables_header.major_version = r.read_bytes(1)![0]
	r.tables_header.minor_version = r.read_bytes(1)![0]
	r.tables_header.heap_sizes = r.read_bytes(1)![0]
	r.tables_header.reserved2 = r.read_bytes(1)![0]

	// Set heap size flags
	r.string_heap_big = (r.tables_header.heap_sizes & heap_string_big) != 0
	r.guid_heap_big = (r.tables_header.heap_sizes & heap_guid_big) != 0
	r.blob_heap_big = (r.tables_header.heap_sizes & heap_blob_big) != 0

	// Read valid and sorted tables masks
	r.tables_header.valid_tables = r.read_u64()!
	r.tables_header.sorted_tables = r.read_u64()!

	// Read row counts for present tables
	for i := 0; i < 64; i++ {
		if (r.tables_header.valid_tables & (u64(1) << i)) != 0 {
			rows := r.read_u32()!
			token_type := unsafe { TokenType(i) }
			r.row_counts.counts[token_type] = rows
		}
	}

	return true
}

// Helper method to read string heap index
fn (mut r WinMDReader) read_string_index() !u32 {
	if r.string_heap_big {
		return r.read_u32()!
	}
	return u32(r.read_u16()!)
}

// Helper method to read guid heap index
fn (mut r WinMDReader) read_guid_index() !u32 {
	if r.guid_heap_big {
		return r.read_u32()!
	}
	return u32(r.read_u16()!)
}

// Helper method to read blob heap index
fn (mut r WinMDReader) read_blob_index() !u32 {
	if r.blob_heap_big {
		return r.read_u32()!
	}
	return u32(r.read_u16()!)
}

// Helper method to read coded index
fn (mut r WinMDReader) read_coded_index(index_type CodedIndexType) !u32 {
	match index_type {
		.type_def_or_ref {
			// TypeDef = 0, TypeRef = 1, TypeSpec = 2
			raw := if r.get_index_size(index_type)! > 2 {
				r.read_u32()!
			} else {
				u32(r.read_u16()!)
			}
			table := raw & 0x03 // 2 bits for table
			idx := raw >> 2 // Remaining bits for row
			if idx == 0 {
				return 0 // Null reference
			}

			match table {
				0 { return encode_token(.type_def, idx) }
				1 { return encode_token(.type_ref, idx) }
				2 { return encode_token(.type_spec, idx) }
				else { return error('Invalid TypeDefOrRef table: ${table}') }
			}
		}
		.has_constant {
			// Field = 0, Param = 1, Property = 2
			raw := if r.get_index_size(index_type)! > 2 {
				r.read_u32()!
			} else {
				u32(r.read_u16()!)
			}
			table := raw & 0x03
			idx := raw >> 2

			if idx == 0 {
				return 0
			}

			match table {
				0 { return encode_token(.field_def, idx) }
				1 { return encode_token(.param, idx) }
				2 { return encode_token(.property, idx) }
				else { return error('Invalid HasConstant table: ${table}') }
			}
		}
		.has_custom_attribute {
			// 5 bits for tables
			raw := if r.get_index_size(index_type)! > 2 {
				r.read_u32()!
			} else {
				u32(r.read_u16()!)
			}
			table := raw & 0x1F
			idx := raw >> 5

			if idx == 0 {
				return 0
			}

			return encode_token(unsafe { TokenType(table) }, idx)
		}
		.has_field_marshal {
			// Field = 0, Param = 1
			raw := if r.get_index_size(index_type)! > 2 {
				r.read_u32()!
			} else {
				u32(r.read_u16()!)
			}
			table := raw & 0x01
			idx := raw >> 1

			if idx == 0 {
				return 0
			}

			match table {
				0 { return encode_token(.field_def, idx) }
				1 { return encode_token(.param, idx) }
				else { return error('Invalid HasFieldMarshal table: ${table}') }
			}
		}
		.has_semantics {
			// Event = 0, Property = 1
			raw := if r.get_index_size(index_type)! > 2 {
				r.read_u32()!
			} else {
				u32(r.read_u16()!)
			}
			table := raw & 0x01
			idx := raw >> 1

			if idx == 0 {
				return 0
			}

			match table {
				0 { return encode_token(.event, idx) }
				1 { return encode_token(.property, idx) }
				else { return error('Invalid HasSemantics table: ${table}') }
			}
		}
		.member_ref_parent {
			// TypeDef = 0, TypeRef = 1, ModuleRef = 2, MethodDef = 3, TypeSpec = 4
			raw := if r.get_index_size(index_type)! > 2 {
				r.read_u32()!
			} else {
				u32(r.read_u16()!)
			}
			table := raw & 0x07 // 3 bits
			idx := raw >> 3

			if idx == 0 {
				return 0
			}

			match table {
				0 { return encode_token(.type_def, idx) }
				1 { return encode_token(.type_ref, idx) }
				2 { return encode_token(.module_ref, idx) }
				3 { return encode_token(.method_def, idx) }
				4 { return encode_token(.type_spec, idx) }
				else { return error('Invalid MemberRefParent table: ${table}') }
			}
		}
		.resolution_scope {
			// Module = 0, ModuleRef = 1, AssemblyRef = 2, TypeRef = 3
			raw := if r.get_index_size(index_type)! > 2 {
				r.read_u32()!
			} else {
				u32(r.read_u16()!)
			}
			table := raw & 0x03
			idx := raw >> 2

			if idx == 0 {
				return 0
			}

			match table {
				0 { return encode_token(.module, idx) }
				1 { return encode_token(.module_ref, idx) }
				2 { return encode_token(.assembly_ref, idx) }
				3 { return encode_token(.type_ref, idx) }
				else { return error('Invalid ResolutionScope table: ${table}') }
			}
		}
		else {
			return error('Unknown coded index type')
		}
	}
}

fn (r &WinMDReader) get_index_size(index_type CodedIndexType) !int {
	match index_type {
		.type_def_or_ref {
			max_rows := arrays.max([
				r.row_counts.counts[.type_def],
				r.row_counts.counts[.type_ref],
				r.row_counts.counts[.type_spec],
			])!
			return if (max_rows >> 14) > 0 { 4 } else { 2 }
		}
		.has_constant {
			max_rows := arrays.max([
				r.row_counts.counts[.field_def],
				r.row_counts.counts[.param],
				r.row_counts.counts[.property],
			])!
			return if (max_rows >> 14) > 0 { 4 } else { 2 }
		}
		.has_custom_attribute {
			mut max_rows := u32(0)

			// Check all possible tables that can have custom attributes
			for token_type in [
				TokenType.method_def,
				.field_def,
				.type_ref,
				.type_def,
				.param,
				.interface_impl,
				.member_ref,
				.module,
				.property,
				.event,
				.standalonesig,
				.module_ref,
				.type_spec,
				.assembly,
				.assembly_ref,
				.file,
				.exported_type,
				.manifest_resource,
				.generic_param,
				.generic_param_constraint,
				.method_spec,
			] {
				if count := r.row_counts.counts[token_type] {
					if count > max_rows {
						max_rows = count
					}
				}
			}
			return if (max_rows >> 11) > 0 { 4 } else { 2 }
		}
		.has_field_marshal {
			max_rows := arrays.max([
				r.row_counts.counts[.field_def],
				r.row_counts.counts[.param],
			])!
			return if (max_rows >> 15) > 0 { 4 } else { 2 }
		}
		.has_semantics {
			max_rows := arrays.max([
				r.row_counts.counts[.event],
				r.row_counts.counts[.property],
			])!
			return if (max_rows >> 15) > 0 { 4 } else { 2 }
		}
		.member_ref_parent {
			max_rows := arrays.max([
				r.row_counts.counts[.type_def],
				r.row_counts.counts[.type_ref],
				r.row_counts.counts[.module_ref],
				r.row_counts.counts[.method_def],
				r.row_counts.counts[.type_spec],
			])!
			return if (max_rows >> 13) > 0 { 4 } else { 2 }
		}
		.resolution_scope {
			max_rows := arrays.max([
				r.row_counts.counts[.module],
				r.row_counts.counts[.module_ref],
				r.row_counts.counts[.assembly_ref],
				r.row_counts.counts[.type_ref],
			])!
			return if (max_rows >> 14) > 0 { 4 } else { 2 }
		}
		else {
			return error('Unknown coded index type')
		}
	}
}

fn (r &WinMDReader) validate_row_index(token_type TokenType, row_idx u32) !bool {
	if row_idx == 0 {
		return false
	}

	if row_count := r.row_counts.counts[token_type] {
		if row_idx > row_count {
			return error('Row index ${row_idx} exceeds table size ${row_count} for table ${token_type}')
		}
		return true
	}

	return error('Table ${token_type} not present in metadata')
}

// Read MethodDef table
pub fn (mut r WinMDReader) read_methoddef_table() ![]MethodDef {
	mut rows := []MethodDef{}

	if methoddef_count := r.row_counts.counts[.method_def] {
		for i := u32(0); i < methoddef_count; i++ {
			rows << r.read_methoddef_entry(i + 1)!
		}
	}

	return rows
}

// Get methods for a type
fn (mut r WinMDReader) collect_type_methods(type_name string, type_namespace string) ![]MethodDef {
	mut methods := []MethodDef{}

	// Find the type definition first
	typedef := r.find_typedef(type_name, type_namespace)!

	// Get method range
	start_idx := typedef.method_list
	end_idx := if typedef.row_id >= r.row_counts.counts[.type_def] {
		r.row_counts.counts[.method_def]
	} else {
		next_typedef := r.read_typedef_entry(typedef.row_id + 1)!
		next_typedef.method_list
	}

	// Read and resolve all methods in range
	for method_idx := start_idx; method_idx < end_idx; method_idx++ {
		method := r.read_methoddef_entry(method_idx)!
		methods << method
	}

	return methods
}

// Find typedef by name
fn (mut r WinMDReader) find_typedef(type_name string, type_namespace string) !TypeDef {
	mut typedefs := r.read_typedef_table()!

	// Look for matching type
	for typedef in typedefs {
		name := typedef.name
		namespace := typedef.namespace

		if name == type_name && namespace == type_namespace {
			return typedef
		}
	}

	return error('Type not found: ${type_namespace}.${type_name}')
}

// Get table offset
fn (mut r WinMDReader) get_table_offset(token_type TokenType) !u64 {
	mut offset := u64(0)

	// Calculate offset from base of metadata
	metadata_offset := r.rva_to_offset(r.cli_header.metadata_directory.virtual_address)!

	// Find #~ stream
	tables_stream := r.get_stream_header('#~') or { return error('Could not find #~ stream') }

	// Add stream offset
	offset += u64(metadata_offset + tables_stream.offset)

	// Skip header
	offset += 24 // Size of tables header

	// Skip row counts
	valid_bits := r.tables_header.valid_tables
	for i := u32(0); i < u32(token_type); i++ {
		if (valid_bits & (u64(1) << i)) != 0 {
			current_id := unsafe { TokenType(i) }
			row_count := r.row_counts.counts[current_id]
			row_size := r.get_row_size(current_id)!
			offset += u64(row_count) * u64(row_size)
		}
	}

	return offset
}

// Calculate row size for a table
fn (r &WinMDReader) get_row_size(token_type TokenType) !int {
	// Base sizes for raw table rows
	size := match token_type {
		.module { 10 } // Generation(2) + Name(2) + Mvid(2) + EncId(2) + EncBaseId(2)
		.type_ref { 6 } // ResolutionScope(2) + Name(2) + Namespace(2)
		.type_def { 24 } // Flags(4) + Name(2) + Namespace(2) + Extends(4) + FieldList(4) + MethodList(4)
		.field_def { 8 } // Flags(4) + Name(2) + Signature(2)
		.method_def { 14 } // RVA(4) + ImplFlags(2) + Flags(2) + Name(2) + Signature(2) + ParamList(2)
		.param { 6 } // Flags(2) + Sequence(2) + Name(2)
		.interface_impl { 4 } // Class(2) + Interface(2)
		.member_ref { 6 } // Class(2) + Name(2) + Signature(2)
		.constant { 8 } // Type(1) + PaddingZero(1) + Parent(2) + Value(2)
		.custom_attribute { 6 } // Parent(2) + Type(2) + Value(2)
		.field_marshal { 4 } // Parent(2) + NativeType(2)
		.decl_security { 6 } // Action(2) + Parent(2) + PermissionSet(2)
		.class_layout { 8 } // PackingSize(2) + ClassSize(4) + Parent(2)
		.field_layout { 6 } // Offset(4) + Field(2)
		.standalonesig { 2 } // Signature(2)
		.event_map { 4 } // Parent(2) + EventList(2)
		.event { 8 } // Flags(2) + Name(2) + EventType(2)
		.property_map { 4 } // Parent(2) + PropertyList(2)
		.property { 6 } // Flags(2) + Name(2) + Type(2)
		.method_semantics { 6 } // Semantic(2) + Method(2) + Association(2)
		.method_impl { 6 } // Class(2) + MethodBody(2) + MethodDeclaration(2)
		else { return error('Unknown table ID: ${int(token_type)}') }
	}

	// Add extra size for wide indexes if needed
	mut extra := 0
	if r.string_heap_big {
		extra += match token_type {
			.type_def, .type_ref, .field_def, .method_def, .param, .property {
				2
			}
			else {
				0
			}
		}
	}
	if r.guid_heap_big {
		extra += match token_type {
			.module { 2 }
			else { 0 }
		}
	}
	if r.blob_heap_big {
		extra += match token_type {
			.field_def, .method_def, .member_ref, .constant, .custom_attribute, .property {
				2
			}
			else {
				0
			}
		}
	}

	return size + extra
}

// Add to WinMDReader
fn (mut r WinMDReader) find_property_map(type_rid u32) !u32 {
	if map_count := r.row_counts.counts[.property_map] {
		for i := u32(0); i < map_count; i++ {
			map_ := r.read_propertymap_entry(i + 1)!
			if map_.parent.row_id == type_rid {
				return i + 1
			}
		}
	}
	return 0
}

fn (mut r WinMDReader) get_property_range_start(map_rid u32) !u32 {
	r.seek_to_propertymap_row(map_rid)!
	_ = r.read_u32()! // Skip parent
	return r.read_u32()! // Property list
}

fn (mut r WinMDReader) get_property_range_end(map_rid u32) !u32 {
	if map_rid >= r.row_counts.counts[.property_map] {
		return r.row_counts.counts[.property]
	}
	r.seek_to_propertymap_row(map_rid + 1)!
	_ = r.read_u32()! // Skip parent
	return r.read_u32()! // Next property list
}

fn (mut r WinMDReader) seek_to_property_row(rid u32) ! {
	offset := r.get_table_offset(.property)! + (u64(rid - 1) * u64(property_row_size))
	r.file.seek(i64(offset), .start)!
}

fn (mut r WinMDReader) seek_to_propertymap_row(rid u32) ! {
	offset := r.get_table_offset(.property_map)! + (u64(rid - 1) * u64(property_map_row_size))
	r.file.seek(i64(offset), .start)!
}

fn (mut r WinMDReader) seek_to_field_row(rid u32) ! {
	offset := r.get_table_offset(.field_def)! + (u64(rid - 1) * u64(field_row_size))
	r.file.seek(i64(offset), .start)!
}

fn (mut r WinMDReader) seek_to_constant_row(rid u32) ! {
	offset := r.get_table_offset(.constant)! + (rid - 1) * constant_row_size
	r.file.seek(i64(offset), .start)!
}

fn (mut r WinMDReader) seek_to_methodsemantic_row(rid u32) ! {
	offset := r.get_table_offset(.method_semantics)! + (rid - 1) * methodsemantic_row_size
	r.file.seek(i64(offset), .start)!
}

fn (mut r WinMDReader) get_field_constant(field_rid u32) !string {
	// Search constant table for matching parent
	if const_count := r.row_counts.counts[.constant] {
		for i := u32(0); i < const_count; i++ {
			r.seek_to_constant_row(i + 1)!
			parent := r.read_coded_index(.has_constant)!

			if unsafe { decode_token(parent).index == field_rid } {
				type_ := r.read_u8()!
				_ = r.read_u8()! // padding
				value_idx := r.read_blob_index()!
				blob := r.get_blob(value_idx)!
				return r.decode_constant_value(type_, blob)!
			}
		}
	}
	return error('Constant not found')
}

fn (mut r WinMDReader) decode_constant_value(type_id u8, blob []u8) !string {
	if blob.len == 0 {
		return error('Empty constant blob')
	}

	unsafe {
		match type_id {
			0x02 { // Boolean
				return if blob[0] == 0 { 'false' } else { 'true' }
			}
			0x04 { // I4
				if blob.len != 4 {
					return error('Invalid I4 blob size')
				}
				value := u32(blob[0]) | (u32(blob[1]) << 8) | (u32(blob[2]) << 16) | (u32(blob[3]) << 24)
				return i32(value).str()
			}
			0x08 { // String
				// Handle null strings
				if blob.len == 0 || (blob.len == 1 && blob[0] == 0xFF) {
					return ''
				}
				return blob.bytestr()
			}
			0x09 { // Class
				if blob.len != 4 {
					return error('Invalid class token size')
				}
				token := u32(blob[0]) | (u32(blob[1]) << 8) | (u32(blob[2]) << 16) | (u32(blob[3]) << 24)
				type_ref := r.resolve_typedefref(token)!
				return '${type_ref.namespace}.${type_ref.name}'
			}
			0x0A { // U4
				if blob.len != 4 {
					return error('Invalid U4 blob size')
				}
				value := u32(blob[0]) | (u32(blob[1]) << 8) | (u32(blob[2]) << 16) | (u32(blob[3]) << 24)
				return value.str()
			}
			else {
				return error('Unsupported constant type: 0x${type_id.hex()}')
			}
		}
	}
}

// Add method to get base type
fn (mut r WinMDReader) get_base_type(type_name string, type_namespace string) !TypeRef {
	// Find typedef
	typedef := r.find_typedef(type_name, type_namespace)!

	// Resolve base type reference
	if typedef.extends != 0 {
		return r.resolve_typedefref(typedef.extends)
	}

	return error('Type has no base type')
}

fn (mut r WinMDReader) resolve_factory_attribute(attr CustomAttributeRowRaw) !FactoryInfo {
	mut factory := FactoryInfo{
		interface_name: ''
		methods:        []MethodDef{}
	}

	// Get factory type from custom attribute
	attr_type := decode_token(attr.type_)
	if attr_type.token_type != .type_ref {
		return error('Factory attribute must reference a type')
	}

	type_ref := r.resolve_typedefref(attr_type.index)!
	factory.interface_name = '${type_ref.namespace}.${type_ref.name}'

	// Get factory interface GUID
	factory.guid = r.get_type_guid(attr_type.index)!

	// Get factory methods
	methods := r.collect_interface_methods(attr_type.index)!
	factory.methods = methods

	return factory
}

fn (mut r WinMDReader) resolve_type_ref(type_ref_idx u32) !string {
	type_ref := r.read_typeref_entry(type_ref_idx)!
	name := type_ref.name
	namespace := type_ref.namespace

	if namespace == '' {
		return name
	}
	return '${namespace}.${name}'
}
