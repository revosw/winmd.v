module main

import os
import encoding.binary { little_endian_u16_at, little_endian_u32_at, little_endian_u64_at }

// "BSJB" in little-endian ascii
const metadata_signature = u32(0x424A5342)

fn main() {
	// Read the winmd file from disk, and store the entire thing in memory
	winmd_bytes := os.read_file('WinMetadata/Windows.Data.winmd')!.bytes()

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

	// The offset of the StreamHeaders. There are always five streams: #~, #Strings, #US, #GUID and #Blob
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

	for type_ref_entry in tables_stream.get_type_ref_table() {
		println(type_ref_entry.token.hex_full())
	}
	// for constant_entry in tables_stream.get_constant_table() {
	// 	println(constant_entry.rid)
	// 	// tables_stream.get_table()
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
pub:
	heap_sizes     HeapSizeFlags
	present_tables TableFlags
	sorted_tables  TableFlags
	num_rows       map[TableFlags]u32
}

fn (s TablesStream) get_pos(table TableFlags) int {
	mut pos := s.tables_stream.pos

	println("At position: ${pos}")

	if table == .module {
		return pos
	}
	println("Adding ${s.num_rows[.module]} * ${u32(Module.row_size(s.heap_sizes))} to ${pos}")
	pos += int(s.num_rows[.module] * u32(Module.row_size(s.heap_sizes)))
	if table == .type_ref {
		return pos
	}
	pos += int(s.num_rows[.type_ref] * u32(TypeRef.row_size(s.heap_sizes)))
	if table == .type_def {
		return pos
	}
	pos += int(s.num_rows[.type_def] * u32(TypeDef.row_size(s.heap_sizes)))
	// pos += int(s.num_rows[.field_ptr] * u32(FieldPtr.row_size(s.heap_sizes)))
	if table == .field {
		return pos
	}
	pos += int(s.num_rows[.field] * u32(Field.row_size(s.heap_sizes)))
	// pos += int(s.num_rows[.method_ptr] * u32(MethodPtr.row_size(s.heap_sizes)))
	if table == .method {
		return pos
	}
	pos += int(s.num_rows[.method] * u32(Method.row_size(s.heap_sizes)))
	// pos += int(s.num_rows[.param_ptr] * u32(ParamPtr.row_size(s.heap_sizes)))
	if table == .param {
		return pos
	}
	pos += int(s.num_rows[.param] * u32(Param.row_size(s.heap_sizes)))
	if table == .interface_impl {
		return pos
	}
	pos += int(s.num_rows[.interface_impl] * u32(InterfaceImpl.row_size(s.heap_sizes)))
	if table == .member_ref {
		return pos
	}
	pos += int(s.num_rows[.member_ref] * u32(MemberRef.row_size(s.heap_sizes)))
	if table == .constant {
		return pos
	}
	pos += int(s.num_rows[.constant] * u32(Constant.row_size(s.heap_sizes)))
	if table == .custom_attribute {
		return pos
	}
	pos += int(s.num_rows[.custom_attribute] * u32(CustomAttribute.row_size(s.heap_sizes)))
	if table == .field_marshal {
		return pos
	}
	pos += int(s.num_rows[.field_marshal] * u32(FieldMarshal.row_size(s.heap_sizes)))
	if table == .decl_security {
		return pos
	}
	pos += int(s.num_rows[.decl_security] * u32(DeclSecurity.row_size(s.heap_sizes)))
	if table == .class_layout {
		return pos
	}
	pos += int(s.num_rows[.class_layout] * u32(ClassLayout.row_size(s.heap_sizes)))
	if table == .field_layout {
		return pos
	}
	pos += int(s.num_rows[.field_layout] * u32(FieldLayout.row_size(s.heap_sizes)))
	if table == .stand_alone_sig {
		return pos
	}
	pos += int(s.num_rows[.stand_alone_sig] * u32(StandAloneSig.row_size(s.heap_sizes)))
	if table == .event_map {
		return pos
	}
	pos += int(s.num_rows[.event_map] * u32(EventMap.row_size(s.heap_sizes)))
	// pos += int(s.num_rows[.event_ptr] * u32(EventPtr.row_size(s.heap_sizes)))
	if table == .event {
		return pos
	}
	pos += int(s.num_rows[.event] * u32(Event.row_size(s.heap_sizes)))
	if table == .property_map {
		return pos
	}
	pos += int(s.num_rows[.property_map] * u32(PropertyMap.row_size(s.heap_sizes)))
	// pos += int(s.num_rows[.property_ptr] * u32(PropertyPtr.row_size(s.heap_sizes)))
	if table == .property {
		return pos
	}
	pos += int(s.num_rows[.property] * u32(Property.row_size(s.heap_sizes)))
	if table == .method_semantics {
		return pos
	}
	pos += int(s.num_rows[.method_semantics] * u32(MethodSemantics.row_size(s.heap_sizes)))
	if table == .method_impl {
		return pos
	}
	pos += int(s.num_rows[.method_impl] * u32(MethodImpl.row_size(s.heap_sizes)))
	if table == .module_ref {
		return pos
	}
	pos += int(s.num_rows[.module_ref] * u32(ModuleRef.row_size(s.heap_sizes)))
	if table == .type_spec {
		return pos
	}
	pos += int(s.num_rows[.type_spec] * u32(TypeSpec.row_size(s.heap_sizes)))
	if table == .impl_map {
		return pos
	}
	pos += int(s.num_rows[.impl_map] * u32(ImplMap.row_size(s.heap_sizes)))
	if table == .field_rva {
		return pos
	}
	pos += int(s.num_rows[.field_rva] * u32(FieldRVA.row_size(s.heap_sizes)))
	// pos += int(s.num_rows[.enc_lg] * u32(EncLg.row_size(s.heap_sizes)))
	// pos += int(s.num_rows[.enc_map] * u32(EncMap.row_size(s.heap_sizes)))
	if table == .assembly {
		return pos
	}
	pos += int(s.num_rows[.assembly] * u32(Assembly.row_size(s.heap_sizes)))
	if table == .assembly_processor {
		return pos
	}
	pos += int(s.num_rows[.assembly_processor] * u32(AssemblyProcessor.row_size(s.heap_sizes)))
	if table == .assembly_os {
		return pos
	}
	pos += int(s.num_rows[.assembly_os] * u32(AssemblyOS.row_size(s.heap_sizes)))
	if table == .assembly_ref {
		return pos
	}
	pos += int(s.num_rows[.assembly_ref] * u32(AssemblyRef.row_size(s.heap_sizes)))
	if table == .assembly_ref_processor {
		return pos
	}
	pos += int(s.num_rows[.assembly_ref_processor] * u32(AssemblyRefProcessor.row_size(s.heap_sizes)))
	if table == .assembly_ref_os {
		return pos
	}
	pos += int(s.num_rows[.assembly_ref_os] * u32(AssemblyRefOS.row_size(s.heap_sizes)))
	if table == .file {
		return pos
	}
	pos += int(s.num_rows[.file] * u32(File.row_size(s.heap_sizes)))
	if table == .exported_type {
		return pos
	}
	pos += int(s.num_rows[.exported_type] * u32(ExportedType.row_size(s.heap_sizes)))
	if table == .manifest_resource {
		return pos
	}
	pos += int(s.num_rows[.manifest_resource] * u32(ManifestResource.row_size(s.heap_sizes)))
	if table == .nested_class {
		return pos
	}
	pos += int(s.num_rows[.nested_class] * u32(NestedClass.row_size(s.heap_sizes)))
	if table == .generic_param {
		return pos
	}
	pos += int(s.num_rows[.generic_param] * u32(GenericParam.row_size(s.heap_sizes)))
	if table == .method_spec {
		return pos
	}
	pos += int(s.num_rows[.method_spec] * u32(MethodSpec.row_size(s.heap_sizes)))
	if table == .generic_param_constraint {
		return pos
	}
	pos += int(s.num_rows[.generic_param_constraint] * u32(GenericParamConstraint.row_size(s.heap_sizes)))
	return pos
}

