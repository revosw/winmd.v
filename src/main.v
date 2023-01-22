module main
import metadata { get_metadata_dispenser }

fn main() {
	if C.RoInitialize(RoInitType.singlethreaded) != 0 {
		panic('Out of memory or something, idk')
	}
	dispenser := get_metadata_dispenser()
	dispenser.open_scope("C:/Windows/System32/WinMetadata/Windows.Foundation.winmd", )
}

pub struct Guid {
	data1 u32
	data2 u16
	data3 u16
	data4 [8]u8
}

enum RoInitType {
	singlethreaded
	multithreaded
}

fn C.RoInitialize(RoInitType) u32
