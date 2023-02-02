module main

import metadata { get_metadata_dispenser }

fn main() {
	if C.RoInitialize(RoInitType.multithreaded) != 0 {
		panic('Out of memory, how is that even possible?')
	}

	dispenser := get_metadata_dispenser()
	mut md_import := dispenser.open_scope('C:/dev/v/winmd/winmd_files/Windows.Win32.winmd\0')

	mut current_type_def := u32(0)
	mut next_type_def := u32(0)
	mut count := u32(0)

	if 0 != md_import.import_ptr.lpVtbl.EnumTypeDefs(md_import.import_ptr, &current_type_def, &next_type_def,
		1, &count) {
	}


	// for type_def in md_import.type_defs {
	//
	// 	// for member in type_def.members {
	//
	// 	// }
	// }
}

enum RoInitType {
	singlethreaded
	multithreaded
}

fn C.RoInitialize(RoInitType) u32