fn (s TablesStream) get_type_ref_table() []TypeRef {
	mut type_refs := []TypeRef{}

	mut pos := s.get_pos(.type_ref)
    
    println("TypeRef table rows: ${s.num_rows[.type_ref]}")
    println("TypeRef table row size: ${TypeRef.row_size(s.heap_sizes)}")

	for i in 0 .. s.num_rows[.type_ref] {
		// TypeRef is a struct with a size of 2 bytes
		name := if s.heap_sizes.has(.strings) {
			little_endian_u32_at(s.winmd_bytes, pos + 12)
		} else {
			little_endian_u16_at(s.winmd_bytes, pos + 12)
		}
		namespace := if s.heap_sizes.has(.strings) {
			little_endian_u32_at(s.winmd_bytes, pos + 12 + 4)
		} else {
			little_endian_u16_at(s.winmd_bytes, pos + 12 + 2)
		}

		type_refs << TypeRef{
			rid:              i
			token:            little_endian_u32_at(s.winmd_bytes, pos)
			offset:           little_endian_u32_at(s.winmd_bytes, pos + 8)
			resolution_scope: little_endian_u32_at(s.winmd_bytes, pos + 12)
			name:             name
			namespace:        namespace
		}
		pos += TypeRef.row_size(s.heap_sizes)
	}

	return type_refs
}

