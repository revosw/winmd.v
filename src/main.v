module main

import metadata { get_metadata_dispenser }

fn main() {
	if C.RoInitialize(RoInitType.singlethreaded) != 0 {
		panic('Out of memory or something, idk')
	}
	dispenser := get_metadata_dispenser()
	dispenser.open_scope('C:/Windows/System32/WinMetadata/Windows.Foundation.winmd')
}

enum RoInitType {
	singlethreaded
	multithreaded
}

fn C.RoInitialize(RoInitType) u32
