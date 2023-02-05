module main

import metadata { metadata }

fn main() {
	unsafe {
		if C.RoInitialize(RoInitType.multithreaded) != 0 {
			panic('Out of memory, how is that even possible?')
		}

		md := metadata()

		for type_def in md.@import.type_defs {
			println('TypeDef: ${voidptr(type_def.token)}')

			// for member in type_def.members {
			// 	println(member)
			// }

			break
		}
	}
}

enum RoInitType {
	singlethreaded
	multithreaded
}

fn C.RoInitialize(RoInitType) u32
