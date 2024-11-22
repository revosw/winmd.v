module winmd

import os

// DOS Header magic number 'MZ'
const dos_magic = [u8(0x4D), 0x5A]

// PE Header magic "PE\0\0"
const pe_magic = [u8(0x50), 0x45, 0x00, 0x00]

pub struct DOSHeader {
mut:
	e_magic [2]u8
	// Magic number
	e_cblp u16
	// Bytes on last page of file
	e_cp u16
	// Pages in file
	e_crlc u16
	// Relocations
	e_cparhdr u16
	// Size of header in paragraphs
	e_minalloc u16
	// Minimum extra paragraphs needed
	e_maxalloc u16
	// Maximum extra paragraphs needed
	e_ss u16
	// Initial (relative) SS value
	e_sp u16
	// Initial SP value
	e_csum u16
	// Checksum
	e_ip u16
	// Initial IP value
	e_cs u16
	// Initial (relative) CS value
	e_lfarlc u16
	// File address of relocation table
	e_ovno u16
	// Overlay number
	e_res [8]u16
	// Reserved words
	e_oemid u16
	// OEM identifier
	e_oeminfo u16
	// OEM information
	e_res2 [10]u16
	// Reserved words
	e_lfanew u32
	// File address of new exe header
}

pub struct PEHeader {
mut:
	signature [4]u8
	// PE Signature "PE\0\0"
	machine u16
	// Target machine type
	num_sections u16
	// Number of sections
	time_date u32
	// Time/date stamp
	sym_table_ptr u32
	// Pointer to symbol table
	num_symbols u32
	// Number of symbols
	opt_hdr_size u16
	// Size of optional header
	characteristics u16
	// Characteristics
}

// Create a new WinMDReader for the given file path
pub fn new_reader(path string) !&WinMDReader {
	file := os.open(path) or { return error('Failed to open file: ${path}') }
	fileinfo := os.inode(path)
	return &WinMDReader{
		file:       &file
		size:       fileinfo.size
		dos_header: DOSHeader{}
		pe_header:  PEHeader{}
	}
}

// Read bytes from the current position
fn (mut r WinMDReader) read_bytes(count int) ![]u8 {
	mut buffer := []u8{len: count}
	bytes_read := r.file.read(mut buffer) or {
		return error('Failed to read ${count} bytes from file')
	}
	if bytes_read != count {
		return error('Expected to read ${count} bytes but got ${bytes_read}')
	}
	return buffer
}

// Read and validate the DOS header
pub fn (mut r WinMDReader) read_dos_header() !bool {
	// Read DOS magic number (first 2 bytes)
	magic := r.read_bytes(2)!
	if magic != dos_magic {
		return error('Invalid DOS header magic number')
	}

	// Read the rest of the DOS header (64 bytes total)
	mut buffer := r.read_bytes(0x3E)! // 0x40 - 2 bytes we already read

	// Parse important fields (we mainly care about e_lfanew)
	r.dos_header.e_lfanew = u32(buffer[0x3A]) | (u32(buffer[0x3B]) << 8) | (u32(buffer[0x3C]) << 16) | (u32(buffer[0x3D]) << 24)

	return true
}

// Read and validate the PE header
pub fn (mut r WinMDReader) read_pe_header() !bool {
	// Seek to PE header location
	r.file.seek(i64(r.dos_header.e_lfanew), .start) or {
		return error('Failed to seek to PE header')
	}

	// Read and validate PE signature
	signature := r.read_bytes(4)!
	if signature != pe_magic {
		return error('Invalid PE signature')
	}

	// Read COFF header fields
	machine := r.read_bytes(2)!
	r.pe_header.machine = u16(machine[0]) | (u16(machine[1]) << 8)

	num_sections := r.read_bytes(2)!
	r.pe_header.num_sections = u16(num_sections[0]) | (u16(num_sections[1]) << 8)

	time_date := r.read_bytes(4)!
	r.pe_header.time_date = u32(time_date[0]) | (u32(time_date[1]) << 8) | (u32(time_date[2]) << 16) | (u32(time_date[3]) << 24)

	// Read remaining COFF header fields
	sym_ptr := r.read_bytes(4)!
	r.pe_header.sym_table_ptr = u32(sym_ptr[0]) | (u32(sym_ptr[1]) << 8) | (u32(sym_ptr[2]) << 16) | (u32(sym_ptr[3]) << 24)

	num_symbols := r.read_bytes(4)!
	r.pe_header.num_symbols = u32(num_symbols[0]) | (u32(num_symbols[1]) << 8) | (u32(num_symbols[2]) << 16) | (u32(num_symbols[3]) << 24)

	opt_size := r.read_bytes(2)!
	r.pe_header.opt_hdr_size = u16(opt_size[0]) | (u16(opt_size[1]) << 8)

	chars := r.read_bytes(2)!
	r.pe_header.characteristics = u16(chars[0]) | (u16(chars[1]) << 8)

	return true
}
