module main

import os
import encoding.binary { little_endian_u16_at, little_endian_u32_at, little_endian_u64_at }
import strings
// import x.json2

// "BSJB" in little-endian ascii
const metadata_signature = u32(0x424A5342)

const out_root = '${os.home_dir()}/.vmodules'

fn init_mod_recursively(path string) ! {
	mut indices := []int{cap: path.count('/') + 2}

	if indices.cap == 2 {
		init_mod(path, path)!
		return
	}

	indices << 0
	for index, letter in path {
		if letter == u8(`/`) {
			indices << index + 1
		}
	}

	indices << path.len + 1

	for i in 1 .. indices.len {
		mod_path := path[..indices[i] - 1]
		mod_name := path[indices[i - 1]..indices[i] - 1]
		init_mod(mod_path, mod_name)!
	}
}

fn init_mod(path string, name string) ! {
	out_path := '${out_root}/${path}'
	os.mkdir_all(out_path)!

	if !os.exists('${out_path}/v.mod') {
		mut mod_file := os.create('${out_path}/v.mod')!
		// vfmt off
        mod_file.write_string(
            "Module{\n"
            + "\tname: '${name}'\n"
            + "\tdescription: 'Bindings for the Windows API'\n"
            + "\tversion: '0.0.1'\n"
            + "\tlicense: 'MIT'\n"
            + "\tdependencies: []\n"
            + "}"
        )!
		// vfmt on
		mod_file.close()
	}
}

// Decodes a constant value from the Constant table blob
// Returns (type_string, value_string) for emission
fn decode_constant_value(const_type u32, blob []u8) (string, string) {
	if blob.len == 0 {
		return '', ''
	}

	match const_type {
		0x02 { // ELEMENT_TYPE_BOOLEAN
			val := if blob[0] != 0 { 'true' } else { 'false' }
			return 'bool', val
		}
		0x03 { // ELEMENT_TYPE_CHAR
			if blob.len >= 2 {
				val := little_endian_u16_at(blob, 0)
				return 'u16', '${val}'
			}
		}
		0x04 { // ELEMENT_TYPE_I1
			return 'i8', '${i8(blob[0])}'
		}
		0x05 { // ELEMENT_TYPE_U1
			return 'u8', '${blob[0]}'
		}
		0x06 { // ELEMENT_TYPE_I2
			if blob.len >= 2 {
				val := i16(little_endian_u16_at(blob, 0))
				return 'i16', '${val}'
			}
		}
		0x07 { // ELEMENT_TYPE_U2
			if blob.len >= 2 {
				val := little_endian_u16_at(blob, 0)
				return 'u16', '${val}'
			}
		}
		0x08 { // ELEMENT_TYPE_I4
			if blob.len >= 4 {
				val := i32(little_endian_u32_at(blob, 0))
				return 'i32', '${val}'
			}
		}
		0x09 { // ELEMENT_TYPE_U4
			if blob.len >= 4 {
				val := little_endian_u32_at(blob, 0)
				return 'u32', '${val}'
			}
		}
		0x0A { // ELEMENT_TYPE_I8
			if blob.len >= 8 {
				val := i64(little_endian_u64_at(blob, 0))
				return 'i64', '${val}'
			}
		}
		0x0B { // ELEMENT_TYPE_U8
			if blob.len >= 8 {
				val := little_endian_u64_at(blob, 0)
				return 'u64', '${val}'
			}
		}
		0x0C { // ELEMENT_TYPE_R4 (float32)
			if blob.len >= 4 {
				// Reinterpret as f32
				bits := little_endian_u32_at(blob, 0)
				val := *(&f32(&bits))
				return 'f32', '${val}'
			}
		}
		0x0D { // ELEMENT_TYPE_R8 (float64)
			if blob.len >= 8 {
				// Reinterpret as f64
				bits := little_endian_u64_at(blob, 0)
				val := *(&f64(&bits))
				return 'f64', '${val}'
			}
		}
		0x0E { // ELEMENT_TYPE_STRING
			// String constant - decode as UTF-16LE
			if blob.len >= 2 {
				mut str_val := ''
				for i := 0; i < blob.len - 1; i += 2 {
					char_val := little_endian_u16_at(blob, i)
					if char_val == 0 {
						break
					}
					str_val += rune(char_val).str()
				}
				// Escape the string for V
				escaped := str_val.replace('\\', '\\\\').replace("'", "\\'")
				return 'string', "'${escaped}'"
			}
		}
		else {}
	}

	return '', ''
}

// Recursively inlines fields from nested types (unions/structs) into the output buffer
// emitted_fields tracks field names already written to avoid duplicates
fn inline_nested_fields(
	mut buffer strings.Builder,
	typedef_rid u32,
	type_def_table []TypeDef,
	field_table []Field,
	type_ref_table []TypeRef,
	nested_to_enclosing map[u32]u32,
	nested_name_to_typedef_rid map[string]u32,
	mut streams Streams,
	mut emitted_fields map[string]bool
) {
	if typedef_rid == 0 || typedef_rid > u32(type_def_table.len) {
		return
	}

	nested_type_def := type_def_table[typedef_rid - 1]

	// Determine field range for nested type
	nested_next_field_list := if typedef_rid == u32(type_def_table.len) {
		u32(field_table.len + 1)
	} else {
		type_def_table[typedef_rid].field_list
	}

	// Skip if no fields
	if nested_type_def.field_list == 0 || nested_next_field_list <= nested_type_def.field_list {
		return
	}

	for j in nested_type_def.field_list .. nested_next_field_list {
		nested_field := field_table[j - 1]
		nested_field_name := streams.get_string(int(nested_field.name))

		// Decode nested field signature
		nested_field_signature := streams.get_blob(int(nested_field.signature))
		nested_field_sig := streams.decode_field_signature(nested_field_signature)
		nested_field_type := nested_field_sig.field_type

		// Check if this nested field is also a nested type that needs inlining
		mut sub_nested_rid := u32(0)
		if nested_field_type.is_type_def && nested_field_type.rid in nested_to_enclosing {
			sub_nested_rid = nested_field_type.rid
		} else if nested_field_type.is_type_ref && nested_field_type.rid > 0 {
			type_ref_entry := type_ref_table[nested_field_type.rid - 1]
			ref_type_name := streams.get_string(int(type_ref_entry.name))
			if ref_type_name in nested_name_to_typedef_rid {
				sub_nested_rid = nested_name_to_typedef_rid[ref_type_name]
			}
		}

		if sub_nested_rid != 0 {
			// Recursively inline this sub-nested type's fields
			inline_nested_fields(mut buffer, sub_nested_rid, type_def_table, field_table,
				type_ref_table, nested_to_enclosing, nested_name_to_typedef_rid, mut streams,
				mut emitted_fields)
		} else {
			// Skip if this field name was already emitted (deduplication)
			if nested_field_name in emitted_fields {
				continue
			}
			emitted_fields[nested_field_name] = true

			nested_field_type_str := streams.resolve_abi_type(nested_field_type)
			buffer.write_string('\t${nested_field_name}\t${nested_field_type_str}\n')
		}
	}
}

