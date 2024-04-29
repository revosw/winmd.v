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
		typ := get_field_or_param_or_return_type(param.@type)
		w.buf.write_string('${typ}, ')
	}
	w.buf.write_string(')\n\n')
}

pub fn (mut w JsonWriter) write_type(@type ApiType) {
	match @type {
		// ❓ Maybe done?
		ComClassIDType {
			w.buf.write_string('pub const C.${@type.name} = Guid.new(${@type.guid})\n\n')
		}
		// ❌ Not done
		ComType {
			w.buf.write_string('@[typedef]\nstruct C.${@type.name} {\nvtbl &C.${@type.name}Vtbl\n}\n\n')
			w.buf.write_string('@[typedef]\nstruct C.${@type.name}Vtbl {\nppv &voidptr\n}\n\n')

			for method in @type.methods {
				w.buf.write_string('fn (mut v C.${@type.name}) ${method.name}(')

				for param in method.params {
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
					typ := get_field_or_param_or_return_type(param.@type)
					w.buf.write_string('${typ}, ')
				}

				w.buf.write_string(') ')

				typ := get_field_or_param_or_return_type(method.return_type)
				w.buf.writeln(typ)
			}
		}
		// ❓ Maybe done?
		EnumType {
			if @type.flags {
				w.buf.write_string('@[flags]\n')
			}
			integer_base := get_native_type(@type.integer_base)
            
			w.buf.write_string('enum C.${@type.name} as ${integer_base} {\n')
			for a in @type.values {
				w.buf.write_string('${a.name} ${a.value}\n')
			}
			w.buf.write_string('}')
		}
		// ❌ Not done
		FunctionPointerType {
			//
		}
		// ❌ Not done
		NativeTypedefType {
			typ := get_field_or_param_or_return_type(@type.def)

			w.buf.write_string('type C.${@type.name} = ${typ}\n\n')
		}
		// ❓ Maybe done?
		StructOrUnionType {
            mut already_generated_anon_structs := []string{}

			// There is a maximum of 4 levels of NestedTypes nesting
			for nested_type1 in @type.nested_types {
				for nested_type2 in nested_type1.nested_types {
					for nested_type3 in nested_type2.nested_types {
						for nested_type4 in nested_type2.nested_types {
							for nested_type5 in nested_type2.nested_types {
								for nested_type6 in nested_type2.nested_types {
                                    if nested_type6.name in already_generated_anon_structs {
                                        continue
                                    }

									if nested_type6.kind == 'Struct' {
										w.buf.write_string('struct ')
									} else if nested_type6.kind == 'Union' {
										w.buf.write_string('union ')
									}

									w.buf.write_string('C.${nested_type6.name} {\n')
									for a in nested_type6.fields {
                                        w.buf.write_string('\t')
										get_name_and_type(mut w, a)
									}
									w.buf.write_string('}\n\n')

                                    already_generated_anon_structs << nested_type6.name
								}
                                if nested_type5.name in already_generated_anon_structs {
                                    continue
                                }
								if nested_type5.kind == 'Struct' {
									w.buf.write_string('struct ')
								} else if nested_type5.kind == 'Union' {
									w.buf.write_string('union ')
								}

								w.buf.write_string('C.${nested_type5.name} {\n')
								for a in nested_type5.fields {
                                    w.buf.write_string('\t')
									get_name_and_type(mut w, a)
								}
								w.buf.write_string('}\n\n')

                                already_generated_anon_structs << nested_type5.name
							}
                            if nested_type4.name in already_generated_anon_structs {
                                continue
                            }
							if nested_type4.kind == 'Struct' {
								w.buf.write_string('struct ')
							} else if nested_type4.kind == 'Union' {
								w.buf.write_string('union ')
							}

							w.buf.write_string('C.${nested_type4.name} {\n')
							for a in nested_type4.fields {
                                w.buf.write_string('\t')
								get_name_and_type(mut w, a)
							}
							w.buf.write_string('}\n\n')

                            already_generated_anon_structs << nested_type4.name
						}
                        if nested_type3.name in already_generated_anon_structs {
                            continue
                        }
						if nested_type3.kind == 'Struct' {
							w.buf.write_string('struct ')
						} else if nested_type3.kind == 'Union' {
							w.buf.write_string('union ')
						}

						w.buf.write_string('C.${nested_type3.name} {\n')
						for a in nested_type3.fields {
                            w.buf.write_string('\t')
							get_name_and_type(mut w, a)
						}
						w.buf.write_string('}\n\n')

                        already_generated_anon_structs << nested_type3.name
					}
                    if nested_type2.name in already_generated_anon_structs {
                        continue
                    }
					if nested_type2.kind == 'Struct' {
						w.buf.write_string('struct ')
					} else if nested_type2.kind == 'Union' {
						w.buf.write_string('union ')
					}

					w.buf.write_string('C.${nested_type2.name} {\n')
					for a in nested_type2.fields {
                        w.buf.write_string('\t')
						get_name_and_type(mut w, a)
					}
					w.buf.write_string('}\n\n')

                    already_generated_anon_structs << nested_type2.name
				}
                if nested_type1.name in already_generated_anon_structs {
                    continue
                }
				if nested_type1.kind == 'Struct' {
					w.buf.write_string('struct ')
				} else if nested_type1.kind == 'Union' {
					w.buf.write_string('union ')
				}

				w.buf.write_string('C.${nested_type1.name} {\n')
				for a in nested_type1.fields {
                    w.buf.write_string('\t')
					get_name_and_type(mut w, a)
				}
				w.buf.write_string('}\n\n')

                already_generated_anon_structs << nested_type1.name
			}
            if @type.name in already_generated_anon_structs {
                return
            }

			w.buf.write_string('struct C.${@type.name} {\n')

			for field in @type.fields {
                w.buf.write_string('\t')
				get_name_and_type(mut w, field)

				// A field consists of multiple parts.
				// struct C.SomeName { [mut] <name> [?][&]<type> }

				// 1. Maybe output mut
				// if 'Out' in field.attrs {
				// 	w.buf.write_string('mut ')
				// }

				// 2. Output field name
				// w.buf.write_string('${field.name} ')

				// 3. Output optional
				// if 'Optional' in field.attrs {
				// 	w.buf.write_string('?')
				// }

				// 4. Output reference/pointer/array marker and type name. The maximum number of indirections across the entire Windows API surface is 4
			}

			w.buf.write_string('} ')
		}
	}

	w.buf.write_string('\n\n')
}

