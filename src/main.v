module main

import os
import encoding.binary { little_endian_u16_at, little_endian_u32_at, little_endian_u64_at }

// "BSJB" in little-endian ascii

// "BSJB" in little-endian ascii
const metadata_signature = u32(0x424A5342)

fn main() {
	// Read the winmd file from disk, and store the entire thing in memory
	winmd_bytes := os.read_file('WinMetadata/Windows.Win32.winmd')!.bytes()

	// Since a winmd file is a portable executable (PE) file, it consists
	// of these parts:
	// - MS DOS stub (128 bytes)
	// - PE signature (4 bytes)
	// - COFF header (20 bytes)
	// - Optional header (either 224 bytes for PE32 files, or 240 bytes for PE32+ files)
	// - Section table (40 bytes per section, )
	//
	// We could just start our logic directly at the optional header.
	// But just to be pedantic, we do the entire dance of reading the `lfanew` field,
	// and getting the optional header position.
	coff_header_pos := get_coff_header_pos(winmd_bytes)

	// To progress, we need to know how big the optional header is.
	// That information can be found at the 16th byte from the start of
	// the COFF header.
	opt_header_pos, opt_header_size := get_opt_header_pos_and_size(winmd_bytes, coff_header_pos)

	metadata_pos := get_metadata_pos(winmd_bytes, opt_header_pos, opt_header_size)

	// Since we're here anyway, check if the metadata signature BSJB is present. If not,
	// we might be reading an executable file, but not necessarily a CLI assembly file.
	validate_metadata_signature(winmd_bytes, metadata_pos)!

	// The offset of the StreamHeaders. According to ECMA-335, if any stream is empty, the writer is free to
	// omit it from the file. But we'll assume that all five streams are present: #~, #Strings, #US, #GUID and #Blob
	streams_pos := get_streams_pos(winmd_bytes, metadata_pos)
	streams := get_streams(winmd_bytes, streams_pos, metadata_pos)
	tables_stream := get_tables_stream(winmd_bytes, streams.tables)

	// We're now in the second phase. We have successfully navigated through the file headers
	// and have all the information we need to start parsing the tables stream.

	// Here are the steps we need to do to generate V code from the constants table.
	// The goal is to end up with something like:
	// ```
	// const status_success = NtStatus(0)
	// const status_wait_0 = NtStatus(1)
	// ```
	// For this, we need three things - the name, type and value of the constant.

	// for i in 0..0xFFFFFFFF {
	// 	re := little_endian_u32_at(winmd_bytes, i)
	// 	if re == metadata_signature {
	// 		println("found at ${i}")
	// 		break
	// 	}
	// }

	// for type_ref_entry in tables_stream.get_type_ref_table() {
	// 	// type refs
	// }
	// for type_def_entry in tables_stream.get_type_def_table() {
	// 	// type defs
	// }
	// for field_entry in tables_stream.get_field_table() {
	// 	// fields
	// }
	// for method_def_entry in tables_stream.get_method_def_table() {
	// 	// method defs
	// }
	// for param_entry in tables_stream.get_param_table() {
	// 	// params
	// }
	// for interface_impl_entry in tables_stream.get_interface_impl_table() {
	// 	// interface impls
	// }
	// for member_ref_entry in tables_stream.get_member_ref_table() {
	// 	// interface impls
	// }
	// for constant_entry in tables_stream.get_constant_table() {
	// 	// constants
	// }
	// for custom_attribute_entry in tables_stream.get_custom_attribute_table() {
	// 	// custom attributes
	// }
	// for field_marshal_entry in tables_stream.get_field_marshal_table() {
	// 	// property map
	// }
	// for decl_security_entry in tables_stream.get_decl_security_table() {
	// 	// property map
	// }
	for class_layout_entry in tables_stream.get_class_layout_table() {
		// property map
	}
	// for field_layout_entry in tables_stream.get_field_layout_table() {
	// 	// property map
	// }
	// for stand_alone_sig_entry in tables_stream.get_stand_alone_sig_table() {
	// 	// property map
	// }
	// for event_map_entry in tables_stream.get_event_map_table() {
	// 	// property map
	// }
	// for event_entry in tables_stream.get_event_table() {
	// 	// property map
	// }
	// for property_map_entry in tables_stream.get_property_map_table() {
	// 	// property map
	// }
	// for property_entry in tables_stream.get_property_table() {
	// 	// property map
	// }
	// for method_semantics_entry in tables_stream.get_method_semantics_table() {
	// 	// property map
	// }
	// for method_impl_entry in tables_stream.get_method_impl_table() {
	// 	// property map
	// }
	// for type_spec_entry in tables_stream.get_type_spec_table() {
	// 	// property map
	// }
	// for impl_map_entry in tables_stream.get_impl_map_table() {
	// 	// property map
	// }
	// for field_rva_entry in tables_stream.get_field_rva_table() {
	// 	// property map
	// }
	// for assembly_entry in tables_stream.get_assembly_table() {
	// 	// property map
	// }
	// for assembly_ref_entry in tables_stream.get_assembly_ref_table() {
	// 	// property map
	// }
	// for nested_class_entry in tables_stream.get_nested_class_table() {
	// 	// property map
	// }
	// for generic_param_entry in tables_stream.get_generic_param_table() {
	// 	// property map
	// }
	// for method_spec_entry in tables_stream.get_method_spec_table() {
	// 	// property map
	// }
	// for generic_param_constraints_entry in tables_stream.get_generic_param_constraints_table() {
	// 	// property map
	// }

	// A WinMD file has five different metadata streams.
	// The first stream is `#~`. This is also called the tables stream.
	// This is where all the functions, classes, methods, generics
	// and more are defined.
	//
	// The second stream is the `#Strings` stream. It is a heap of all
	// the names of functions, generics, parameters, methods and more.
	// The tables stream only defines the relatinships between
	// classes, methods, parameters and so on, but we need to dive into
	// the string heap to get their readable names.
	//
	// The third stream is the `#US` stream. US stands for user string.
	// The specification, however, keeps us pondering what the user string
	// heap even is for.
	//
	// The fourth stream is the `#GUID` stream. It contains all the GUIDs.
	// Shocking, I know. The GUIDs can be COM IIDs (interface IDs), for example.
	//
	// The fifth stream is the `#Blob` stream. It contains information
	// such as the signature of methods, the parameters of generics, and
	// information about marshalling of COM objects
	//
	// The streams are documented in the ECMA-335 specification.
	// https://ecma-international.org/wp-content/uploads/ECMA-335_6th_edition_june_2012.pdf
}

// get_coff_header_pos gets the offset of the COFF header inside the PE header.
// The offset of the PE header is defined by the lfanew field. We need to add
// 4 to this offset, the four bytes being the PE signature `PE\0\0`.
// See the following stack overflow post for one theory why lfanew is named lfanew
// https://stackoverflow.com/a/47711673
//
// Here is a handy overview of the entire MS DOS stub, as seen in section
// II.25.2.1 in ECMA-335.
//
// Offset:     Data:
// 0x00        | 0x4d | 0x5a | 0x90 | 0x00 | 0x03 | 0x00 | 0x00 | 0x00 |
// 0x08        | 0x04 | 0x00 | 0x00 | 0x00 | 0xFF | 0xFF | 0x00 | 0x00 |
// 0x10        | 0xb8 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 |
// 0x18        | 0x40 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 |
// 0x20        | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 |
// 0x28        | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 |
// 0x30        | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 |
// 0x38        | 0x00 | 0x00 | 0x00 | 0x00 | lfanew                    | <- lfanew at 0x3C
// 0x40        | 0x0e | 0x1f | 0xba | 0x0e | 0x00 | 0xb4 | 0x09 | 0xcd |
// 0x48        | 0x21 | 0xb8 | 0x01 | 0x4c | 0xcd | 0x21 | 0x54 | 0x68 |
// 0x50        | 0x69 | 0x73 | 0x20 | 0x70 | 0x72 | 0x6f | 0x67 | 0x72 |
// 0x58        | 0x61 | 0x6d | 0x20 | 0x63 | 0x61 | 0x6e | 0x6e | 0x6f |
// 0x60        | 0x74 | 0x20 | 0x62 | 0x65 | 0x20 | 0x72 | 0x75 | 0x6e |
// 0x68        | 0x69 | 0x20 | 0x44 | 0x4f | 0x53 | 0x20 | 0x65 | 0x6e |
// 0x70        | 0x6d | 0x6f | 0x64 | 0x65 | 0x2e | 0x0d | 0x0a | 0x00 |
// 0x78        | 0x24 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 | 0x00 |
fn get_coff_header_pos(winmd_bytes []u8) int {
	lfanew_pos := 0x3C
	// Add 4 to skip the PE\0\0 bytes
	return int(little_endian_u32_at(winmd_bytes, lfanew_pos)) + 4
}

// The optional header size is located at the 16th byte offset from the start of the COFF header,
// as described in the table below
//
// ## II.25.2.2 PE file header
//
// Immediately after the PE signature is the PE File header consisting of the following:
//
//  Offset | Size | Field | Description
//  ---- | ---- | ---- | ----
//  0 | 2 | Machine | Always 0x14c.
//  2 | 2 | Number of Sections | Number of sections; indicates size of the Section Table, which immediately follows the headers.
//  4 | 4 | Time/Date Stamp | Time and date the file was created in seconds since January 1<sup>st</sup> 1970 00:00:00 or 0.
//  8 | 4 | Pointer to Symbol Table | Always 0 (§[II.24.1](ii.24.1-fixed-fields.md)).
//  12 | 4 | Number of Symbols | Always 0 (§[II.24.1](ii.24.1-fixed-fields.md)).
//  16 | 2 | Optional Header Size | Size of the optional header, the format is described below.
//  18 | 2 | Characteristics | Flags indicating attributes of the file, see §[II.25.2.2.1](ii.25.2.2.1-characteristics.md).
fn get_opt_header_pos_and_size(winmd_bytes []u8, coff_header_pos int) (int, u16) {
	// The COFF header is 20 bytes in size, and the optional header immediately follows
	opt_header_pos := coff_header_pos + 20
	// The optional header size is either 224 for PE32, or 240 for PE32+ files
	return opt_header_pos, little_endian_u16_at(winmd_bytes, coff_header_pos + 16)
}

