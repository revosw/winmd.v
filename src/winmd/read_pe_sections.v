module winmd

// Previous code remains the same, adding new structures and methods:

// Section Header
pub struct SectionHeader {
mut:
	name                 [8]u8
	virtual_size         u32
	virtual_address      u32
	size_of_raw_data     u32
	pointer_to_raw_data  u32
	pointer_to_relocs    u32
	pointer_to_line_nums u32
	number_of_relocs     u16
	number_of_line_nums  u16
	characteristics      u32
}

// Magic numbers for Optional Header
const pe32_magic = u16(0x10B)
const pe32plus_magic = u16(0x20B)

// Data Directory entry
pub struct ImageDataDirectory {
mut:
	virtual_address u32
	size            u32
}

// Optional Header for PE32+
pub struct OptionalHeader64 {
mut:
	magic u16
	// Magic number (0x20B for PE32+)
	major_linker_version u8
	minor_linker_version u8
	size_of_code         u32
	size_of_init_data    u32
	size_of_uninit_data  u32
	addr_of_entry_point  u32
	base_of_code         u32
	image_base           u64
	// Different from PE32
	section_alignment     u32
	file_alignment        u32
	major_os_version      u16
	minor_os_version      u16
	major_image_version   u16
	minor_image_version   u16
	major_subsys_version  u16
	minor_subsys_version  u16
	win32_version_value   u32
	size_of_image         u32
	size_of_headers       u32
	checksum              u32
	subsystem             u16
	dll_characteristics   u16
	size_of_stack_reserve u64
	// Different from PE32
	size_of_stack_commit u64
	// Different from PE32
	size_of_heap_reserve u64
	// Different from PE32
	size_of_heap_commit u64
	// Different from PE32
	loader_flags            u32
	number_of_rva_and_sizes u32
	data_directory          []ImageDataDirectory
}

// Read Optional Header
pub fn (mut r WinMDReader) read_optional_header() !bool {
	// Read magic number to determine format
	magic_bytes := r.read_bytes(2)!
	magic := u16(magic_bytes[0]) | (u16(magic_bytes[1]) << 8)
	println(magic)

	if magic != pe32_magic {
		return error('Unsupported PE format. Expected PE32+ (0x20B)')
	}

	r.opt_header.magic = magic

	// Read basic fields
	linker_version := r.read_bytes(2)!
	r.opt_header.major_linker_version = linker_version[0]
	r.opt_header.minor_linker_version = linker_version[1]

	// Read sizes
	r.opt_header.size_of_code = r.read_u32()!
	r.opt_header.size_of_init_data = r.read_u32()!
	r.opt_header.size_of_uninit_data = r.read_u32()!

	// Entry point and code base
	r.opt_header.addr_of_entry_point = r.read_u32()!
	r.opt_header.base_of_code = r.read_u32()!

	// PE32+ specific fields
	r.opt_header.image_base = r.read_u64()!
	r.opt_header.section_alignment = r.read_u32()!
	r.opt_header.file_alignment = r.read_u32()!

	// Version information
	r.opt_header.major_os_version = r.read_u16()!
	r.opt_header.minor_os_version = r.read_u16()!
	r.opt_header.major_image_version = r.read_u16()!
	r.opt_header.minor_image_version = r.read_u16()!
	r.opt_header.major_subsys_version = r.read_u16()!
	r.opt_header.minor_subsys_version = r.read_u16()!

	// Reserved
	r.opt_header.win32_version_value = r.read_u32()!

	// Size information
	r.opt_header.size_of_image = r.read_u32()!
	r.opt_header.size_of_headers = r.read_u32()!
	r.opt_header.checksum = r.read_u32()!

	// Subsystem and DLL characteristics
	r.opt_header.subsystem = r.read_u16()!
	r.opt_header.dll_characteristics = r.read_u16()!

	// Stack and heap sizes
	r.opt_header.size_of_stack_reserve = r.read_u64()!
	r.opt_header.size_of_stack_commit = r.read_u64()!
	r.opt_header.size_of_heap_reserve = r.read_u64()!
	r.opt_header.size_of_heap_commit = r.read_u64()!

	// Loader flags and data directories
	r.opt_header.loader_flags = r.read_u32()!
	r.opt_header.number_of_rva_and_sizes = r.read_u32()!

	// Read data directories
	for _ in 0 .. r.opt_header.number_of_rva_and_sizes {
		mut dir := ImageDataDirectory{}
		dir.virtual_address = r.read_u32()!
		dir.size = r.read_u32()!
		r.opt_header.data_directory << dir
	}

	return true
}

// Read Section Headers
pub fn (mut r WinMDReader) read_section_headers() !bool {
	for _ in 0 .. r.pe_header.num_sections {
		mut section := SectionHeader{}

		// Read name (8 bytes)
		name_bytes := r.read_bytes(8)!
		for i, b in name_bytes {
			section.name[i] = b
		}

		// Read other fields
		section.virtual_size = r.read_u32()!
		section.virtual_address = r.read_u32()!
		section.size_of_raw_data = r.read_u32()!
		section.pointer_to_raw_data = r.read_u32()!
		section.pointer_to_relocs = r.read_u32()!
		section.pointer_to_line_nums = r.read_u32()!
		section.number_of_relocs = r.read_u16()!
		section.number_of_line_nums = r.read_u16()!
		section.characteristics = r.read_u32()!

		r.sections << section
	}

	return true
}

// Helper method to read u16
fn (mut r WinMDReader) read_u16() !u16 {
	bytes := r.read_bytes(2)!
	return u16(bytes[0]) | (u16(bytes[1]) << 8)
}

// Helper method to read u32
fn (mut r WinMDReader) read_u32() !u32 {
	bytes := r.read_bytes(4)!
	return u32(bytes[0]) | (u32(bytes[1]) << 8) | (u32(bytes[2]) << 16) | (u32(bytes[3]) << 24)
}

// Helper method to read u64
fn (mut r WinMDReader) read_u64() !u64 {
	bytes := r.read_bytes(8)!
	return u64(bytes[0]) | (u64(bytes[1]) << 8) | (u64(bytes[2]) << 16) | (u64(bytes[3]) << 24) | (u64(bytes[4]) << 32) | (u64(bytes[5]) << 40) | (u64(bytes[6]) << 48) | (u64(bytes[7]) << 56)
}

// Helper method to get section by name
pub fn (r &WinMDReader) get_section_by_name(name string) ?&SectionHeader {
	for section in r.sections {
		mut section_name := []u8{}
		for b in section.name {
			if b == 0 {
				break
			}
			section_name << b
		}
		if section_name.str() == name {
			unsafe {
				return &section
			}
		}
	}
	return none
}