fn get_name_and_type(mut w JsonWriter, field_or_param FieldOrParam) {
	// A field consists of multiple parts.
	// struct C.SomeName { [mut] <name> [?][&]<type> }

	// 1. Maybe output mut
	if 'Out' in field_or_param.attrs {
		w.buf.write_string('mut ')
	}

	// 2. Output field name
	w.buf.write_string('${field_or_param.name} ')

	// 3. Output optional
	if 'Optional' in field_or_param.attrs {
		w.buf.write_string('?')
	}

	// 4. Output reference/pointer/array marker and type name. The maximum number of indirections across the entire Windows API surface is 4
	typ := get_field_or_param_or_return_type(field_or_param.@type)
	w.buf.write_string('${typ}\n')
}

fn get_field_or_param_or_return_type(@type DataType) string {
	return match @type {
		PointerToType {
			match @type.child {
				PointerToType {
					match @type.child.child {
						PointerToType {
							match @type.child.child.child {
								PointerToType {
									''
								}
								NativeType {
									'&&&${get_native_type(@type.child.child.child.name)}'
								}
								ApiRefType {
									'&&&C.${@type.child.child.child.name}'
								}
							}
						}
						NativeType {
							'&&${get_native_type(@type.child.child.name)}'
						}
						ApiRefType {
							'&&C.${@type.child.child.name}'
						}
					}
				}
				NativeType {
					'&${get_native_type(@type.child.name)}'
				}
				ApiRefType {
					'&C.${@type.child.name}'
				}
			}
		}
		NativeType {
			'${get_native_type(@type.name)}'
		}
		ApiRefType {
			'C.${@type.name}'
		}
		ArrayType {
			match @type.child {
				ArrayType {
					match @type.child.child {
						ArrayType {
							match @type.child.child.child {
								ArrayType {
									''
								}
								NativeType {
									'[][][]${get_native_type(@type.child.child.child.name)}'
								}
								ApiRefType {
									'[][][]C.${@type.child.child.child.name}'
								}
							}
						}
						NativeType {
							'[][]${get_native_type(@type.child.child.name)}'
						}
						ApiRefType {
							'[][]C.${@type.child.child.name}'
						}
					}
				}
				NativeType {
					'[]${get_native_type(@type.child.name)}'
				}
				ApiRefType {
					'[]C.${@type.child.name}'
				}
			}
		}
	}
}

fn get_native_type(type_name string) string {
    return match type_name {
        'UInt64' { 'u64' }
        'UInt32' { 'u32' }
        'UInt16' { 'u16' }
        'Byte'   { 'u8' }
        'Int64'  { 'i64' }
        'Int32'  { 'i32' }
        'Int16'  { 'i16' }
        'SByte'  { 'i8' }
        'Guid'   { 'Guid' }
        'Void'   { 'void' }
        'IntPtr' { '&i32' }
        else { 'TODO ${type_name}' }
    }
}

// fn to_v_symbol(sym string) string {
// 	mut builder := strings.new_builder(300)
// 	lowercased := sym.to_lower()
//     println(lowercased)
// 	// The first letter should never
// 	// be followed by an underscore
//     println(sym)
//
//     builder.write_u8(sym[0])
//
// 	for i in 1 .. sym.len - 1 {
//         if sym[i-1].is_lower() && sym[i].is_lower() {
//             builder.write_u8(lowercase[i])
//         }
//         if sym[i-1].is_lower() && sym[i].is_upper() {
//             builder.write_string('_${lowercased[i].ascii_str()}')
//             builder.write_u8(lowercase[i+1])
//         }
//         if sym[i-1].is_upper() && sym[i].is_lower() {
//             builder.write_u8(lowercase[i])
//             builder.write_u8(lowercase[i+1])
//         }
//         if sym[i-1].is_upper() && sym[i].is_upper() {
//             builder.write_u8(lowercase[i])
//         }
//
// 		match sym[i] {
// 			`A`...`Z` {
// 			}
// 			else {
// 				builder.write_u8(lowercased[i])
// 			}
// 		}
// 	}
//
//     return builder.str()
// }

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

type ArrayTypeChild = ApiRefType | ArrayType | NativeType

pub struct ArrayType {
pub:
	kind  string         @[json: Kind]
	shape ArrayTypeShape @[json: Shape]
	child ArrayTypeChild @[json: Child]
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
