module main

// import metadata
import writer
import os
import json
import winmd

// fn main() {
// 	os.mkdir_all('win32') or { panic("Couldn't create the 'win32' dir") }
// 	os.create('win32/win32.c.v') or { panic("Couldn't create win32.c.v file") }

// 	// from_json()!

// 	mut w := writer.JsonWriter.new()
// 	println(os.getwd())
// 	content := os.read_file('./WinMetadata/json/Devices.DeviceQuery.json')!
// 	println(content)
// 	out := json.decode(writer.Declaration, content)!
// 	println(out)
// 	for c in out.constants {
// 		println(c)
// 		w.write_constant(c)
// 	}
// 	for @type in out.types {
// 		w.write_type(@type)
// 	}
// 	for func in out.functions {
// 		w.write_function(func)
// 	}

// 	os.write_file('win32/win32.c.v', w.buf.str())!
// }

// fn from_json() ! {
// 	mut w := writer.JsonWriter.new()
// 	println(os.getwd())
// 	content := os.read_file('./WinMetadata/json/Devices.DeviceQuery.json')!
// 	println(content)
// 	out := json.decode(writer.Declaration, content)!
// 	println(out)
// 	for c in out.constants {
// 		println(c)
// 		w.write_constant(c)
// 	}
// 	for @type in out.types {
// 		w.write_type(@type)
// 	}
// 	for func in out.functions {
// 		w.write_function(func)
// 	}

// 	os.write_file('win32/win32.c.v', w.buf.str())!
// }

fn main() {
	mut reader := winmd.new_reader('./WinMetadata/winmd/Windows.Win32.winmd')!

	is_valid := reader.validate() or {
		println('Invalid WinMD file: ${err}')
		return
	}

	if is_valid {
		// 3. Create metadata collector
		mut collector := winmd.new_collector(reader)

		// 4. Collect all metadata
		collector.collect()!

		// 5. Setup code generator
		mut generator := winmd.new_code_generator(collector, 'generated')

		// 6. Generate V code with error handling
		generator.generate() or {
			println('Code generation failed: ${err}')
			return
		}
	}
}

// fn from_winmd() ? {
// 	unsafe {
// 		if C.RoInitialize(RoInitType.singlethreaded) != 0 {
// 			panic('Out of memory, how is that even possible?')
// 		}
// 		mut w := new_writer()

// 		for type_def in md().@import.type_defs {
// 			base_type := type_def.get_base_type()?

// 			// Check if the type is special
// 			match base_type.get_name() {
// 				'Enum' {
// 					w.write_enum(type_def)
// 				}
// 				// "Attribute" {
// 				// 	w.write_attribute(type_def)
// 				// }
// 				else {
// 					w.write_struct(type_def)

// 					println('\n\nStarting new method iteration\n')
// 					for method in type_def.methods {
// 						println('nice')
// 						w.write_method(method)
// 					}
// 				}
// 			}

// 			type_def.get_name()
// 			type_def.get_namespace()
// 			println(type_def.get_attributes().hex_full())
// 			println(base_type.get_name())
// 			println(base_type.get_namespace())

// 			for field in type_def.fields_iter {
// 				println(field)
// 			}
// 			s := GenStruct{}
// 			w.write_struct(type_def)
// 			type_def

// 			for member in type_def.members {
// 				println(member)
// 			}

// 			break
// 		}
// 		C.RoUninitialize()
// 	}
// }