fn main() {
	mut namespace_to_output_c_v_file := []string{}
	mut namespace_to_output_v_file := []string{}

	// api_docs_file := os.read_file('./apidocs.json')!
	// api_docs_file.replace('\\n', '...')
	// api_details := json2.raw_decode(api_docs_file)!
	// docs := DocGen{
	// 	docs: api_details.arr()[0].as_map()
	// }

	// Read the winmd file from disk, and store the entire thing in memory
	winmd_bytes := os.read_file('Windows.Win32.winmd')!.bytes()

	// Since a winmd file is a portable executable (PE) file, it consists
	// of these parts:
	// - MS DOS stub (128 bytes)
	// - PE signature (4 bytes)
	// - COFF header (20 bytes)
	// - Optional header (either 224 bytes for PE32 files, or 240 bytes for PE32+ files)
	// - Section table (40 bytes per section, I think 16 sections in all winmd files? not sure)
	//
	// We could just start our logic directly at the optional header.
	// But just to be pedantic, we do the entire dance of reading the `lfanew` field,
	// and getting the optional header position.
	coff_header_pos := get_coff_header_pos(winmd_bytes)

	// To progress, we need to know how big the optional header is.
	// That information can be found at the 16th byte from the start of
	// the COFF header.
	opt_header_pos, opt_header_size := get_opt_header_pos_and_size(winmd_bytes, coff_header_pos)

	metadata_pos := get_metadata_pos(winmd_bytes, opt_header_pos, opt_header_size)

	// Since we're here anyway, check if the metadata signature BSJB is present. If not,
	// we might be reading an executable file, but not necessarily a CLI assembly file.
	validate_metadata_signature(winmd_bytes, metadata_pos)!

	// A WinMD file has five different metadata streams.
	// The first stream is `#~`. This is also called the tables stream.
	// This is where all the functions, classes, methods, generics
	// and more are defined.
	//
	// The second stream is the `#Strings` stream. It is a heap of all
	// the names of functions, generics, parameters, methods and more.
	// The tables stream only defines the relatinships between
	// classes, methods, parameters and so on, but we need to dive into
	// the string heap to get their readable names.
	//
	// The third stream is the `#US` stream. US stands for user string.
	// The specification, however, keeps us pondering what the user string
	// heap even is for.
	//
	// The fourth stream is the `#GUID` stream. It contains all the GUIDs.
	// Shocking, I know. The GUIDs can be COM IIDs (interface IDs), for example.
	//
	// The fifth stream is the `#Blob` stream. It contains information
	// such as the signature of methods, the parameters of generics, and
	// information about marshalling of COM objects
	//
	// The streams are documented in the ECMA-335 specification.
	// https://ecma-international.org/wp-content/uploads/ECMA-335_6th_edition_june_2012.pdf

	// The offset of the StreamHeaders. According to ECMA-335, if any stream is empty, the writer is free to
	// omit it from the file. But we'll assume that all five streams are present: #~, #Strings, #US, #GUID and #Blob
	streams_pos := get_streams_pos(winmd_bytes, metadata_pos)
	mut streams := get_streams(winmd_bytes, streams_pos, metadata_pos)

	// for type_ref_entry in tables_stream.get_type_ref_table() {
	// 	// type refs
	// }
	type_def_table := streams.tables.get_type_def_table()
	type_ref_table := streams.tables.get_type_ref_table()
	field_table := streams.tables.get_field_table()
	method_table := streams.tables.get_method_def_table()
	param_table := streams.tables.get_param_table()
	impl_map_table := streams.tables.get_impl_map_table()
	module_ref_table := streams.tables.get_module_ref_table()
	nested_class_table := streams.tables.get_nested_class_table()
	constant_table := streams.tables.get_constant_table()

	// Build a map from field token to constant entry for quick lookup
	mut field_to_constant := map[u32]Constant{}
	for c in constant_table {
		field_to_constant[c.parent] = c
	}

	// Build a map from nested class RID to enclosing class RID
	// This helps us identify which types are nested within other types
	mut nested_to_enclosing := map[u32]u32{}
	for nc in nested_class_table {
		nested_to_enclosing[nc.nested_class] = nc.enclosing_class
	}

	// Build a map from type name to TypeDef RID for nested types
	// This allows us to resolve TypeRefs to their TypeDef RIDs
	mut nested_name_to_typedef_rid := map[string]u32{}
	for nc in nested_class_table {
		if nc.nested_class == 0 || nc.nested_class > u32(type_def_table.len) {
			continue
		}
		nested_type_def := type_def_table[nc.nested_class - 1]
		nested_type_name := streams.get_string(int(nested_type_def.name))
		nested_name_to_typedef_rid[nested_type_name] = nc.nested_class
	}

	mut handled_namespaces := []string{}
	// Initialize all modules
	for type_def_entry in type_def_table {
		namespace := streams.get_string(int(type_def_entry.namespace))

		if namespace.len > 0 && namespace !in handled_namespaces {
			handled_namespaces << namespace
			path := namespace.to_lower().replace_each(['.', '/'])
			println('Opening v.mod, mod.c.v and mod.v files at ${out_root}/${path}')
			init_mod_recursively(path)!

			mut file := os.create('${out_root}/${path}/mod.c.v')!
			file.write_string('module ${namespace.split('.').last().to_lower()}\n\n')!
			file.close()
			file = os.create('${out_root}/${path}/mod.v')!
			file.write_string('module ${namespace.split('.').last().to_lower()}\n\n')!
			file.close()
		}
	}
	for type_ref_entry in type_ref_table {
		namespace := streams.get_string(int(type_ref_entry.namespace))

		if namespace.len > 0 && namespace !in handled_namespaces {
			handled_namespaces << namespace
			path := namespace.to_lower().replace_each(['.', '/'])
			println('Opening v.mod, mod.c.v and mod.v files at ${out_root}/${path}')

			init_mod_recursively(path)!
			mut file := os.create('${out_root}/${path}/mod.c.v')!
			file.close()
			file = os.create('${out_root}/${path}/mod.v')!
			file.close()
		}
	}

	// Some type defs do not have fields. This means ([index] .. [index + 1]) resolves to
	// for example 4 .. 4, which does nothing.

	// 10 MB
	// mut out := strings.new_builder(1024 * 1024 * 10)

	for type_def_index, type_def_entry in type_def_table {
		next_field_list := if type_def_index == type_def_table.len - 1 {
			u32(field_table.len)
		} else {
			u32(type_def_table[type_def_index + 1].field_list)
		}
		next_method_list := if type_def_index == type_def_table.len - 1 {
			u32(method_table.len)
		} else {
			u32(type_def_table[type_def_index + 1].method_list)
		}
		namespace := streams.get_string(int(type_def_entry.namespace))

		// Type def is enum - emit as type alias and constants
		if type_def_entry.base_type == 0x010000C6 {
			type_name := streams.get_string(int(type_def_entry.name))
			mut const_buffer := strings.new_builder(1024 * 16)

			// The first field of an enum defines its underlying type
			enum_type := streams.decode_field_signature(streams.get_blob(int(field_table[type_def_entry.field_list - 1].signature)))
			underlying_type := enum_type.field_type.primitive_type

			// Emit the enum type as a type alias
			const_buffer.write_string('pub type C.${type_name} = ${underlying_type}\n')

			// Emit each enum value as a constant
			for j in type_def_entry.field_list .. next_field_list {
				field := field_table[j - 1]

				// Skip the first field (it defines the underlying type, not a value)
				if j == type_def_entry.field_list {
					continue
				}

				field_name := streams.get_string(int(field.name))

				// Look up the constant value
				if field.token in field_to_constant {
					constant := field_to_constant[field.token]
					const_value_blob := streams.get_blob(int(constant.value))
					_, const_value_str := decode_constant_value(constant.type, const_value_blob)
					if const_value_str.len > 0 {
						const_buffer.write_string('pub const ${field_name.to_lower()} = ${underlying_type}(${const_value_str})\n')
					}
				}
			}

			unsafe {
				path := namespace.to_lower().replace_each(['.', '/'])
				mut c_v_file := os.open_file('${out_root}/${path}/mod.c.v', 'a')!
				c_v_file.write(const_buffer.reuse_as_plain_u8_array())!
				c_v_file.close()
			}
		}

		// Type def is a delegate (function pointer) - System.MulticastDelegate
		if type_def_entry.base_type == 0x01000057 {
			type_name := streams.get_string(int(type_def_entry.name))

			// Delegates are function pointers, emit as voidptr
			unsafe {
				path := namespace.to_lower().replace_each(['.', '/'])
				mut c_v_file := os.open_file('${out_root}/${path}/mod.c.v', 'a')!
				c_v_file.write_string('pub type C.${type_name} = voidptr\n')!
				c_v_file.close()
			}
		}

		if type_def_entry.base_type == 0x010002A8 {
			attributes := streams.get_attributes(type_def_entry.token)
			type_name := streams.get_string(int(type_def_entry.name))

			// Skip nested types - they will be generated inline with their parent struct
			if type_def_entry.rid in nested_to_enclosing {
				continue
			}

			// All typedefs in the .c.v file
			mut c_v_type_buffer := strings.new_builder(1024 * 1024)

			// I can't see an easy way to check if I should output "pub type C.xxx = xxx"
			// or "struct C.xxx { ... }" other than getting the first field and
			// checking if the field is the word "Value". I don't think there is a single
			// occurrence of a struct with only a single field called "Value" in the Windows API
			single_field := field_table[type_def_entry.field_list - 1]
			single_field_name := streams.get_string(int(single_field.name))

			if next_field_list - type_def_entry.field_list == 1 && single_field_name == 'Value' {
				// Decode field signature
				field_signature := streams.get_blob(int(single_field.signature))
				field_sig := streams.decode_field_signature(field_signature)
				field_type := field_sig.field_type
				field_type_str := streams.resolve_abi_type(field_type)

				c_v_type_buffer.write_string('pub type C.${type_name} = ${field_type_str}\n')
			} else {
				// All Windows API structs are C typedefs, so emit @[typedef]
				c_v_type_buffer.write_string('@[typedef]\n')
				c_v_type_buffer.write_string('pub struct C.${type_name} {\n')
				// Track emitted field names to avoid duplicates when inlining unions
				mut emitted_fields := map[string]bool{}

				for i in type_def_entry.field_list .. next_field_list {
					field := field_table[i - 1]
					field_name := streams.get_string(int(field.name))

					// Decode field signature
					field_signature := streams.get_blob(int(field.signature))
					field_sig := streams.decode_field_signature(field_signature)
					field_type := field_sig.field_type

					// Check if this field references a nested type (anonymous union/struct)
					// In V, we inline the nested type's fields directly into the parent struct
					// The field type might be a TypeRef, so we need to resolve it by name
					mut nested_typedef_rid := u32(0)
					if field_type.is_type_def && field_type.rid in nested_to_enclosing {
						nested_typedef_rid = field_type.rid
					} else if field_type.is_type_ref && field_type.rid > 0 {
						// Resolve TypeRef to TypeDef by looking up the type name
						type_ref_entry := type_ref_table[field_type.rid - 1]
						ref_type_name := streams.get_string(int(type_ref_entry.name))
						if ref_type_name in nested_name_to_typedef_rid {
							nested_typedef_rid = nested_name_to_typedef_rid[ref_type_name]
						}
					}

					if nested_typedef_rid != 0 {
						// Recursively inline all fields from the nested union/struct
						inline_nested_fields(mut c_v_type_buffer, nested_typedef_rid, type_def_table,
							field_table, type_ref_table, nested_to_enclosing, nested_name_to_typedef_rid,
							mut streams, mut emitted_fields)
					} else {
						// Skip if this field name was already emitted
						if field_name in emitted_fields {
							continue
						}
						emitted_fields[field_name] = true

						field_type_str := streams.resolve_abi_type(field_type)
						c_v_type_buffer.write_string('\t${field_name}\t${field_type_str}\n')
					}
				}
				c_v_type_buffer.write_string('}\n')
			}
			unsafe {
				path := namespace.to_lower().replace_each(['.', '/'])

				// Output to .c.v file
				mut c_v_file := os.open_file('${out_root}/${path}/mod.c.v', 'a')!
				c_v_file.write(c_v_type_buffer.reuse_as_plain_u8_array())!
				c_v_file.close()
			}
		}

		// Type def is collection of functions in a namespace (also contains constants)
		if type_def_entry.base_type == 0x0100003F {
			// Emit constant fields (static literal fields)
			if type_def_entry.field_list > 0 && next_field_list > type_def_entry.field_list {
				mut const_buffer := strings.new_builder(1024 * 64)

				for i in type_def_entry.field_list .. next_field_list {
					field := field_table[i - 1]

					// Only process static literal fields (constants)
					if !field.static() || !field.literal() {
						continue
					}

					field_name := streams.get_string(int(field.name))

					// Look up the constant value
					if field.token in field_to_constant {
						constant := field_to_constant[field.token]
						const_value_blob := streams.get_blob(int(constant.value))

						// Decode the constant value based on type
						const_type_str, const_value_str := decode_constant_value(constant.type, const_value_blob)
						if const_type_str.len > 0 {
							const_buffer.write_string('pub const ${field_name.to_lower()} = ${const_type_str}(${const_value_str})\n')
						}
					}
				}

				if const_buffer.len > 0 {
					unsafe {
						path := namespace.to_lower().replace_each(['.', '/'])
						mut c_v_file := os.open_file('${out_root}/${path}/mod.c.v', 'a')!
						c_v_file.write(const_buffer.reuse_as_plain_u8_array())!
						c_v_file.close()
					}
				}
			}

			// Skip method processing if no methods
			if type_def_entry.method_list == next_method_list {
				continue
			}

			// All import statements in the .c.v file
			mut c_v_import_buffer := strings.new_builder(1024)
			// All #flag statements in the .c.v file
			mut c_v_flag_buffer := strings.new_builder(1024)
			// All C. fn declarations in the .c.v file
			mut c_v_fn_buffer := strings.new_builder(1024 * 1024)
			// All import statements in the .v file
			mut v_import_buffer := strings.new_builder(1024)
			// All types in the .v file
			mut v_type_buffer := strings.new_builder(1024 * 1024)

			mut added_libs := []u32{}

			for method_rid in type_def_entry.method_list .. next_method_list {
				method_index := method_rid - 1

				method := method_table[method_index]

				// Get the .dll it is defined in
				if method.pinvoke_impl() {
					if impl_map_entry := impl_map_table.filter(it.member_forwarded == method.token)[0] {
						if impl_map_entry.import_scope !in added_libs {
							added_libs << impl_map_entry.import_scope
							module_ref_entry := module_ref_table[impl_map_entry.import_scope - 1]
							dll_name := streams.get_string(int(module_ref_entry.name))
							lib_name := '${dll_name[..dll_name.len - 4]}'
                            if (!lib_name.starts_with('api-ms-win-')) {
							    c_v_flag_buffer.write_string('#flag -l${lib_name}\n')
                            }
						}
					}
				}

				method_name := streams.get_string(int(method.name))
				method_def_signature := streams.get_blob(int(method.signature))
				method_signature := streams.decode_method_def_signature(method_def_signature)

				// c_v_fn_buffer.write_string(docs.doc(method_name))
				c_v_fn_buffer.write_string('pub fn C.${method_name}(')

				if method_signature.param_count > 0 {
					// There are some entries with a sequence of 0. I think the specification is saying
					// that this refers to the return value, but there are no special flags or name or anything.
					// If preset, skip the 0 entry and go straight onto 1 and up
					mut offset := u32(0)
					if param_table[method.param_list].sequence == 0 {
						offset = u32(1)
					}

					for i, param_type in method_signature.param_types {
						param_entry := param_table[method.param_list + u32(i) + offset]

						if param_entry.out() {
							c_v_fn_buffer.write_string('mut ')
						}

						param_name := streams.get_string(int(param_entry.name))
						if param_name == 'fn' {
							c_v_fn_buffer.write_string('fn_ ')
						} else {
							c_v_fn_buffer.write_string('${param_name} ')
						}

						abi_type := streams.resolve_abi_type(param_type)

						c_v_fn_buffer.write_string(abi_type)

						if i != method_signature.param_types.len - 1 {
							c_v_fn_buffer.write_string(', ')
						}
					}
				}

				ret_abi_type := streams.resolve_abi_type(method_signature.return_type)
				c_v_fn_buffer.write_string(') ${ret_abi_type}\n')
			}
			unsafe {
				path := namespace.to_lower().replace_each(['.', '/'])

				// Output to .c.v file
				fn_buffer := c_v_fn_buffer.reuse_as_plain_u8_array()
				mut c_v_file := os.open_file('${out_root}/${path}/mod.c.v', 'a')!
				c_v_file.write(c_v_import_buffer.reuse_as_plain_u8_array())!
				c_v_file.write(c_v_flag_buffer.reuse_as_plain_u8_array())!
				c_v_file.write(fn_buffer)!
                if path.ends_with("/foundation") {
                    c_v_file.write_string("pub struct C.Guid {\n\tunused\tint\n}\n")!
                }
				c_v_file.close()

				// Output to .v file
				mut v_file := os.open_file('${out_root}/${path}/mod.v', 'a')!
				v_file.write(v_import_buffer.reuse_as_plain_u8_array())!
				v_file.write(v_type_buffer.reuse_as_plain_u8_array())!
				v_file.close()
			}
		}
	}
}

fn (mut s Streams) resolve_abi_type(p_ ParamType) string {
	mut p := p_

	// Build pointer prefix
	mut ptr_prefix := ''
	if p.is_voidptr {
		if p.is_ptrptrptr {
			ptr_prefix = '&&'
		} else if p.is_ptrptr {
			ptr_prefix = '&'
		} else if p.is_ptr {
			ptr_prefix = ''
		}
	} else {
		if p.is_ptrptrptr {
			ptr_prefix = '&&&'
		} else if p.is_ptrptr {
			ptr_prefix = '&&'
		} else if p.is_ptr {
			ptr_prefix = '&'
		}
	}

	mut arr_prefix := ''
	for arr_rank in 0 .. p.array_rank {
		if p.is_ptr {
			arr_prefix += '&'
		} else {
			if p.array_sizes[arr_rank] or { 0 } == 0 {
				arr_prefix += '[]'
			} else {
				arr_prefix += '[${p.array_sizes[arr_rank]}]'
			}
		}
	}

	// Handle primitives
	if p.is_primitive {
		return '${ptr_prefix}${arr_prefix}${p.primitive_type}'
	}

	// Handle voidptr
	if p.is_voidptr {
		return '${ptr_prefix}${arr_prefix}voidptr'
	}

	type_def_table := s.tables.get_type_def_table()
	type_ref_table := s.tables.get_type_ref_table()

	// Get the type name (either from TypeRef or TypeDef)
	mut type_name := ''
	mut type_namespace := ''

	if p.is_type_ref {
		type_ref_entry := type_ref_table[p.rid - 1]
		type_name = s.get_string(int(type_ref_entry.name))
		type_namespace = s.get_string(int(type_ref_entry.namespace))
	} else if p.is_type_def {
		type_def_entry := type_def_table[p.rid - 1]
		type_name = s.get_string(int(type_def_entry.name))
		type_namespace = s.get_string(int(type_def_entry.namespace))
	}

	// Return the full type with C. prefix and pointer prefix
	if type_namespace.len > 0 {
		return '${ptr_prefix}${arr_prefix}C.${type_name}'
	}

	return '${ptr_prefix}${arr_prefix}${type_name}'
}

// get_coff_header_pos gets the offset of the COFF header inside the PE header.
// The offset of the PE header is defined by the lfanew field. We need to add
// 4 to this offset, the four bytes being the PE signature `PE\0\0`.
// See the following stack overflow post for one theory why lfanew is named lfanew
// https://stackoverflow.com/a/47711673
//
// Here is a handy overview of the entire MS DOS stub, as seen in section
// II.25.2.1 in ECMA-335.
//
// Offset:     Data:
// 0x00        | 0x4d | 0x5a | 0x90 | 0x00 | 0x03 | 0x00 | 0x00 | 0x00 |
// 0x08        | 0x04 | 0x00 | 0x00 | 0x00 | 0xFF | 0xFF | 0x00 | 0x00 |
// 0x10        | 0xb8 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 |
// 0x18        | 0x40 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 |
// 0x20        | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 |
// 0x28        | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 |
// 0x30        | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 |
// 0x38        | 0x00 | 0x00 | 0x00 | 0x00 | lfanew                    | <- lfanew at 0x3C
// 0x40        | 0x0e | 0x1f | 0xba | 0x0e | 0x00 | 0xb4 | 0x09 | 0xcd |
// 0x48        | 0x21 | 0xb8 | 0x01 | 0x4c | 0xcd | 0x21 | 0x54 | 0x68 |
// 0x50        | 0x69 | 0x73 | 0x20 | 0x70 | 0x72 | 0x6f | 0x67 | 0x72 |
// 0x58        | 0x61 | 0x6d | 0x20 | 0x63 | 0x61 | 0x6e | 0x6e | 0x6f |
// 0x60        | 0x74 | 0x20 | 0x62 | 0x65 | 0x20 | 0x72 | 0x75 | 0x6e |
// 0x68        | 0x69 | 0x20 | 0x44 | 0x4f | 0x53 | 0x20 | 0x65 | 0x6e |
// 0x70        | 0x6d | 0x6f | 0x64 | 0x65 | 0x2e | 0x0d | 0x0a | 0x00 |
// 0x78        | 0x24 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 |
fn get_coff_header_pos(winmd_bytes []u8) int {
	lfanew_pos := 0x3C
	// Add 4 to skip the PE\0\0 bytes
	return int(little_endian_u32_at(winmd_bytes, lfanew_pos)) + 4
}

