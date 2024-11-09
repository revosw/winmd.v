module winmd

import strconv

// GUID (Globally Unique Identifier) structure
pub struct GUID {
pub mut:
	data1 u32
	// First 32 bits
	data2 u16
	// Next 16 bits
	data3 u16
	// Next 16 bits
	data4 [8]u8
	// Last 64 bits
}

// Create a new GUID from string representation
pub fn new_guid(guid_str string) !GUID {
	if guid_str.len != 36 && guid_str.len != 38 {
		return error('Invalid GUID string length: ${guid_str}')
	}

	// Remove braces if present
	clean_str := if guid_str.starts_with('{') && guid_str.ends_with('}') {
		guid_str[1..37]
	} else {
		guid_str
	}

	// Validate format (8-4-4-4-12)
	if clean_str[8] != `-` || clean_str[13] != `-` || clean_str[18] != `-` || clean_str[23] != `-` {
		return error('Invalid GUID format')
	}

	mut guid := GUID{}

	// Parse data1 (8 chars)
	guid.data1 = u32(strconv.parse_uint(clean_str[0..8], 16, 32)!)

	// Parse data2 (4 chars)
	guid.data2 = u16(strconv.parse_uint(clean_str[9..13], 16, 16)!)

	// Parse data3 (4 chars)
	guid.data3 = u16(strconv.parse_uint(clean_str[14..18], 16, 16)!)

	// Parse data4 (4 chars + 12 chars)
	first_bytes := clean_str[19..23]
	second_bytes := clean_str[24..]

	// First two bytes of data4
	first_part := u16(strconv.parse_uint(first_bytes, 16, 16)!)
	guid.data4[0] = u8(first_part >> 8)
	guid.data4[1] = u8(first_part & 0xFF)

	// Last six bytes of data4
	for i := 0; i < 6; i++ {
		start := i * 2
		guid.data4[i + 2] = u8(strconv.parse_uint(second_bytes[start..start + 2], 16,
			8)!)
	}

	return guid
}

// Convert GUID to string
pub fn (g GUID) str() string {
	return '{' + '${g.data1:08x}-' + '${g.data2:04x}-' + '${g.data3:04x}-' +
		'${g.data4[0]:02x}${g.data4[1]:02x}-' +
		'${g.data4[2]:02x}${g.data4[3]:02x}${g.data4[4]:02x}${g.data4[5]:02x}${g.data4[6]:02x}${g.data4[7]:02x}' +
		'}'
}

// Check if two GUIDs are equal
@[inline]
pub fn (g GUID) == (other GUID) bool {
	return g.data1 == other.data1 && g.data2 == other.data2 && g.data3 == other.data3
		&& g.data4 == other.data4
}

// Create an empty (null) GUID
pub fn null_guid() GUID {
	mut data4 := [8]u8{}
	return GUID{
		data1: 0
		data2: 0
		data3: 0
		data4: data4
	}
}

// Create a GUID from raw bytes
pub fn guid_from_bytes(bytes []u8) !GUID {
	if bytes.len != 16 {
		return error('Invalid u8 array length for GUID: expected 16, got ${bytes.len}')
	}

	mut data4 := [8]u8{}
	for i in 0 .. 8 {
		data4[i] = bytes[8 + i]
	}

	return GUID{
		data1: u32(bytes[0]) | (u32(bytes[1]) << 8) | (u32(bytes[2]) << 16) | (u32(bytes[3]) << 24)
		data2: u16(bytes[4]) | (u16(bytes[5]) << 8)
		data3: u16(bytes[6]) | (u16(bytes[7]) << 8)
		data4: data4
	}
}

// Convert GUID to bytes
pub fn (g GUID) bytes() []u8 {
	mut bytes := []u8{len: 16}

	// data1
	bytes[0] = u8(g.data1 & 0xFF)
	bytes[1] = u8((g.data1 >> 8) & 0xFF)
	bytes[2] = u8((g.data1 >> 16) & 0xFF)
	bytes[3] = u8((g.data1 >> 24) & 0xFF)

	// data2
	bytes[4] = u8(g.data2 & 0xFF)
	bytes[5] = u8((g.data2 >> 8) & 0xFF)

	// data3
	bytes[6] = u8(g.data3 & 0xFF)
	bytes[7] = u8((g.data3 >> 8) & 0xFF)

	// data4
	for i in 0 .. 8 {
		bytes[8 + i] = g.data4[i]
	}

	return bytes
}

// Common system GUIDs
pub const iid_iunknown = GUID{
	data1: 0x00000000
	data2: 0x0000
	data3: 0x0000
	data4: [u8(0xC0), u8(0x00), u8(0x00), u8(0x00), u8(0x00), u8(0x00), u8(0x00), u8(0x46)]!
}

pub const iid_iinspectable = GUID{
	data1: 0xAF86E2E0
	data2: 0xB12D
	data3: 0x4c6a
	data4: [u8(0x9C), u8(0x5A), u8(0xD7), u8(0xAA), u8(0x65), u8(0x10), u8(0x1E), u8(0x90)]!
}

pub const iid_iagileobject = GUID{
	data1: 0x94EA2B94
	data2: 0xE9CC
	data3: 0x49E0
	data4: [u8(0xC0), u8(0xFF), u8(0xEE), u8(0x64), u8(0xCA), u8(0x8F), u8(0x5B), u8(0x9E)]!
}
