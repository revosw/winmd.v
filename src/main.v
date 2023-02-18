module main

import os
import metadata { md }
import writer { Writer }

fn main() {
	unsafe {
		if C.RoInitialize(RoInitType.multithreaded) != 0 {
			panic('Out of memory, how is that even possible?')
		}

		w := Writer{
			out: os.open_append("win32.c.v")!
		}

		for type_def in md().@import.type_defs {
			base_type := type_def.get_base_type()?

			// Check if the type is special
			match base_type.get_name() {
				"Enum" {
					w.write_enum(type_def)
				}
				// "Attribute" {
				// 	w.write_attribute(type_def)
				// }
				else { w.write_struct(type_def) }
			}

			// type_def.get_name()
			// type_def.get_namespace()
			// println(type_def.get_attributes().hex_full())
			// println(base_type.get_name())
			// println(base_type.get_namespace())

			// for field in type_def.fields_iter {
			// 	println(field)
			// }
			// s := GenStruct{
			//
			// }
			// w.write_struct(type_def)
			// type_def

			// for member in type_def.members {
			// 	println(member)
			// }

			// break
		}
		C.RoUninitialize()
	}
}

enum RoInitType {
	singlethreaded
	multithreaded
}

fn C.RoInitialize(RoInitType) u32
fn C.RoUninitialize()