fn (s TablesStream) get_type_def_table() []TypeDef {
	mut type_defs := []TypeDef{}

	mut pos := s.get_pos(.type_def)
	num_rows := s.num_rows[.type_def]
    
    println("TypeDef table rows: ${num_rows}")
    println("TypeDef table row size: ${TypeDef.row_size(s.heap_sizes)}")

	for i in 0 .. num_rows {
		// TypeRef is a struct with a size of 2 bytes
		type_defs << TypeDef{
			rid:         i
			token:       little_endian_u32_at(s.winmd_bytes, pos + 4)
			offset:      little_endian_u32_at(s.winmd_bytes, pos + 2)
			attributes:  little_endian_u32_at(s.winmd_bytes, pos)
			name:        little_endian_u32_at(s.winmd_bytes, pos + 2)
			namespace:   little_endian_u32_at(s.winmd_bytes, pos + 2)
			base_type:   little_endian_u32_at(s.winmd_bytes, pos + 2)
			field_list:  little_endian_u32_at(s.winmd_bytes, pos + 2)
			method_list: little_endian_u32_at(s.winmd_bytes, pos + 2)
		}
		pos += TypeDef.row_size(s.heap_sizes)
	}

	return type_defs
}

fn (s TablesStream) get_field_table() []Field {
	mut fields := []Field{}

	mut pos := s.get_pos(.field)
	num_rows := s.num_rows[.field]

    println("Field table rows: ${num_rows}")
    println("Field table row size: ${Field.row_size(s.heap_sizes)}")

	for i in 0 .. num_rows {
		// TypeRef is a struct with a size of 2 bytes
		fields << Field{
			rid:        i
			token:      little_endian_u32_at(s.winmd_bytes, pos + 4)
			offset:     little_endian_u32_at(s.winmd_bytes, pos + 2)
			attributes: little_endian_u32_at(s.winmd_bytes, pos)
			name:       little_endian_u32_at(s.winmd_bytes, pos + 2)
			signature:  little_endian_u32_at(s.winmd_bytes, pos + 2)
		}
		pos += Field.row_size(s.heap_sizes)
	}

	return fields
}

fn (s TablesStream) get_constant_table() []Constant {
	mut constants := []Constant{}

	mut pos := s.get_pos(.constant)
	num_rows := s.num_rows[.constant]

    println("Constant table rows: ${num_rows}")
    println("Constant table row size: ${Constant.row_size(s.heap_sizes)}")

	for i in 0 .. num_rows {
		constants << Constant{
			rid:    i
			token:  little_endian_u32_at(s.winmd_bytes, pos + 4)
			offset: little_endian_u32_at(s.winmd_bytes, pos + 4)
			type:   little_endian_u16_at(s.winmd_bytes, pos + 4)
			parent: little_endian_u32_at(s.winmd_bytes, pos + 4)
			value:  little_endian_u32_at(s.winmd_bytes, pos + 4)
		}

        pos += Constant.row_size(s.heap_sizes)
	}

	return constants
}

@[flag]
enum HeapSizeFlags {
	strings
	guid
	blob
}

@[flag]
enum TableFlags {
	module                   // bit 1
	type_ref                 // bit 2
	type_def                 // bit 3
	field_ptr                // bit 4
	field                    // bit 5
	method_ptr               // bit 6
	method                   // bit 7
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
	method                   = 0x06 //  Methods defined in this module
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

	// Instead of storing number of rows as a compact array,
	// we store it in a sparse array where the index is the table index.
	// So for example, if the 0x02 bit is set in present_tables, then
	// num_rows[0x02] will contain the number of rows for the TypeDef table.
	mut num_rows := map[TableFlags]u32
	mut row_idx := 0
	for i in 0 .. 0x2C {
		unsafe {
			table_type := TableFlags(u64(1) << i)
			if present_tables.has(table_type) {
				table_num_rows := little_endian_u32_at(winmd_bytes, tables_stream.pos + 24 + 4 * row_idx)
				num_rows[table_type] = table_num_rows
				row_idx += 1
			} else {
				num_rows[table_type] = u32(0)
			}
		}
	}

	return TablesStream{
		winmd_bytes:    winmd_bytes
		tables_stream:  tables_stream
		heap_sizes:     heap_sizes
		present_tables: present_tables
		sorted_tables:  sorted_tables
		num_rows:       num_rows
	}
}