// get_cli_header_rva gets the relative virtual address and the size of the CLI header.
// These values are located inside the optional header. The optional header resides just after
// the COFF header, and just before the .text section. Below is an overview of the data directories
// and their offsets. The CLI header rva and size can be found at offset 208 from the start of the
// optional header.
//
// ## II.25.2.3.3 PE header data directories
//
// The optional header data directories give the address and size of several tables that appear in the sections of the PE file. Each data directory entry contains the RVA and Size of the structure it describes, in that order.
//
//  Offset | Size | Field | Description
//  ---- | ---- | ---- | ----
//  96 | 8 | Export Table | Always 0 (§[II.24.1](ii.24.1-fixed-fields.md)).
//  104 | 8 | Import Table | RVA and Size of Import Table, (§[II.25.3.1](ii.25.3.1-import-table-and-import-address-table-iat.md)).
//  112 | 8 | Resource Table | Always 0 (§[II.24.1](ii.24.1-fixed-fields.md)).
//  120 | 8 | Exception Table | Always 0 (§[II.24.1](ii.24.1-fixed-fields.md)).
//  128 | 8 | Certificate Table | Always 0 (§[II.24.1](ii.24.1-fixed-fields.md)).
//  136 | 8 | Base Relocation Table | Relocation Table; set to 0 if unused (§).
//  144 | 8 | Debug | Always 0 (§[II.24.1](ii.24.1-fixed-fields.md)).
//  152 | 8 | Copyright | Always 0 (§[II.24.1](ii.24.1-fixed-fields.md)).
//  160 | 8 | Global Ptr | Always 0 (§[II.24.1](ii.24.1-fixed-fields.md)).
//  168 | 8 | TLS Table | Always 0 (§[II.24.1](ii.24.1-fixed-fields.md)).
//  176 | 8 | Load Config Table | Always 0 (§[II.24.1](ii.24.1-fixed-fields.md)).
//  184 | 8 | Bound Import | Always 0 (§[II.24.1](ii.24.1-fixed-fields.md)).
//  192 | 8 | IAT | RVA and Size of Import Address Table, (§[II.25.3.1](ii.25.3.1-import-table-and-import-address-table-iat.md)).
//  200 | 8 | Delay Import Descriptor | Always 0 (§[II.24.1](ii.24.1-fixed-fields.md)).
//  208 | 8 | CLI Header | CLI Header with directories for runtime data, (§[II.25.3.1](ii.25.3.1-import-table-and-import-address-table-iat.md)).
//  216 | 8 | Reserved | Always 0 (§[II.24.1](ii.24.1-fixed-fields.md)).
fn get_cli_header_rva(winmd_bytes []u8, opt_header_pos int) int {
	// the cli header is located at the 208th byte in the optional header
	cli_header_rva := int(little_endian_u32_at(winmd_bytes, opt_header_pos + 208))
	// cli_header_size := little_endian_u32_at(winmd_bytes, opt_header_pos + 208 + 4)

	// println('\nDebug: CLI Header Details')
	// println('  ${cli_header_rva.hex_full()} | CLI RVA')
	// println('  ${cli_header_size.hex_full()} | CLI Size')
	return cli_header_rva
}

// From the .text section we want to get the address of the metadata root.
// Below is an overview of the contents of a section.
//
// ## II.25.3 Section headers
//
// Immediately following the optional header is the Section Table, which contains a number of section headers. This positioning is required because the file header does not contain a direct pointer to the section table; the location of the section table is determined by calculating the location of the first byte after the headers.
//
// Each section header has the following format, for a total of 40 bytes per entry:
//
//  Offset | Size | Field | Description
//  ---- | ---- | ---- | ----
//  0 | 8 | Name | An 8-byte, null-padded ASCII string. There is no terminating null if the string is exactly eight characters long.
//  8 | 4 | VirtualSize | Total size of the section in bytes. If this value is greater than SizeOfRawData, the section is zero-padded.
//  12 | 4 | VirtualAddress | For executable images this is the address of the first byte of the section, when loaded into memory, relative to the image base.
//  16 | 4 | SizeOfRawData | Size of the initialized data on disk in bytes, shall be a multiple of FileAlignment from the PE header. If this is less than VirtualSize the remainder of the section is zero filled. Because this field is rounded while the VirtualSize field is not it is possible for this to be greater than VirtualSize as well. When a section contains only uninitialized data, this field should be 0.
//  20 | 4 | PointerToRawData | Offset of section's first page within the PE file. This shall be a multiple of FileAlignment from the optional header. When a section contains only uninitialized data, this field should be 0.
//  24 | 4 | PointerToRelocations | Should be 0 (§[II.24.1](ii.24.1-fixed-fields.md)).
//  28 | 4 | PointerToLinenumbers | Should be 0 (§[II.24.1](ii.24.1-fixed-fields.md)).
//  32 | 2 | NumberOfRelocations | Should be 0 (§[II.24.1](ii.24.1-fixed-fields.md)).
//  34 | 2 | NumberOfLinenumbers | Should be 0 (§[II.24.1](ii.24.1-fixed-fields.md)).
//  36 | 4 | Characteristics | Flags describing section's characteristics; see below.
fn get_metadata_pos(winmd_bytes []u8, opt_header_pos int, opt_header_size u32) int {
	text_section_pos := opt_header_pos + int(opt_header_size)
	// The section name (.text) occupies the first 8 bytes, skip it

	// virtual means how the file is laid out in memory
	// virtual_text_section_size := little_endian_u32_at(winmd_bytes, text_section_pos + 8)
	virtual_text_section_pos := int(little_endian_u32_at(winmd_bytes, text_section_pos + 12))
	// raw means how the file is laid out physically on disk
	// raw_text_section_size := little_endian_u32_at(winmd_bytes, text_section_pos + 16)
	raw_text_section_pos := int(little_endian_u32_at(winmd_bytes, text_section_pos + 20))

	// println('Debug: Text Section Details')
	// println('  ${virtual_text_section_size.hex_full()} | Virtual Size')
	// println('  ${virtual_text_section_pos.hex_full()} | Virtual Address')
	// println('  ${raw_text_section_size.hex_full()} | Size of Raw Data')
	// println('  ${raw_text_section_pos.hex_full()} | Pointer to Raw Data')

	cli_header_rva := get_cli_header_rva(winmd_bytes, opt_header_pos)
	virtual_cli_header_pos := cli_header_rva - virtual_text_section_pos
	raw_cli_header_pos := virtual_cli_header_pos + raw_text_section_pos

	// println('\nDebug: CLI Header Conversion')
	// println('  ${virtual_cli_header_pos.hex_full()} | CLI Offset from VA')
	// println('  ${raw_cli_header_pos.hex_full()} | CLI File Offset')

	// Read metadata directory RVA from CLI header
	metadata_rva := int(little_endian_u32_at(winmd_bytes, raw_cli_header_pos + 8))
	// virtual_metadata_size := little_endian_u32_at(winmd_bytes, raw_cli_header_pos + 12)

	// println('\nDebug: Metadata Details')
	// println('  ${metadata_rva.hex_full()} | Metadata RVA')
	// println('  ${virtual_metadata_size.hex_full()} | Metadata Size')

	virtual_metadata_pos := metadata_rva - virtual_text_section_pos
	raw_metadata_pos := virtual_metadata_pos + raw_text_section_pos

	// println('\nDebug: Metadata Conversion')
	// println('  ${virtual_text_section_pos.hex_full()} | Section VA')
	// println('  ${raw_text_section_pos.hex_full()} | Section Raw')
	// println('  ${virtual_metadata_pos.hex_full()} | Metadata Offset from VA')
	// println('  ${raw_metadata_pos.hex_full()} | Final Metadata File Offset')

	return raw_metadata_pos
}

fn validate_metadata_signature(winmd_bytes []u8, metadata_pos int) ! {
	signature := little_endian_u32_at(winmd_bytes, metadata_pos)
	if signature != metadata_signature {
		return error('Invalid metadata signature. Got 0x${signature.hex_full()} but expected ${metadata_signature.hex_full()}. You need to input a winmd file, such as Windows.Win32.winmd.')
	}
}

// Metadata root layout, as from the specification:
// | Offset    | Size   | Field           | Description                                                                                       |
// |-----------|--------|-----------------|---------------------------------------------------------------------------------------------------|
// | 0         | 4      | Signature       | Magic signature for physical metadata: 0x424A5342.                                                |
// | 4         | 2      | MajorVersion    | Major version, 1 (ignore on read)                                                                 |
// | 6         | 2      | MinorVersion    | Minor version, 1 (ignore on read)                                                                 |
// | 8         | 4      | Reserved        | Reserved, always 0 (§II.24.1).                                                                    |
// | 12        | 4      | Length          | Number of bytes allocated to hold version string (including null terminator), call this x.        |
// |           |        |                 | Call the length of the string (including the terminator) m (we require m <= 255); the length x is |
// |           |        |                 | m rounded up to a multiple of four.                                                               |
// | 16        | m      | Version         | UTF8-encoded null-terminated version string of length m (see above)                               |
// | 16+m      | x−m    | Padding         | Padding to next 4 byte boundary.                                                                  |
// | 16+x      | 2      | Flags           | Reserved, always 0 (§II.24.1).                                                                    |
// | 16+x+2    | 2      | Streams         | Number of streams, say n.                                                                         |
// | 16+x+4    |        | StreamHeaders   | Array of n StreamHdr structures.                                                                  |
fn get_streams_pos(winmd_bytes []u8, metadata_pos int) int {
	version_length := little_endian_u32_at(winmd_bytes, metadata_pos + 12)
	// version_length represents the x in the table above
	streams_pos := metadata_pos + int(16 + version_length + 4)
	return streams_pos
}