// The optional header size is located at the 16th byte offset from the start of the COFF header,
// as described in the table below
//
// ## II.25.2.2 PE file header
//
// Immediately after the PE signature is the PE File header consisting of the following:
//
//  Offset | Size | Field | Description
//  ---- | ---- | ---- | ----
//  0 | 2 | Machine | Always 0x14c.
//  2 | 2 | Number of Sections | Number of sections; indicates size of the Section Table, which immediately follows the headers.
//  4 | 4 | Time/Date Stamp | Time and date the file was created in seconds since January 1<sup>st</sup> 1970 00:00:00 or 0.
//  8 | 4 | Pointer to Symbol Table | Always 0 (§[II.24.1](ii.24.1-fixed-fields.md)).
//  12 | 4 | Number of Symbols | Always 0 (§[II.24.1](ii.24.1-fixed-fields.md)).
//  16 | 2 | Optional Header Size | Size of the optional header, the format is described below.
//  18 | 2 | Characteristics | Flags indicating attributes of the file, see §[II.25.2.2.1](ii.25.2.2.1-characteristics.md).
fn get_opt_header_pos_and_size(winmd_bytes []u8, coff_header_pos int) (int, u16) {
	// The COFF header is 20 bytes in size, and the optional header immediately follows
	opt_header_pos := coff_header_pos + 20
	// The optional header size is either 224 for PE32, or 240 for PE32+ files
	return opt_header_pos, little_endian_u16_at(winmd_bytes, coff_header_pos + 16)
}

// get_cli_header_rva gets the relative virtual address and the size of the CLI header.
// These values are located inside the optional header. The optional header resides just after
// the COFF header, and just before the .text section. Below is an overview of the data directories
// and their offsets. The CLI header rva and size can be found at offset 208 from the start of the
// optional header.
//
// ## II.25.2.3.3 PE header data directories
//
// The optional header data directories give the address and size of several tables that appear in the sections of the PE file. Each data directory entry contains the RVA and Size of the structure it describes, in that order.
//
//  Offset | Size | Field | Description
//  ---- | ---- | ---- | ----
//  96 | 8 | Export Table | Always 0 (§[II.24.1](ii.24.1-fixed-fields.md)).
//  104 | 8 | Import Table | RVA and Size of Import Table, (§[II.25.3.1](ii.25.3.1-import-table-and-import-address-table-iat.md)).
//  112 | 8 | Resource Table | Always 0 (§[II.24.1](ii.24.1-fixed-fields.md)).
//  120 | 8 | Exception Table | Always 0 (§[II.24.1](ii.24.1-fixed-fields.md)).
//  128 | 8 | Certificate Table | Always 0 (§[II.24.1](ii.24.1-fixed-fields.md)).
//  136 | 8 | Base Relocation Table | Relocation Table; set to 0 if unused (§).
//  144 | 8 | Debug | Always 0 (§[II.24.1](ii.24.1-fixed-fields.md)).
//  152 | 8 | Copyright | Always 0 (§[II.24.1](ii.24.1-fixed-fields.md)).
//  160 | 8 | Global Ptr | Always 0 (§[II.24.1](ii.24.1-fixed-fields.md)).
//  168 | 8 | TLS Table | Always 0 (§[II.24.1](ii.24.1-fixed-fields.md)).
//  176 | 8 | Load Config Table | Always 0 (§[II.24.1](ii.24.1-fixed-fields.md)).
//  184 | 8 | Bound Import | Always 0 (§[II.24.1](ii.24.1-fixed-fields.md)).
//  192 | 8 | IAT | RVA and Size of Import Address Table, (§[II.25.3.1](ii.25.3.1-import-table-and-import-address-table-iat.md)).
//  200 | 8 | Delay Import Descriptor | Always 0 (§[II.24.1](ii.24.1-fixed-fields.md)).
//  208 | 8 | CLI Header | CLI Header with directories for runtime data, (§[II.25.3.1](ii.25.3.1-import-table-and-import-address-table-iat.md)).
//  216 | 8 | Reserved | Always 0 (§[II.24.1](ii.24.1-fixed-fields.md)).
fn get_cli_header_rva(winmd_bytes []u8, opt_header_pos int) int {
	// the cli header is located at the 208th byte in the optional header
	cli_header_rva := int(little_endian_u32_at(winmd_bytes, opt_header_pos + 208))
	// cli_header_size := little_endian_u32_at(winmd_bytes, opt_header_pos + 208 + 4)

	return cli_header_rva
}

// From the .text section we want to get the address of the metadata root.
// Below is an overview of the contents of a section.
//
// ## II.25.3 Section headers
//
// Immediately following the optional header is the Section Table, which contains a number of section headers. This positioning is required because the file header does not contain a direct pointer to the section table; the location of the section table is determined by calculating the location of the first byte after the headers.
//
// Each section header has the following format, for a total of 40 bytes per entry:
//
//  Offset | Size | Field | Description
//  ---- | ---- | ---- | ----
//  0 | 8 | Name | An 8-byte, null-padded ASCII string. There is no terminating null if the string is exactly eight characters long.
//  8 | 4 | VirtualSize | Total size of the section in bytes. If this value is greater than SizeOfRawData, the section is zero-padded.
//  12 | 4 | VirtualAddress | For executable images this is the address of the first byte of the section, when loaded into memory, relative to the image base.
//  16 | 4 | SizeOfRawData | Size of the initialized data on disk in bytes, shall be a multiple of FileAlignment from the PE header. If this is less than VirtualSize the remainder of the section is zero filled. Because this field is rounded while the VirtualSize field is not it is possible for this to be greater than VirtualSize as well. When a section contains only uninitialized data, this field should be 0.
//  20 | 4 | PointerToRawData | Offset of section's first page within the PE file. This shall be a multiple of FileAlignment from the optional header. When a section contains only uninitialized data, this field should be 0.
//  24 | 4 | PointerToRelocations | Should be 0 (§[II.24.1](ii.24.1-fixed-fields.md)).
//  28 | 4 | PointerToLinenumbers | Should be 0 (§[II.24.1](ii.24.1-fixed-fields.md)).
//  32 | 2 | NumberOfRelocations | Should be 0 (§[II.24.1](ii.24.1-fixed-fields.md)).
//  34 | 2 | NumberOfLinenumbers | Should be 0 (§[II.24.1](ii.24.1-fixed-fields.md)).
//  36 | 4 | Characteristics | Flags describing section's characteristics; see below.
fn get_metadata_pos(winmd_bytes []u8, opt_header_pos int, opt_header_size u32) int {
	text_section_pos := opt_header_pos + int(opt_header_size)
	// The section name (.text) occupies the first 8 bytes, skip it

	// virtual means how the file is laid out in memory
	virtual_text_section_pos := int(little_endian_u32_at(winmd_bytes, text_section_pos + 12))

	// raw means how the file is laid out physically on disk
	raw_text_section_pos := int(little_endian_u32_at(winmd_bytes, text_section_pos + 20))

	cli_header_rva := get_cli_header_rva(winmd_bytes, opt_header_pos)
	virtual_cli_header_pos := cli_header_rva - virtual_text_section_pos
	raw_cli_header_pos := virtual_cli_header_pos + raw_text_section_pos

	// Read metadata directory RVA from CLI header
	metadata_rva := int(little_endian_u32_at(winmd_bytes, raw_cli_header_pos + 8))

	virtual_metadata_pos := metadata_rva - virtual_text_section_pos
	raw_metadata_pos := virtual_metadata_pos + raw_text_section_pos

	return raw_metadata_pos
}

fn validate_metadata_signature(winmd_bytes []u8, metadata_pos int) ! {
	signature := little_endian_u32_at(winmd_bytes, metadata_pos)
	if signature != metadata_signature {
		return error('Invalid metadata signature. Got 0x${signature.hex_full()} but expected ${metadata_signature.hex_full()}. You need to input a winmd file, such as Windows.Win32.winmd.')
	}
}

// Metadata root layout, as from the specification:
// | Offset    | Size   | Field           | Description                                                                                       |
// |-----------|--------|-----------------|---------------------------------------------------------------------------------------------------|
// | 0         | 4      | Signature       | Magic signature for physical metadata: 0x424A5342.                                                |
// | 4         | 2      | MajorVersion    | Major version, 1 (ignore on read)                                                                 |
// | 6         | 2      | MinorVersion    | Minor version, 1 (ignore on read)                                                                 |
// | 8         | 4      | Reserved        | Reserved, always 0 (§II.24.1).                                                                    |
// | 12        | 4      | Length          | Number of bytes allocated to hold version string (including null terminator), call this x.        |
// |           |        |                 | Call the length of the string (including the terminator) m (we require m <= 255); the length x is |
// |           |        |                 | m rounded up to a multiple of four.                                                               |
// | 16        | m      | Version         | UTF8-encoded null-terminated version string of length m (see above)                               |
// | 16+m      | x−m    | Padding         | Padding to next 4 byte boundary.                                                                  |
// | 16+x      | 2      | Flags           | Reserved, always 0 (§II.24.1).                                                                    |
// | 16+x+2    | 2      | Streams         | Number of streams, say n.                                                                         |
// | 16+x+4    |        | StreamHeaders   | Array of n StreamHdr structures.                                                                  |
fn get_streams_pos(winmd_bytes []u8, metadata_pos int) int {
	version_length := little_endian_u32_at(winmd_bytes, metadata_pos + 12)
	// version_length represents the x in the table above
	streams_pos := metadata_pos + int(16 + version_length + 4)
	return streams_pos
}

// ## II.24.2.2 Stream header
//
// A stream header gives the names, and the position and length of a particular table or heap. Note that the length of a Stream header structure is not fixed, but depends on the length of its name field (a variable length null-terminated string).
//
//  Offset | Size | Field | Description
//  ---- | ---- | ---- | ----
//  0 | 4 | **Offset** | Memory offset to start of this stream from start of the metadata root (§[II.24.2.1](ii.24.2.1-metadata-root.md))
//  4 | 4 | **Size** | Size of this stream in bytes, shall be a multiple of 4.
//  8 | &nbsp; | **Name** | Name of the stream as null-terminated variable length array of ASCII characters, padded to the next 4-byte boundary with `\0` characters. The name is limited to 32 characters.
fn get_streams(winmd_bytes []u8, streams_pos int, metadata_pos int) Streams {
	tables_stream_pos := int(little_endian_u32_at(winmd_bytes, streams_pos)) + metadata_pos
	tables_stream_name_size := 4

	strings_stream_offset := streams_pos + 8 + tables_stream_name_size
	strings_stream_pos := int(little_endian_u32_at(winmd_bytes, strings_stream_offset)) +
		metadata_pos
	strings_stream_size := little_endian_u32_at(winmd_bytes, strings_stream_offset + 4)
	strings_stream_name_size := 12

	// The #~ stream name occupies 12 bytes
	us_stream_offset := strings_stream_offset + 8 + strings_stream_name_size
	us_stream_pos := int(little_endian_u32_at(winmd_bytes, us_stream_offset)) + metadata_pos
	us_stream_size := little_endian_u32_at(winmd_bytes, us_stream_offset + 4)
	us_stream_name_size := 4

	guid_stream_offset := us_stream_offset + 8 + us_stream_name_size
	guid_stream_pos := int(little_endian_u32_at(winmd_bytes, guid_stream_offset)) + metadata_pos
	guid_stream_size := little_endian_u32_at(winmd_bytes, guid_stream_offset + 4)
	guid_stream_name_size := 8

	blob_stream_offset := guid_stream_offset + 8 + guid_stream_name_size
	blob_stream_pos := int(little_endian_u32_at(winmd_bytes, blob_stream_offset)) + metadata_pos
	blob_stream_size := little_endian_u32_at(winmd_bytes, blob_stream_offset + 4)

	return Streams{
		winmd_bytes: winmd_bytes
		tables:      get_tables_stream(winmd_bytes, tables_stream_pos)
		strings:     Stream{
			pos:  strings_stream_pos
			size: strings_stream_size
		}
		us:          Stream{
			pos:  us_stream_pos
			size: us_stream_size
		}
		guid:        Stream{
			pos:  guid_stream_pos
			size: guid_stream_size
		}
		blob:        Stream{
			pos:  blob_stream_pos
			size: blob_stream_size
		}
	}
}

struct Streams {
	winmd_bytes []u8
pub mut:
	tables  TablesStream
	strings Stream
	us      Stream
	guid    Stream
	blob    Stream
}

fn (s Streams) get_string(index int) string {
	start_pos := s.strings.pos + index
	mut end_pos := start_pos

	for {
		if s.winmd_bytes[end_pos] == 0 {
			break
		}
		end_pos += 1
	}

	return s.winmd_bytes[start_pos..end_pos].bytestr()
}

fn (s Streams) get_blob(index int) []u8 {
	start_pos := s.blob.pos + index
	// A blob is counted - meaning the first byte tells us
	// how many bytes the following signature consists of
	mut end_pos := start_pos + 1 + s.winmd_bytes[start_pos]

	return s.winmd_bytes[start_pos + 1..end_pos]
}

fn (s Streams) get_us(index int) string {
	start_pos := s.us.pos + index
	mut end_pos := start_pos

	for {
		if s.winmd_bytes[end_pos] == 0 {
			break
		}
		end_pos += 1
	}

	return s.winmd_bytes[start_pos..end_pos].bytestr()
}

