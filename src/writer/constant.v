module writer

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

pub type Constant = BcryptAlgHandleConstant
	| ByteConstant
	| DpiAwarenessContextConstant
	| GuidConstant
	| HandleConstant
	| HbitmapConstant
	| HkeyConstant
	| HresultConstant
	| HtreeitemConstant
	| HwndConstant
	| Int32Constant
	| NtStatusConstant
	| PropertyKeyConstant
	| PstrConstant
	| PwstrConstant
	| SocketConstant
	| StringConstant
	| UInt16Constant
	| UInt32Constant

pub struct BcryptAlgHandleConstant {
pub:
	@type      ApiRefType @[json: Type]
	name       string     @[json: Name]
	value_type string     @[json: ValueType]
	value      u32        @[json: Value]
	attrs      []string   @[json: Attrs]
}

pub struct ByteConstant {
pub:
	@type      NativeType @[json: Type]
	name       string     @[json: Name]
	value_type string     @[json: ValueType]
	value      u8         @[json: Value]
	attrs      []string   @[json: Attrs]
}

pub struct DpiAwarenessContextConstant {
pub:
	@type      ApiRefType @[json: Type]
	name       string     @[json: Name]
	value_type string     @[json: ValueType]
	value      i32        @[json: Value]
	attrs      []string   @[json: Attrs]
}

pub struct GuidConstant {
pub:
	@type      NativeType @[json: Type]
	name       string     @[json: Name]
	value_type string     @[json: ValueType]
	value      string     @[json: Value]
	attrs      []string   @[json: Attrs]
}

pub struct HandleConstant {
pub:
	@type      ApiRefType @[json: Type]
	name       string     @[json: Name]
	value_type string     @[json: ValueType]
	value      i32        @[json: Value]
	attrs      []string   @[json: Attrs]
}

pub struct HbitmapConstant {
pub:
	@type      ApiRefType @[json: Type]
	name       string     @[json: Name]
	value_type string     @[json: ValueType]
	value      i32        @[json: Value]
	attrs      []string   @[json: Attrs]
}

pub struct Int32Constant {
pub:
	@type      NativeType @[json: Type]
	name       string     @[json: Name]
	value_type string     @[json: ValueType]
	value      i32        @[json: Value]
	attrs      []string   @[json: Attrs]
}

pub struct NtStatusConstant {
pub:
	@type      ApiRefType @[json: Type]
	name       string     @[json: Name]
	value_type string     @[json: ValueType]
	value      i32        @[json: Value]
	attrs      []string   @[json: Attrs]
}

pub struct HkeyConstant {
pub:
	@type      ApiRefType @[json: Type]
	name       string     @[json: Name]
	value_type string     @[json: ValueType]
	value      i32        @[json: Value]
	attrs      []string   @[json: Attrs]
}

pub struct HtreeitemConstant {
pub:
	@type      ApiRefType @[json: Type]
	name       string     @[json: Name]
	value_type string     @[json: ValueType]
	value      i32        @[json: Value]
	attrs      []string   @[json: Attrs]
}

pub struct HresultConstant {
pub:
	@type      ApiRefType @[json: Type]
	name       string     @[json: Name]
	value_type string     @[json: ValueType]
	value      i32        @[json: Value]
	attrs      []string   @[json: Attrs]
}

pub struct HwndConstant {
pub:
	@type      ApiRefType @[json: Type]
	name       string     @[json: Name]
	value_type string     @[json: ValueType]
	value      i32        @[json: Value]
	attrs      []string   @[json: Attrs]
}

pub struct PropertyKeyValue {
pub:
	fmtid string @[json: Fmtid]
	pid   u16    @[json: Pid]
}

pub struct PropertyKeyConstant {
pub:
	@type      ApiRefType       @[json: Type]
	name       string           @[json: Name]
	value_type string           @[json: ValueType]
	value      PropertyKeyValue @[json: Value]
	attrs      []string         @[json: Attrs]
}

pub struct PstrConstant {
pub:
	@type      ApiRefType @[json: Type]
	name       string     @[json: Name]
	value_type string     @[json: ValueType]
	value      i32        @[json: Value]
	attrs      []string   @[json: Attrs]
}

pub struct PwstrConstant {
pub:
	@type      ApiRefType @[json: Type]
	name       string     @[json: Name]
	value_type string     @[json: ValueType]
	value      i32        @[json: Value]
	attrs      []string   @[json: Attrs]
}

pub struct SocketConstant {
pub:
	@type      ApiRefType @[json: Type]
	name       string     @[json: Name]
	value_type string     @[json: ValueType]
	value      u32        @[json: Value]
	attrs      []string   @[json: Attrs]
}

pub struct StringConstant {
pub:
	@type      NativeType @[json: Type]
	name       string     @[json: Name]
	value_type string     @[json: ValueType]
	value      string     @[json: Value]
	attrs      []string   @[json: Attrs]
}

pub struct UInt16Constant {
pub:
	@type      NativeType @[json: Type]
	name       string     @[json: Name]
	value_type string     @[json: ValueType]
	value      u16        @[json: Value]
	attrs      []string   @[json: Attrs]
}

pub struct UInt32Constant {
pub:
	@type      NativeType @[json: Type]
	name       string     @[json: Name]
	value_type string     @[json: ValueType]
	value      u32        @[json: Value]
	attrs      []string   @[json: Attrs]
}