// ## II.24.2.2 Stream header
//
// A stream header gives the names, and the position and length of a particular table or heap. Note that the length of a Stream header structure is not fixed, but depends on the length of its name field (a variable length null-terminated string).
//
//  Offset | Size | Field | Description
//  ---- | ---- | ---- | ----
//  0 | 4 | **Offset** | Memory offset to start of this stream from start of the metadata root (§[II.24.2.1](ii.24.2.1-metadata-root.md))
//  4 | 4 | **Size** | Size of this stream in bytes, shall be a multiple of 4.
//  8 | &nbsp; | **Name** | Name of the stream as null-terminated variable length array of ASCII characters, padded to the next 4-byte boundary with `\0` characters. The name is limited to 32 characters.
fn get_streams(winmd_bytes []u8, streams_pos int, metadata_pos int) Streams {
	tables_stream_pos := little_endian_u16_at(winmd_bytes, streams_pos) + metadata_pos
	tables_stream_size := little_endian_u16_at(winmd_bytes, streams_pos + 4)
	tables_stream_name_size := 4

	strings_stream_offset := streams_pos + 8 + tables_stream_name_size
	strings_stream_pos := little_endian_u16_at(winmd_bytes, strings_stream_offset) + metadata_pos
	strings_stream_size := little_endian_u16_at(winmd_bytes, strings_stream_offset + 4)
	strings_stream_name_size := 12

	// The #~ stream name occupies 12 bytes
	us_stream_offset := strings_stream_offset + 8 + strings_stream_name_size
	us_stream_pos := little_endian_u16_at(winmd_bytes, us_stream_offset) + metadata_pos
	us_stream_size := little_endian_u16_at(winmd_bytes, us_stream_offset + 4)
	us_stream_name_size := 4

	guid_stream_offset := us_stream_offset + 8 + us_stream_name_size
	guid_stream_pos := little_endian_u16_at(winmd_bytes, guid_stream_offset) + metadata_pos
	guid_stream_size := little_endian_u16_at(winmd_bytes, guid_stream_offset + 4)
	guid_stream_name_size := 8

	blob_stream_offset := guid_stream_offset + 8 + guid_stream_name_size
	blob_stream_pos := little_endian_u16_at(winmd_bytes, blob_stream_offset) + metadata_pos
	blob_stream_size := little_endian_u16_at(winmd_bytes, blob_stream_offset + 4)

	// println('Debug: Streams')
	// println('  ${streams_pos.hex_full()} | Streams pos')
	// println('  ${tables_stream_pos.hex_full()} | #~ pos')
	// println('  ${tables_stream_size.hex_full()} | #~ size')
	// println('  ${strings_stream_pos.hex_full()} | #Strings pos')
	// println('  ${strings_stream_size.hex_full()} | #Strings size')
	// println('  ${us_stream_pos.hex_full()} | #US pos')
	// println('  ${us_stream_size.hex_full()} | #US size')
	// println('  ${guid_stream_pos.hex_full()} | #GUID pos')
	// println('  ${guid_stream_size.hex_full()} | #GUID size')
	// println('  ${blob_stream_pos.hex_full()} | #Blob pos')
	// println('  ${blob_stream_size.hex_full()} | #Blob size')

	return Streams{
		tables:  Stream{
			name: '#~'
			pos:  tables_stream_pos
			size: tables_stream_size
		}
		strings: Stream{
			name: '#Strings'
			pos:  strings_stream_pos
			size: strings_stream_size
		}
		us:      Stream{
			name: '#US'
			pos:  us_stream_pos
			size: us_stream_size
		}
		guid:    Stream{
			name: '#GUID'
			pos:  guid_stream_pos
			size: guid_stream_size
		}
		blob:    Stream{
			name: '#Blob'
			pos:  blob_stream_pos
			size: blob_stream_size
		}
	}
}

struct Streams {
pub:
	tables  Stream
	strings Stream
	us      Stream
	guid    Stream
	blob    Stream
}

struct Stream {
	name string
mut:
	// The absolute offset of the stream. When reading the stream position from the stream header,
	// we get the position relative to the metadata root. This means if we want to get values
	// from the string stream using winmd_bytes, we have to constantly add the metadata root position to all calculations.
	// The metadata root position is therefore added to this field once so we don't have to do it again and again.
	pos int
	// How many bytes does this stream occupy?
	size u32
}

struct TablesStream {
	winmd_bytes   []u8
	tables_stream Stream
	// While the pos inside tables_stream points to the start
	// of the table stream describing the version, sorted tables, present tables,
	// number of rows per table and so on, tables_pos points directly to the starting
	// address of the first table
	tables_pos int
pub:
	heap_sizes     HeapSizeFlags
	present_tables TableFlags
	sorted_tables  TableFlags
	num_rows       map[TableFlags]u32
}