fn (s Streams) get_guid(index int) []u8 {
	// GUIDs are always 16 bytes long. Index 1 points to the
	// first guid, 2 points to the second guid, and so on
	start_pos := s.guid.pos + (index - 1) * 16

	// Imagine we have the GUID:
	// 00112233-4455-6677-8899-AABBCCDDEEFF
	//
	// The layout of the GUID's bytes looks like this
	// in the winmd file:
	// 33 22 11 00 55 44 77 66 88 99 AA BB CC DD EE FF

	return [
		s.winmd_bytes[start_pos + 3],
		s.winmd_bytes[start_pos + 2],
		s.winmd_bytes[start_pos + 1],
		s.winmd_bytes[start_pos + 0],
		s.winmd_bytes[start_pos + 5],
		s.winmd_bytes[start_pos + 4],
		s.winmd_bytes[start_pos + 7],
		s.winmd_bytes[start_pos + 6],
		s.winmd_bytes[start_pos + 8],
		s.winmd_bytes[start_pos + 9],
		s.winmd_bytes[start_pos + 10],
		s.winmd_bytes[start_pos + 11],
		s.winmd_bytes[start_pos + 12],
		s.winmd_bytes[start_pos + 13],
		s.winmd_bytes[start_pos + 14],
		s.winmd_bytes[start_pos + 15],
	]
}

struct Stream {
mut:
	// The absolute offset of the stream. When reading the stream position from the stream header,
	// we get the position relative to the metadata root. This means if we want to get values
	// from the string stream using winmd_bytes, we have to constantly add the metadata root position to all calculations.
	// The metadata root position is therefore added to this field once so we don't have to do it again and again.
	pos int
	// How many bytes does this stream occupy?
	size u32
}

struct TablesStream {
	winmd_bytes   []u8
	tables_stream Stream
	// While the pos inside tables_stream points to the start
	// of the table stream describing the version, sorted tables, present tables,
	// number of rows per table and so on, tables_pos points directly to the starting
	// address of the first table
	tables_pos int
pub:
	heap_sizes     HeapSizeFlags
	present_tables TableFlags
	sorted_tables  TableFlags
	num_rows       map[TableFlags]u32
mut:
	type_def_table         []TypeDef
	type_ref_table         []TypeRef
	method_def_table       []MethodDef
	member_ref_table       []MemberRef
	field_table            []Field
	param_table            []Param
	constant_table         []Constant
	custom_attribute_table []CustomAttribute
}

fn (s TablesStream) get_pos(table TableFlags) int {
	mut pos := s.tables_pos

	if table == .module {
		return pos
	}
	pos += int(s.num_rows[.module] * Module.row_size(s))

	if table == .type_ref {
		return pos
	}
	pos += int(s.num_rows[.type_ref] * TypeRef.row_size(s))

	if table == .type_def {
		return pos
	}
	pos += int(s.num_rows[.type_def] * TypeDef.row_size(s))

	// pos += int(s.num_rows[.field_ptr] * FieldPtr.row_size(s))

	if table == .field {
		return pos
	}
	pos += int(s.num_rows[.field] * Field.row_size(s))

	// pos += int(s.num_rows[.method_ptr] * MethodPtr.row_size(s))

	if table == .method_def {
		return pos
	}
	pos += int(s.num_rows[.method_def] * MethodDef.row_size(s))

	// pos += int(s.num_rows[.param_ptr] * ParamPtr.row_size(s))

	if table == .param {
		return pos
	}
	pos += int(s.num_rows[.param] * Param.row_size(s))

	if table == .interface_impl {
		return pos
	}
	pos += int(s.num_rows[.interface_impl] * InterfaceImpl.row_size(s))

	if table == .member_ref {
		return pos
	}
	pos += int(s.num_rows[.member_ref] * MemberRef.row_size(s))

	if table == .constant {
		return pos
	}
	pos += int(s.num_rows[.constant] * Constant.row_size(s))

	if table == .custom_attribute {
		return pos
	}
	pos += int(s.num_rows[.custom_attribute] * CustomAttribute.row_size(s))

	if table == .field_marshal {
		return pos
	}
	pos += int(s.num_rows[.field_marshal] * FieldMarshal.row_size(s))

	if table == .decl_security {
		return pos
	}
	pos += int(s.num_rows[.decl_security] * DeclSecurity.row_size(s))

	if table == .class_layout {
		return pos
	}
	pos += int(s.num_rows[.class_layout] * ClassLayout.row_size(s))

	if table == .field_layout {
		return pos
	}
	pos += int(s.num_rows[.field_layout] * FieldLayout.row_size(s))

	if table == .stand_alone_sig {
		return pos
	}
	pos += int(s.num_rows[.stand_alone_sig] * StandAloneSig.row_size(s))

	if table == .event_map {
		return pos
	}
	pos += int(s.num_rows[.event_map] * EventMap.row_size(s))

	if table == .event {
		return pos
	}
	pos += int(s.num_rows[.event] * Event.row_size(s))

	if table == .property_map {
		return pos
	}
	pos += int(s.num_rows[.property_map] * PropertyMap.row_size(s))

	// pos += int(s.num_rows[.property_ptr] * PropertyPtr.row_size(s))

	if table == .property {
		return pos
	}
	pos += int(s.num_rows[.property] * Property.row_size(s))

	if table == .method_semantics {
		return pos
	}
	pos += int(s.num_rows[.method_semantics] * MethodSemantics.row_size(s))

	if table == .method_impl {
		return pos
	}
	pos += int(s.num_rows[.method_impl] * MethodImpl.row_size(s))

	if table == .module_ref {
		return pos
	}
	pos += int(s.num_rows[.module_ref] * ModuleRef.row_size(s))

	if table == .type_spec {
		return pos
	}
	pos += int(s.num_rows[.type_spec] * TypeSpec.row_size(s))

	if table == .impl_map {
		return pos
	}
	pos += int(s.num_rows[.impl_map] * ImplMap.row_size(s))

	if table == .field_rva {
		return pos
	}
	pos += int(s.num_rows[.field_rva] * FieldRVA.row_size(s))

	// pos += int(s.num_rows[.enc_lg] * EncLg.row_size(s))

	// pos += int(s.num_rows[.enc_map] * EncMap.row_size(s))

	if table == .assembly {
		return pos
	}
	pos += int(s.num_rows[.assembly] * Assembly.row_size(s))

	if table == .assembly_processor {
		return pos
	}
	pos += int(s.num_rows[.assembly_processor] * AssemblyProcessor.row_size(s))

	if table == .assembly_os {
		return pos
	}
	pos += int(s.num_rows[.assembly_os] * AssemblyOS.row_size(s))

	if table == .assembly_ref {
		return pos
	}
	pos += int(s.num_rows[.assembly_ref] * AssemblyRef.row_size(s))

	if table == .assembly_ref_processor {
		return pos
	}
	pos += int(s.num_rows[.assembly_ref_processor] * AssemblyRefProcessor.row_size(s))

	if table == .assembly_ref_os {
		return pos
	}
	pos += int(s.num_rows[.assembly_ref_os] * AssemblyRefOS.row_size(s))

	if table == .file {
		return pos
	}
	pos += int(s.num_rows[.file] * File.row_size(s))

	if table == .exported_type {
		return pos
	}
	pos += int(s.num_rows[.exported_type] * ExportedType.row_size(s))

	if table == .manifest_resource {
		return pos
	}
	pos += int(s.num_rows[.manifest_resource] * ManifestResource.row_size(s))

	if table == .nested_class {
		return pos
	}
	pos += int(s.num_rows[.nested_class] * NestedClass.row_size(s))

	if table == .generic_param {
		return pos
	}
	pos += int(s.num_rows[.generic_param] * GenericParam.row_size(s))

	if table == .method_spec {
		return pos
	}
	pos += int(s.num_rows[.method_spec] * MethodSpec.row_size(s))

	if table == .generic_param_constraint {
		return pos
	}
	pos += int(s.num_rows[.generic_param_constraint] * GenericParamConstraint.row_size(s))

	return pos
}

fn (mut s TablesStream) get_type_ref_table() []TypeRef {
	if s.type_ref_table.len > 0 {
		return s.type_ref_table
	}

	mut type_refs := []TypeRef{}
	mut pos := s.get_pos(.type_ref)

	num_rows := s.num_rows[.type_ref]

	for i in 0 .. num_rows {
		rid := u32(i + 1)
		token := u32(Tables.type_def) << 24 + rid

		offset := pos

		coded_resolution_scope := if get_resolution_scope_size(s) == 4 {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			u32(little_endian_u16_at(s.winmd_bytes, pos - 2))
		}
		resolution_scope := decode_resolution_scope(coded_resolution_scope)

		name := if s.heap_sizes.has(.strings) {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			little_endian_u16_at(s.winmd_bytes, pos - 2)
		}

		namespace := if s.heap_sizes.has(.strings) {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			little_endian_u16_at(s.winmd_bytes, pos - 2)
		}

		type_refs << TypeRef{
			rid:              rid
			token:            token
			offset:           offset
			resolution_scope: resolution_scope
			name:             name
			namespace:        namespace
		}
	}

	s.type_ref_table = type_refs

	return type_refs
}

fn (mut s TablesStream) get_type_def_table() []TypeDef {
	if s.type_def_table.len > 0 {
		return s.type_def_table
	}

	mut type_defs := []TypeDef{}

	mut pos := s.get_pos(.type_def)
	num_rows := s.num_rows[.type_def]

	for i in 0 .. num_rows {
		rid := u32(i + 1)
		token := u32(Tables.type_def) << 24 + rid

		offset := pos

		flags := little_endian_u32_at(s.winmd_bytes, pos)
		pos += 4

		name := if s.heap_sizes.has(.strings) {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			little_endian_u16_at(s.winmd_bytes, pos - 2)
		}

		namespace := if s.heap_sizes.has(.strings) {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			little_endian_u16_at(s.winmd_bytes, pos - 2)
		}

		coded_base_type := if get_type_def_or_ref_size(s) == 4 {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			little_endian_u16_at(s.winmd_bytes, pos - 2)
		}
		base_type := decode_type_def_or_ref(coded_base_type)

		field_list := if s.num_rows[.field] > 0xFFFF {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			little_endian_u16_at(s.winmd_bytes, pos - 2)
		}

		method_list := if s.num_rows[.method_def] > 0xFFFF {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			little_endian_u16_at(s.winmd_bytes, pos - 2)
		}

		type_defs << TypeDef{
			rid:         rid
			token:       token
			offset:      offset
			flags:       flags
			name:        name
			namespace:   namespace
			base_type:   base_type
			field_list:  field_list
			method_list: method_list
		}
	}

	s.type_def_table = type_defs

	return type_defs
}

fn (mut s TablesStream) get_field_table() []Field {
	if s.field_table.len > 0 {
		return s.field_table
	}

	mut fields := []Field{}

	mut pos := s.get_pos(.field)
	num_rows := s.num_rows[.field]

	for i in 0 .. num_rows {
		rid := u32(i + 1)
		token := u32(Tables.field) << 24 + rid

		offset := pos

		flags := little_endian_u32_at(s.winmd_bytes, pos)
		pos += 2

		name := if s.heap_sizes.has(.strings) {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			little_endian_u16_at(s.winmd_bytes, pos - 2)
		}

		signature := if s.heap_sizes.has(.blob) {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			little_endian_u16_at(s.winmd_bytes, pos - 2)
		}

		fields << Field{
			rid:       rid
			token:     token
			offset:    offset
			flags:     flags
			name:      name
			signature: signature
		}
	}

	s.field_table = fields

	return fields
}

fn (mut s TablesStream) get_method_def_table() []MethodDef {
	if s.method_def_table.len > 0 {
		return s.method_def_table
	}
	mut method_defs := []MethodDef{}

	mut pos := s.get_pos(.method_def)
	num_rows := s.num_rows[.method_def]

	for i in 0 .. num_rows {
		rid := u32(i + 1)
		token := u32(Tables.method_def) << 24 + rid

		offset := pos

		rva := little_endian_u32_at(s.winmd_bytes, pos)
		pos += 4

		impl_flags := u32(little_endian_u16_at(s.winmd_bytes, pos))
		pos += 2

		flags := u32(little_endian_u16_at(s.winmd_bytes, pos))
		pos += 2

		name := if s.heap_sizes.has(.strings) {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			little_endian_u16_at(s.winmd_bytes, pos - 2)
		}

		signature := if s.heap_sizes.has(.blob) {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			little_endian_u16_at(s.winmd_bytes, pos - 2)
		}

		params_list := if s.num_rows[.param] > 0xFFFF {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			little_endian_u16_at(s.winmd_bytes, pos - 2)
		}

		method_defs << MethodDef{
			rid:        rid
			token:      token
			offset:     offset
			flags:      flags
			impl_flags: impl_flags
			rva:        rva
			name:       name
			signature:  signature
			param_list: params_list - 1
		}
	}

	s.method_def_table = method_defs

	return method_defs
}

fn (mut s TablesStream) get_method_ref_table() []MemberRef {
	if s.member_ref_table.len > 0 {
		return s.member_ref_table
	}
	mut member_refs := []MemberRef{}

	mut pos := s.get_pos(.member_ref)
	num_rows := s.num_rows[.member_ref]

	for i in 0 .. num_rows {
		rid := u32(i + 1)
		token := u32(Tables.member_ref) << 24 + rid

		offset := pos

		coded_parent := if get_has_semantics_size(s) == 4 {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			u32(little_endian_u16_at(s.winmd_bytes, pos - 2))
		}
		parent := decode_has_semantics(coded_parent)

		name := if s.heap_sizes.has(.strings) {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			little_endian_u16_at(s.winmd_bytes, pos - 2)
		}

		signature := if s.heap_sizes.has(.blob) {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			little_endian_u16_at(s.winmd_bytes, pos - 2)
		}

		member_refs << MemberRef{
			rid:       rid
			token:     token
			offset:    offset
			parent:    parent
			name:      name
			signature: signature
		}
	}

	s.member_ref_table = member_refs

	return member_refs
}

fn (mut s TablesStream) get_param_table() []Param {
	if s.param_table.len > 0 {
		return s.param_table
	}
	mut params := []Param{}

	mut pos := s.get_pos(.param)
	num_rows := s.num_rows[.param]

	for i in 0 .. num_rows {
		rid := u32(i + 1)
		token := u32(Tables.param) << 24 + rid

		offset := pos

		flags := u32(little_endian_u16_at(s.winmd_bytes, pos))
		pos += 2

		sequence := u32(little_endian_u16_at(s.winmd_bytes, pos))
		pos += 2

		name := if s.heap_sizes.has(.strings) {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			little_endian_u16_at(s.winmd_bytes, pos - 2)
		}

		params << Param{
			rid:      rid
			token:    token
			offset:   offset
			flags:    flags
			name:     name
			sequence: sequence
		}
	}

	s.param_table = params

	return params
}

