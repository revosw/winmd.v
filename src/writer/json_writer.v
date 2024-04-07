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

pub fn (mut w JsonWriter) write_function(function Function) {
	w.buf.write_string('fn C.${function.name}(')
	for param in function.params {
		// A parameter consists of multiple parts.
		// fn C.SomeMethod([mut] <name> [?][&]<type>,)

		// 1. Maybe output mut
		if 'Out' in param.attrs {
			w.buf.write_string('mut ')
		}

		// 2. Output parameter name
		w.buf.write_string('${param.name} ')

		// 3. Output optional
		if 'Optional' in param.attrs {
			w.buf.write_string('?')
		}

		// 4. Output reference/pointer/array marker and type name. The maximum number of indirections across the entire Windows API surface is 4
		match param.@type {
			PointerToType {
				match param.@type.child {
					PointerToType {
						match param.@type.child.child {
							PointerToType {
								match param.@type.child.child.child {
									PointerToType {}
									NativeType {
										w.buf.write_string('&&&${param.@type.child.child.child.name}, ')
									}
									ApiRefType {
										w.buf.write_string('&&&${param.@type.child.child.child.name}, ')
									}
								}
							}
							NativeType {
								w.buf.write_string('&&${param.@type.child.child.name}, ')
							}
							ApiRefType {
								w.buf.write_string('&&${param.@type.child.child.name}, ')
							}
						}
					}
					NativeType {
						w.buf.write_string('&${param.@type.child.name}, ')
					}
					ApiRefType {
						w.buf.write_string('&${param.@type.child.name}, ')
					}
				}
			}
			NativeType {
				w.buf.write_string('${param.@type.name}, ')
			}
			ApiRefType {
				w.buf.write_string('${param.@type.name}, ')
			}
			ArrayType {
                match param.@type.child {
                    ArrayType {
                        match param.@type.child.child {
                            ArrayType {
                                match param.@type.child.child.child {
                                    ArrayType {}
                                    NativeType {
				                        w.buf.write_string('[][][]${param.@type.child.child.child.name}')
                                    }
                                    ApiRefType {
				                        w.buf.write_string('[][][]${param.@type.child.child.child.name}')
                                    }
                                }
                            }
                            NativeType {
                                w.buf.write_string('[][]${param.@type.child.child.name}')
                            }
                            ApiRefType {
                                w.buf.write_string('[][]${param.@type.child.child.name}')
                            }
                        }
                    }
                    NativeType {
                        w.buf.write_string('[]${param.@type.child.name}')
                    }
                    ApiRefType {
                        w.buf.write_string('[]${param.@type.child.name}')
                    }
                }
			}
		}
	}
	w.buf.write_string(')\n\n')
}

pub fn (mut w JsonWriter) write_type(@type ApiType) {
	str := match @type {
		ComClassIDType {
			'C.${@type.name}\n\n'
		}
		ComType {
			'C.${@type.name}\n\n'
		}
		EnumType {
			'C.${@type.name}\n\n'
		}
		FunctionPointerType {
			'C.${@type.name}\n\n'
		}
		NativeTypedefType {
			'C.${@type.name}\n\n'
		}
		StructType {
			'C.${@type.name}\n\n'
		}
		UnionType {
			'C.${@type.name}\n\n'
		}
	}

	w.buf.write_string(str)
}

pub struct Declaration {
pub:
	constants       []Constant @[json: Constants]
	types           []ApiType  @[json: Types]
	functions       []Function @[json: Functions]
	unicode_aliases []string   @[json: UnicodeAliases]
}

pub struct Value {
pub:
	name  string @[json: Name]
	value int    @[json: Value]
}

// There are four types of data - Native, ApiRef, Array and PointerTo.
//
// Data of type Native are plain values without any relation
// to a specific Windows API. Examples are strings, GUIDs or UInt32.
//
// Data of type ApiRef are reference types tightly related to a specific
// Windows API, such as a socket handle in the WinSock API.
//
// Data of type Array are pointers with a byte size.
//
// Data of type PointerTo is a pointer to a struct, function or void.

pub struct NativeType {
pub:
	kind string @[json: Kind]
	name string @[json: Name]
}

pub struct ApiRefType {
pub:
	kind        string   @[json: Kind]
	name        string   @[json: Name]
	target_kind string   @[json: TargetKind]
	api         string   @[json: Api]
	parents     []string @[json: Parents]
}

pub struct ArrayTypeShape {
pub:
	size u32 @[json: Size]
}

type ArrayTypeChild = NativeType | ApiRefType | ArrayType

pub struct ArrayType {
pub:
	kind  string         @[json: Kind]
	shape ArrayTypeShape @[json: Shape]
	child ArrayTypeChild       @[json: Child]
}

type PointerToTypeChild = ApiRefType | NativeType | PointerToType

pub struct PointerToType {
pub:
	kind  string             @[json: Kind]
	child PointerToTypeChild @[json: Child]
}

pub type DataType = ApiRefType | ArrayType | NativeType | PointerToType

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