fn (s TablesStream) get_pos(table TableFlags) int {
	mut pos := s.tables_pos

	println('At position: ${pos}')
	if table == .module {
		println('.module pos: ${pos}')
		return pos
	}
	println('Skipped .module, Adding ${s.num_rows[.module]} * ${Module.row_size(s)} to ${pos}')
	pos += int(s.num_rows[.module] * Module.row_size(s))
	if table == .type_ref {
		println('.type_ref pos: ${pos}')
		return pos
	}
	println('Skpped .type_ref, Adding ${s.num_rows[.type_ref]} * ${TypeRef.row_size(s)} to ${pos}')
	pos += int(s.num_rows[.type_ref] * TypeRef.row_size(s))
	if table == .type_def {
		println('.type_def pos: ${pos}')
		return pos
	}
	println('Skpped .type_def, Adding ${s.num_rows[.type_def]} * ${TypeDef.row_size(s)} to ${pos}')
	pos += int(s.num_rows[.type_def] * TypeDef.row_size(s))
	// pos += int(s.num_rows[.field_ptr] * FieldPtr.row_size(s))
	if table == .field {
		println('.field pos: ${pos}')
		return pos
	}
	println('Skpped .field, Adding ${s.num_rows[.field]} * ${Field.row_size(s)} to ${pos}')
	pos += int(s.num_rows[.field] * Field.row_size(s))
	// pos += int(s.num_rows[.method_ptr] * MethodPtr.row_size(s))
	if table == .method_def {
		println('.method_def pos: ${pos}')
		return pos
	}
	println('Skpped .method_def, Adding ${s.num_rows[.method_def]} * ${MethodDef.row_size(s)} to ${pos}')
	pos += int(s.num_rows[.method_def] * MethodDef.row_size(s))
	// pos += int(s.num_rows[.param_ptr] * ParamPtr.row_size(s))
	if table == .param {
		println('.param pos: ${pos}')
		return pos
	}
	println('Skpped .param, Adding ${s.num_rows[.param]} * ${Param.row_size(s)} to ${pos}')
	pos += int(s.num_rows[.param] * Param.row_size(s))
	if table == .interface_impl {
		println('.interface_impl pos: ${pos}')
		return pos
	}
	println('Skpped .interface_impl, Adding ${s.num_rows[.interface_impl]} * ${InterfaceImpl.row_size(s)} to ${pos}')
	pos += int(s.num_rows[.interface_impl] * InterfaceImpl.row_size(s))
	if table == .member_ref {
		println('.member_ref pos: ${pos}')
		return pos
	}
	println('Skpped .member_ref, Adding ${s.num_rows[.member_ref]} * ${MemberRef.row_size(s)} to ${pos}')
	pos += int(s.num_rows[.member_ref] * MemberRef.row_size(s))
	if table == .constant {
		println('.constant pos: ${pos}')
		return pos
	}
	println('Skpped .constant, Adding ${s.num_rows[.constant]} * ${Constant.row_size(s)} to ${pos}')
	pos += int(s.num_rows[.constant] * Constant.row_size(s))
	if table == .custom_attribute {
		println('.custom_attribute pos: ${pos}')
		return pos
	}
	println('Skpped .custom_attribute, Adding ${s.num_rows[.custom_attribute]} * ${CustomAttribute.row_size(s)} to ${pos}')
	pos += int(s.num_rows[.custom_attribute] * CustomAttribute.row_size(s))
	if table == .field_marshal {
		println('.field_marshal pos: ${pos}')
		return pos
	}
	println('Skpped .field_marshal, Adding ${s.num_rows[.field_marshal]} * ${FieldMarshal.row_size(s)} to ${pos}')
	pos += int(s.num_rows[.field_marshal] * FieldMarshal.row_size(s))
	if table == .decl_security {
		println('.decl_security pos: ${pos}')
		return pos
	}
	println('Skpped .decl_security, Adding ${s.num_rows[.decl_security]} * ${DeclSecurity.row_size(s)} to ${pos}')
	pos += int(s.num_rows[.decl_security] * DeclSecurity.row_size(s))
	if table == .class_layout {
		println('.class_layout pos: ${pos}')
		return pos
	}
	println('Skpped .class_layout, Adding ${s.num_rows[.class_layout]} * ${ClassLayout.row_size(s)} to ${pos}')
	pos += int(s.num_rows[.class_layout] * ClassLayout.row_size(s))
	if table == .field_layout {
		println('.field_layout pos: ${pos}')
		return pos
	}
	println('Skpped .field_layout, Adding ${s.num_rows[.field_layout]} * ${FieldLayout.row_size(s)} to ${pos}')
	pos += int(s.num_rows[.field_layout] * FieldLayout.row_size(s))
	if table == .stand_alone_sig {
		println('.stand_alone_sig pos: ${pos}')
		return pos
	}
	println('Skpped .stand_alone_sig, Adding ${s.num_rows[.stand_alone_sig]} * ${StandAloneSig.row_size(s)} to ${pos}')
	pos += int(s.num_rows[.stand_alone_sig] * StandAloneSig.row_size(s))
	if table == .event_map {
		println('.event_map pos: ${pos}')
		return pos
	}
	println('Skpped .event_map, Adding ${s.num_rows[.event_map]} * ${EventMap.row_size(s)} to ${pos}')
	pos += int(s.num_rows[.event_map] * EventMap.row_size(s))
	// pos += int(s.num_rows[.event_ptr] * EventPtr.row_size(s))
	if table == .event {
		println('.event pos: ${pos}')
		return pos
	}
	println('Skpped .event, Adding ${s.num_rows[.event]} * ${Event.row_size(s)} to ${pos}')
	pos += int(s.num_rows[.event] * Event.row_size(s))
	if table == .property_map {
		println('.property_map pos: ${pos}')
		return pos
	}
	println('Skpped .property_map, Adding ${s.num_rows[.property_map]} * ${PropertyMap.row_size(s)} to ${pos}')
	pos += int(s.num_rows[.property_map] * PropertyMap.row_size(s))
	// pos += int(s.num_rows[.property_ptr] * PropertyPtr.row_size(s))
	if table == .property {
		println('.property pos: ${pos}')
		return pos
	}
	println('Skpped .property, Adding ${s.num_rows[.property]} * ${Property.row_size(s)} to ${pos}')
	pos += int(s.num_rows[.property] * Property.row_size(s))
	if table == .method_semantics {
		println('.method_semantics pos: ${pos}')
		return pos
	}
	println('Skpped .method_semantics, Adding ${s.num_rows[.method_semantics]} * ${MethodSemantics.row_size(s)} to ${pos}')
	pos += int(s.num_rows[.method_semantics] * MethodSemantics.row_size(s))
	if table == .method_impl {
		println('.method_impl pos: ${pos}')
		return pos
	}
	println('Skpped .method_impl, Adding ${s.num_rows[.method_impl]} * ${MethodImpl.row_size(s)} to ${pos}')
	pos += int(s.num_rows[.method_impl] * MethodImpl.row_size(s))
	if table == .module_ref {
		println('.module_ref pos: ${pos}')
		return pos
	}
	println('Skpped .module_ref, Adding ${s.num_rows[.module_ref]} * ${ModuleRef.row_size(s)} to ${pos}')
	pos += int(s.num_rows[.module_ref] * ModuleRef.row_size(s))
	if table == .type_spec {
		println('.type_spec pos: ${pos}')
		return pos
	}
	println('Skpped .type_spec, Adding ${s.num_rows[.type_spec]} * ${TypeSpec.row_size(s)} to ${pos}')
	pos += int(s.num_rows[.type_spec] * TypeSpec.row_size(s))
	if table == .impl_map {
		println('.impl_map pos: ${pos}')
		return pos
	}
	println('Skpped .impl_map, Adding ${s.num_rows[.impl_map]} * ${ImplMap.row_size(s)} to ${pos}')
	pos += int(s.num_rows[.impl_map] * ImplMap.row_size(s))
	if table == .field_rva {
		println('.field_rva pos: ${pos}')
		return pos
	}
	println('Skpped .field_rva, Adding ${s.num_rows[.field_rva]} * ${FieldRVA.row_size(s)} to ${pos}')
	pos += int(s.num_rows[.field_rva] * FieldRVA.row_size(s))
	// pos += int(s.num_rows[.enc_lg] * EncLg.row_size(s))
	// pos += int(s.num_rows[.enc_map] * EncMap.row_size(s))
	if table == .assembly {
		println('.assembly pos: ${pos}')
		return pos
	}
	println('Skpped .assembly, Adding ${s.num_rows[.assembly]} * ${Assembly.row_size(s)} to ${pos}')
	pos += int(s.num_rows[.assembly] * Assembly.row_size(s))
	if table == .assembly_processor {
		println('.assembly_processor pos: ${pos}')
		return pos
	}
	println('Skpped .assembly_processor, Adding ${s.num_rows[.assembly_processor]} * ${AssemblyProcessor.row_size(s)} to ${pos}')
	pos += int(s.num_rows[.assembly_processor] * AssemblyProcessor.row_size(s))
	if table == .assembly_os {
		println('.assembly_os pos: ${pos}')
		return pos
	}
	println('Skpped .assembly_os, Adding ${s.num_rows[.assembly_os]} * ${AssemblyOS.row_size(s)} to ${pos}')
	pos += int(s.num_rows[.assembly_os] * AssemblyOS.row_size(s))
	if table == .assembly_ref {
		println('.assembly_ref pos: ${pos}')
		return pos
	}
	println('Skpped .assembly_ref, Adding ${s.num_rows[.assembly_ref]} * ${AssemblyRef.row_size(s)} to ${pos}')
	pos += int(s.num_rows[.assembly_ref] * AssemblyRef.row_size(s))
	if table == .assembly_ref_processor {
		println('.assembly_ref_processor pos: ${pos}')
		return pos
	}
	println('Skpped .assembly_ref_processor, Adding ${s.num_rows[.assembly_ref_processor]} * ${AssemblyRefProcessor.row_size(s)} to ${pos}')
	pos += int(s.num_rows[.assembly_ref_processor] * AssemblyRefProcessor.row_size(s))
	if table == .assembly_ref_os {
		println('.assembly_ref_os pos: ${pos}')
		return pos
	}
	println('Skpped .assembly_ref_os, Adding ${s.num_rows[.assembly_ref_os]} * ${AssemblyRefOS.row_size(s)} to ${pos}')
	pos += int(s.num_rows[.assembly_ref_os] * AssemblyRefOS.row_size(s))
	if table == .file {
		println('.file pos: ${pos}')
		return pos
	}
	println('Skpped .file, Adding ${s.num_rows[.file]} * ${File.row_size(s)} to ${pos}')
	pos += int(s.num_rows[.file] * File.row_size(s))
	if table == .exported_type {
		println('.exported_type pos: ${pos}')
		return pos
	}
	println('Skpped .exported_type, Adding ${s.num_rows[.exported_type]} * ${ExportedType.row_size(s)} to ${pos}')
	pos += int(s.num_rows[.exported_type] * ExportedType.row_size(s))
	if table == .manifest_resource {
		println('.manifest_resource pos: ${pos}')
		return pos
	}
	println('Skpped .manifest_resource, Adding ${s.num_rows[.manifest_resource]} * ${ManifestResource.row_size(s)} to ${pos}')
	pos += int(s.num_rows[.manifest_resource] * ManifestResource.row_size(s))
	if table == .nested_class {
		println('.nested_class pos: ${pos}')
		return pos
	}
	println('Skpped .nested_class, Adding ${s.num_rows[.nested_class]} * ${NestedClass.row_size(s)} to ${pos}')
	pos += int(s.num_rows[.nested_class] * NestedClass.row_size(s))
	if table == .generic_param {
		println('.generic_param pos: ${pos}')
		return pos
	}
	println('Skpped .generic_param, Adding ${s.num_rows[.generic_param]} * ${GenericParam.row_size(s)} to ${pos}')
	pos += int(s.num_rows[.generic_param] * GenericParam.row_size(s))
	if table == .method_spec {
		println('.method_spec pos: ${pos}')
		return pos
	}
	println('Skpped .method_spec, Adding ${s.num_rows[.method_spec]} * ${MethodSpec.row_size(s)} to ${pos}')
	pos += int(s.num_rows[.method_spec] * MethodSpec.row_size(s))
	if table == .generic_param_constraint {
		println('.generic_param_constraint pos: ${pos}')
		return pos
	}
	pos += int(s.num_rows[.generic_param_constraint] * GenericParamConstraint.row_size(s))
	return pos
}

fn (s TablesStream) get_type_ref_table() []TypeRef {
	mut type_refs := []TypeRef{}
	mut pos := s.get_pos(.type_ref)

	println('TypeRef table rows: ${s.num_rows[.type_ref]}')
	println('TypeRef table row size: ${TypeRef.row_size(s)}')

	for i in 1 .. s.num_rows[.type_ref] {
		offset := pos

		coded_resolution_scope := if get_resolution_scope_size(s) == 4 {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			u32(little_endian_u16_at(s.winmd_bytes, pos - 2))
		}
		resolution_scope := decode_resolution_scope(coded_resolution_scope)

		name := if s.heap_sizes.has(.strings) {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			little_endian_u16_at(s.winmd_bytes, pos - 2)
		}
		// println('Got name index ${name.hex_full()}')
		// println('Resolved into name ${name}')

		namespace := if s.heap_sizes.has(.strings) {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			little_endian_u16_at(s.winmd_bytes, pos - 2)
		}

		type_refs << TypeRef{
			rid:              i
			token:            u32(Tables.type_ref) << 24 + i
			offset:           offset
			resolution_scope: resolution_scope
			name:             name
			namespace:        namespace
		}
	}

	return type_refs
}

