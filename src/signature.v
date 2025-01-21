module main

import encoding.binary

// Returns the decoded value and number of bytes consumed
fn decode_unsigned(token u32) ?(u32, int) {
	data := binary.big_endian_get_u32(token)

	first_byte := data[0]

	// 1-byte format (0xxxxxxx)
	if (first_byte & 0x80) == 0 {
		return u32(first_byte), 1
	}

	// 2-byte format (10xxxxxx xxxxxxxx)
	if (first_byte & 0xC0) == 0x80 {
		if data.len < 2 {
			// return error('Insufficient data for 2-byte value')
		}
		value := u32(first_byte & 0x3F) << 8 | u32(data[1])
		return value, 2
	}

	// 4-byte format (110xxxxx xxxxxxxx xxxxxxxx xxxxxxxx)
	if (first_byte & 0xE0) == 0xC0 {
		if data.len < 4 {
			// return error('Insufficient data for 4-byte value')
		}
		value := u32(first_byte & 0x1F) << 24 | u32(data[1]) << 16 | u32(data[2]) << 8 | u32(data[3])
		return value, 4
	}

	return none

	// return error('Invalid compression format')
}

// Returns the decoded value and number of bytes consumed
fn decode_signed(data []u8) ?(int, int) {
	if data.len == 0 {
		// return error('No data to decode')
	}

	first_byte := data[0]

	// Check for null string marker
	if first_byte == 0xFF {
		// return error('Null string marker encountered')
	}

	// 1-byte format (0xxxxxxx) - 6-bit signed value rotated left once
	if (first_byte & 0x80) == 0 {
		// Rotate right to get original value
		rotated := (first_byte >> 1) | ((first_byte & 1) << 6)

		// Sign extend from 7 bits
		if (rotated & 0x40) != 0 {
			value := int(rotated | 0xFFFFFF80)
			return value, 1
		} else {
			return int(rotated), 1
		}
	}

	// 2-byte format (10xxxxxx xxxxxxxx) - 13-bit signed value rotated left once
	if (first_byte & 0xC0) == 0x80 {
		if data.len < 2 {
			// return error('Insufficient data for 2-byte value')
		}

		// Combine bytes and rotate right
		combined := u16(first_byte & 0x3F) << 8 | u16(data[1])
		rotated := (combined >> 1) | ((combined & 1) << 13)

		// Sign extend from 14 bits
		if (rotated & 0x2000) != 0 {
			value := int(rotated | 0xFFFFC000)
			return value, 2
		} else {
			return int(rotated), 2
		}
	}

	// 4-byte format (110xxxxx xxxxxxxx xxxxxxxx xxxxxxxx) - 28-bit signed value rotated left once
	if (first_byte & 0xE0) == 0xC0 {
		if data.len < 4 {
			// return error('Insufficient data for 4-byte value')
		}

		// Combine bytes and rotate right
		combined := u32(first_byte & 0x1F) << 24 | u32(data[1]) << 16 | u32(data[2]) << 8 | u32(data[3])
		rotated := (combined >> 1) | ((combined & 1) << 28)

		// Sign extend from 29 bits
		if (rotated & 0x10000000) != 0 {
			value := int(rotated | 0xE0000000)
			return value, 4
		} else {
			return int(rotated), 4
		}
	}

	return none

	// return error('Invalid compression format')
}

// Helper function to check if a string is null-terminated
fn is_null_string(data []u8) bool {
	return data.len > 0 && data[0] == 0xFF
}
