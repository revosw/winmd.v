module writer

import encoding.binary

// https://learn.microsoft.com/en-us/windows/win32/api/guiddef/ns-guiddef-guid
pub struct Guid {
	data1 u32
	data2 u16
	data3 u16
	data4 []u8
}

pub fn Guid.new(guid string) Guid {
	parts := guid.split('-')
	return Guid{
		data1: parts[0].u32()
		data2: parts[1].u16()
		data3: parts[2].u16()
		data4: '0x${parts[3]}'.u8_array()
	}
}

// There is not a single constant with Int16 type.name, no reason to implement
pub type Constant = ByteConstant
	| GuidConstant
	| HresultConstant
	| Int32Constant
	| StringConstant
	| UInt16Constant
	| UInt32Constant

// PropertyKeyConstant
// NtStatusConstant
// PstrConstant
// PwstrConstant
// SocketConstant
// HandleConstant
// BcryptAlgHandleConstant
// HkeyConstant
// HbitmapConstant
// HtreeitemConstant
// DpiAwarenessContextConstant
// HwndConstant
pub struct StringConstant {
pub:
	name  string        @[json: Name]
	@type struct {
		kind string @[json: Kind]
		name string @[json: Name]
	} @[json: Type]

	value_type string   @[json: ValueType]
	value      string   @[json: Value]
	attrs      []string @[json: Attrs]
}

pub struct Int32Constant {
pub:
	name  string        @[json: Name]
	@type struct {
		kind string @[json: Kind]
		name string @[json: Name]
	} @[json: Type]

	value_type string   @[json: ValueType]
	value      i32      @[json: Value]
	attrs      []string @[json: Attrs]
}

pub struct UInt32Constant {
pub:
	name  string        @[json: Name]
	@type struct {
		kind string @[json: Kind]
		name string @[json: Name]
	} @[json: Type]

	value_type string   @[json: ValueType]
	value      u32      @[json: Value]
	attrs      []string @[json: Attrs]
}

pub struct UInt16Constant {
pub:
	name  string        @[json: Name]
	@type struct {
		kind string @[json: Kind]
		name string @[json: Name]
	} @[json: Type]

	value_type string   @[json: ValueType]
	value      u16      @[json: Value]
	attrs      []string @[json: Attrs]
}

pub struct ByteConstant {
pub:
	name  string        @[json: Name]
	@type struct {
		kind string @[json: Kind]
		name string @[json: Name]
	} @[json: Type]

	value_type string   @[json: ValueType]
	value      u8       @[json: Value]
	attrs      []string @[json: Attrs]
}

pub struct GuidConstant {
pub:
	name  string        @[json: Name]
	@type struct {
		kind string @[json: Kind]
		name string @[json: Name]
	} @[json: Type]

	value_type string   @[json: ValueType]
	value      string   @[json: Value]
	attrs      []string @[json: Attrs]
}

pub struct HresultConstant {
pub:
	name  string        @[json: Name]
	@type struct {
		kind        string   @[json: Kind]
		name        string   @[json: Name]
		target_kind string   @[json: TargetKind]
		api         string   @[json: Api]
		parents     []string @[json: Parents]
	} @[json: Type]

	value_type string   @[json: ValueType]
	value      i32      @[json: Value]
	attrs      []string @[json: Attrs]
}

// Next up: create rest of the constant types