fn (s TablesStream) get_type_def_table() []TypeDef {
	mut type_defs := []TypeDef{}

	mut pos := s.get_pos(.type_def)
	num_rows := s.num_rows[.type_def]

	println('TypeDef table rows: ${num_rows}')
	println('TypeDef table row size: ${TypeDef.row_size(s)}')

	for i in 1 .. num_rows {
		offset := pos
		// println("")
		// println("${(u32(Tables.type_def) << 24 + i).hex_full()} at ${pos.hex_full()}")
		// println("|   FLG    | NAM | NS  | BAS | FIE | MET ")
		// println("${s.winmd_bytes[pos].hex()} ${s.winmd_bytes[pos+1].hex()} ${s.winmd_bytes[pos+2].hex()} ${s.winmd_bytes[pos+3].hex()} ${s.winmd_bytes[pos+4].hex()} ${s.winmd_bytes[pos+5].hex()} ${s.winmd_bytes[pos+6].hex()} ${s.winmd_bytes[pos+7].hex()} ${s.winmd_bytes[pos+8].hex()} ${s.winmd_bytes[pos+9].hex()} ${s.winmd_bytes[pos+10].hex()} ${s.winmd_bytes[pos+11].hex()} ${s.winmd_bytes[pos+12].hex()} ${s.winmd_bytes[pos+13].hex()}")

		flags := little_endian_u32_at(s.winmd_bytes, pos)
		pos += 4

		name := if s.heap_sizes.has(.strings) {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			little_endian_u16_at(s.winmd_bytes, pos - 2)
		}

		namespace := if s.heap_sizes.has(.strings) {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			little_endian_u16_at(s.winmd_bytes, pos - 2)
		}

		base_type := if get_resolution_scope_size(s) == 4 {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			little_endian_u16_at(s.winmd_bytes, pos - 2)
		}

		field_list := if get_resolution_scope_size(s) == 4 {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			little_endian_u16_at(s.winmd_bytes, pos - 2)
		}

		method_list := if s.num_rows[.method_def] > 0xFFFF {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			little_endian_u16_at(s.winmd_bytes, pos - 2)
		}

		type_defs << TypeDef{
			rid:         i
			token:       u32(Tables.type_def) << 24 + i
			offset:      offset
			flags:       flags
			name:        name
			namespace:   namespace
			base_type:   base_type
			field_list:  field_list
			method_list: method_list
		}
	}

	return type_defs
}

fn (s TablesStream) get_field_table() []Field {
	mut fields := []Field{}

	mut pos := s.get_pos(.field)
	num_rows := s.num_rows[.field]

	println('Starting from ${pos.hex_full()}')

	println('Field table rows: ${num_rows}')
	println('Field table row size: ${Field.row_size(s)}')

	for i in 1 .. num_rows {
		offset := pos
		// println("")
		// println("${(u32(Tables.field) << 24 + i).hex_full()} at ${pos.hex_full()}")
		// println("| FLG | NAM | SIG")
		// println("${s.winmd_bytes[pos].hex()} ${s.winmd_bytes[pos+1].hex()} ${s.winmd_bytes[pos+2].hex()} ${s.winmd_bytes[pos+3].hex()} ${s.winmd_bytes[pos+4].hex()} ${s.winmd_bytes[pos+5].hex()} ${s.winmd_bytes[pos+6].hex()} ${s.winmd_bytes[pos+7].hex()} ${s.winmd_bytes[pos+8].hex()} ${s.winmd_bytes[pos+9].hex()} ${s.winmd_bytes[pos+10].hex()}")

		flags := little_endian_u32_at(s.winmd_bytes, pos)
		pos += 2

		name := if s.heap_sizes.has(.strings) {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			little_endian_u16_at(s.winmd_bytes, pos - 2)
		}

		signature := if s.heap_sizes.has(.blob) {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			little_endian_u16_at(s.winmd_bytes, pos - 2)
		}

		fields << Field{
			rid:       i
			token:     u32(Tables.field) << 24 + i
			offset:    offset
			flags:     flags
			name:      name
			signature: signature
		}
	}

	return fields
}

fn (s TablesStream) get_method_def_table() []MethodDef {
	mut method_defs := []MethodDef{}

	mut pos := s.get_pos(.method_def)
	num_rows := s.num_rows[.method_def]

	println('MethodDef table rows: ${num_rows}')
	println('MethodDef table row size: ${MethodDef.row_size(s)}')

	for i in 1 .. num_rows {
		offset := pos

		rva := little_endian_u32_at(s.winmd_bytes, pos)
		pos += 4

		impl_flags := u32(little_endian_u16_at(s.winmd_bytes, pos))
		pos += 2

		flags := u32(little_endian_u16_at(s.winmd_bytes, pos))
		pos += 2

		name := if s.heap_sizes.has(.strings) {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			little_endian_u16_at(s.winmd_bytes, pos - 2)
		}

		signature := if s.heap_sizes.has(.blob) {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			little_endian_u16_at(s.winmd_bytes, pos - 2)
		}

		params_list := if s.num_rows[.param] > 0xFFFF {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			little_endian_u16_at(s.winmd_bytes, pos - 2)
		}

		method_defs << MethodDef{
			rid:        i
			token:      u32(Tables.method_def) << 24 + i
			offset:     offset
			flags:      flags
			impl_flags: impl_flags
			rva:        rva
			name:       name
			signature:  signature
			param_list: params_list
		}
	}

	return method_defs
}

fn (s TablesStream) get_param_table() []Param {
	mut params := []Param{}

	mut pos := s.get_pos(.param)
	num_rows := s.num_rows[.param]

	println('Param table rows: ${num_rows}')
	println('Param table row size: ${Param.row_size(s)}')

	for i in 1 .. num_rows {
		offset := pos
		// if i < 100 {
		// 	println('')
		// 	println('${(u32(Tables.param) << 24 + i).hex_full()} at ${pos.hex_full()}')
		// 	println('FLG | SEQ | NAM')
		// 	// vfmt off
		// 	println("${s.winmd_bytes[pos].hex()} ${s.winmd_bytes[pos+1].hex()} ${s.winmd_bytes[pos+2].hex()} ${s.winmd_bytes[pos+3].hex()} ${s.winmd_bytes[pos+4].hex()} ${s.winmd_bytes[pos+5].hex()}")
		// 	// vfmt on
		// }

		sequence := u32(little_endian_u16_at(s.winmd_bytes, pos - 2))
		pos += 2

		flags := little_endian_u32_at(s.winmd_bytes, pos)
		pos += 2

		name := if s.heap_sizes.has(.strings) {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			little_endian_u16_at(s.winmd_bytes, pos - 2)
		}

		params << Param{
			rid:      i
			token:    u32(Tables.param) << 24 + i
			offset:   offset
			flags:    flags
			name:     name
			sequence: sequence
		}
	}

	return params
}

fn (s TablesStream) get_interface_impl_table() []InterfaceImpl {
	mut interface_impls := []InterfaceImpl{}

	mut pos := s.get_pos(.interface_impl)
	num_rows := s.num_rows[.interface_impl]

	println('InterfaceImpl table rows: ${num_rows}')
	println('InterfaceImpl table row size: ${InterfaceImpl.row_size(s)}')

	for i in 1 .. num_rows {
		offset := pos
		println('')
		println('${(u32(Tables.interface_impl) << 24 + i).hex_full()} at ${pos.hex_full()}')
		println('CLS | INF')
		// vfmt on
		println('${s.winmd_bytes[pos].hex()} ${s.winmd_bytes[pos + 1].hex()} ${s.winmd_bytes[pos + 2].hex()} ${s.winmd_bytes[
			pos + 3].hex()}')
		// vfmt off

		class := if s.num_rows[.type_def] > 0xFFFF {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			little_endian_u16_at(s.winmd_bytes, pos - 2)
		}

		coded_interface := if get_type_def_or_ref_size(s) == 4 {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			little_endian_u16_at(s.winmd_bytes, pos - 2)
		}
		@interface := decode_type_def_or_ref(coded_interface)
		println(@interface.hex_full())

		interface_impls << InterfaceImpl{
			rid:       i
			token:     u32(Tables.interface_impl) << 24 + i
			offset:    offset
			class:     class
			interface: @interface
		}
	}

	return interface_impls
}

fn (s TablesStream) get_member_ref_table() []MemberRef {
	mut member_refs := []MemberRef{}

	mut pos := s.get_pos(.member_ref)
	num_rows := s.num_rows[.member_ref]

	println('MemberRef table rows: ${num_rows}')
	println('MemberRef table row size: ${MemberRef.row_size(s)}')

	for i in 1 .. num_rows {
		offset := pos
		// if i < 10 {
		// 	println('')
		// 	println('${(u32(Tables.member_ref) << 24 + i).hex_full()} at ${pos.hex_full()}')
		// 	println('PAR | NAM | SIG')
		// 	// vfmt off
		// 	println('${s.winmd_bytes[pos].hex()} ${s.winmd_bytes[pos + 1].hex()} ${s.winmd_bytes[pos + 2].hex()} ${s.winmd_bytes[pos + 3].hex()} ${s.winmd_bytes[pos + 4].hex()} ${s.winmd_bytes[pos + 5].hex()}')
		// 	// vfmt on
		// }

		coded_parent := if get_member_ref_parent_size(s) == 4 {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			little_endian_u16_at(s.winmd_bytes, pos - 2)
		}
		parent := decode_member_ref_parent(coded_parent)

		name := if s.heap_sizes.has(.strings) {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			little_endian_u16_at(s.winmd_bytes, pos - 2)
		}

		signature := if s.heap_sizes.has(.blob) {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			little_endian_u16_at(s.winmd_bytes, pos - 2)
		}

		member_refs << MemberRef{
			rid:       i
			token:     u32(Tables.member_ref) << 24 + i
			offset:    offset
			parent:    parent
			name:      name
			signature: signature
		}
	}

	return member_refs
}

fn (s TablesStream) get_constant_table() []Constant {
	mut constants := []Constant{}

	mut pos := s.get_pos(.constant)
	num_rows := s.num_rows[.constant]

	for i in 1 .. num_rows {
		offset := pos

		// For constants, the type is always 2 bytes
		type := u32(little_endian_u16_at(s.winmd_bytes, pos))
		pos += 2

		coded_parent := if get_has_constant_size(s) == 4 {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			u32(little_endian_u16_at(s.winmd_bytes, pos - 2))
		}
		parent := decode_has_constant(coded_parent)

		value := if s.heap_sizes.has(.strings) {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			u32(little_endian_u16_at(s.winmd_bytes, pos - 2))
		}

		constants << Constant{
			rid:    i
			token:  u32(Tables.constant) << 24 + i
			offset: offset
			type:   type
			parent: parent
			value:  value
		}
	}

	return constants
}