fn (s TablesStream) get_interface_impl_table() []InterfaceImpl {
	mut interface_impls := []InterfaceImpl{}

	mut pos := s.get_pos(.interface_impl)
	num_rows := s.num_rows[.interface_impl]

	for i in 0 .. num_rows {
		rid := u32(i + 1)
		token := u32(Tables.interface_impl) << 24 + rid

		offset := pos

		class := if s.num_rows[.type_def] > 0xFFFF {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			little_endian_u16_at(s.winmd_bytes, pos - 2)
		}

		coded_interface := if get_type_def_or_ref_size(s) == 4 {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			little_endian_u16_at(s.winmd_bytes, pos - 2)
		}
		@interface := decode_type_def_or_ref(coded_interface)

		interface_impls << InterfaceImpl{
			rid:       rid
			token:     token
			offset:    offset
			class:     class
			interface: @interface
		}
	}

	return interface_impls
}

fn (s TablesStream) get_member_ref_table() []MemberRef {
	mut member_refs := []MemberRef{}

	mut pos := s.get_pos(.member_ref)
	num_rows := s.num_rows[.member_ref]

	for i in 0 .. num_rows {
		rid := u32(i + 1)
		token := u32(Tables.member_ref) << 24 + rid

		offset := pos

		coded_parent := if get_member_ref_parent_size(s) == 4 {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			little_endian_u16_at(s.winmd_bytes, pos - 2)
		}
		parent := decode_member_ref_parent(coded_parent)

		name := if s.heap_sizes.has(.strings) {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			little_endian_u16_at(s.winmd_bytes, pos - 2)
		}

		signature := if s.heap_sizes.has(.blob) {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			little_endian_u16_at(s.winmd_bytes, pos - 2)
		}

		member_refs << MemberRef{
			rid:       rid
			token:     token
			offset:    offset
			parent:    parent
			name:      name
			signature: signature
		}
	}

	return member_refs
}

fn (s TablesStream) get_constant_table() []Constant {
	mut constants := []Constant{}

	mut pos := s.get_pos(.constant)
	num_rows := s.num_rows[.constant]

	for i in 0 .. num_rows {
		rid := u32(i + 1)
		token := u32(Tables.constant) << 24 + rid

		offset := pos

		// For constants, the type is always 2 bytes
		type := u32(little_endian_u16_at(s.winmd_bytes, pos))
		pos += 2

		coded_parent := if get_has_constant_size(s) == 4 {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			u32(little_endian_u16_at(s.winmd_bytes, pos - 2))
		}
		parent := decode_has_constant(coded_parent)

		value := if s.heap_sizes.has(.strings) {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			u32(little_endian_u16_at(s.winmd_bytes, pos - 2))
		}

		constants << Constant{
			rid:    rid
			token:  token
			offset: offset
			type:   type
			parent: parent
			value:  value
		}
	}

	return constants
}

fn (mut s TablesStream) get_custom_attribute_table() []CustomAttribute {
	if s.custom_attribute_table.len > 0 {
		return s.custom_attribute_table
	}
	mut custom_attributes := []CustomAttribute{}

	mut pos := s.get_pos(.custom_attribute)
	num_rows := s.num_rows[.custom_attribute]

	for i in 0 .. num_rows {
		rid := u32(i + 1)
		token := u32(Tables.custom_attribute) << 24 + rid

		offset := pos

		coded_parent := if get_has_custom_attribute_size(s) == 4 {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			u32(little_endian_u16_at(s.winmd_bytes, pos - 2))
		}
		parent := decode_has_custom_attribute(coded_parent)

		coded_constructor := if get_custom_attribute_type_size(s) == 4 {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			u32(little_endian_u16_at(s.winmd_bytes, pos - 2))
		}
		constructor := decode_custom_attribute_type(coded_constructor)

		value := if s.heap_sizes.has(.blob) {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			u32(little_endian_u16_at(s.winmd_bytes, pos - 2))
		}

		custom_attributes << CustomAttribute{
			rid:         rid
			token:       token
			offset:      offset
			parent:      parent
			constructor: constructor
			value:       value
		}
	}

	s.custom_attribute_table = custom_attributes

	return custom_attributes
}

// TODO: FieldMarshal

// TODO: DeclSecurity

fn (s TablesStream) get_class_layout_table() []ClassLayout {
	mut class_layouts := []ClassLayout{}

	mut pos := s.get_pos(.class_layout)
	num_rows := s.num_rows[.class_layout]

	for i in 0 .. num_rows {
		rid := u32(i + 1)
		token := u32(Tables.class_layout) << 24 + rid

		offset := pos

		class_size := little_endian_u32_at(s.winmd_bytes, pos)
		pos += 4

		packing_size := little_endian_u16_at(s.winmd_bytes, pos)
		pos += 2

		parent := if s.num_rows[.type_def] > 0xFFFF {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			u32(little_endian_u16_at(s.winmd_bytes, pos - 2))
		}

		class_layouts << ClassLayout{
			rid:          rid
			token:        token
			offset:       offset
			class_size:   class_size
			packing_size: packing_size
			parent:       parent
		}
	}

	return class_layouts
}

fn (s TablesStream) get_field_layout_table() []FieldLayout {
	mut field_layouts := []FieldLayout{}

	mut pos := s.get_pos(.field_layout)
	num_rows := s.num_rows[.field_layout]

	for i in 0 .. num_rows {
		rid := u32(i + 1)
		token := u32(Tables.field_layout) << 24 + rid

		offset := pos

		field_offset := little_endian_u16_at(s.winmd_bytes, pos)
		pos += 4

		field := if s.num_rows[.field] > 0xFFFF {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			u32(little_endian_u16_at(s.winmd_bytes, pos - 2))
		}

		field_layouts << FieldLayout{
			rid:          rid
			token:        token
			offset:       offset
			field:        field
			field_offset: field_offset
		}
	}

	return field_layouts
}

// TODO: StandAloneSig

// TODO: EventMap

// TODO: Event

fn (s TablesStream) get_property_map_table() []PropertyMap {
	mut property_maps := []PropertyMap{}

	mut pos := s.get_pos(.property_map)
	num_rows := s.num_rows[.property_map]

	for i in 0 .. num_rows {
		rid := u32(i + 1)
		token := u32(Tables.property_map) << 24 + rid

		offset := pos

		parent := if s.num_rows[.type_def] > 0xFFFF {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			u32(little_endian_u16_at(s.winmd_bytes, pos - 2))
		}

		property_list := if s.num_rows[.property] > 0xFFFF {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			u32(little_endian_u16_at(s.winmd_bytes, pos - 2))
		}

		property_maps << PropertyMap{
			rid:           rid
			token:         token
			offset:        offset
			parent:        parent
			property_list: property_list
		}
	}

	return property_maps
}

fn (s TablesStream) get_property_table() []Property {
	mut properties := []Property{}

	mut pos := s.get_pos(.property)
	num_rows := s.num_rows[.property]

	for i in 0 .. num_rows {
		rid := u32(i + 1)
		token := u32(Tables.property) << 24 + rid

		offset := pos

		flags := u32(little_endian_u16_at(s.winmd_bytes, pos))
		pos += 2

		name := if s.heap_sizes.has(.strings) {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			u32(little_endian_u16_at(s.winmd_bytes, pos - 2))
		}

		signature := if s.heap_sizes.has(.blob) {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			u32(little_endian_u16_at(s.winmd_bytes, pos - 2))
		}

		properties << Property{
			rid:       rid
			token:     token
			offset:    offset
			flags:     flags
			name:      name
			signature: signature
		}
	}

	return properties
}

fn (s TablesStream) get_method_semantics_table() []MethodSemantics {
	mut method_semantics := []MethodSemantics{}

	mut pos := s.get_pos(.method_semantics)
	num_rows := s.num_rows[.method_semantics]

	for i in 0 .. num_rows {
		rid := u32(i + 1)
		token := u32(Tables.method_semantics) << 24 + rid

		offset := pos

		semantics := u32(little_endian_u16_at(s.winmd_bytes, pos))
		pos += 2

		method := if s.num_rows[.method_def] > 0xFFFF {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			u32(little_endian_u16_at(s.winmd_bytes, pos - 2))
		}

		coded_association := if get_has_semantics_size(s) == 4 {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			u32(little_endian_u16_at(s.winmd_bytes, pos - 2))
		}
		association := decode_has_semantics(coded_association)

		method_semantics << MethodSemantics{
			rid:         rid
			token:       token
			offset:      offset
			semantics:   semantics
			method:      method
			association: association
		}
	}

	return method_semantics
}

fn (s TablesStream) get_method_impl_table() []MethodImpl {
	mut method_impls := []MethodImpl{}

	mut pos := s.get_pos(.method_impl)
	num_rows := s.num_rows[.method_impl]

	for i in 0 .. num_rows {
		rid := u32(i + 1)
		token := u32(Tables.method_impl) << 24 + rid

		offset := pos

		method_declaration := if get_method_def_or_ref_size(s) == 4 {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			u32(little_endian_u16_at(s.winmd_bytes, pos - 2))
		}

		method_body := if get_method_def_or_ref_size(s) == 4 {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			u32(little_endian_u16_at(s.winmd_bytes, pos - 2))
		}

		class := if s.num_rows[.type_def] > 0xFFFF {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			u32(little_endian_u16_at(s.winmd_bytes, pos - 2))
		}

		method_impls << MethodImpl{
			rid:                rid
			token:              token
			offset:             offset
			method_declaration: method_declaration
			method_body:        method_body
			class:              class
		}
	}

	return method_impls
}

fn (s TablesStream) get_module_ref_table() []ModuleRef {
	mut module_refs := []ModuleRef{}

	mut pos := s.get_pos(.module_ref)
	num_rows := s.num_rows[.module_ref]

	for i in 0 .. num_rows {
		rid := u32(i + 1)
		token := u32(Tables.module_ref) << 24 + rid

		offset := pos

		name := if s.heap_sizes.has(.strings) {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			u32(little_endian_u16_at(s.winmd_bytes, pos - 2))
		}

		module_refs << ModuleRef{
			rid:    rid
			token:  token
			offset: offset
			name:   name
		}
	}

	return module_refs
}

fn (s TablesStream) get_type_spec_table() []TypeSpec {
	mut type_specs := []TypeSpec{}

	mut pos := s.get_pos(.type_spec)
	num_rows := s.num_rows[.type_spec]

	for i in 0 .. num_rows {
		rid := u32(i + 1)
		token := u32(Tables.type_spec) << 24 + rid

		offset := pos

		signature := if s.heap_sizes.has(.blob) {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			u32(little_endian_u16_at(s.winmd_bytes, pos - 2))
		}

		type_specs << TypeSpec{
			rid:       rid
			token:     token
			offset:    offset
			signature: signature
		}
	}

	return type_specs
}

fn (s TablesStream) get_impl_map_table() []ImplMap {
	mut impl_maps := []ImplMap{}

	mut pos := s.get_pos(.impl_map)
	num_rows := s.num_rows[.impl_map]

	for i in 0 .. num_rows {
		rid := u32(i + 1)
		token := u32(Tables.impl_map) << 24 + rid

		offset := pos

		mapping_flags := u32(little_endian_u16_at(s.winmd_bytes, pos))
		pos += 2

		coded_member_forwarded := if get_member_forwarded_size(s) == 4 {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			u32(little_endian_u16_at(s.winmd_bytes, pos - 2))
		}
		member_forwarded := decode_member_forwarded(coded_member_forwarded)

		import_name := if s.heap_sizes.has(.strings) {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			u32(little_endian_u16_at(s.winmd_bytes, pos - 2))
		}

		import_scope := if s.num_rows[.module_ref] > 0xFFFF {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			u32(little_endian_u16_at(s.winmd_bytes, pos - 2))
		}

		impl_maps << ImplMap{
			rid:              rid
			token:            token
			offset:           offset
			import_name:      import_name
			import_scope:     import_scope
			mapping_flags:    mapping_flags
			member_forwarded: member_forwarded
		}
	}

	return impl_maps
}

// TODO: FieldRVA

fn (s TablesStream) get_assembly_table() []Assembly {
	mut assemblies := []Assembly{}

	mut pos := s.get_pos(.assembly)
	num_rows := s.num_rows[.assembly]

	for i in 0 .. num_rows {
		rid := u32(i + 1)
		token := u32(Tables.assembly) << 24 + rid

		offset := pos

		hash_algorithm := little_endian_u32_at(s.winmd_bytes, pos)
		pos += 4

		flags := little_endian_u32_at(s.winmd_bytes, pos)
		pos += 4

		version := little_endian_u32_at(s.winmd_bytes, pos)
		pos += 4

		name := if s.heap_sizes.has(.strings) {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			u32(little_endian_u16_at(s.winmd_bytes, pos - 2))
		}

		culture := if s.heap_sizes.has(.strings) {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			u32(little_endian_u16_at(s.winmd_bytes, pos - 2))
		}

		assemblies << Assembly{
			rid:            rid
			token:          token
			offset:         offset
			flags:          flags
			culture:        culture
			hash_algorithm: hash_algorithm
			name:           name
			version:        version
		}
	}

	return assemblies
}

// TODO: AssemblyProcessor

// TODO: AssemblyOS

fn (s TablesStream) get_assembly_ref_table() []AssemblyRef {
	mut assembly_refs := []AssemblyRef{}

	mut pos := s.get_pos(.assembly_ref)
	num_rows := s.num_rows[.assembly_ref]

	for i in 0 .. num_rows {
		rid := u32(i + 1)
		token := u32(Tables.assembly_ref) << 24 + rid

		offset := pos

		flags := little_endian_u32_at(s.winmd_bytes, pos)
		pos += 4

		version := little_endian_u32_at(s.winmd_bytes, pos)
		pos += 4

		name := if s.heap_sizes.has(.strings) {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			u32(little_endian_u16_at(s.winmd_bytes, pos - 2))
		}

		culture := if s.heap_sizes.has(.strings) {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			u32(little_endian_u16_at(s.winmd_bytes, pos - 2))
		}

		hash_value := if s.heap_sizes.has(.strings) {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			u32(little_endian_u16_at(s.winmd_bytes, pos - 2))
		}

		assembly_refs << AssemblyRef{
			rid:        rid
			token:      token
			offset:     offset
			flags:      flags
			culture:    culture
			hash_value: hash_value
			name:       name
			version:    version
		}
	}

	return assembly_refs
}

