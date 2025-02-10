module main

// Returns the decoded value and number of bytes consumed
fn decode_unsigned(data []u8) (u32, int) {
	first_byte := data[0]

	// 1-byte format (0xxxxxxx)
	if (first_byte & 0x80) == 0 {
		return u32(first_byte), 1
	}

	// 2-byte format (10xxxxxx xxxxxxxx)
	if (first_byte & 0xC0) == 0x80 {
		value := u32(first_byte & 0x3F) << 8 | u32(data[1])
		return value, 2
	}

	// 4-byte format (110xxxxx xxxxxxxx xxxxxxxx xxxxxxxx)
	if (first_byte & 0xE0) == 0xC0 {
		value := u32(first_byte & 0x1F) << 24 | u32(data[1]) << 16 | u32(data[2]) << 8 | u32(data[3])
		return value, 4
	}

	return 0, -1
}

// Returns the decoded value and number of bytes consumed
fn decode_signed(data []u8) (int, int) {
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

	return 0, -1
}

// Helper function to check if a string is null-terminated
fn is_null_string(data []u8) bool {
	return data.len > 0 && data[0] == 0xFF
}

// According to ECMA-335, here are all the element types.
//
// Name | Value | Remarks
//  ---- | ---- | ----
//  `ELEMENT_TYPE_END` | 0x00 | Marks end of a list
//  `ELEMENT_TYPE_VOID` | 0x01 | &nbsp;
//  `ELEMENT_TYPE_BOOLEAN` | 0x02 | &nbsp;
//  `ELEMENT_TYPE_CHAR` | 0x03 | &nbsp;
//  `ELEMENT_TYPE_I1` | 0x04 | &nbsp;
//  `ELEMENT_TYPE_U1` | 0x05 | &nbsp;
//  `ELEMENT_TYPE_I2` | 0x06 | &nbsp;
//  `ELEMENT_TYPE_U2` | 0x07 | &nbsp;
//  `ELEMENT_TYPE_I4` | 0x08 | &nbsp;
//  `ELEMENT_TYPE_U4` | 0x09 | &nbsp;
//  `ELEMENT_TYPE_I8` | 0x0a | &nbsp;
//  `ELEMENT_TYPE_U8` | 0x0b | &nbsp;
//  `ELEMENT_TYPE_R4` | 0x0c | &nbsp;
//  `ELEMENT_TYPE_R8` | 0x0d | &nbsp;
//  `ELEMENT_TYPE_STRING` | 0x0e | &nbsp;
//  `ELEMENT_TYPE_PTR` | 0x0f | Followed by *type*
//  `ELEMENT_TYPE_BYREF` | 0x10 | Followed by *type*
//  `ELEMENT_TYPE_VALUETYPE` | 0x11 | Followed by _TypeDef_ or _TypeRef_ token
//  `ELEMENT_TYPE_CLASS` | 0x12 | Followed by_ TypeDef_ or _TypeRef_ token
//  `ELEMENT_TYPE_VAR` | 0x13 | Generic parameter in a generic type definition, represented as _number_ (compressed unsigned integer)
//  `ELEMENT_TYPE_ARRAY` | 0x14 | *type* *rank* *boundsCount* *bound1* &hellip; *loCount* *lo1* &hellip;
//  `ELEMENT_TYPE_GENERICINST` | 0x15 | Generic type instantiation. Followed by *type* *type-arg-count* *type-1* &hellip; *type-n*
//  `ELEMENT_TYPE_TYPEDBYREF` | 0x16 | &nbsp;
//  `ELEMENT_TYPE_I` | 0x18 | `System.IntPtr`
//  `ELEMENT_TYPE_U` | 0x19 | `System.UIntPtr`
//  `ELEMENT_TYPE_FNPTR` | 0x1b | Followed by full method signature
//  `ELEMENT_TYPE_OBJECT` | 0x1c | `System.Object`
//  `ELEMENT_TYPE_SZARRAY` | 0x1d | Single-dim array with 0 lower bound
//  `ELEMENT_TYPE_MVAR` | 0x1e | Generic parameter in a generic method definition, represented as *number* (compressed unsigned integer)
//  `ELEMENT_TYPE_CMOD_REQD` | 0x1f | Required modifier: followed by a _TypeDef_ or _TypeRef_ token
//  `ELEMENT_TYPE_CMOD_OPT` | 0x20 | Optional modifier: followed by a _TypeDef_ or _TypeRef_ token
//  `ELEMENT_TYPE_INTERNAL` | 0x21 | Implemented within the CLI
//  `ELEMENT_TYPE_MODIFIER` | 0x40 | Or'd with following element types
//  `ELEMENT_TYPE_SENTINEL` | 0x41 | Sentinel for vararg method signature
//  `ELEMENT_TYPE_PINNED` | 0x45 | Denotes a local variable that points at a pinned

// get_primitive_type returns the V type name of the corresponding
// primitive type, if the provided element_type matches a primitive type
fn get_primitive_type(element_type u32) ?string {
	return match element_type {
		0x02 { 'bool' } // ELEMENT_TYPE_BOOLEAN
		0x03 { 'u8' } // ELEMENT_TYPE_CHAR
		0x04 { 'i8' } // ELEMENT_TYPE_I1
		0x05 { 'u8' } // ELEMENT_TYPE_U1
		0x06 { 'i16' } // ELEMENT_TYPE_I2
		0x07 { 'u16' } // ELEMENT_TYPE_U2
		0x08 { 'i32' } // ELEMENT_TYPE_I4
		0x09 { 'u32' } // ELEMENT_TYPE_U4
		0x0A { 'i64' } // ELEMENT_TYPE_I8
		0x0B { 'u64' } // ELEMENT_TYPE_U8
		0x0C { 'f32' } // ELEMENT_TYPE_R4 (R meaning Real)
		0x0D { 'f64' } // ELEMENT_TYPE_R8
		0x0E { 'string' } // ELEMENT_TYPE_STRING
		0x0F { 'voidptr' } // ELEMENT_TYPE_PTR, followed by type
		else { none }
	}
}