fn (s TablesStream) get_custom_attribute_table() []CustomAttribute {
	mut custom_attributes := []CustomAttribute{}

	mut pos := s.get_pos(.custom_attribute)
	num_rows := s.num_rows[.custom_attribute]

	for i in 1 .. num_rows {
		offset := pos
		if i < 10 {
			println('')
			println('${(u32(Tables.member_ref) << 24 + i).hex_full()} at ${pos.hex_full()}')
			println('PAR | CON | VAL')
			// vfmt off
			println('${s.winmd_bytes[pos].hex()} ${s.winmd_bytes[pos + 1].hex()} ${s.winmd_bytes[pos + 2].hex()} ${s.winmd_bytes[pos + 3].hex()} ${s.winmd_bytes[pos + 4].hex()} ${s.winmd_bytes[pos + 5].hex()}')
			// vfmt on
		}

		coded_parent := if get_has_custom_attribute_size(s) == 4 {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			u32(little_endian_u16_at(s.winmd_bytes, pos - 2))
		}
		parent := decode_has_custom_attribute(coded_parent)

		coded_constructor := if get_custom_attribute_type_size(s) == 4 {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			u32(little_endian_u16_at(s.winmd_bytes, pos - 2))
		}
		constructor := decode_custom_attribute_type(coded_constructor)

		value := if s.heap_sizes.has(.blob) {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			u32(little_endian_u16_at(s.winmd_bytes, pos - 2))
		}

		custom_attributes << CustomAttribute{
			rid:         i
			token:       u32(Tables.custom_attribute) << 24 + i
			offset:      offset
			parent:      parent
			constructor: constructor
			value:       value
		}
	}

	return custom_attributes
}

// TODO: FieldMarshal

// TODO: DeclSecurity

fn (s TablesStream) get_class_layout_table() []ClassLayout {
	mut class_layouts := []ClassLayout{}

	mut pos := s.get_pos(.class_layout)
	num_rows := s.num_rows[.class_layout]

	for i in 1 .. num_rows {
		offset := pos
		if i < 10 {
			println('')
			println('${(u32(Tables.member_ref) << 24 + i).hex_full()} at ${pos.hex_full()}')
			println('PAR | CON | VAL')
			// vfmt off
			println('${s.winmd_bytes[pos].hex()} ${s.winmd_bytes[pos + 1].hex()} ${s.winmd_bytes[pos + 2].hex()} ${s.winmd_bytes[pos + 3].hex()} ${s.winmd_bytes[pos + 4].hex()} ${s.winmd_bytes[pos + 5].hex()}')
			// vfmt on
		}

		class_size := little_endian_u32_at(s.winmd_bytes, pos)
		pos += 4

		packing_size := little_endian_u16_at(s.winmd_bytes, pos)
		pos += 2

		parent := if s.num_rows[.type_def] > 0xFFFF {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			u32(little_endian_u16_at(s.winmd_bytes, pos - 2))
		}

		class_layouts << ClassLayout{
			rid:          i
			token:        u32(Tables.class_layout) << 24 + i
			offset:       offset
			class_size:   class_size
			packing_size: packing_size
			parent:       parent
		}
	}

	return class_layouts
}

fn (s TablesStream) get_field_layout_table() []FieldLayout {
	mut field_layouts := []FieldLayout{}

	mut pos := s.get_pos(.field_layout)
	num_rows := s.num_rows[.field_layout]

	for i in 1 .. num_rows {
		offset := pos
		if i < 10 {
			println('')
			println('${(u32(Tables.member_ref) << 24 + i).hex_full()} at ${pos.hex_full()}')
			println('PAR | CON | VAL')
			// vfmt off
			println('${s.winmd_bytes[pos].hex()} ${s.winmd_bytes[pos + 1].hex()} ${s.winmd_bytes[pos + 2].hex()} ${s.winmd_bytes[pos + 3].hex()} ${s.winmd_bytes[pos + 4].hex()} ${s.winmd_bytes[pos + 5].hex()}')
			// vfmt on
		}

		field_offset := little_endian_u16_at(s.winmd_bytes, pos)
		pos += 4

		field := if s.num_rows[.field] > 0xFFFF {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			u32(little_endian_u16_at(s.winmd_bytes, pos - 2))
		}

		field_layouts << FieldLayout{
			rid:          i
			token:        u32(Tables.field_layout) << 24 + i
			offset:       offset
			field:        field
			field_offset: field_offset
		}
	}

	return field_layouts
}

// TODO: StandAloneSig

// TODO: EventMap

// TODO: Event

fn (s TablesStream) get_property_map_table() []PropertyMap {
	mut property_maps := []PropertyMap{}

	mut pos := s.get_pos(.property_map)
	num_rows := s.num_rows[.property_map]

	for i in 1 .. num_rows {
		offset := pos
		if i < 10 {
			println('')
			println('${(u32(Tables.member_ref) << 24 + i).hex_full()} at ${pos.hex_full()}')
			println('PAR | CON | VAL')
			// vfmt off
			println('${s.winmd_bytes[pos].hex()} ${s.winmd_bytes[pos + 1].hex()} ${s.winmd_bytes[pos + 2].hex()} ${s.winmd_bytes[pos + 3].hex()} ${s.winmd_bytes[pos + 4].hex()} ${s.winmd_bytes[pos + 5].hex()}')
			// vfmt on
		}

		parent := if s.num_rows[.type_def] > 0xFFFF {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			u32(little_endian_u16_at(s.winmd_bytes, pos - 2))
		}

		property_list := if s.num_rows[.property] > 0xFFFF {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			u32(little_endian_u16_at(s.winmd_bytes, pos - 2))
		}

		property_maps << PropertyMap{
			rid:           i
			token:         u32(Tables.property_map) << 24 + i
			offset:        offset
			parent:        parent
			property_list: property_list
		}
	}

	return property_maps
}

fn (s TablesStream) get_property_table() []Property {
	mut properties := []Property{}

	mut pos := s.get_pos(.property)
	num_rows := s.num_rows[.property]

	for i in 1 .. num_rows {
		offset := pos
		if i < 10 {
			println('')
			println('${(u32(Tables.member_ref) << 24 + i).hex_full()} at ${pos.hex_full()}')
			println('PAR | CON | VAL')
			// vfmt off
			println('${s.winmd_bytes[pos].hex()} ${s.winmd_bytes[pos + 1].hex()} ${s.winmd_bytes[pos + 2].hex()} ${s.winmd_bytes[pos + 3].hex()} ${s.winmd_bytes[pos + 4].hex()} ${s.winmd_bytes[pos + 5].hex()}')
			// vfmt on
		}

		flags := u32(little_endian_u16_at(s.winmd_bytes, pos))
		pos += 2

		name := if s.heap_sizes.has(.strings) {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			u32(little_endian_u16_at(s.winmd_bytes, pos - 2))
		}

		signature := if s.heap_sizes.has(.blob) {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			u32(little_endian_u16_at(s.winmd_bytes, pos - 2))
		}

		properties << Property{
			rid:       i
			token:     u32(Tables.property) << 24 + i
			offset:    offset
			flags:     flags
			name:      name
			signature: signature
		}
	}

	return properties
}

fn (s TablesStream) get_method_semantics_table() []MethodSemantics {
	mut method_semantics := []MethodSemantics{}

	mut pos := s.get_pos(.method_semantics)
	num_rows := s.num_rows[.method_semantics]

	for i in 1 .. num_rows {
		offset := pos
		if i < 10 {
			println('')
			println('${(u32(Tables.member_ref) << 24 + i).hex_full()} at ${pos.hex_full()}')
			println('PAR | CON | VAL')
			// vfmt off
			println('${s.winmd_bytes[pos].hex()} ${s.winmd_bytes[pos + 1].hex()} ${s.winmd_bytes[pos + 2].hex()} ${s.winmd_bytes[pos + 3].hex()} ${s.winmd_bytes[pos + 4].hex()} ${s.winmd_bytes[pos + 5].hex()}')
			// vfmt on
		}

		semantics := u32(little_endian_u16_at(s.winmd_bytes, pos))
		pos += 2

		method := if s.num_rows[.method_def] > 0xFFFF {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			u32(little_endian_u16_at(s.winmd_bytes, pos - 2))
		}

		coded_association := if get_has_semantics_size(s) == 4 {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			u32(little_endian_u16_at(s.winmd_bytes, pos - 2))
		}
		association := decode_has_semantics(coded_association)

		method_semantics << MethodSemantics{
			rid:         i
			token:       u32(Tables.method_semantics) << 24 + i
			offset:      offset
			semantics:   semantics
			method:      method
			association: association
		}
	}

	return method_semantics
}

fn (s TablesStream) get_method_impl_table() []MethodImpl {
	mut method_impls := []MethodImpl{}

	mut pos := s.get_pos(.method_impl)
	num_rows := s.num_rows[.method_impl]

	for i in 1 .. num_rows {
		offset := pos
		if i < 10 {
			println('')
			println('${(u32(Tables.member_ref) << 24 + i).hex_full()} at ${pos.hex_full()}')
			println('PAR | CON | VAL')
			// vfmt off
			println('${s.winmd_bytes[pos].hex()} ${s.winmd_bytes[pos + 1].hex()} ${s.winmd_bytes[pos + 2].hex()} ${s.winmd_bytes[pos + 3].hex()} ${s.winmd_bytes[pos + 4].hex()} ${s.winmd_bytes[pos + 5].hex()}')
			// vfmt on
		}

		method_declaration := if get_method_def_or_ref_size(s) == 4 {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			u32(little_endian_u16_at(s.winmd_bytes, pos - 2))
		}

		method_body := if get_method_def_or_ref_size(s) == 4 {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			u32(little_endian_u16_at(s.winmd_bytes, pos - 2))
		}

		class := if s.num_rows[.type_def] > 0xFFFF {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			u32(little_endian_u16_at(s.winmd_bytes, pos - 2))
		}

		method_impls << MethodImpl{
			rid:                i
			token:              u32(Tables.method_impl) << 24 + i
			offset:             offset
			method_declaration: method_declaration
			method_body:        method_body
			class:              class
		}
	}

	return method_impls
}

