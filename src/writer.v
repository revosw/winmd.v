module writer

import io

struct Writer {
mut:
	out io.Writer
}

pub struct GenStruct {
	struct_name   string
	struct_fields map[string]string
}

pub fn (mut w Writer) write_struct(s GenStruct) {
	mut struct_output := 'struct C.${s.struct_name}{'

	for field_name, field_type in s.struct_fields {
		struct_output += '\n${field_name} ${field_type}'
	}

	struct_output += '\n}'

	println(struct_output)
	w.out.write(struct_output.bytes()) or { eprintln(err) }
}