// TODO: AssemblyRefProcessor

// TODO: AssemblyRefOS

// TODO: File

// TODO: ExportedType

// TODO: ManifestResource

fn (s TablesStream) get_nested_class_table() []NestedClass {
	mut nested_classes := []NestedClass{}

	mut pos := s.get_pos(.nested_class)
	num_rows := s.num_rows[.nested_class]

	for i in 0 .. num_rows {
		rid := u32(i + 1)
		token := u32(Tables.nested_class) << 24 + rid

		offset := pos

		// ECMA-335 II.22.32: NestedClass table has NestedClass first, then EnclosingClass
		nested_class := if s.num_rows[.type_def] > 0xFFFF {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			u32(little_endian_u16_at(s.winmd_bytes, pos - 2))
		}

		enclosing_class := if s.num_rows[.type_def] > 0xFFFF {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			u32(little_endian_u16_at(s.winmd_bytes, pos - 2))
		}

		nested_classes << NestedClass{
			rid:             rid
			token:           token
			offset:          offset
			nested_class:    nested_class
			enclosing_class: enclosing_class
		}
	}

	return nested_classes
}

// TODO: GenericParam

// TODO: MethodSpec

// TODO: GenericParamConstraint

struct ParamType {
mut:
	is_primitive   bool
	primitive_type string
	is_type_def    bool
	is_type_ref    bool
	rid            u32
	is_ptr         bool
	is_ptrptr      bool
	is_ptrptrptr   bool
	is_voidptr     bool
	is_array       bool
	array_rank     int
	array_sizes    []int
}

fn (p ParamType) emit_primitive() string {
	return p.emit_from_type(p.primitive_type)
}

fn (p ParamType) emit_from_type(t string) string {
	if p.is_ptrptrptr {
		return '&&&${t}'
	}
	if p.is_ptrptr {
		return '&&${t}'
	}
	if p.is_ptr {
		return '&${t}'
	}
	if p.is_array {
		return '[]${t}'
	}
	if p.is_voidptr {
		return 'voidptr'
	}
	return t
}

// get_type decodes a signature and returns that information in a way that is
// more easy to handle
fn (s Streams) get_type(signature []u8) (ParamType, int) {
	return s.get_type_rec(0, signature, ParamType{})
}

enum AttributeType {
	const_                             = 0x01
	guid                               = 0x02
	supported_os_platform              = 0x03
	documentation                      = 0x04
	ansi                               = 0x05
	unicode                            = 0x06
	associated_enum                    = 0x07
	native_array_info                  = 0x08
	reserved                           = 0x09
	memory_size                        = 0x0A
	raii_free                          = 0x0B
	unmanaged_function_pointer         = 0x0C
	constant                           = 0x0D
	native_encoding                    = 0x0E
	com_out_ptr                        = 0x0F
	can_return_multiple_success_values = 0x10
	flags                              = 0x11
	null_null_terminated               = 0x12
	not_null_terminated                = 0x13
	supported_architecture             = 0x14
	obsolete                           = 0x15
	does_not_return                    = 0x16
	retained                           = 0x17
	can_return_errors_as_success       = 0x18
	attribute_usage                    = 0x19
	com_visible                        = 0x1A
	free_with                          = 0x1B
	associated_constant                = 0x1C
	do_not_release                     = 0x1D
	ret_val                            = 0x1E
	obsolete_superseded                = 0x1F
	ignore_if_return                   = 0x20
	native_bit_field                   = 0x21
	flexible_array                     = 0x22
	struct_size_field                  = 0x23
	native_type_def                    = 0x24
	invalid_handle_value               = 0x25
	also_usable_for                    = 0x26
	metadata_type_def                  = 0x27
	scoped_enum                        = 0x28
	agile                              = 0x29
}

// Attribute is just a container for any kind of attribute. The type determines
// how you should treat this attribute. It doesn't make sense to try to read
// the supported_os field if the attribute type is a GuidAttribute for example
struct Attribute {
	type                       AttributeType
	value_as_string            string
	value_as_guid              []u8
	value_as_int               int
	value_as_native_array_info NativeArrayInfo
	value_as_attribute_usage   AttributeUsage
	value_as_native_bit_field  NativeBitField
	value_as_memory_size       MemorySize
}

fn (mut s Streams) get_attributes(token u32) []Attribute {
	custom_attribute_table := s.tables.get_custom_attribute_table()
	custom_attributes := custom_attribute_table.filter(it.parent == token)
	attributes := []Attribute{}

	for custom_attribute in custom_attributes {
		// The .value field is a MethodRefSig. According to ECMA-335, this means
		// the signature will start with the calling convention,
		// followed by the return type, followed by number of params,
		// then each param type.
		//
		// However, win32metadata repurposes the value field of
		// the MemberRef table to hold strings. The param count
		// then instead means how many characters there are in the
		// following string.
		// An example of a signature value is this:
		// 01-00-0A-77-69-6E-64-6F-77-73-38-2E-30-00-00
		//
		// 01-00: we don't use the calling convention nor the return type
		// 0A: The string is 10 characters long
		// 77-69-6E-64-6F-77-73-38-2E-30: windows8.0
		// 00-00: I am not quite sure why there are two null terminators
		value := s.get_blob(int(custom_attribute.value))

		unsafe {
			attribute_type := AttributeType(custom_attribute.constructor & 0x00FFFFFF)
			if attribute_type == .const_ {
				// ✅
				attributes << Attribute{
					type: AttributeType.const_
				}
			}
			if attribute_type == .guid {
				// ✅
				// While for strings the third byte
				// is the length of the string, we always
				// know the length of a GUID. The GUID
				// therefore starts at the third byte
				attributes << Attribute{
					type:          AttributeType.guid
					value_as_guid: [
						value[2 + 3],
						value[2 + 2],
						value[2 + 1],
						value[2 + 0],
						value[2 + 5],
						value[2 + 4],
						value[2 + 7],
						value[2 + 6],
						value[2 + 8],
						value[2 + 9],
						value[2 + 10],
						value[2 + 11],
						value[2 + 12],
						value[2 + 13],
						value[2 + 14],
						value[2 + 15],
					]
				}
			}
			if attribute_type == .supported_os_platform {
				// ✅
				// Supported os platform's value refers to a windows version.
				// Possible versions:
				//
				// windows8.0
				string_len := value[2]

				attributes << Attribute{
					type:            AttributeType.obsolete
					value_as_string: value[3..3 + string_len].bytestr()
				}
			}
			if attribute_type == .documentation {
				// ✅
				string_len := value[2]
				attributes << Attribute{
					type:            AttributeType.documentation
					value_as_string: value[3..3 + string_len].bytestr()
				}
			}
			if attribute_type == .ansi {
				// ✅
				attributes << Attribute{
					type: AttributeType.ansi
				}
			}
			if attribute_type == .unicode {
				// ✅
				attributes << Attribute{
					type: AttributeType.unicode
				}
			}
			if attribute_type == .associated_enum {
				// ✅
				string_len := value[2]
				attributes << Attribute{
					type:            AttributeType.associated_enum
					value_as_string: value[3..3 + string_len].bytestr()
				}
			}
			if attribute_type == .native_array_info {
				// TODO: decode value as custom attribute
				decoded_value := s.decode_custom_attribute_value(.native_array_info, value)
				attributes << Attribute{
					type:                       AttributeType.native_array_info
					value_as_native_array_info: decoded_value.native_array_info
				}
			}
			if attribute_type == .reserved {
				// ✅
				attributes << Attribute{
					type: AttributeType.reserved
				}
			}
			if attribute_type == .memory_size {
				// TODO: decode as custom attribute
				decoded_value := s.decode_custom_attribute_value(.memory_size, value)
				attributes << Attribute{
					type:                 AttributeType.memory_size
					value_as_memory_size: decoded_value.memory_size
				}
			}
			if attribute_type == .raii_free {
				// ✅
				string_len := value[2]
				attributes << Attribute{
					type:            AttributeType.raii_free
					value_as_string: value[3..3 + string_len].bytestr()
				}
			}
			if attribute_type == .unmanaged_function_pointer {
				// 0x0000A876 is 01-00-01-00-00-00-00-00
				// 0x00041B8B is 01-00-02-00-00-00-00-00
				// TODO: what does pointer type 1 or 2 even mean?
				fn_ptr_type := if value[2] == 1 { 1 } else { 2 }
				attributes << Attribute{
					type:         AttributeType.unmanaged_function_pointer
					value_as_int: fn_ptr_type
				}
			}
			if attribute_type == .constant {
				// TODO: https://chatgpt.com/share/67b9ba61-7a70-8004-b6d0-d7f4190a5332
				attributes << Attribute{
					type: AttributeType.constant
				}
			}
			if attribute_type == .native_encoding {
				// ✅
				string_len := value[2]
				attributes << Attribute{
					type:            AttributeType.native_encoding
					value_as_string: value[3..3 + string_len].bytestr()
				}
			}
			if attribute_type == .com_out_ptr {
				// ✅
				attributes << Attribute{
					type: AttributeType.com_out_ptr
				}
			}
			if attribute_type == .can_return_multiple_success_values {
				// ✅
				attributes << Attribute{
					type: AttributeType.can_return_multiple_success_values
				}
			}
			if attribute_type == .flags {
				// ✅
				attributes << Attribute{
					type: AttributeType.flags
				}
			}
			if attribute_type == .null_null_terminated {
				// ✅
				attributes << Attribute{
					type: AttributeType.null_null_terminated
				}
			}
			if attribute_type == .not_null_terminated {
				// ✅
				attributes << Attribute{
					type: AttributeType.not_null_terminated
				}
			}
			if attribute_type == .supported_architecture {
				// ✅
				// Architecture is stored as a 32-bit integer (little-endian)
				// Values: None=0, X86=1, X64=2, Arm64=4, All=7 (can be combined as flags)
				arch_value := int(little_endian_u32_at(value, 2))
				attributes << Attribute{
					type:         AttributeType.supported_architecture
					value_as_int: arch_value
				}
			}
			if attribute_type == .obsolete {
				// ✅
				// This type is obsolete with nothing to supersede it,
				// unlike obsolete_superseded
				string_len := value[2]

				attributes << Attribute{
					type:            AttributeType.obsolete
					value_as_string: value[3..3 + string_len].bytestr()
				}
			}
			if attribute_type == .does_not_return {
				// ✅
				attributes << Attribute{
					type: AttributeType.does_not_return
				}
			}
			if attribute_type == .retained {
				// ✅
				attributes << Attribute{
					type: AttributeType.retained
				}
			}
			if attribute_type == .can_return_errors_as_success {
				// ✅
				attributes << Attribute{
					type: AttributeType.can_return_errors_as_success
				}
			}
			if attribute_type == .attribute_usage {
				// TODO: decode as custom attribute
				decoded_value := s.decode_custom_attribute_value(.attribute_usage, value)
				attributes << Attribute{
					type:                     AttributeType.attribute_usage
					value_as_attribute_usage: decoded_value.attribute_usage
				}
			}
			if attribute_type == .com_visible {
				// ✅
				attributes << Attribute{
					type:         AttributeType.com_visible
					value_as_int: value[2]
				}
			}
			if attribute_type == .free_with {
				// ✅
				string_len := value[2]
				attributes << Attribute{
					type:            AttributeType.free_with
					value_as_string: value[3..3 + string_len].bytestr()
				}
			}
			if attribute_type == .associated_constant {
				// ✅
				string_len := value[2]
				attributes << Attribute{
					type:            AttributeType.associated_constant
					value_as_string: value[3..3 + string_len].bytestr()
				}
			}
			if attribute_type == .do_not_release {
				// ✅
				attributes << Attribute{
					type: AttributeType.do_not_release
				}
			}
			if attribute_type == .ret_val {
				// ✅
				attributes << Attribute{
					type: AttributeType.ret_val
				}
			}
			if attribute_type == .obsolete_superseded {
				// ✅
				// Let's say SomeFunction() is obsolete. The value of
				// the obsolete attribute refers to the function that supersedes
				// this function, maybe SomeFunctionEx().
				string_len := value[2]

				attributes << Attribute{
					type:            AttributeType.obsolete
					value_as_string: value[3..3 + string_len].bytestr()
				}
			}
			if attribute_type == .ignore_if_return {
				// ✅
				string_len := value[2]

				attributes << Attribute{
					type:            AttributeType.ignore_if_return
					value_as_string: value[3..3 + string_len].bytestr()
				}
			}
			if attribute_type == .native_bit_field {
				// TODO: decode as custom attribute
				decoded_value := s.decode_custom_attribute_value(.native_bit_field, value)
				attributes << Attribute{
					type:                      AttributeType.native_bit_field
					value_as_native_bit_field: decoded_value.native_bit_field
				}
			}
			if attribute_type == .flexible_array {
				// ✅
				attributes << Attribute{
					type: AttributeType.flexible_array
				}
			}
			if attribute_type == .struct_size_field {
				// ✅
				// As of version 63.0.31-preview of Windows.Win32.winmd,
				// every struct size field attribute holds the value
				// cbSize
				attributes << Attribute{
					type:            AttributeType.struct_size_field
					value_as_string: 'cbSize'
				}
			}
			if attribute_type == .native_type_def {
				// ✅
				attributes << Attribute{
					type: AttributeType.native_type_def
				}
			}
			if attribute_type == .invalid_handle_value {
				// Invalid handle value can be either -1 or 0.
				// In the metadata, the blobs are stored as one of:
				//
				// 01-00-FF-FF-FF-FF-FF-FF-FF-FF-00-00
				// 01-00-00-00-00-00-00-00-00-00-00-00
				//
				// For now it suffices to check if the third byte is 0
				invalid_handle_value := if value[2] == 0 { 0 } else { -1 }
				attributes << Attribute{
					type:         AttributeType.invalid_handle_value
					value_as_int: invalid_handle_value
				}
			}
			if attribute_type == .also_usable_for {
				// ✅
				string_len := value[2]
				attributes << Attribute{
					type:            AttributeType.also_usable_for
					value_as_string: value[3..3 + string_len].bytestr()
				}
			}
			if attribute_type == .metadata_type_def {
				// ✅
				attributes << Attribute{
					type: AttributeType.metadata_type_def
				}
			}
			if attribute_type == .scoped_enum {
				// ✅
				attributes << Attribute{
					type: AttributeType.scoped_enum
				}
			}
			if attribute_type == .agile {
				// ✅
				// What the heck is agile? This is what ChatGPT has to say about it:
				//
				// In the Windows API, **agile interfaces** refer to interfaces that
				// can be accessed from multiple [COM apartment models](https://learn.microsoft.com/en-us/windows/win32/com/com-objects-and-apartments)
				// without requiring marshaling. This means that objects implementing
				// agile interfaces can be freely used across **STA (Single-Threaded Apartments)**
				// and **MTA (Multi-Threaded Apartments)** without additional complexity.

				// ### Key Points:
				// - Normally, COM objects are bound to a specific apartment (STA or MTA),
				//   and accessing them from a different apartment requires marshaling via the **COM runtime**.
				// - Agile interfaces bypass this restriction, allowing direct access from any apartment.
				// - They are commonly used in **WinRT (Windows Runtime)**, which heavily relies on agility to simplify development.

				// ### Example:
				// Windows API functions returning objects with **`IAgileObject`** or
				// **agile reference wrappers** allow cross-apartment use without developers
				// needing to handle marshaling explicitly.
				attributes << Attribute{
					type: AttributeType.agile
				}
			}
		}
	}

	return attributes
}