// TODO: ModuleRef

fn (s TablesStream) get_type_spec_table() []TypeSpec {
	mut type_specs := []TypeSpec{}

	mut pos := s.get_pos(.type_spec)
	num_rows := s.num_rows[.type_spec]

	for i in 1 .. num_rows {
		offset := pos
		if i < 10 {
			println('')
			println('${(u32(Tables.member_ref) << 24 + i).hex_full()} at ${pos.hex_full()}')
			println('PAR | CON | VAL')
			// vfmt off
			println('${s.winmd_bytes[pos].hex()} ${s.winmd_bytes[pos + 1].hex()} ${s.winmd_bytes[pos + 2].hex()} ${s.winmd_bytes[pos + 3].hex()} ${s.winmd_bytes[pos + 4].hex()} ${s.winmd_bytes[pos + 5].hex()}')
			// vfmt on
		}

		signature := if s.heap_sizes.has(.blob) {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			u32(little_endian_u16_at(s.winmd_bytes, pos - 2))
		}

		type_specs << TypeSpec{
			rid:       i
			token:     u32(Tables.type_spec) << 24 + i
			offset:    offset
			signature: signature
		}
	}

	return type_specs
}

fn (s TablesStream) get_impl_map_table() []ImplMap {
	mut impl_maps := []ImplMap{}

	mut pos := s.get_pos(.impl_map)
	num_rows := s.num_rows[.impl_map]

	for i in 1 .. num_rows {
		offset := pos
		if i < 10 {
			println('')
			println('${(u32(Tables.member_ref) << 24 + i).hex_full()} at ${pos.hex_full()}')
			println('PAR | CON | VAL')
			// vfmt off
			println('${s.winmd_bytes[pos].hex()} ${s.winmd_bytes[pos + 1].hex()} ${s.winmd_bytes[pos + 2].hex()} ${s.winmd_bytes[pos + 3].hex()} ${s.winmd_bytes[pos + 4].hex()} ${s.winmd_bytes[pos + 5].hex()}')
			// vfmt on
		}

		mapping_flags := little_endian_u32_at(s.winmd_bytes, pos)
		pos += 4

		coded_member_forwarded := if get_has_constant_size(s) == 4 {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			u32(little_endian_u16_at(s.winmd_bytes, pos - 2))
		}
		member_forwarded := decode_has_constant(coded_member_forwarded)

		import_name := if s.heap_sizes.has(.strings) {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			u32(little_endian_u16_at(s.winmd_bytes, pos - 2))
		}

		import_scope := if s.num_rows[.module_ref] > 0xFFFF {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			u32(little_endian_u16_at(s.winmd_bytes, pos - 2))
		}

		impl_maps << ImplMap{
			rid:              i
			token:            u32(Tables.impl_map) << 24 + i
			offset:           offset
			import_name:      import_name
			import_scope:     import_scope
			mapping_flags:    mapping_flags
			member_forwarded: member_forwarded
		}
	}

	return impl_maps
}

// TODO: FieldRVA

fn (s TablesStream) get_assembly_table() []Assembly {
	mut assemblies := []Assembly{}

	mut pos := s.get_pos(.assembly)
	num_rows := s.num_rows[.assembly]

	for i in 1 .. num_rows {
		offset := pos
		if i < 10 {
			println('')
			println('${(u32(Tables.member_ref) << 24 + i).hex_full()} at ${pos.hex_full()}')
			println('HSH | FLA | VER | NAM | CUL')
			// vfmt off
			println('${s.winmd_bytes[pos].hex()} ${s.winmd_bytes[pos + 1].hex()} ${s.winmd_bytes[pos + 2].hex()} ${s.winmd_bytes[pos + 3].hex()} ${s.winmd_bytes[pos + 4].hex()} ${s.winmd_bytes[pos + 5].hex()}')
			// vfmt on
		}

		hash_algorithm := little_endian_u32_at(s.winmd_bytes, pos)
		pos += 4

		flags := little_endian_u32_at(s.winmd_bytes, pos)
		pos += 4

		version := little_endian_u32_at(s.winmd_bytes, pos)
		pos += 4

		name := if s.heap_sizes.has(.strings) {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			u32(little_endian_u16_at(s.winmd_bytes, pos - 2))
		}

		culture := if s.heap_sizes.has(.strings) {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			u32(little_endian_u16_at(s.winmd_bytes, pos - 2))
		}

		assemblies << Assembly{
			rid:            i
			token:          u32(Tables.assembly) << 24 + i
			offset:         offset
			flags:          flags
			culture:        culture
			hash_algorithm: hash_algorithm
			name:           name
			version:        version
		}
	}

	return assemblies
}

// TODO: AssemblyProcessor

// TODO: AssemblyOS

fn (s TablesStream) get_assembly_ref_table() []AssemblyRef {
	mut assembly_refs := []AssemblyRef{}

	mut pos := s.get_pos(.assembly_ref)
	num_rows := s.num_rows[.assembly_ref]

	for i in 1 .. num_rows {
		offset := pos
		if i < 10 {
			println('')
			println('${(u32(Tables.member_ref) << 24 + i).hex_full()} at ${pos.hex_full()}')
			println('HSH | FLA | VER | NAM | CUL')
			// vfmt off
			println('${s.winmd_bytes[pos].hex()} ${s.winmd_bytes[pos + 1].hex()} ${s.winmd_bytes[pos + 2].hex()} ${s.winmd_bytes[pos + 3].hex()} ${s.winmd_bytes[pos + 4].hex()} ${s.winmd_bytes[pos + 5].hex()}')
			// vfmt on
		}

		flags := little_endian_u32_at(s.winmd_bytes, pos)
		pos += 4

		version := little_endian_u32_at(s.winmd_bytes, pos)
		pos += 4

		name := if s.heap_sizes.has(.strings) {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			u32(little_endian_u16_at(s.winmd_bytes, pos - 2))
		}

		culture := if s.heap_sizes.has(.strings) {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			u32(little_endian_u16_at(s.winmd_bytes, pos - 2))
		}

		hash_value := if s.heap_sizes.has(.strings) {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			u32(little_endian_u16_at(s.winmd_bytes, pos - 2))
		}

		assembly_refs << AssemblyRef{
			rid:        i
			token:      u32(Tables.assembly_ref) << 24 + i
			offset:     offset
			flags:      flags
			culture:    culture
			hash_value: hash_value
			name:       name
			version:    version
		}
	}

	return assembly_refs
}

// TODO: AssemblyRefProcessor

// TODO: AssemblyRefOS

// TODO: File

// TODO: ExportedType

// TODO: ManifestResource

fn (s TablesStream) get_nested_class_table() []NestedClass {
	mut nested_classes := []NestedClass{}

	mut pos := s.get_pos(.nested_class)
	num_rows := s.num_rows[.nested_class]

	for i in 1 .. num_rows {
		offset := pos
		if i < 10 {
			println('')
			println('${(u32(Tables.member_ref) << 24 + i).hex_full()} at ${pos.hex_full()}')
			println('PAR | CON | VAL')
			// vfmt off
			println('${s.winmd_bytes[pos].hex()} ${s.winmd_bytes[pos + 1].hex()} ${s.winmd_bytes[pos + 2].hex()} ${s.winmd_bytes[pos + 3].hex()} ${s.winmd_bytes[pos + 4].hex()} ${s.winmd_bytes[pos + 5].hex()}')
			// vfmt on
		}

		enclosing_class := if s.num_rows[.type_def] > 0xFFFF {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			u32(little_endian_u16_at(s.winmd_bytes, pos - 2))
		}

		nested_class := if s.num_rows[.type_def] > 0xFFFF {
			pos += 4
			little_endian_u32_at(s.winmd_bytes, pos - 4)
		} else {
			pos += 2
			u32(little_endian_u16_at(s.winmd_bytes, pos - 2))
		}

		nested_classes << NestedClass{
			rid:             i
			token:           u32(Tables.nested_class) << 24 + i
			offset:          offset
			enclosing_class: enclosing_class
			nested_class:    nested_class
		}
	}

	return nested_classes
}

// TODO: GenericParam

// TODO: MethodSpec

// TODO: GenericParamConstraint

@[flag]
enum HeapSizeFlags {
	strings
	guid
	blob
}

@[flag]
enum TableFlags as u64 {
	module                   // bit 1
	type_ref                 // bit 2
	type_def                 // bit 3
	field_ptr                // bit 4
	field                    // bit 5
	method_ptr               // bit 6
	method_def               // bit 7
	param_ptr                // bit 8
	param                    // bit 9
	interface_impl           // bit 10
	member_ref               // bit 11
	constant                 // bit 12
	custom_attribute         // bit 13
	field_marshal            // bit 14
	decl_security            // bit 15
	class_layout             // bit 16
	field_layout             // bit 17
	stand_alone_sig          // bit 18
	event_map                // bit 19
	event_ptr                // bit 20
	event                    // bit 21
	property_map             // bit 22
	property_ptr             // bit 23
	property                 // bit 24
	method_semantics         // bit 25
	method_impl              // bit 26
	module_ref               // bit 27
	type_spec                // bit 28
	impl_map                 // bit 29
	field_rva                // bit 30
	enc_lg                   // bit 31
	enc_map                  // bit 32
	assembly                 // bit 33
	assembly_processor       // bit 34
	assembly_os              // bit 35
	assembly_ref             // bit 36
	assembly_ref_processor   // bit 37
	assembly_ref_os          // bit 38
	file                     // bit 39
	exported_type            // bit 40
	manifest_resource        // bit 41
	nested_class             // bit 42
	generic_param            // bit 43
	method_spec              // bit 44
	generic_param_constraint // bit 45
}

