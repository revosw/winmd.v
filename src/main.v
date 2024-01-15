module main

// import metadata
// import writer
import os
import json

fn main() {
	// unsafe {
	// 	if C.RoInitialize(RoInitType.singlethreaded) != 0 {
	// 		panic('Out of memory, how is that even possible?')
	// 	}

	// 	// from_winmd()

	// 	C.RoUninitialize()
	// }
	from_json()!
}

struct Declaration {
	constants []Constant @[json: Constants]
	types     []Type     @[json: Types]
	functions []Function @[json: Functions]
	unicode_aliases []string @[json: UnicodeAliases]
}

struct Constant {
	name  string        @[json: Name]
	@type struct {
		kind string @[json: Kind]
		name string @[json: Name]
		target_kind ?string @[json: TargetKind]
		api ?string @[json: Api]
		parents []string @[json: Parents]
	} @[json: Type]

	valuetype string   @[json: ValueType]
	value     int      @[json: Value]
	attrs     []string @[json: Attrs]
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

struct Type {
	name          string   @[json: Name]
	architectures []string @[json: Architectures]
	platform      string   @[json: Platform]
	kind          string   @[json: Kind]
	flags         bool     @[json: Flags]
	scoped        bool     @[json: Scoped]
	values        []Values @[json: Values]
	integer_base  string   @[json: IntegerBase]
}

struct Function {
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

struct Values {
	name  string @[json: Name]
	value int    @[json: Value]
}

fn from_json() ! {
	mut file := os.open_file('./file.txt', 'w')!
	defer {
		file.close()
	}
	content := os.read_file('/dev/v/winmd/src/jsonmetadata/Devices.SerialCommunication.json')!
	out := json.decode(Declaration, content)!

	println(out)
	// for c in out.constants {
	// 	c.name
	// }
}

// fn from_winmd() ? {
// 	mut w := new_writer()
//
// 	for type_def in md().@import.type_defs {
// 		base_type := type_def.get_base_type()?
//
// 		// Check if the type is special
// 		match base_type.get_name() {
// 			"Enum" {
// 				w.write_enum(type_def)
// 			}
// 			// "Attribute" {
// 			// 	w.write_attribute(type_def)
// 			// }
// 			else {
// 				w.write_struct(type_def)
//
// 				println("\n\nStarting new method iteration\n")
// 				for method in type_def.methods {
// 					println("nice")
// 					w.write_method(method)
// 				}
// 			}
// 		}
//
// 		// type_def.get_name()
// 		// type_def.get_namespace()
// 		// println(type_def.get_attributes().hex_full())
// 		// println(base_type.get_name())
// 		// println(base_type.get_namespace())
//
// 		// for field in type_def.fields_iter {
// 		// 	println(field)
// 		// }
// 		// s := GenStruct{
// 		//
// 		// }
// 		// w.write_struct(type_def)
// 		// type_def
//
// 		// for member in type_def.members {
// 		// 	println(member)
// 		// }
//
// 		// break
// 	}
// }

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