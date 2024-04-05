module writer

import strings

pub struct JsonWriter {
pub mut:
	buf strings.Builder
}

pub fn JsonWriter.new() JsonWriter {
	mut w := JsonWriter{
		buf: strings.new_builder(1024 * 256)
	}
	w.buf.write_string('module win32\n\n')

	return w
}

pub fn (mut w JsonWriter) write_struct(@struct string) {
}

pub fn (mut w JsonWriter) write_method(method string) {
}

pub fn (mut w JsonWriter) write_enum(@enum string) {
}

pub fn (mut w JsonWriter) write_constant(constant Constant) {
	str := match constant {
		BcryptAlgHandleConstant {
			'pub const ${constant.name.to_lower()} = u32(${constant.value})\n\n'
		}
		ByteConstant {
			'pub const ${constant.name.to_lower()} = u8(${constant.value})\n\n'
		}
		DpiAwarenessContextConstant {
			'pub const ${constant.name.to_lower()} = i32(${constant.value})\n\n'
		}
		GuidConstant {
			'pub const ${constant.name.to_lower()} = Guid.new(${constant.value})\n\n'
		}
		HandleConstant {
			'pub const ${constant.name.to_lower()} = i32(${constant.value})\n\n'
		}
		HbitmapConstant {
			'pub const ${constant.name.to_lower()} = i32(${constant.value})\n\n'
		}
		HkeyConstant {
			'pub const ${constant.name.to_lower()} = i32(${constant.value})\n\n'
		}
		HresultConstant {
			'pub const ${constant.name.to_lower()} = i32(${constant.value})\n\n'
		}
		HtreeitemConstant {
			'pub const ${constant.name.to_lower()} = i32(${constant.value})\n\n'
		}
		HwndConstant {
			'pub const ${constant.name.to_lower()} = i32(${constant.value})\n\n'
		}
		Int32Constant {
			'pub const ${constant.name.to_lower()} = i32(${constant.value})\n\n'
		}
		NtStatusConstant {
			'pub const ${constant.name.to_lower()} = i32(${constant.value})\n\n'
		}
		PropertyKeyConstant {
			'pub const ${constant.name.to_lower()} = PropertyKeyValue{fmtid: ${constant.value.fmtid} pid: ${constant.value.pid}}\n\n'
		}
		PstrConstant {
			'pub const ${constant.name.to_lower()} = i32(${constant.value})\n\n'
		}
		PwstrConstant {
			'pub const ${constant.name.to_lower()} = i32(${constant.value})\n\n'
		}
		SocketConstant {
			'pub const ${constant.name.to_lower()} = u32(${constant.value})\n\n'
		}
		StringConstant {
			'pub const ${constant.name.to_lower()} = \'${constant.value}\'\n\n'
		}
		UInt16Constant {
			'pub const ${constant.name.to_lower()} = u16(${constant.value})\n\n'
		}
		UInt32Constant {
			'pub const ${constant.name.to_lower()} = u32(${constant.value})\n\n'
		}
	}

	w.buf.write_string(str)
}

pub fn (mut w JsonWriter) write_attribute(attribute string) {
}

pub struct Declaration {
pub:
	constants       []Constant @[json: Constants]
	types           []Type     @[json: Types]
	functions       []Function @[json: Functions]
	unicode_aliases []string   @[json: UnicodeAliases]
}

pub struct Type {
pub:
	name          string   @[json: Name]
	architectures []string @[json: Architectures]
	platform      string   @[json: Platform]
	kind          string   @[json: Kind]
	flags         bool     @[json: Flags]
	scoped        bool     @[json: Scoped]
	value         []Value  @[json: Values]
	integer_base  string   @[json: IntegerBase]
}

pub struct Function {
pub:
	name           string        @[json: Name]
	set_last_error bool          @[json: SetLastError]
	dll_import     string        @[json: DllImport]
	return_type    struct {
		kind        string   @[json: Kind]
		name        string   @[json: Name]
		target_kind string   @[json: TargetKind]
		api         string   @[json: Api]
		parents     []string @[json: Parents]
	}

