module main

import os
import encoding.binary { little_endian_u16_at, little_endian_u32_at }

// "BSJB" in little-endian ascii
const metadata_signature = u32(0x424A5342)

fn main() {
	// Read the winmd file from disk, and store the entire thing in memory
	winmd_bytes := os.read_file('WinMetadata/winmd/Windows.Data.winmd')!.bytes()

	// Since a winmd file is a portable executable (PE) file, it consists
	// of these parts:
	// - MS DOS stub (128 bytes)
	// - PE signature (4 bytes)
	// - COFF header (20 bytes)
	// - Optional header (either 224 bytes for PE32 files, or 240 bytes for PE32+ files)
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

	// The offset of the StreamHeaders. There are always five streams: #~, #Strings, #US, #GUID and #Blob
	streams_pos := get_streams_pos(winmd_bytes, metadata_pos)
	streams := get_streams(winmd_bytes, streams_pos, metadata_pos)

	// We're now in the second phase. We have successfully navigated through the file headers
	// and have all the information we need to start parsing the tables stream.

	// We get the different flags and the start position of the tables stream.
	// The flags are:
	// -

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

// get_cli_header_rva_and_size gets the relative virtual address and the size of the CLI header.
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
	cli_header_size := little_endian_u32_at(winmd_bytes, opt_header_pos + 208 + 4)

	println('\nDebug: CLI Header Details')
	println('  ${cli_header_rva.hex_full()} | CLI RVA')
	println('  ${cli_header_size.hex_full()} | CLI Size')
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
	virtual_text_section_size := little_endian_u32_at(winmd_bytes, text_section_pos + 8)
	virtual_text_section_pos := int(little_endian_u32_at(winmd_bytes, text_section_pos + 12))
	// raw means how the file is laid out physically on disk
	raw_text_section_size := little_endian_u32_at(winmd_bytes, text_section_pos + 16)
	raw_text_section_pos := int(little_endian_u32_at(winmd_bytes, text_section_pos + 20))

	println('Debug: Text Section Details')
	println('  ${virtual_text_section_size.hex_full()} | Virtual Size')
	println('  ${virtual_text_section_pos.hex_full()} | Virtual Address')
	println('  ${raw_text_section_size.hex_full()} | Size of Raw Data')
	println('  ${raw_text_section_pos.hex_full()} | Pointer to Raw Data')

	cli_header_rva := get_cli_header_rva(winmd_bytes, opt_header_pos)
	virtual_cli_header_pos := cli_header_rva - virtual_text_section_pos
	raw_cli_header_pos := virtual_cli_header_pos + raw_text_section_pos

	println('\nDebug: CLI Header Conversion')
	println('  ${virtual_cli_header_pos.hex_full()} | CLI Offset from VA')
	println('  ${raw_cli_header_pos.hex_full()} | CLI File Offset')

	// Read metadata directory RVA from CLI header
	metadata_rva := int(little_endian_u32_at(winmd_bytes, raw_cli_header_pos + 8))
	virtual_metadata_size := little_endian_u32_at(winmd_bytes, raw_cli_header_pos + 12)

	println('\nDebug: Metadata Details')
	println('  ${metadata_rva.hex_full()} | Metadata RVA')
	println('  ${virtual_metadata_size.hex_full()} | Metadata Size')

	virtual_metadata_pos := metadata_rva - virtual_text_section_pos
	raw_metadata_pos := virtual_metadata_pos + raw_text_section_pos

	println('\nDebug: Metadata Conversion')
	println('  ${virtual_text_section_pos.hex_full()} | Section VA')
	println('  ${raw_text_section_pos.hex_full()} | Section Raw')
	println('  ${virtual_metadata_pos.hex_full()} | Metadata Offset from VA')
	println('  ${raw_metadata_pos.hex_full()} | Final Metadata File Offset')

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
//
// We're not interested in anything but the StreamHeaders. We therefore do this:
// 1) Read the version string length
// 2) Read byte-for-byte untill null byte encountered
// 3) Add padding
// 4) Add 4
//
fn get_streams_pos(winmd_bytes []u8, metadata_pos int) int {
	println(metadata_pos.hex_full())
	version_length := little_endian_u32_at(winmd_bytes, metadata_pos + 12)
	println(version_length)
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

	println('Debug: Streams')
	println('  ${streams_pos.hex_full()} | Streams pos')
	println('  ${tables_stream_pos.hex_full()} | #~ pos')
	println('  ${tables_stream_size.hex_full()} | #~ size')
	println('  ${strings_stream_pos.hex_full()} | #Strings pos')
	println('  ${strings_stream_size.hex_full()} | #Strings size')
	println('  ${us_stream_pos.hex_full()} | #US pos')
	println('  ${us_stream_size.hex_full()} | #US size')
	println('  ${guid_stream_pos.hex_full()} | #GUID pos')
	println('  ${guid_stream_size.hex_full()} | #GUID size')
	println('  ${blob_stream_pos.hex_full()} | #Blob pos')
	println('  ${blob_stream_size.hex_full()} | #Blob size')

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

struct TableStreamMeta {
	heap_sizes HeapSize
}

@[flag]
enum HeapSize {
	strings
	guid
	blob
}
