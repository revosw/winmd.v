module winmd

// Previous code remains the same, adding new structures and methods:

// CLI Header structure
pub struct CLIHeader {
mut:
	cb u32
	// Header size (72 bytes)
	major_runtime_version u16
	minor_runtime_version u16
	metadata_directory    ImageDataDirectory
	flags                 u32
	entry_point_token     u32
	resources_directory   ImageDataDirectory
	strong_name_signature ImageDataDirectory
	code_manager_table    ImageDataDirectory
	vtable_fixups         ImageDataDirectory
	export_address_table  ImageDataDirectory
	managed_native_header ImageDataDirectory
}

// Metadata Header structure
pub struct MetadataHeader {
mut:
	signature u32
	// "BSJB"
	major_version  u16
	minor_version  u16
	reserved       u32
	version_length u32
	version_string string
	flags          u16
	streams        u16
}

// Stream Header structure
pub struct StreamHeader {
mut:
	offset u32
	size   u32
	name   string
}

// Constants for CLI Header
const cli_header_size = u32(72)
const metadata_signature = u32(0x424A5342)
// "BSJB"

// Find the CLI Header location using the COM descriptor
fn (mut r WinMDReader) find_cli_header() !u32 {
	// COM descriptor is the 15th data directory (index 14)
	if r.opt_header.data_directory.len <= 14 {
		return error('No COM descriptor found in data directories')
	}

	r.com_descriptor = r.opt_header.data_directory[14]
	if r.com_descriptor.virtual_address == 0 {
		return error('Invalid COM descriptor address')
	}

	return r.com_descriptor.virtual_address
}

// Convert RVA (Relative Virtual Address) to file offset
fn (mut r WinMDReader) rva_to_offset(rva u32) !u32 {
	// Find the section containing this RVA
	for section in r.sections {
		if rva >= section.virtual_address && rva < section.virtual_address + section.virtual_size {
			// Calculate offset within section
			offset := rva - section.virtual_address
			return section.pointer_to_raw_data + offset
		}
	}
	return error('Could not find section for RVA: 0x${rva.hex()}')
}

// Read CLI Header
pub fn (mut r WinMDReader) read_cli_header() !bool {
	// Find CLI header location
	cli_rva := r.find_cli_header()!

	// Convert RVA to file offset
	cli_offset := r.rva_to_offset(cli_rva)!

	// Seek to CLI header
	r.file.seek(i64(cli_offset), .start) or { return error('Failed to seek to CLI header') }

	// Read header size
	r.cli_header.cb = r.read_u32()!
	if r.cli_header.cb != cli_header_size {
		return error('Invalid CLI header size: ${r.cli_header.cb}')
	}

	// Read version info
	r.cli_header.major_runtime_version = r.read_u16()!
	r.cli_header.minor_runtime_version = r.read_u16()!

	// Read metadata directory
	r.cli_header.metadata_directory.virtual_address = r.read_u32()!
	r.cli_header.metadata_directory.size = r.read_u32()!

	// Read flags and entry point
	r.cli_header.flags = r.read_u32()!
	r.cli_header.entry_point_token = r.read_u32()!

	// Read remaining directories
	r.cli_header.resources_directory.virtual_address = r.read_u32()!
	r.cli_header.resources_directory.size = r.read_u32()!

	r.cli_header.strong_name_signature.virtual_address = r.read_u32()!
	r.cli_header.strong_name_signature.size = r.read_u32()!

	r.cli_header.code_manager_table.virtual_address = r.read_u32()!
	r.cli_header.code_manager_table.size = r.read_u32()!

	r.cli_header.vtable_fixups.virtual_address = r.read_u32()!
	r.cli_header.vtable_fixups.size = r.read_u32()!

	r.cli_header.export_address_table.virtual_address = r.read_u32()!
	r.cli_header.export_address_table.size = r.read_u32()!

	r.cli_header.managed_native_header.virtual_address = r.read_u32()!
	r.cli_header.managed_native_header.size = r.read_u32()!

	return true
}

// Read Metadata Header
pub fn (mut r WinMDReader) read_metadata_header() !bool {
	// Convert metadata RVA to file offset
	metadata_offset := r.rva_to_offset(r.cli_header.metadata_directory.virtual_address)!

	// Seek to metadata header
	r.file.seek(i64(metadata_offset), .start) or {
		return error('Failed to seek to metadata header')
	}

	// Read and verify signature
	r.metadata_header.signature = r.read_u32()!
	if r.metadata_header.signature != metadata_signature {
		return error('Invalid metadata signature: 0x${r.metadata_header.signature.hex()}')
	}

	// Read version information
	r.metadata_header.major_version = r.read_u16()!
	r.metadata_header.minor_version = r.read_u16()!
	r.metadata_header.reserved = r.read_u32()!

	// Read version string
	r.metadata_header.version_length = r.read_u32()!
	version_bytes := r.read_bytes(int(r.metadata_header.version_length))!
	r.metadata_header.version_string = version_bytes.str()
	padding := (4 - (r.metadata_header.version_length % 4)) % 4
	if padding > 0 {
		r.read_bytes(int(padding))!
	}

	// Read flags and number of streams
	r.metadata_header.flags = r.read_u16()!
	r.metadata_header.streams = r.read_u16()!

	return true
}

// Read stream headers
pub fn (mut r WinMDReader) read_stream_headers() !bool {
	for _ in 0 .. r.metadata_header.streams {
		mut stream := StreamHeader{}

		// Read offset and size
		stream.offset = r.read_u32()!
		stream.size = r.read_u32()!

		// Read name (null-terminated)
		mut name_bytes := []u8{}
		for {
			b := r.read_bytes(1)!
			if b[0] == 0 {
				break
			}
			name_bytes << b[0]
		}
		stream.name = name_bytes.str()

		// Pad to next 4-u8 boundary
		padding := (4 - (name_bytes.len + 1) % 4) % 4
		if padding > 0 {
			r.read_bytes(int(padding))!
		}

		r.stream_headers << stream
	}

	return true
}

// Helper method to get stream by name
pub fn (r &WinMDReader) get_stream_header(name string) ?&StreamHeader {
	for stream in r.stream_headers {
		if stream.name == name {
			unsafe {
				return &stream
			}
		}
	}
	return none
}