	return_attrs  []string        @[json: ReturnAttrs]
	architectures []string        @[json: Architectures]
	platform      string          @[json: Platform]
	attrs         []string        @[json: Attrs]
	params        []struct {
		name  string        @[json: Name]
		@type struct {
			kind        string   @[json: Kind]
			name        string   @[json: Name]
			target_kind string   @[json: TargetKind]
			api         string   @[json: Api]
			parents     []string @[json: Parents]
		} @[json: Type]

		attrs []string @[json: Attrs]
	}
}

pub struct Value {
pub:
	name  string @[json: Name]
	value int    @[json: Value]
}

// export enum ReturnTypeKind {
//     APIRef = "ApiRef",
//     LPArray = "LPArray",
//     Native = "Native",
//     PointerTo = "PointerTo",
// }

// export interface Function {
//     Name:          string;
//     SetLastError:  boolean;
//     DllImport:     string;
//     ReturnType:    Type;
//     ReturnAttrs:   any[];
//     Architectures: any[];
//     Platform:      Platform | null;
//     Attrs:         any[];
//     Params:        Param[];
// }

// export interface Param {
//     Name:  string;
//     Type:  ParamType;
//     Attrs: Attr[];
// }

// export enum Attr {
//     Const = "Const",
//     In = "In",
//     Optional = "Optional",
//     Out = "Out",
// }

// export interface ParamType {
//     Kind:             ReturnTypeKind;
//     Name?:            string;
//     TargetKind?:      TargetKind;
//     Api?:             API;
//     Parents?:         any[];
//     Child?:           Type;
//     NullNullTerm?:    boolean;
//     CountConst?:      number;
//     CountParamIndex?: number;
// }

// export enum Platform {
//     Windows10010240 = "windows10.0.10240",
//     Windows50 = "windows5.0",
//     Windows512600 = "windows5.1.2600",
// }

// export interface TypeElement {
//     Name:           string;
//     Architectures:  any[];
//     Platform:       null;
//     Kind:           NestedTypeKind;
//     Flags?:         boolean;
//     Scoped?:        boolean;
//     Values?:        Value[];
//     IntegerBase?:   ValueType;
//     AlsoUsableFor?: null;
//     Def?:           Def;
//     FreeFunc?:      null | string;
//     Size?:          number;
//     PackingSize?:   number;
//     Fields?:        TypeField[];
//     NestedTypes?:   TypeNestedType[];
//     SetLastError?:  boolean;
//     ReturnType?:    ReturnType;
//     ReturnAttrs?:   any[];
//     Attrs?:         any[];
//     Params?:        FieldElement[];
// }

// export interface Def {
//     Kind:   ReturnTypeKind;
//     Name?:  string;
//     Child?: ReturnType;
// }

// export interface ReturnType {
//     Kind: ReturnTypeKind;
//     Name: string;
// }

// export interface TypeField {
//     Name:  string;
//     Type:  FieldType;
//     Attrs: string[];
// }

// export interface FieldType {
//     Kind:        PurpleKind;
//     Name?:       string;
//     TargetKind?: TargetKind;
//     Api?:        API;
//     Parents?:    any[];
//     Shape?:      Shape;
//     Child?:      ReturnType;
// }

// export enum PurpleKind {
//     APIRef = "ApiRef",
//     Array = "Array",
//     Native = "Native",
// }

// export interface Shape {
//     Size: number;
// }

// export enum NestedTypeKind {
//     Enum = "Enum",
//     FunctionPointer = "FunctionPointer",
//     NativeTypedef = "NativeTypedef",
//     Struct = "Struct",
//     Union = "Union",
// }

// export interface TypeNestedType {
//     Name:          string;
//     Architectures: any[];
//     Platform:      null;
//     Kind:          NestedTypeKind;
//     Size:          number;
//     PackingSize:   number;
//     Fields:        NestedTypeField[];
//     NestedTypes:   NestedTypeNestedType[];
// }

// export interface NestedTypeField {
//     Name:  string;
//     Type:  Type;
//     Attrs: any[];
// }

// export interface NestedTypeNestedType {
//     Name:          ValueType;
//     Architectures: any[];
//     Platform:      null;
//     Kind:          NestedTypeKind;
//     Size:          number;
//     PackingSize:   number;
//     Fields:        FieldElement[];
//     NestedTypes:   any[];
// }

// export interface FieldElement {
//     Name:  string;
//     Type:  ReturnType;
//     Attrs: Attr[];
// }

// export interface Value {
//     Name:  string;
//     Value: number;
// }
