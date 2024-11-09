module winmd

pub fn read_compressed_uint(blob []u8, mut pos &int) !u32 {
	unsafe {
		if *pos >= blob.len {
			return error('Invalid compressed integer position')
		}

		first := blob[*pos]
		*pos += 1

		if first & 0x80 == 0 {
			return u32(first) // 1-byte encoding
		}

		if first & 0x40 == 0 {
			// 2-byte encoding
			if *pos >= blob.len {
				return error('Invalid compressed integer: incomplete 2-byte encoding')
			}
			second := blob[*pos]
			*pos += 1

			value := (u32(first & 0x3F) << 8) | u32(second)
			if value <= 0x7F {
				return error('Invalid compressed integer: 2-byte encoding used for small value')
			}
			return value
		}

		// 4-byte encoding
		if *pos + 3 > blob.len {
			return error('Invalid compressed integer: incomplete 4-byte encoding')
		}

		second := blob[*pos]
		third := blob[*pos + 1]
		fourth := blob[*pos + 2]
		*pos += 3

		value := (u32(first & 0x3F) << 24) | (u32(second) << 16) | (u32(third) << 8) | u32(fourth)

		if value <= 0x3FFF {
			return error('Invalid compressed integer: 4-byte encoding used for small value')
		}

		return value
	}
}