// The inner recursion
fn (s Streams) get_type_rec(consumed int, signature []u8, collected_ ParamType) (ParamType, int) {
	mut collected := collected_

	if signature.len == 0 {
		return collected, consumed
	}

	if signature[0] == 1 {
		if collected.is_ptr {
			collected.is_voidptr = true
		}

		return collected, consumed + 1
	}

	// The param type will always be 1 byte
	param_type := u32(signature[0])
	mut new_consumed := consumed + 1

	// Check for single-dimensional array (SZARRAY)
	if param_type == 0x1D {
		collected.is_array = true
		collected.array_rank = 1
		// Recursively decode the element type
		return s.get_type_rec(new_consumed, signature[1..], collected)
	}

	// Check for multi-dimensional array (ARRAY)
	if param_type == 0x14 {
		collected.is_array = true
		// Recursively decode the element type
		mut element_collected, temp_consumed := s.get_type_rec(new_consumed, signature[1..],
			collected)
		new_consumed = temp_consumed

		// Then decode rank (compressed unsigned integer)
		rank, rank_consumed := decode_unsigned(signature[new_consumed - consumed..])
		new_consumed += rank_consumed
		element_collected.array_rank = int(rank)

		// Decode NumSizes
		num_sizes, num_sizes_consumed := decode_unsigned(signature[new_consumed - consumed..])
		new_consumed += num_sizes_consumed

		// Decode Sizes (array of compressed unsigned integers)
		mut sizes := []int{}
		for i := 0; i < int(num_sizes); i++ {
			size, size_consumed := decode_unsigned(signature[new_consumed - consumed..])
			new_consumed += size_consumed
			sizes << int(size)
		}
		element_collected.array_sizes = sizes

		// Lower bounds decoding is skipped as requested
		// Note: The signature may still contain NumLoBounds and LoBounds data

		return element_collected, new_consumed
	}

	if param_type == 0x0F {
		// If the type is a pointer or ref type, we need to go deeper.
		collected.is_ptrptrptr = collected.is_ptrptr
		collected.is_ptrptr = collected.is_ptr
		collected.is_ptr = true

		return s.get_type_rec(new_consumed, signature[1..], collected)
	}

	if param_type2 := get_primitive_type(param_type) {
		collected.is_primitive = true
		collected.primitive_type = param_type2
		return collected, new_consumed
	}

	if param_type == 0x11 || param_type == 0x12 {
		coded_type_def_or_ref, temp_consumed := decode_unsigned(signature[1..])
		new_consumed += temp_consumed

		type_def_or_ref := decode_type_def_or_ref(coded_type_def_or_ref)

		if (type_def_or_ref >> 24) ^ u32(Tables.type_def) == 0 {
			collected.is_type_def = true
			collected.rid = type_def_or_ref & 0x00FFFFFF

			return collected, new_consumed
		}
		if (type_def_or_ref >> 24) ^ u32(Tables.type_ref) == 0 {
			collected.is_type_ref = true
			collected.rid = type_def_or_ref & 0x00FFFFFF

			return collected, new_consumed
		}
	}

	return collected, new_consumed
}

fn (s Streams) decode_field_signature(signature []u8) FieldSignature {
	// First byte: Calling convention
	mod_opt := (signature[0] & 0x01) != 0
	mod_req := (signature[0] & 0x02) != 0

	// Guaranteed to be a primitive
	if signature.len == 2 {
		return FieldSignature{
			mod_opt:    mod_opt
			mod_req:    mod_req
			field_type: ParamType{
				is_primitive:   true
				primitive_type: get_primitive_type(signature[1]) or { '' }
			}
		}
	}

	// Rest of the bytes: any type from the ELEMENT_TYPE_* list
	type, _ := s.get_type(signature[1..])

	return FieldSignature{
		mod_opt:    mod_opt
		mod_req:    mod_req
		field_type: type
	}
}

struct FieldSignature {
	mod_req    bool
	mod_opt    bool
	field_type ParamType
}

fn (s Streams) decode_method_def_signature(signature []u8) MethodDefSignature {
	mut offset := 0

	// 0x00	DEFAULT	Standard managed method (static or instance).
	// 0x05	VARARG	Function has variable arguments (similar to C-style variadic functions).
	// 0x10	GENERIC	The method itself is generic (i.e., it has type parameters).
	// 0x20	HAS_THIS	Instance method (first argument is an implicit this pointer).
	// 0x40	EXPLICIT_THIS	Method has an explicit this parameter, meaning it follows a custom calling convention.

	// First byte: Calling convention
	calling_convention := signature[offset]
	has_this := (calling_convention & 0x20) != 0
	explicit_this := (calling_convention & 0x40) != 0
	is_default := (calling_convention & 0x10) == 0
	offset++

	// If generic method, decode generic parameter count
	mut generic_param_count := u32(0)
	if (calling_convention & 0x10) != 0 {
		decoded_generic, consumed := decode_unsigned(signature[offset..])
		generic_param_count = decoded_generic
		offset += consumed
	}

	// Decode parameter count
	param_count, param_count_len := decode_unsigned(signature[offset..])
	offset += param_count_len

	// Decode return type
	v_return_type, consumed_return_type := s.get_type(signature[offset..])
	offset += consumed_return_type

	// Decode parameter types
	mut param_types := []ParamType{}
	for _ in 0 .. param_count {
		param_type, consumed_param_type := s.get_type(signature[offset..])
		offset += consumed_param_type

		param_types << param_type
	}

	return MethodDefSignature{
		has_this:            has_this
		explicit_this:       explicit_this
		is_default:          is_default
		generic_param_count: generic_param_count
		param_count:         param_count
		return_type:         v_return_type
		param_types:         param_types
	}
}

struct MethodDefSignature {
	has_this            bool
	explicit_this       bool
	is_default          bool
	generic_param_count u32
	param_count         u32
	return_type         ParamType
	param_types         []ParamType
}

fn (mut s Streams) decode_custom_attribute_value(type AttributeType, value []u8) CustomAttributeValue {
	// I thought about implementing custom attribute decoding so that I could use it for all kinds of
	// custom attributes, but I quickly changed my mind to just hardcoding the decoding for
	// only the attribute types that aren't just plain strings.
	// Currently the attribute types that I am deciding to handle are:
	// - NativeArrayInfo
	// - MemorySize
	// - AttributeUsage
	// - NativeBitField

	if type == .native_array_info {
		// A native array info attribute can describe one of three things:
		// - CountParamIndex
		// - CountFieldName
		// - CountConst
		//
		// From the win32metadata documentation:
		// Pointer parameters that represent arrays are decorated with
		// the [NativeArrayInfo] attribute that can contain the size of
		// a fixed-length array (CountConst), the 0-based index of
		// the parameter that defines the size of the array (CountParamIndex),
		// or the struct field name (CountFieldName) that defines the size of the array

		// We do a dumb check to differentiate between the three types. We know the
		// length of the strings, and the lengths are different. Simply check the
		// string length, then get the value that comes after. An example of
		// a native array info follows:
		//
		// 01-00-01-00-53-06-0F-43-6F-75-6E-74-50-61-72-61-6D-49-6E-64-65-78-03-00
		// └───┘  └───┘ └┘ └─┘ └┘ └────────────────────────────────────────────────┘ └───┘
		//   1     2   3  4  5                      6                          7
		//
		// 1: prolog (always 01-00 for any custom attribute)
		// 2: uint16 named parameter count
		// 3: The named parameter that follows is a field
		//    (as opposed to 0x54, which is a param)
		// 4: The element type of the value that the named argument
		//    refers to (7) is an int16
		// 5: The named argument is 15 characters long
		// 6: The string "CountParamIndex"
		// 7: Which param index that specifies the length of the array
		//
		// Since the native array info custom attribute constructor takes no arguments
		// according to its MemberRef entry, there are no FixedArgs to account for.
		if value[6] == 0x0F {
			// We're dealing with CountParamIndex
			return CustomAttributeValue{
				is_native_array_info: true
				native_array_info:    NativeArrayInfo{
					is_count_param_index: true
					param_index:          int(little_endian_u16_at(value, value.len - 2))
				}
			}
		}
		if value[6] == 0x0E {
			// We're dealing with CountFieldName
			return CustomAttributeValue{
				is_native_array_info: true
				native_array_info:    NativeArrayInfo{
					is_count_field_name: true
					field_name:          value[21..].bytestr()
				}
			}
		}
		if value[6] == 0x0A {
			// We're dealing with CountConst. The last number
			// tells us directly the length of the array
			return CustomAttributeValue{
				is_native_array_info: true
				native_array_info:    NativeArrayInfo{
					is_count_const: true
					count:          int(little_endian_u16_at(value, value.len - 2))
				}
			}
		}
	}

	if type == .memory_size {
		// A memory size attribute ...
		//
		// From the win32metadata documentation:
		// Pointer parameters whose byte size must be specified in another
		// parameter are decorated with the [MemorySize] attribute that
		// will contain the 0-based index of the parameter that can be
		// automatically populated with the size of the provided
		// pointer parameter (BytesParamIndex)

		// Two examples of memory size follows:
		//
		// 01-00-80-00-00-00-02-00-53-02-0D-41-6C-6C-6F-77-4D-75-6C-74-69-70-6C-65-00-53-02-09-49-6E-68-65-72-69-74-65-64-00
		// 01-00-98-29-00-00-02-00-53-02-0D-41-6C-6C-6F-77-4D-75-6C-74-69-70-6C-65-00-53-02-09-49-6E-68-65-72-69-74-65-64-00
		// └───┘  └──────────┘ └───┘ └─┘ └┘ └┘ └─────────────────────────────────────────┘ └─┘ └────────────────────────────────────────┘
		//   1        2        3   4   5 6                     7                    8                   9
		//
		// 1: prolog (always 01-00 for any custom attribute)
		// 2: Although the MemberRef entry for MemorySize
		//    says it takes no parameters, for some reason
		//    there's a fixed argument here... Ignore it
		// 3: There are two named arguments
		// 4: The first named argument that follows is a field
		//    (as opposed to 0x54, which is a param)
		// 5: The element type of the value that the named argument
		//    refers to (7) is a bool
		// 6: The first named argument is 13 characters long
		// 7: The argument is called "AllowMultiple"
		// 8: The value false
		// 9: A named argument "Inherited" as a field that refers to a boolean value of false

		return CustomAttributeValue{
			is_memory_size: true
			memory_size:    MemorySize{
				allow_multiple: true // TODO: get actual value
				inherited:      true // TODO: get actual value
				size:           int(little_endian_u32_at(value, 2))
			}
		}
	}

	if type == .attribute_usage {
		// A attribute usage attribute ...
		//
		// From the win32metadata documentation:
		// typedefs (e.g. BCRYPT_KEY_HANDLE) are represented as CLR structs
		// with a single field where either the NativeTypedef or
		// MetadataTypedef attribute is applied to the struct.
		// NativeTypedef represents typedefs that exist in the Win32 headers
		// while MetadataTypedef represents metadata-only typedefs
		// added to improve API usability. Projections can choose
		// to unwrap MetadataTypedef structs in order to align with
		// the original header definitions. The type being defined
		// is given by the name of the struct, and the type it is being defined as
		// is the type of the struct field. typedefs can include
		// the attributes AlsoUsableFor, RAIIFree and InvalidHandleValue:
		// - AlsoUsableFor indicates that the type is implicitly convertible
		//   to another type (e.g. BCRYPT_HANDLE)
		// - RAIIFree indicates the default function that should be used
		//   to close the handle (e.g. HANDLE -> CloseHandle).
		//   RAIIFree may also be decorated in context on a return value
		//   or [Out] parameter to indicate a more specific function
		//   that should be used to close the handle
		//   (e.g. HeapCreate -> [return: RAIIFree("HeapDestroy")]).
		// - InvalidHandleValue attributes indicate invalid handle values (e.g. 0L)
		// NOTE: AlsoUsableFor and RAIIFree APIs exist in the same namespace as the typedef.

		// An example of an attribute usage attribute is this:
		// 01-00-00-08-00-00-02-00-53-02-0D-41-6C-6C-6F-77-4D-75-6C-74-69-70-6C-65-00-53-02-09-49-6E-68-65-72-69-74-65-64-01
		// └───┘  └──────────┘ └───┘ └───────────────────────────────────────────────────────┘ └─────────────────────────────────────────┘
		//   1        2        3                         4                                             5
		//
		// 1: prolog (always 01-00 for any custom attribute)
		// 2: AttributeUsageAttribute takes one argument,
		//    a System.AttributeTargets. I'm not sure how
		//    to deal with that information.
		// 3: There are two named arguments
		// 4: A named argument "AllowMultiple" as a field that refers to a boolean value of false
		// 5: A named argument "Inherited" as a field that refers to a boolean value of true
		//
		// TODO: be able to decode attribute_usage

		return CustomAttributeValue{
			is_attribute_usage: true
			attribute_usage:    AttributeUsage{
				allow_multiple: true // TODO: get actual value
				inherited:      true // TODO: get actual value
				value:          int(little_endian_u32_at(value, 2))
			}
		}
	}

	if type == .native_bit_field {
		// A native bit field attribute ...
		//
		// From the win32metadata documentation:
		// Bitfields are represented by _bitfieldN fields that have
		// one or more [NativeBitfield] attributes applied. Each attribute
		// represents a member of the bitfield and defines that member's name,
		// offset within the backing _bitfieldN field, and length.
		// Projections can provide friendly definitions of these bitfield members
		// that read and write to the appropriate bits in the backing _bitfieldN field.

		// An example of a native bit field is this: 3710A9 3710CB 3710EF
		//
		// 01-00-0E-56-70-48-6F-74-41-64-64-52-65-6D-6F-76-65-09-00-00-00-00-00-00-00-01-00-00-00-00-00-00-00-00-00
		// └───┘
		// 01-00-0C-49-6F-6D-6D-75-53-75-70-70-6F-72-74-08-00-00-00-00-00-00-00-01-00-00-00-00-00-00-00-00-00
		// 01-00-08-52-65-73-65-72-76-65-64-0A-00-00-00-00-00-00-00-36-00-00-00-00-00-00-00-00-00
		// └───┘  └┘ └────────────────────────┘ └────────────────────────┘ └────────────────────────┘ └───┘
		//   1    2            3                      4                          5            6
		//
		// 1: prolog (always 01-00 for any custom attribute)
		// 2: First fixed argument, string length
		// 3: First fixed argument, the string "Reserved"
		// 4: Second fixed argument, the field offset
		// 5: Third fixed argument, the field length
		// 6: padding? not sure
		//
		// Since the native array info custom attribute constructor takes no arguments
		// according to its MemberRef entry, there are no FixedArgs to account for.
		return CustomAttributeValue{
			is_native_bit_field: true
			native_bit_field:    NativeBitField{
				name:   value[3..3 + value[2]].bytestr()
				offset: i64(little_endian_u64_at(value, value.len - 2 - 8 - 8))
				length: i64(little_endian_u64_at(value, value.len - 2 - 8))
			}
		}
	}

	return CustomAttributeValue{}
}

