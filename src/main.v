module main

import metadata { md, get_dispenser_ptr, get_import_ptr }

fn main() {
	unsafe {
		if C.RoInitialize(RoInitType.multithreaded) != 0 {
			panic('Out of memory, how is that even possible?')
		}


		dispenser_ptr := get_dispenser_ptr()
		import_ptr := get_import_ptr(dispenser_ptr, "C:/Windows/System32/WinMetadata/Windows.Foundation.winmd")
		// // MetaDataGetDispenser from rometadata.h
		enum_typedef := usize(0)
		tdef := u32(0)

		println("phEnum outside: ${enum_typedef}")
		println("phEnum outside: ${voidptr(&enum_typedef)}")

		import_ptr.lpVtbl.EnumTypeDefs(import_ptr, mut &enum_typedef, mut &tdef, 1, 0)
		//
		// println(enum_typedef)
		td := usize(0)
		a := md().@import.enum_type_defs(import_ptr,mut &td) or { 0 }

		println(enum_typedef)
		println(a)
		// for type_def in md().@import.type_defs {
		// 	println(type_def)
		//
		// 	// for member in type_def.members {
		// 	// 	println(member)
		// 	// }
		//
		// 	break
		// }
	}
}

enum RoInitType {
	singlethreaded
	multithreaded
}

fn C.RoInitialize(RoInitType) u32