enum Tables {
	module                   = 0x00 //  The module containing this metadata
	type_ref                 = 0x01 //  References to types defined in other modules
	type_def                 = 0x02 //  Type definitions in this module
	field_ptr                = 0x03 //  Used for edit-and-continue scenarios
	field                    = 0x04 //  Fields defined in this module
	method_ptr               = 0x05 //  Used for edit-and-continue scenarios
	method_def               = 0x06 //  Methods defined in this module
	param_ptr                = 0x07 //  Used for edit-and-continue scenarios
	param                    = 0x08 //  Parameters for methods
	interface_impl           = 0x09 //  Interfaces implemented by types
	member_ref               = 0x0A //  References to members of other modules
	constant                 = 0x0B //  Constants for fields, params, properties
	custom_attribute         = 0x0C //  Custom attributes
	field_marshal            = 0x0D //  Marshaling information for fields
	decl_security            = 0x0E //  Security declarations
	class_layout             = 0x0F //  Class layout information
	field_layout             = 0x10 //  Field layout information
	stand_alone_sig          = 0x11 //  Standalone signatures
	event_map                = 0x12 //  Event mapping information
	event_ptr                = 0x13 //  Used for edit-and-continue scenarios
	event                    = 0x14 //  Events defined in this module
	property_map             = 0x15 //  Property mapping information
	property_ptr             = 0x16 //  Used for edit-and-continue scenarios
	property                 = 0x17 //  Properties defined in this module
	method_semantics         = 0x18 //  Method semantics
	method_impl              = 0x19 //  Method implementations
	module_ref               = 0x1A //  References to other modules
	type_spec                = 0x1B //  Type specifications
	impl_map                 = 0x1C //  Implementation information
	field_rva                = 0x1D //  Field RVA information
	enc_lg                   = 0x1E //  Edit-and-continue log
	enc_map                  = 0x1F //  Edit-and-continue mapping
	assembly                 = 0x20 //  Assembly information
	assembly_processor       = 0x21 //  Assembly processor information
	assembly_os              = 0x22 //  Assembly OS requirements
	assembly_ref             = 0x23 //  References to other assemblies
	assembly_ref_processor   = 0x24 //  Assembly reference processor information
	assembly_ref_os          = 0x25 //  Assembly reference OS requirements
	file                     = 0x26 //  Files in the assembly
	exported_type            = 0x27 //  Types exported from this assembly
	manifest_resource        = 0x28 //  Resources in this assembly
	nested_class             = 0x29 //  Nested class information
	generic_param            = 0x2A //  Generic parameters
	method_spec              = 0x2B //  Method specifications
	generic_param_constraint = 0x2C //  Generic parameter constraints
}

// ## II.24.2.6 #~ stream

// The "`#~`" streams contain the actual physical representations of the logical metadata tables (§[II.22](ii.22-metadata-logical-format-tables.md)). A "`#~`" stream has the following top-level structure:

// Offset | Size | Field | Description
// ---- | ---- | ---- | ----
// 0 | 4 | **Reserved** | Reserved, always 0 (§[II.24.1](ii.24.1-fixed-fields.md)).
// 4 | 1 | **MajorVersion** | Major version of table schemata; shall be 2 (§[II.24.1](ii.24.1-fixed-fields.md)).
// 5 | 1 | **MinorVersion** | Minor version of table schemata; shall be 0 (§[II.24.1](ii.24.1-fixed-fields.md)).
// 6 | 1 | **HeapSizes** | Bit vector for heap sizes.
// 7 | 1 | **Reserved** | Reserved, always 1 (§[II.24.1](ii.24.1-fixed-fields.md)).
// 8 | 8 | **Valid** | Bit vector of present tables, let *n* be the number of bits that are 1.
// 16 | 8 | **Sorted** | Bit vector of sorted tables.
// 24 | 4\**n* | **Rows** | Array of *n* 4-byte unsigned integers indicating the number of rows for each present table.
// 24+4\**n* | &nbsp; | **Tables** | The sequence of physical tables.

// The _HeapSizes_ field is a bitvector that encodes the width of indexes into the various heaps.  If bit 0 is set, indexes into the "`#Strings`" heap are 4 bytes wide; if bit 1 is set, indexes into the "`#GUID`" heap are 4 bytes wide; if bit 2 is set, indexes into the "`#Blob`" heap are 4 bytes wide. Conversely, if the _HeapSizes_ bit for a particular heap is not set, indexes into that heap are 2 bytes wide.

//  Heap size flag | Description
//  ---- | ----
//  0x01 | Size of "`#Strings`" stream &ge; 2<sup>16</sup>.
//  0x02 | Size of "`#GUID`" stream &ge; 2<sup>16</sup>.
//  0x04 | Size of "`#Blob`" stream &ge; 2<sup>16</sup>.

// The _Valid_ field is a 64-bit bitvector that has a specific bit set for each table that is stored in the stream; the mapping of tables to indexes is given at the start of §[II.22](ii.22-metadata-logical-format-tables.md). For example when the _DeclSecurity_ table is present in the logical metadata, bit 0x0e should be set in the Valid vector. It is invalid to include non-existent tables in _Valid_, so all bits above 0x2c shall be zero.

// The _Rows_ array contains the number of rows for each of the tables that are present. When decoding physical metadata to logical metadata, the number of 1's in _Valid_ indicates the number of elements in the _Rows_ array.

// A crucial aspect in the encoding of a logical table is its schema. The schema for each table is given in §[II.22](ii.22-metadata-logical-format-tables.md). For example, the table with assigned index 0x02 is a _TypeDef_ table, which, according to its specification in §[II.22.37](ii.22.37-typedef-0x02.md), has the following columns: a 4-byte-wide flags, an index into the String heap, another index into the String heap, an index into _TypeDef_, _TypeRef_, or _TypeSpec_ table, an index into _Field_ table, and an index into _MethodDef_ table.

// The physical representation of a table with *n* columns and *m* rows with schema (*C*<sub>0</sub>,&hellip;,*C*<sub>*n*-1</sub>) consists of the concatenation of the physical representation of each of its rows. The physical representation of a row with schema (*C*<sub>0</sub>,&hellip;,*C*<sub>n-1</sub>) is the concatenation of the physical representation of each of its elements. The physical representation of a row cell *e* at a column with type *C* is defined as follows:

//  * If *e* is a constant, it is stored using the number of bytes as specified for its column type *C* (i.e., a 2-bit mask of type _PropertyAttributes_)

//  * If *e* is an index into the GUID heap, 'blob', or String heap, it is stored using the number of bytes as defined in the *HeapSizes* field.

//  * If *e* is a simple index into a table with index *i*, it is stored using 2 bytes if table *i* has less than 216 rows, otherwise it is stored using 4 bytes.

//  * If *e* is a coded index that points into table *t*<sub>*i*</sub> out of *n* possible tables *t*<sub>0</sub>,&hellip;*t*<sub>*n*-1</sub>, then it is stored as *e* << (log *n*) | tag{ *t*<sub>0</sub>,&hellip;*t*<sub>*n*-1</sub> }\[ *t*<sub>*i*</sub> \] using 2 bytes if the maximum number of rows of tables *t*<sub>0</sub>,&hellip;*t*<sub>*n*-1</sub>, is less than 2(16 – (log *n*)), and using 4 bytes otherwise. The family of finite maps tag{ *t*<sub>0</sub>,&hellip;*t*<sub>*n*-1</sub> } is defined below. Note that decoding a physical row requires the inverse of this mapping. [For example, the _Parent_ column of the _Constant_ table indexes a row in the _Field_, _Param_, or _Property_ tables. The actual table is encoded into the low 2 bits of the number, using the values: 0 => _Field_, 1 => _Param_, 2 => _Property_. The remaining bits hold the actual row number being indexed. For example, a value of 0x321, indexes row number 0xC8 in the _Param_ table.]
fn get_tables_stream(winmd_bytes []u8, tables_stream Stream) TablesStream {
	raw_heap_sizes := winmd_bytes[tables_stream.pos + 6]
	heap_sizes := unsafe { HeapSizeFlags(raw_heap_sizes) }

	raw_present_tables := little_endian_u64_at(winmd_bytes, tables_stream.pos + 8)
	present_tables := unsafe { TableFlags(raw_present_tables) }

	raw_sorted_tables := little_endian_u64_at(winmd_bytes, tables_stream.pos + 8)
	sorted_tables := unsafe { TableFlags(raw_sorted_tables) }

	mut num_rows := map[TableFlags]u32{}
	mut row_idx := 0
	for i in 0 .. 0x2C {
		unsafe {
			table_type := TableFlags(u64(1) << i)
			if present_tables.has(table_type) {
				table_num_rows := little_endian_u32_at(winmd_bytes, tables_stream.pos + 24 +
					4 * row_idx)
				num_rows[table_type] = table_num_rows
				row_idx += 1
			} else {
				num_rows[table_type] = u32(0)
			}
		}
	}

	tables_pos := tables_stream.pos + 24 + 4 * row_idx

	return TablesStream{
		winmd_bytes:    winmd_bytes
		tables_stream:  tables_stream
		tables_pos:     tables_pos
		heap_sizes:     heap_sizes
		present_tables: present_tables
		sorted_tables:  sorted_tables
		num_rows:       num_rows
	}
}