struct CustomAttributeValue {
	is_native_array_info bool
	native_array_info    NativeArrayInfo
	is_memory_size       bool
	memory_size          MemorySize
	is_attribute_usage   bool
	attribute_usage      AttributeUsage
	is_native_bit_field  bool
	native_bit_field     NativeBitField
}

struct NativeArrayInfo {
	is_count_param_index bool
	param_index          int
	is_count_field_name  bool
	field_name           string
	is_count_const       bool
	count                int
}

struct MemorySize {
	allow_multiple bool
	inherited      bool
	size           int
}

struct AttributeUsage {
	allow_multiple bool
	inherited      bool
	value          int
}

struct NativeBitField {
	name   string
	offset i64
	length i64
}

@[flag]
enum HeapSizeFlags {
	strings
	guid
	blob
}

@[flag]
enum TableFlags as u64 {
	module                   // bit 1
	type_ref                 // bit 2
	type_def                 // bit 3
	field_ptr                // bit 4
	field                    // bit 5
	method_ptr               // bit 6
	method_def               // bit 7
	param_ptr                // bit 8
	param                    // bit 9
	interface_impl           // bit 10
	member_ref               // bit 11
	constant                 // bit 12
	custom_attribute         // bit 13
	field_marshal            // bit 14
	decl_security            // bit 15
	class_layout             // bit 16
	field_layout             // bit 17
	stand_alone_sig          // bit 18
	event_map                // bit 19
	event_ptr                // bit 20
	event                    // bit 21
	property_map             // bit 22
	property_ptr             // bit 23
	property                 // bit 24
	method_semantics         // bit 25
	method_impl              // bit 26
	module_ref               // bit 27
	type_spec                // bit 28
	impl_map                 // bit 29
	field_rva                // bit 30
	enc_lg                   // bit 31
	enc_map                  // bit 32
	assembly                 // bit 33
	assembly_processor       // bit 34
	assembly_os              // bit 35
	assembly_ref             // bit 36
	assembly_ref_processor   // bit 37
	assembly_ref_os          // bit 38
	file                     // bit 39
	exported_type            // bit 40
	manifest_resource        // bit 41
	nested_class             // bit 42
	generic_param            // bit 43
	method_spec              // bit 44
	generic_param_constraint // bit 45
}

enum Tables {
	module                   = 0x00 //  The module containing this metadata
	type_ref                 = 0x01 //  References to types defined in other modules
	type_def                 = 0x02 //  Type definitions in this module
	field_ptr                = 0x03 //  Used for edit-and-continue scenarios
	field                    = 0x04 //  Fields defined in this module
	method_ptr               = 0x05 //  Used for edit-and-continue scenarios
	method_def               = 0x06 //  Methods defined in this module
	param_ptr                = 0x07 //  Used for edit-and-continue scenarios
	param                    = 0x08 //  Parameters for methods
	interface_impl           = 0x09 //  Interfaces implemented by types
	member_ref               = 0x0A //  References to members of other modules
	constant                 = 0x0B //  Constants for fields, params, properties
	custom_attribute         = 0x0C //  Custom attributes
	field_marshal            = 0x0D //  Marshaling information for fields
	decl_security            = 0x0E //  Security declarations
	class_layout             = 0x0F //  Class layout information
	field_layout             = 0x10 //  Field layout information
	stand_alone_sig          = 0x11 //  Standalone signatures
	event_map                = 0x12 //  Event mapping information
	event_ptr                = 0x13 //  Used for edit-and-continue scenarios
	event                    = 0x14 //  Events defined in this module
	property_map             = 0x15 //  Property mapping information
	property_ptr             = 0x16 //  Used for edit-and-continue scenarios
	property                 = 0x17 //  Properties defined in this module
	method_semantics         = 0x18 //  Method semantics
	method_impl              = 0x19 //  Method implementations
	module_ref               = 0x1A //  References to other modules
	type_spec                = 0x1B //  Type specifications
	impl_map                 = 0x1C //  Implementation information
	field_rva                = 0x1D //  Field RVA information
	enc_lg                   = 0x1E //  Edit-and-continue log
	enc_map                  = 0x1F //  Edit-and-continue mapping
	assembly                 = 0x20 //  Assembly information
	assembly_processor       = 0x21 //  Assembly processor information
	assembly_os              = 0x22 //  Assembly OS requirements
	assembly_ref             = 0x23 //  References to other assemblies
	assembly_ref_processor   = 0x24 //  Assembly reference processor information
	assembly_ref_os          = 0x25 //  Assembly reference OS requirements
	file                     = 0x26 //  Files in the assembly
	exported_type            = 0x27 //  Types exported from this assembly
	manifest_resource        = 0x28 //  Resources in this assembly
	nested_class             = 0x29 //  Nested class information
	generic_param            = 0x2A //  Generic parameters
	method_spec              = 0x2B //  Method specifications
	generic_param_constraint = 0x2C //  Generic parameter constraints
}

// ## II.24.2.6 #~ stream

// The "`#~`" streams contain the actual physical representations of the logical metadata tables (§[II.22](ii.22-metadata-logical-format-tables.md)). A "`#~`" stream has the following top-level structure:

// Offset | Size | Field | Description
// ---- | ---- | ---- | ----
// 0 | 4 | **Reserved** | Reserved, always 0 (§[II.24.1](ii.24.1-fixed-fields.md)).
// 4 | 1 | **MajorVersion** | Major version of table schemata; shall be 2 (§[II.24.1](ii.24.1-fixed-fields.md)).
// 5 | 1 | **MinorVersion** | Minor version of table schemata; shall be 0 (§[II.24.1](ii.24.1-fixed-fields.md)).
// 6 | 1 | **HeapSizes** | Bit vector for heap sizes.
// 7 | 1 | **Reserved** | Reserved, always 1 (§[II.24.1](ii.24.1-fixed-fields.md)).
// 8 | 8 | **Valid** | Bit vector of present tables, let *n* be the number of bits that are 1.
// 16 | 8 | **Sorted** | Bit vector of sorted tables.
// 24 | 4\**n* | **Rows** | Array of *n* 4-byte unsigned integers indicating the number of rows for each present table.
// 24+4\**n* | &nbsp; | **Tables** | The sequence of physical tables.

// The _HeapSizes_ field is a bitvector that encodes the width of indexes into the various heaps.  If bit 0 is set, indexes into the "`#Strings`" heap are 4 bytes wide; if bit 1 is set, indexes into the "`#GUID`" heap are 4 bytes wide; if bit 2 is set, indexes into the "`#Blob`" heap are 4 bytes wide. Conversely, if the _HeapSizes_ bit for a particular heap is not set, indexes into that heap are 2 bytes wide.

//  Heap size flag | Description
//  ---- | ----
//  0x01 | Size of "`#Strings`" stream &ge; 2<sup>16</sup>.
//  0x02 | Size of "`#GUID`" stream &ge; 2<sup>16</sup>.
//  0x04 | Size of "`#Blob`" stream &ge; 2<sup>16</sup>.

// The _Valid_ field is a 64-bit bitvector that has a specific bit set for each table that is stored in the stream; the mapping of tables to indexes is given at the start of §[II.22](ii.22-metadata-logical-format-tables.md). For example when the _DeclSecurity_ table is present in the logical metadata, bit 0x0e should be set in the Valid vector. It is invalid to include non-existent tables in _Valid_, so all bits above 0x2c shall be zero.

// The _Rows_ array contains the number of rows for each of the tables that are present. When decoding physical metadata to logical metadata, the number of 1's in _Valid_ indicates the number of elements in the _Rows_ array.

// A crucial aspect in the encoding of a logical table is its schema. The schema for each table is given in §[II.22](ii.22-metadata-logical-format-tables.md). For example, the table with assigned index 0x02 is a _TypeDef_ table, which, according to its specification in §[II.22.37](ii.22.37-typedef-0x02.md), has the following columns: a 4-byte-wide flags, an index into the String heap, another index into the String heap, an index into _TypeDef_, _TypeRef_, or _TypeSpec_ table, an index into _Field_ table, and an index into _MethodDef_ table.

// The physical representation of a table with *n* columns and *m* rows with schema (*C*<sub>0</sub>,&hellip;,*C*<sub>*n*-1</sub>) consists of the concatenation of the physical representation of each of its rows. The physical representation of a row with schema (*C*<sub>0</sub>,&hellip;,*C*<sub>n-1</sub>) is the concatenation of the physical representation of each of its elements. The physical representation of a row cell *e* at a column with type *C* is defined as follows:

//  * If *e* is a constant, it is stored using the number of bytes as specified for its column type *C* (i.e., a 2-bit mask of type _PropertyAttributes_)

//  * If *e* is an index into the GUID heap, 'blob', or String heap, it is stored using the number of bytes as defined in the *HeapSizes* field.

//  * If *e* is a simple index into a table with index *i*, it is stored using 2 bytes if table *i* has less than 216 rows, otherwise it is stored using 4 bytes.

//  * If *e* is a coded index that points into table *t*<sub>*i*</sub> out of *n* possible tables *t*<sub>0</sub>,&hellip;*t*<sub>*n*-1</sub>, then it is stored as *e* << (log *n*) | tag{ *t*<sub>0</sub>,&hellip;*t*<sub>*n*-1</sub> }\[ *t*<sub>*i*</sub> \] using 2 bytes if the maximum number of rows of tables *t*<sub>0</sub>,&hellip;*t*<sub>*n*-1</sub>, is less than 2(16 – (log *n*)), and using 4 bytes otherwise. The family of finite maps tag{ *t*<sub>0</sub>,&hellip;*t*<sub>*n*-1</sub> } is defined below. Note that decoding a physical row requires the inverse of this mapping. [For example, the _Parent_ column of the _Constant_ table indexes a row in the _Field_, _Param_, or _Property_ tables. The actual table is encoded into the low 2 bits of the number, using the values: 0 => _Field_, 1 => _Param_, 2 => _Property_. The remaining bits hold the actual row number being indexed. For example, a value of 0x321, indexes row number 0xC8 in the _Param_ table.]
fn get_tables_stream(winmd_bytes []u8, tables_stream_pos int) TablesStream {
	raw_heap_sizes := winmd_bytes[tables_stream_pos + 6]
	heap_sizes := unsafe { HeapSizeFlags(raw_heap_sizes) }

	raw_present_tables := little_endian_u64_at(winmd_bytes, tables_stream_pos + 8)
	present_tables := unsafe { TableFlags(raw_present_tables) }

	raw_sorted_tables := little_endian_u64_at(winmd_bytes, tables_stream_pos + 8)
	sorted_tables := unsafe { TableFlags(raw_sorted_tables) }

	mut num_rows := map[TableFlags]u32{}
	mut row_idx := 0
	for i in 0 .. 0x2C {
		unsafe {
			table_type := TableFlags(u64(1) << i)
			if present_tables.has(table_type) {
				table_num_rows := little_endian_u32_at(winmd_bytes, tables_stream_pos + 24 +
					4 * row_idx)
				num_rows[table_type] = table_num_rows
				row_idx += 1
			} else {
				num_rows[table_type] = u32(0)
			}
		}
	}

	tables_pos := tables_stream_pos + 24 + 4 * row_idx

	return TablesStream{
		winmd_bytes:    winmd_bytes
		tables_pos:     tables_pos
		heap_sizes:     heap_sizes
		present_tables: present_tables
		sorted_tables:  sorted_tables
		num_rows:       num_rows
	}
}
