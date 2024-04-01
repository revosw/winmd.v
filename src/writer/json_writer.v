module writer

import os

pub struct JsonWriter {
pub mut:
	out os.File
}

pub fn JsonWriter.new() JsonWriter {
	os.mkdir_all('win32') or { panic("Couldn't create the 'win32' dir") }
	mut w := JsonWriter{
		out: os.create('win32/win32.c.v') or { panic("Couldn't create win32.c.v file") }
	}

	w.out.write_string('module win32\n\n') or { panic("Couldn't write to win32 file") }

	return w
}

pub fn (mut w JsonWriter) write_struct(@struct string) {
	// if s := gen_struct_from_type_def(type_def) {
	// 	mut struct_output := 'struct C.${s.struct_name} {'

	// 	for field_name, field_type in s.struct_fields {
	// 		struct_output += '\n\t${field_name} ${field_type}'
	// 	}

	// 	struct_output += '\n}\n\n'

	// 	// println(struct_output)
	// 	w.out.write_string(struct_output) or { eprintln(err) }
	// }
}

pub fn (mut w JsonWriter) write_method(method string) {
	// if s := gen_method_from_method_def(method) {
	// 	mut method_output := 'pub fn (recv ${s.receiver_type}) ${s.method_name}('

	// 	for param_name, param_type in s.params {
	// 		method_output += '${param_name} ${param_type},'
	// 	}
	// 	method_output.trim_right(',')

	// 	method_output += ') {}\n\n'

	// 	// println(method_output)
	// 	w.out.write_string(method_output) or { eprintln(err) }
	// }
}

pub fn (mut w JsonWriter) write_enum(@enum string) {
	// s := gen_enum_from_type_def(type_def)
	// mut enum_output := 'enum ${s.enum_name} {'

	// for enum_name, enum_value in s.enum_values {
	// 	enum_output += '\n\t${enum_name} = ${enum_value}'
	// }

	// enum_output += '\n}\n\n'

	// // println(enum_output)
	// w.out.write(enum_output.bytes()) or { eprintln(err) }
}

pub fn (mut w JsonWriter) write_constant(constant Constant) {
	str := match constant {
		StringConstant {
			'pub const ${constant.name.to_lower()} = \'${constant.value}\'\n\n'
		}
		Int32Constant {
			'pub const ${constant.name.to_lower()} = i32(${constant.value})\n\n'
		}
		UInt32Constant {
			'pub const ${constant.name.to_lower()} = u32(${constant.value})\n\n'
		}
		UInt16Constant {
			'pub const ${constant.name.to_lower()} = u16(${constant.value})\n\n'
		}
		ByteConstant {
			'pub const ${constant.name.to_lower()} = u8(${constant.value})\n\n'
		}
		HresultConstant {
			'pub const ${constant.name.to_lower()} = i32(${constant.value})\n\n'
		}
		GuidConstant {
			'pub const ${constant.name.to_lower()} = Guid.new(${constant.value})\n\n'
		}
	}

	w.out.write_string(str) or { eprintln(err) }
}

pub fn (mut w JsonWriter) write_attribute(attribute string) {
	// if base_type := type_def.get_base_type() {
	// 	s := gen_attribute_from_type_def(type_def)
	// 	mut attribute_output := '[${s.attribute_name} '
	//
	// 	for attribute_name, attribute_value in s.attribute_map {
	// 		attribute_output += '${attribute_name}: \'${attribute_value}\'; '
	// 	}
	//
	// 	attribute_output += ']'
	//
	// 	// println(attribute_output)
	// 	w.out.write(attribute_output.bytes()) or { eprintln(err) }
	// }
}

pub struct Declaration {
pub:
	constants       []Constant @[json: Constants]
	types           []Type     @[json: Types]
	functions       []Function @[json: Functions]
	unicode_aliases []string   @[json: UnicodeAliases]
}

// export interface Constant {
//     Type:      ConstantType;
//     ValueType: ValueType;
// }

// export interface ConstantType {
//     Kind:        ReturnTypeKind;
//     Name:        ValueType;
//     TargetKind?: TargetKind;
//     Api?:        API;
//     Parents?:    string[];
// }
// export enum ValueType {
//     AnonymousEStruct = "_Anonymous_e__Struct",
//     Bool = "BOOL",
//     Bstr = "BSTR",
//     Char = "Char",
//     Handle = "HANDLE",
//     Hresult = "HRESULT",
//     Int32 = "Int32",
//     Ntstatus = "NTSTATUS",
//     UInt16 = "UInt16",
//     UInt32 = "UInt32",
//     UInt64 = "UInt64",
//     Void = "Void",
//     Win32Error = "WIN32_ERROR",
// }

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
