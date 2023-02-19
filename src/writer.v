module writer

import io
import metadata { TypeDef }
import os

pub struct Writer {
pub mut:
	out os.File
}

pub fn new_writer() Writer {
	os.mkdir_all("win32") or { panic("Couldn't create the win32 dir") }
	mut w := Writer{
		out: os.create('win32/win32.c.v') or { panic("Couldn't create win32.c.v file") }
	}

	w.out.write_string('module win32\n\n') or { panic("Couldn't write to win32 file") }

	return w
}

pub struct GenStruct {
	struct_name   string
	struct_fields map[string]string
}

pub struct GenEnum {
	enum_name   string
	enum_values map[string]u32
}

pub struct GenAttribute {
	attribute_name  string
	attribute_value ?string
}

pub fn (mut w Writer) write_struct(type_def TypeDef) {
	if s := gen_struct_from_type_def(type_def) {
		mut struct_output := 'struct C.${s.struct_name} {'

		for field_name, field_type in s.struct_fields {
			struct_output += '\n\t${field_name} ${field_type}'
		}

		struct_output += '\n}\n\n'

		// println(struct_output)
		w.out.write_string(struct_output) or { eprintln(err) }
	}
}

pub fn (mut w Writer) write_enum(type_def TypeDef) {
	s := gen_enum_from_type_def(type_def)
	mut enum_output := 'enum ${s.enum_name} {'

	for enum_name, enum_value in s.enum_values {
		enum_output += '\n\t${enum_name} = ${enum_value}'
	}

	enum_output += '\n}\n\n'

	// println(enum_output)
	w.out.write(enum_output.bytes()) or { eprintln(err) }
}

// pub fn (mut w Writer) write_attribute(type_def TypeDef) {
// 	if base_type := type_def.get_base_type()? {
// 		s := gen_attribute_from_type_def(type_def)
// 		mut attribute_output := '[${s.attribute_name} '
//
// 		for attribute_name, attribute_value in s.attribute_map {
// 			attribute_output += '${attribute_name}: \'${attribute_value}\'; '
// 		}
//
// 		attribute_output += ']'
//
// 		// println(attribute_output)
// 		w.out.write(attribute_output.bytes()) or { eprintln(err) }
// 	}
// }

pub fn gen_struct_from_type_def(type_def TypeDef) ?GenStruct {
	struct_name := type_def.get_name()
	// Skip generic functions for now
	if struct_name.contains('`') {
		return none
	}
	return GenStruct{
		struct_name: type_def.get_name()
		struct_fields: {
			'abc': 'u32'
			'def': 'u32'
		}
	}
}

pub fn gen_enum_from_type_def(type_def TypeDef) GenEnum {
	return GenEnum{
		enum_name: type_def.get_name()
		enum_values: {
			'zero': u32(0)
			'one':  u32(1)
		}
	}
}

// pub fn gen_attribute_from_type_def(type_def TypeDef) GenAttribute {
// 	return GenAttribute{
// 		attribute_name: type_def.get_name()
// 		attribute_value: "testing"
// 	}
// }
