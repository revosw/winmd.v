module main

// import metadata
import writer
import os
import json

fn main() {
	// unsafe {
	// 	if C.RoInitialize(RoInitType.singlethreaded) != 0 {
	// 		panic('Out of memory, how is that even possible?')
	// 	}

	// 	// from_winmd()

	// 	C.RoUninitialize()
	// }
	from_json()!
}

fn from_json() ! {
	w := writer.JsonWriter.new()
	
	content := os.read_file('WinMetadata/json/UI.Input.json')!
	out := json.decode(writer.Declaration, content)!

	for c in out.constants {
		println(c)
		// w.write_constant()
	}

	for t in out.types {
		println(t)
	}
}

// fn from_winmd() ? {
// 	mut w := new_writer()
//
// 	for type_def in md().@import.type_defs {
// 		base_type := type_def.get_base_type()?
//
// 		// Check if the type is special
// 		match base_type.get_name() {
// 			"Enum" {
// 				w.write_enum(type_def)
// 			}
// 			// "Attribute" {
// 			// 	w.write_attribute(type_def)
// 			// }
// 			else {
// 				w.write_struct(type_def)
//
// 				println("\n\nStarting new method iteration\n")
// 				for method in type_def.methods {
// 					println("nice")
// 					w.write_method(method)
// 				}
// 			}
// 		}
//
// 		// type_def.get_name()
// 		// type_def.get_namespace()
// 		// println(type_def.get_attributes().hex_full())
// 		// println(base_type.get_name())
// 		// println(base_type.get_namespace())
//
// 		// for field in type_def.fields_iter {
// 		// 	println(field)
// 		// }
// 		// s := GenStruct{
// 		//
// 		// }
// 		// w.write_struct(type_def)
// 		// type_def
//
// 		// for member in type_def.members {
// 		// 	println(member)
// 		// }
//
// 		// break
// 	}
// }
