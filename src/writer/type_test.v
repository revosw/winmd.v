module writer

// import json
pub fn test_comclassid_type() {
}

pub fn test_com_type() {
	// Don't worry about encoding/decoding json, it's not 100% functional yet.
	// type_json := json.decode(Declaration, '{
	// 	"Types":[
	// {
	//   "Name": "IITWordWheel",
	//   "Architectures": [],
	//   "Platform": null,
	//   "Kind": "Com",
	//   "Guid": "8fa0d5a4-dedf-11d0-9a61-00c04fb68bf7",
	//   "Attrs": [],
	//   "Interface": {
	//     "Kind": "ApiRef",
	//     "Name": "IUnknown",
	//     "TargetKind": "Com",
	//     "Api": "System.Com",
	//     "Parents": []
	//   },
	//   "Methods": [
	//     {
	//       "Name": "Open",
	//       "SetLastError": false,
	//       "ReturnType": {
	//         "Kind": "ApiRef",
	//         "Name": "HRESULT",
	//         "TargetKind": "Default",
	//         "Api": "Foundation",
	//         "Parents": []
	//       },
	//       "ReturnAttrs": [],
	//       "Architectures": [],
	//       "Platform": null,
	//       "Attrs": [],
	//       "Params": [
	//         {
	//           "Name": "lpITDB",
	//           "Type": {
	//             "Kind": "ApiRef",
	//             "Name": "IITDatabase",
	//             "TargetKind": "Com",
	//             "Api": "Data.HtmlHelp",
	//             "Parents": []
	//           },
	//           "Attrs": [
	//             "In"
	//           ]
	//         },
	//         {
	//           "Name": "lpszMoniker",
	//           "Type": {
	//             "Kind": "ApiRef",
	//             "Name": "PWSTR",
	//             "TargetKind": "Default",
	//             "Api": "Foundation",
	//             "Parents": []
	//           },
	//           "Attrs": [
	//             "In",
	//             "Const"
	//           ]
	//         },
	//         {
	//           "Name": "dwFlags",
	//           "Type": {
	//             "Kind": "ApiRef",
	//             "Name": "WORD_WHEEL_OPEN_FLAGS",
	//             "TargetKind": "Default",
	//             "Api": "Data.HtmlHelp",
	//             "Parents": []
	//           },
	//           "Attrs": [
	//             "In"
	//           ]
	//         }
	//       ]
	//     },
	//     {
	//       "Name": "Close",
	//       "SetLastError": false,
	//       "ReturnType": {
	//         "Kind": "ApiRef",
	//         "Name": "HRESULT",
	//         "TargetKind": "Default",
	//         "Api": "Foundation",
	//         "Parents": []
	//       },
	//       "ReturnAttrs": [],
	//       "Architectures": [],
	//       "Platform": null,
	//       "Attrs": [],
	//       "Params": []
	//     },
	//     {
	//       "Name": "GetLocaleInfo",
	//       "SetLastError": false,
	//       "ReturnType": {
	//         "Kind": "ApiRef",
	//         "Name": "HRESULT",
	//         "TargetKind": "Default",
	//         "Api": "Foundation",
	//         "Parents": []
	//       },
	//       "ReturnAttrs": [],
	//       "Architectures": [],
	//       "Platform": null,
	//       "Attrs": [],
	//       "Params": [
	//         {
	//           "Name": "pdwCodePageID",
	//           "Type": {
	//             "Kind": "PointerTo",
	//             "Child": {
	//               "Kind": "Native",
	//               "Name": "UInt32"
	//             }
	//           },
	//           "Attrs": [
	//             "In",
	//             "Out"
	//           ]
	//         },
	//         {
	//           "Name": "plcid",
	//           "Type": {
	//             "Kind": "PointerTo",
	//             "Child": {
	//               "Kind": "Native",
	//               "Name": "UInt32"
	//             }
	//           },
	//           "Attrs": [
	//             "In",
	//             "Out"
	//           ]
	//         }
	//       ]
	//     },
	//     {
	//       "Name": "GetSorterInstance",
	//       "SetLastError": false,
	//       "ReturnType": {
	//         "Kind": "ApiRef",
	//         "Name": "HRESULT",
	//         "TargetKind": "Default",
	//         "Api": "Foundation",
	//         "Parents": []
	//       },
	//       "ReturnAttrs": [],
	//       "Architectures": [],
	//       "Platform": null,
	//       "Attrs": [],
	//       "Params": [
	//         {
	//           "Name": "pdwObjInstance",
	//           "Type": {
	//             "Kind": "PointerTo",
	//             "Child": {
	//               "Kind": "Native",
	//               "Name": "UInt32"
	//             }
	//           },
	//           "Attrs": [
	//             "In",
	//             "Out"
	//           ]
	//         }
	//       ]
	//     },
	//   ]
	// }
	// 	]
	// }')!
	type1 := ComType{
		name: 'IITWordWheel'
		architectures: []
		platform: none
		kind: 'Com'
		guid: '8fa0d5a4-dedf-11d0-9a61-00c04fb68bf7'
		attrs: []
		interface: ComInterface{
			kind: 'ApiRef'
			name: 'IUnknown'
			target_kind: 'Com'
			api: 'System.Com'
			parents: []
		}
		methods: [
			ComMethod{
				name: 'Open'
				set_last_error: false
				return_type: ApiRefType{
					kind: 'ApiRef'
					name: 'HRESULT'
					target_kind: 'Default'
					api: 'Foundation'
					parents: []
				}
				return_attrs: []
				architectures: []
				platform: none
				attrs: []
				params: [
					FieldOrParam{
						name: 'lpITDB'
						@type: ApiRefType{
							kind: 'ApiRef'
							name: 'IITDatabase'
							target_kind: 'Com'
							api: 'Data.HtmlHelp'
							parents: []
						}
						attrs: ['In']
					},
					FieldOrParam{
						name: 'lpszMoniker'
						@type: ApiRefType{
							kind: 'ApiRef'
							name: 'PWSTR'
							target_kind: 'Default'
							api: 'Foundation'
							parents: []
						}
						attrs: ['In', 'Const']
					},
					FieldOrParam{
						name: 'dwFlags'
						@type: ApiRefType{
							kind: 'ApiRef'
							name: 'WORD_WHEEL_OPEN_FLAGS'
							target_kind: 'Default'
							api: 'Data.HtmlHelp'
							parents: []
						}
						attrs: ['In']
					},
				]
			},
			ComMethod{
				name: 'Close'
				set_last_error: false
				return_type: ApiRefType{
					kind: 'ApiRef'
					name: 'HRESULT'
					target_kind: 'Default'
					api: 'Foundation'
					parents: []
				}
				return_attrs: []
				architectures: []
				platform: none
				attrs: []
				params: []
			},
			ComMethod{
				name: 'GetLocaleInfo'
				set_last_error: false
				return_type: ApiRefType{
					kind: 'ApiRef'
					name: 'HRESULT'
					target_kind: 'Default'
					api: 'Foundation'
					parents: []
				}
				return_attrs: []
				architectures: []
				platform: none
				attrs: []
				params: [
					FieldOrParam{
						name: 'pdwCodePageID'
						@type: ApiRefType{
							kind: 'ApiRef'
							name: 'WORD_WHEEL_OPEN_FLAGS'
							target_kind: 'Default'
							api: 'Data.HtmlHelp'
							parents: []
						}
						attrs: ['In']
					},
					FieldOrParam{
						name: 'plcid'
						@type: PointerToType{
							kind: 'PointerTo'
							child: NativeType{
								kind: 'Native'
								name: 'UInt32'
							}
						}
						attrs: ['In', 'Out']
					},
					FieldOrParam{
						name: 'plcid'
						@type: PointerToType{
							kind: 'PointerTo'
							child: NativeType{
								kind: 'Native'
								name: 'UInt32'
							}
						}
						attrs: ['In', 'Out']
					},
				]
			},
			ComMethod{
				name: 'GetSorterInstance'
				set_last_error: false
				return_type: ApiRefType{
					kind: 'ApiRef'
					name: 'HRESULT'
					target_kind: 'Default'
					api: 'Foundation'
					parents: []
				}
				return_attrs: []
				architectures: []
				platform: none
				attrs: []
				params: [
					FieldOrParam{
						name: 'pdwObjInstance'
						@type: PointerToType{
							kind: 'PointerTo'
							child: NativeType{
								kind: 'Native'
								name: 'UInt32'
							}
						}
						attrs: ['In', 'Out']
					},
					FieldOrParam{
						name: 'plcid'
						@type: PointerToType{
							kind: 'PointerTo'
							child: NativeType{
								kind: 'Native'
								name: 'UInt32'
							}
						}
						attrs: ['In', 'Out']
					},
				]
			},
		]
	}

	mut writer := JsonWriter.new()

	// for c in type_json.types {
	// 	writer.write_constant(c)
	// }
	writer.write_type(type1)
	println(writer.buf.str())
}

pub fn test_enum_type() {
	// Don't worry about encoding/decoding json, it's not 100% functional yet.
	// type_json := json.decode(Declaration, '{
	// 	"Types":[
	// {
	//   "Name": "DML_CONVOLUTION_MODE",
	//   "Architectures": [],
	//   "Platform": null,
	//   "Kind": "Enum",
	//   "Flags": false,
	//   "Scoped": false,
	//   "Values": [
	//     {
	//       "Name": "DML_CONVOLUTION_MODE_CONVOLUTION",
	//       "Value": 0
	//     },
	//     {
	//       "Name": "DML_CONVOLUTION_MODE_CROSS_CORRELATION",
	//       "Value": 1
	//     }
	//   ],
	//   "IntegerBase": "Int32"
	// },
	// {
	//   "Name": "MLOperatorExecutionType",
	//   "Architectures": [],
	//   "Platform": null,
	//   "Kind": "Enum",
	//   "Flags": false,
	//   "Scoped": true,
	//   "Values": [
	//     {
	//       "Name": "Undefined",
	//       "Value": 0
	//     },
	//     {
	//       "Name": "Cpu",
	//       "Value": 1
	//     },
	//     {
	//       "Name": "D3D12",
	//       "Value": 2
	//     }
	//   ],
	//   "IntegerBase": "UInt32"
	// }
	// 	]
	// }')!
	type1 := EnumType{
		name: 'DML_CONVOLUTION_MODE'
		architectures: []
		platform: none
		kind: 'Enum'
		flags: true
		scoped: true
		values: [
			EnumValue{
				name: 'DML_CONVOLUTION_MODE_CONVOLUTION'
				value: 0
			},
			EnumValue{
				name: 'DML_CONVOLUTION_MODE_CROSS_CORRELATION'
				value: 1
			},
		]
		integer_base: 'Int32'
	}

	type2 := EnumType{
		name: 'MLOperatorExecutionType'
		architectures: []
		platform: none
		kind: 'Enum'
		flags: true
		scoped: true
		values: [
			EnumValue{
				name: 'DML_CONVOLUTION_MODE_CONVOLUTION'
				value: 0
			},
			EnumValue{
				name: 'DML_CONVOLUTION_MODE_CROSS_CORRELATION'
				value: 1
			},
		]
		integer_base: 'UInt32'
	}

	mut writer := JsonWriter.new()

	// for c in type_json.types {
	// 	writer.write_constant(c)
	// }
	writer.write_type(type1)
	writer.write_type(type2)
	println(writer.buf.str())
}

pub fn test_functionpointer_type() {
	// Don't worry about encoding/decoding json, it's not 100% functional yet.
	// type_json := json.decode(Declaration, '{
	// 	"Types":[
	// {
	//   "Name": "DRMCALLBACK",
	//   "Architectures": [],
	//   "Platform": null,
	//   "Kind": "FunctionPointer",
	//   "SetLastError": false,
	//   "ReturnType": {
	//     "Kind": "ApiRef",
	//     "Name": "HRESULT",
	//     "TargetKind": "Default",
	//     "Api": "Foundation",
	//     "Parents": []
	//   },
	//   "ReturnAttrs": [],
	//   "Attrs": [],
	//   "Params": [
	//     {
	//       "Name": "param0",
	//       "Type": {
	//         "Kind": "ApiRef",
	//         "Name": "DRM_STATUS_MSG",
	//         "TargetKind": "Default",
	//         "Api": "Data.RightsManagement",
	//         "Parents": []
	//       },
	//       "Attrs": [
	//         "In"
	//       ]
	//     },
	//     {
	//       "Name": "param1",
	//       "Type": {
	//         "Kind": "ApiRef",
	//         "Name": "HRESULT",
	//         "TargetKind": "Default",
	//         "Api": "Foundation",
	//         "Parents": []
	//       },
	//       "Attrs": [
	//         "In"
	//       ]
	//     },
	//     {
	//       "Name": "param2",
	//       "Type": {
	//         "Kind": "PointerTo",
	//         "Child": {
	//           "Kind": "Native",
	//           "Name": "Void"
	//         }
	//       },
	//       "Attrs": [
	//         "In",
	//         "Out"
	//       ]
	//     },
	//     {
	//       "Name": "param3",
	//       "Type": {
	//         "Kind": "PointerTo",
	//         "Child": {
	//           "Kind": "Native",
	//           "Name": "Void"
	//         }
	//       },
	//       "Attrs": [
	//         "In",
	//         "Out"
	//       ]
	//     }
	//   ]
	// }
	// 	]
	// }')!
	type1 := FunctionPointerType{
		name: 'DRMCALLBACK'
		architectures: []
		platform: none
		kind: 'FunctionPointer'
		set_last_error: false
		return_type: ApiRefType{
			kind: 'ApiRef'
			name: 'HRESULT'
			target_kind: 'Default'
			api: 'Foundation'
			parents: []
		}
		return_attrs: []
		attrs: []
		params: [
			FieldOrParam{
				name: 'param0'
				@type: ApiRefType{
					kind: 'ApiRef'
					name: 'DRM_STATUS_MSG'
					target_kind: 'Default'
					api: 'Data.RightsManagement'
					parents: []
				}
				attrs: ['In']
			},
			FieldOrParam{
				name: 'param1'
				@type: ApiRefType{
					kind: 'ApiRef'
					name: 'HRESULT'
					target_kind: 'Default'
					api: 'Foundation'
					parents: []
				}
				attrs: ['In']
			},
			FieldOrParam{
				name: 'param2'
				@type: PointerToType{
					kind: 'PointerTo'
					child: NativeType{
						kind: 'Native'
						name: 'Void'
					}
				}
				attrs: ['In', 'Out']
			},
			FieldOrParam{
				name: 'param3'
				@type: PointerToType{
					kind: 'PointerTo'
					child: NativeType{
						kind: 'Native'
						name: 'Void'
					}
				}
				attrs: ['In', 'Out']
			},
		]
	}

	mut writer := JsonWriter.new()

	// for c in type_json.types {
	// 	writer.write_constant(c)
	// }
	writer.write_type(type1)
	println(writer.buf.str())
}

pub fn test_nativetypedef_type() {
	// Don't worry about encoding/decoding json, it's not 100% functional yet.
	// type_json := json.decode(Declaration, '{
	// 	"Types":[
	//  {
	//    "Name": "HCURSOR",
	//    "Architectures": [],
	//    "Platform": null,
	//    "Kind": "NativeTypedef",
	//    "AlsoUsableFor": "HICON",
	//    "Def": {
	//      "Kind": "Native",
	//      "Name": "IntPtr"
	//    },
	//    "FreeFunc": "DestroyCursor",
	//    "InvalidHandleValue": 0
	//  },
	//  {
	//    "Name": "HICON",
	//    "Architectures": [],
	//    "Platform": null,
	//    "Kind": "NativeTypedef",
	//    "AlsoUsableFor": null,
	//    "Def": {
	//      "Kind": "Native",
	//      "Name": "IntPtr"
	//    },
	//    "FreeFunc": "DestroyIcon",
	//    "InvalidHandleValue": 0
	//  },
	//  {
	//    "Name": "HCERTSTORE",
	//    "Architectures": [],
	//    "Platform": null,
	//    "Kind": "NativeTypedef",
	//    "AlsoUsableFor": null,
	//    "Def": {
	//      "Kind": "PointerTo",
	//      "Child": {
	//        "Kind": "Native",
	//        "Name": "Void"
	//      }
	//    },
	//    "FreeFunc": null,
	//    "InvalidHandleValue": 0
	//  }
	// 	]
	// }')!
	type1 := NativeTypedefType{
		name: 'HCURSOR'
		architectures: []
		platform: none
		kind: 'NativeTypedef'
		also_usable_for: 'HICON'
		def: NativeType{
			kind: 'Native'
			name: 'IntPtr'
		}
		free_func: 'DestroyIcon'
		invalid_handle_value: 0
	}

	type2 := NativeTypedefType{
		name: 'HICON'
		architectures: []
		platform: none
		kind: 'NativeTypedef'
		also_usable_for: none
		def: NativeType{
			kind: 'Native'
			name: 'IntPtr'
		}
		free_func: 'DestroyIcon'
		invalid_handle_value: 0
	}

	type3 := NativeTypedefType{
		name: 'HCERTSTORE'
		architectures: []
		platform: none
		kind: 'NativeTypedef'
		also_usable_for: none
		def: PointerToType{
			kind: 'PointerTo'
			child: NativeType{
				kind: 'Native'
				name: 'Void'
			}
		}
		free_func: none
		invalid_handle_value: 0
	}

	mut writer := JsonWriter.new()

	// for c in type_json.types {
	// 	writer.write_constant(c)
	// }
	writer.write_type(type1)
	writer.write_type(type2)
	writer.write_type(type3)
	println(writer.buf.str())
}

pub fn test_struct_type() {
	// Don't worry about encoding/decoding json, it's not 100% functional yet.
	// type_json := json.decode(Declaration, '{
	// 	"Types":[
	// {
	//   "Name": "DML_ELEMENT_WISE_ADD1_OPERATOR_DESC",
	//   "Architectures": [],
	//   "Platform": null,
	//   "Kind": "Struct",
	//   "Size": 0,
	//   "PackingSize": 0,
	//   "Fields": [
	//     {
	//       "Name": "ATensor",
	//       "Type": {
	//         "Kind": "PointerTo",
	//         "Child": {
	//           "Kind": "ApiRef",
	//           "Name": "DML_TENSOR_DESC",
	//           "TargetKind": "Default",
	//           "Api": "AI.MachineLearning.DirectML",
	//           "Parents": []
	//         }
	//       },
	//       "Attrs": [
	//         "Const"
	//       ]
	//     },
	//     {
	//       "Name": "BTensor",
	//       "Type": {
	//         "Kind": "PointerTo",
	//         "Child": {
	//           "Kind": "ApiRef",
	//           "Name": "DML_TENSOR_DESC",
	//           "TargetKind": "Default",
	//           "Api": "AI.MachineLearning.DirectML",
	//           "Parents": []
	//         }
	//       },
	//       "Attrs": [
	//         "Const"
	//       ]
	//     },
	//     {
	//       "Name": "OutputTensor",
	//       "Type": {
	//         "Kind": "PointerTo",
	//         "Child": {
	//           "Kind": "ApiRef",
	//           "Name": "DML_TENSOR_DESC",
	//           "TargetKind": "Default",
	//           "Api": "AI.MachineLearning.DirectML",
	//           "Parents": []
	//         }
	//       },
	//       "Attrs": [
	//         "Const"
	//       ]
	//     },
	//     {
	//       "Name": "FusedActivation",
	//       "Type": {
	//         "Kind": "PointerTo",
	//         "Child": {
	//           "Kind": "ApiRef",
	//           "Name": "DML_OPERATOR_DESC",
	//           "TargetKind": "Default",
	//           "Api": "AI.MachineLearning.DirectML",
	//           "Parents": []
	//         }
	//       },
	//       "Attrs": [
	//         "Const"
	//       ]
	//     }
	//   ],
	//   "NestedTypes": []
	// }
	// {
	//   "Name": "DML_ELEMENT_WISE_ASIN_OPERATOR_DESC",
	//   "Architectures": [],
	//   "Platform": null,
	//   "Kind": "Struct",
	//   "Size": 0,
	//   "PackingSize": 0,
	//   "Fields": [
	//     {
	//       "Name": "InputTensor",
	//       "Type": {
	//         "Kind": "PointerTo",
	//         "Child": {
	//           "Kind": "ApiRef",
	//           "Name": "DML_TENSOR_DESC",
	//           "TargetKind": "Default",
	//           "Api": "AI.MachineLearning.DirectML",
	//           "Parents": []
	//         }
	//       },
	//       "Attrs": [
	//         "Const"
	//       ]
	//     },
	//     {
	//       "Name": "OutputTensor",
	//       "Type": {
	//         "Kind": "PointerTo",
	//         "Child": {
	//           "Kind": "ApiRef",
	//           "Name": "DML_TENSOR_DESC",
	//           "TargetKind": "Default",
	//           "Api": "AI.MachineLearning.DirectML",
	//           "Parents": []
	//         }
	//       },
	//       "Attrs": [
	//         "Const"
	//       ]
	//     },
	//     {
	//       "Name": "ScaleBias",
	//       "Type": {
	//         "Kind": "PointerTo",
	//         "Child": {
	//           "Kind": "ApiRef",
	//           "Name": "DML_SCALE_BIAS",
	//           "TargetKind": "Default",
	//           "Api": "AI.MachineLearning.DirectML",
	//           "Parents": []
	//         }
	//       },
	//       "Attrs": [
	//         "Const"
	//       ]
	//     }
	//   ],
	//   "NestedTypes": []
	// }
	// 	]
	// }')!
	type1 := StructOrUnionType{
		name: 'DML_ELEMENT_WISE_ADD1_OPERATOR_DESC'
		architectures: []
		platform: none
		kind: 'Struct'
		size: 0
		packing_size: 0
		fields: [
			FieldOrParam{
				name: 'ATensor'
				@type: PointerToType{
					kind: 'PointerTo'
					child: ApiRefType{
						kind: 'ApiRef'
						name: 'DML_TENSOR_DESC'
						target_kind: 'Default'
						api: 'AI.MachineLearning.DirectML'
						parents: []
					}
				}
				attrs: ['Const']
			},
			FieldOrParam{
				name: 'BTensor'
				@type: PointerToType{
					kind: 'PointerTo'
					child: ApiRefType{
						kind: 'ApiRef'
						name: 'DML_TENSOR_DESC'
						target_kind: 'Default'
						api: 'AI.MachineLearning.DirectML'
						parents: []
					}
				}
				attrs: ['Const']
			},
			FieldOrParam{
				name: 'OutputTensor'
				@type: PointerToType{
					kind: 'PointerTo'
					child: ApiRefType{
						kind: 'ApiRef'
						name: 'DML_TENSOR_DESC'
						target_kind: 'Default'
						api: 'AI.MachineLearning.DirectML'
						parents: []
					}
				}
				attrs: ['Const']
			},
			FieldOrParam{
				name: 'FusedActivation'
				@type: PointerToType{
					kind: 'PointerTo'
					child: ApiRefType{
						kind: 'ApiRef'
						name: 'DML_OPERATOR_DESC'
						target_kind: 'Default'
						api: 'AI.MachineLearning.DirectML'
						parents: []
					}
				}
				attrs: ['Const']
			},
		]
		nested_types: []
	}

	type2 := StructOrUnionType{
		name: 'DML_ELEMENT_WISE_ASIN_OPERATOR_DESC'
		architectures: []
		platform: none
		kind: 'Struct'
		size: 0
		packing_size: 0
		fields: [
			FieldOrParam{
				name: 'InputTensor'
				@type: PointerToType{
					kind: 'PointerTo'
					child: ApiRefType{
						kind: 'ApiRef'
						name: 'DML_TENSOR_DESC'
						target_kind: 'Default'
						api: 'AI.MachineLearning.DirectML'
						parents: []
					}
				}
				attrs: ['Const']
			},
			FieldOrParam{
				name: 'OutputTensor'
				@type: PointerToType{
					kind: 'PointerTo'
					child: ApiRefType{
						kind: 'ApiRef'
						name: 'DML_TENSOR_DESC'
						target_kind: 'Default'
						api: 'AI.MachineLearning.DirectML'
						parents: []
					}
				}
				attrs: ['Const']
			},
			FieldOrParam{
				name: 'ScaleBias'
				@type: PointerToType{
					kind: 'PointerTo'
					child: ApiRefType{
						kind: 'ApiRef'
						name: 'DML_SCALE_BIAS'
						target_kind: 'Default'
						api: 'AI.MachineLearning.DirectML'
						parents: []
					}
				}
				attrs: ['Const']
			},
		]
		nested_types: []
	}

	mut writer := JsonWriter.new()

	// for c in type_json.types {
	// 	writer.write_constant(c)
	// }
	writer.write_type(type1)
	writer.write_type(type2)
	println(writer.buf.str())
}

pub fn test_union_type() {
	// Don't worry about encoding/decoding json, it's not 100% functional yet.
	// type_json := json.decode(Declaration, '{
	// 	"Types":[
	// {
	//   "Name": "WINBIO_PRESENCE_PROPERTIES",
	//   "Architectures": [],
	//   "Platform": null,
	//   "Kind": "Union",
	//   "Size": 0,
	//   "PackingSize": 0,
	//   "Fields": [
	//     {
	//       "Name": "FacialFeatures",
	//       "Type": {
	//         "Kind": "ApiRef",
	//         "Name": "_FacialFeatures_e__Struct",
	//         "TargetKind": "Default",
	//         "Api": "Devices.BiometricFramework",
	//         "Parents": []
	//       },
	//       "Attrs": []
	//     },
	//     {
	//       "Name": "Iris",
	//       "Type": {
	//         "Kind": "ApiRef",
	//         "Name": "_Iris_e__Struct",
	//         "TargetKind": "Default",
	//         "Api": "Devices.BiometricFramework",
	//         "Parents": []
	//       },
	//       "Attrs": []
	//     }
	//   ],
	//   "NestedTypes": [
	//     {
	//       "Name": "_Iris_e__Struct",
	//       "Architectures": [],
	//       "Platform": null,
	//       "Kind": "Struct",
	//       "Size": 0,
	//       "PackingSize": 0,
	//       "Fields": [
	//         {
	//           "Name": "EyeBoundingBox_1",
	//           "Type": {
	//             "Kind": "ApiRef",
	//             "Name": "RECT",
	//             "TargetKind": "Default",
	//             "Api": "Foundation",
	//             "Parents": []
	//           },
	//           "Attrs": []
	//         },
	//         {
	//           "Name": "EyeBoundingBox_2",
	//           "Type": {
	//             "Kind": "ApiRef",
	//             "Name": "RECT",
	//             "TargetKind": "Default",
	//             "Api": "Foundation",
	//             "Parents": []
	//           },
	//           "Attrs": []
	//         },
	//         {
	//           "Name": "PupilCenter_1",
	//           "Type": {
	//             "Kind": "ApiRef",
	//             "Name": "POINT",
	//             "TargetKind": "Default",
	//             "Api": "Foundation",
	//             "Parents": []
	//           },
	//           "Attrs": []
	//         },
	//         {
	//           "Name": "PupilCenter_2",
	//           "Type": {
	//             "Kind": "ApiRef",
	//             "Name": "POINT",
	//             "TargetKind": "Default",
	//             "Api": "Foundation",
	//             "Parents": []
	//           },
	//           "Attrs": []
	//         },
	//         {
	//           "Name": "Distance",
	//           "Type": {
	//             "Kind": "Native",
	//             "Name": "Int32"
	//           },
	//           "Attrs": []
	//         }
	//       ],
	//       "NestedTypes": []
	//     },
	//     {
	//       "Name": "_FacialFeatures_e__Struct",
	//       "Architectures": [],
	//       "Platform": null,
	//       "Kind": "Struct",
	//       "Size": 0,
	//       "PackingSize": 0,
	//       "Fields": [
	//         {
	//           "Name": "BoundingBox",
	//           "Type": {
	//             "Kind": "ApiRef",
	//             "Name": "RECT",
	//             "TargetKind": "Default",
	//             "Api": "Foundation",
	//             "Parents": []
	//           },
	//           "Attrs": []
	//         },
	//         {
	//           "Name": "Distance",
	//           "Type": {
	//             "Kind": "Native",
	//             "Name": "Int32"
	//           },
	//           "Attrs": []
	//         },
	//         {
	//           "Name": "OpaqueEngineData",
	//           "Type": {
	//             "Kind": "ApiRef",
	//             "Name": "_OpaqueEngineData_e__Struct",
	//             "TargetKind": "Default",
	//             "Api": "Devices.BiometricFramework",
	//             "Parents": [
	//               "_FacialFeatures_e__Struct"
	//             ]
	//           },
	//           "Attrs": []
	//         }
	//       ],
	//       "NestedTypes": [
	//         {
	//           "Name": "_OpaqueEngineData_e__Struct",
	//           "Architectures": [],
	//           "Platform": null,
	//           "Kind": "Struct",
	//           "Size": 0,
	//           "PackingSize": 0,
	//           "Fields": [
	//             {
	//               "Name": "AdapterId",
	//               "Type": {
	//                 "Kind": "Native",
	//                 "Name": "Guid"
	//               },
	//               "Attrs": []
	//             },
	//             {
	//               "Name": "Data",
	//               "Type": {
	//                 "Kind": "Array",
	//                 "Shape": {
	//                   "Size": 78
	//                 },
	//                 "Child": {
	//                   "Kind": "Native",
	//                   "Name": "UInt32"
	//                 }
	//               },
	//               "Attrs": []
	//             }
	//           ],
	//           "NestedTypes": []
	//         }
	//       ]
	//     }
	//   ]
	// }
	// 	]
	// }')!

	type1 := StructOrUnionType{
		name: 'WINBIO_PRESENCE_PROPERTIES'
		architectures: []
		platform: none
		kind: 'Union'
		size: 0
		packing_size: 0
		fields: [
			FieldOrParam{
				name: 'FacialFeatures'
				@type: ApiRefType{
					kind: 'ApiRef'
					name: '_FacialFeatures_e__Struct'
					target_kind: 'Default'
					api: 'Devices.BiometricFramework'
					parents: []
				}
				attrs: []
			},
			FieldOrParam{
				name: 'Iris'
				@type: ApiRefType{
					kind: 'ApiRef'
					name: '_Iris_e__Struct'
					target_kind: 'Default'
					api: 'Devices.BiometricFramework'
					parents: []
				}
				attrs: []
			},
		]
		nested_types: [
			StructOrUnionType{
				name: '_Iris_e__Struct'
				architectures: []
				platform: none
				kind: 'Struct'
				size: 0
				packing_size: 0
				fields: [
					FieldOrParam{
						name: 'EyeBoundingBox_1'
						@type: ApiRefType{
							kind: 'ApiRef'
							name: 'RECT'
							target_kind: 'Default'
							api: 'Foundation'
							parents: []
						}
						attrs: []
					},
					FieldOrParam{
						name: 'EyeBoundingBox_2'
						@type: ApiRefType{
							kind: 'ApiRef'
							name: 'RECT'
							target_kind: 'Default'
							api: 'Foundation'
							parents: []
						}
						attrs: []
					},
					FieldOrParam{
						name: 'PupilCenter_1'
						@type: ApiRefType{
							kind: 'ApiRef'
							name: 'POINT'
							target_kind: 'Default'
							api: 'Foundation'
							parents: []
						}
						attrs: []
					},
					FieldOrParam{
						name: 'PupilCenter_2'
						@type: ApiRefType{
							kind: 'ApiRef'
							name: 'POINT'
							target_kind: 'Default'
							api: 'Foundation'
							parents: []
						}
						attrs: []
					},
					FieldOrParam{
						name: 'Distance'
						@type: NativeType{
							kind: 'Native'
							name: 'Int32'
						}
						attrs: []
					},
				]
				nested_types: []
			},
			StructOrUnionType{
				name: '_FacialFeatures_e__Struct'
				architectures: []
				platform: none
				kind: 'Struct'
				size: 0
				packing_size: 0
				fields: [
					FieldOrParam{
						name: 'BoundingBox'
						@type: ApiRefType{
							kind: 'ApiRef'
							name: 'RECT'
							target_kind: 'Default'
							api: 'Foundation'
							parents: []
						}
						attrs: []
					},
					FieldOrParam{
						name: 'Distance'
						@type: NativeType{
							kind: 'Native'
							name: 'Int32'
						}
						attrs: []
					},
					FieldOrParam{
						name: 'OpaqueEngineData'
						@type: ApiRefType{
							kind: 'ApiRef'
							name: '_OpaqueEngineData_e__Struct'
							target_kind: 'Default'
							api: 'Devices.BiometricFramework'
							parents: ['_FacialFeatures_e__Struct']
						}
						attrs: []
					},
				]
				nested_types: [
					StructOrUnionType{
						name: '_OpaqueEngineData_e__Struct'
						architectures: []
						platform: none
						kind: 'Struct'
						size: 0
						packing_size: 0
						fields: [FieldOrParam{
							name: 'AdapterId'
							@type: NativeType{
								kind: 'Native'
								name: 'Guid'
							}
							attrs: []
						}, FieldOrParam{
							name: 'Data'
							@type: ArrayType{
								kind: 'Native'
								shape: ArrayTypeShape{
									size: 78
								}
								child: NativeType{
									kind: 'Native'
									name: 'UInt32'
								}
							}
							attrs: []
						}]
						nested_types: []
					},
				]
			},
		]
	}

	mut writer := JsonWriter.new()

	// for c in type_json.types {
	// 	writer.write_constant(c)
	// }
	writer.write_type(type1)
	println(writer.buf.str())
}

pub fn test_nested_struct() {
	//        {
	//    "Name": "WINBIO_EXTENDED_ENGINE_INFO",
	//    "Architectures": [],
	//    "Platform": null,
	//    "Kind": "Struct",
	//    "Size": 0,
	//    "PackingSize": 0,
	//    "Fields": [
	//        {
	//        "Name": "GenericEngineCapabilities",
	//        "Type": {
	//            "Kind": "Native",
	//            "Name": "UInt32"
	//        },
	//        "Attrs": []
	//        },
	//        {
	//        "Name": "Factor",
	//        "Type": {
	//            "Kind": "Native",
	//            "Name": "UInt32"
	//        },
	//        "Attrs": []
	//        },
	//        {
	//        "Name": "Specific",
	//        "Type": {
	//            "Kind": "ApiRef",
	//            "Name": "_Specific_e__Union",
	//            "TargetKind": "Default",
	//            "Api": "Devices.BiometricFramework",
	//            "Parents": []
	//        },
	//        "Attrs": []
	//        }
	//    ],
	//    "NestedTypes": [
	//        {
	//        "Name": "_Specific_e__Union",
	//        "Architectures": [],
	//        "Platform": null,
	//        "Kind": "Union",
	//        "Size": 0,
	//        "PackingSize": 0,
	//        "Fields": [
	//            {
	//            "Name": "Null",
	//            "Type": {
	//                "Kind": "Native",
	//                "Name": "UInt32"
	//            },
	//            "Attrs": []
	//            },
	//            {
	//            "Name": "FacialFeatures",
	//            "Type": {
	//                "Kind": "ApiRef",
	//                "Name": "_FacialFeatures_e__Struct",
	//                "TargetKind": "Default",
	//                "Api": "Devices.BiometricFramework",
	//                "Parents": [
	//                "_Specific_e__Union"
	//                ]
	//            },
	//            "Attrs": []
	//            },
	//            {
	//            "Name": "Fingerprint",
	//            "Type": {
	//                "Kind": "ApiRef",
	//                "Name": "_Fingerprint_e__Struct",
	//                "TargetKind": "Default",
	//                "Api": "Devices.BiometricFramework",
	//                "Parents": [
	//                "_Specific_e__Union"
	//                ]
	//            },
	//            "Attrs": []
	//            },
	//            {
	//            "Name": "Iris",
	//            "Type": {
	//                "Kind": "ApiRef",
	//                "Name": "_Iris_e__Struct",
	//                "TargetKind": "Default",
	//                "Api": "Devices.BiometricFramework",
	//                "Parents": [
	//                "_Specific_e__Union"
	//                ]
	//            },
	//            "Attrs": []
	//            },
	//            {
	//            "Name": "Voice",
	//            "Type": {
	//                "Kind": "ApiRef",
	//                "Name": "_Voice_e__Struct",
	//                "TargetKind": "Default",
	//                "Api": "Devices.BiometricFramework",
	//                "Parents": [
	//                "_Specific_e__Union"
	//                ]
	//            },
	//            "Attrs": []
	//            }
	//        ],
	//        "NestedTypes": [
	//            {
	//            "Name": "_Voice_e__Struct",
	//            "Architectures": [],
	//            "Platform": null,
	//            "Kind": "Struct",
	//            "Size": 0,
	//            "PackingSize": 0,
	//            "Fields": [
	//                {
	//                "Name": "Capabilities",
	//                "Type": {
	//                    "Kind": "Native",
	//                    "Name": "UInt32"
	//                },
	//                "Attrs": []
	//                },
	//                {
	//                "Name": "EnrollmentRequirements",
	//                "Type": {
	//                    "Kind": "ApiRef",
	//                    "Name": "_EnrollmentRequirements_e__Struct",
	//                    "TargetKind": "Default",
	//                    "Api": "Devices.BiometricFramework",
	//                    "Parents": [
	//                    "_Specific_e__Union",
	//                    "_Voice_e__Struct"
	//                    ]
	//                },
	//                "Attrs": []
	//                }
	//            ],
	//            "NestedTypes": [
	//                {
	//                "Name": "_EnrollmentRequirements_e__Struct",
	//                "Architectures": [],
	//                "Platform": null,
	//                "Kind": "Struct",
	//                "Size": 0,
	//                "PackingSize": 0,
	//                "Fields": [
	//                    {
	//                    "Name": "Null",
	//                    "Type": {
	//                        "Kind": "Native",
	//                        "Name": "UInt32"
	//                    },
	//                    "Attrs": []
	//                    }
	//                ],
	//                "NestedTypes": []
	//                }
	//            ]
	//            },
	//            {
	//            "Name": "_Iris_e__Struct",
	//            "Architectures": [],
	//            "Platform": null,
	//            "Kind": "Struct",
	//            "Size": 0,
	//            "PackingSize": 0,
	//            "Fields": [
	//                {
	//                "Name": "Capabilities",
	//                "Type": {
	//                    "Kind": "Native",
	//                    "Name": "UInt32"
	//                },
	//                "Attrs": []
	//                },
	//                {
	//                "Name": "EnrollmentRequirements",
	//                "Type": {
	//                    "Kind": "ApiRef",
	//                    "Name": "_EnrollmentRequirements_e__Struct",
	//                    "TargetKind": "Default",
	//                    "Api": "Devices.BiometricFramework",
	//                    "Parents": [
	//                    "_Specific_e__Union",
	//                    "_Iris_e__Struct"
	//                    ]
	//                },
	//                "Attrs": []
	//                }
	//            ],
	//            "NestedTypes": [
	//                {
	//                "Name": "_EnrollmentRequirements_e__Struct",
	//                "Architectures": [],
	//                "Platform": null,
	//                "Kind": "Struct",
	//                "Size": 0,
	//                "PackingSize": 0,
	//                "Fields": [
	//                    {
	//                    "Name": "Null",
	//                    "Type": {
	//                        "Kind": "Native",
	//                        "Name": "UInt32"
	//                    },
	//                    "Attrs": []
	//                    }
	//                ],
	//                "NestedTypes": []
	//                }
	//            ]
	//            },
	//            {
	//            "Name": "_Fingerprint_e__Struct",
	//            "Architectures": [],
	//            "Platform": null,
	//            "Kind": "Struct",
	//            "Size": 0,
	//            "PackingSize": 0,
	//            "Fields": [
	//                {
	//                "Name": "Capabilities",
	//                "Type": {
	//                    "Kind": "Native",
	//                    "Name": "UInt32"
	//                },
	//                "Attrs": []
	//                },
	//                {
	//                "Name": "EnrollmentRequirements",
	//                "Type": {
	//                    "Kind": "ApiRef",
	//                    "Name": "_EnrollmentRequirements_e__Struct",
	//                    "TargetKind": "Default",
	//                    "Api": "Devices.BiometricFramework",
	//                    "Parents": [
	//                    "_Specific_e__Union",
	//                    "_Fingerprint_e__Struct"
	//                    ]
	//                },
	//                "Attrs": []
	//                }
	//            ],
	//            "NestedTypes": [
	//                {
	//                "Name": "_EnrollmentRequirements_e__Struct",
	//                "Architectures": [],
	//                "Platform": null,
	//                "Kind": "Struct",
	//                "Size": 0,
	//                "PackingSize": 0,
	//                "Fields": [
	//                    {
	//                    "Name": "GeneralSamples",
	//                    "Type": {
	//                        "Kind": "Native",
	//                        "Name": "UInt32"
	//                    },
	//                    "Attrs": []
	//                    },
	//                    {
	//                    "Name": "Center",
	//                    "Type": {
	//                        "Kind": "Native",
	//                        "Name": "UInt32"
	//                    },
	//                    "Attrs": []
	//                    },
	//                    {
	//                    "Name": "TopEdge",
	//                    "Type": {
	//                        "Kind": "Native",
	//                        "Name": "UInt32"
	//                    },
	//                    "Attrs": []
	//                    },
	//                    {
	//                    "Name": "BottomEdge",
	//                    "Type": {
	//                        "Kind": "Native",
	//                        "Name": "UInt32"
	//                    },
	//                    "Attrs": []
	//                    },
	//                    {
	//                    "Name": "LeftEdge",
	//                    "Type": {
	//                        "Kind": "Native",
	//                        "Name": "UInt32"
	//                    },
	//                    "Attrs": []
	//                    },
	//                    {
	//                    "Name": "RightEdge",
	//                    "Type": {
	//                        "Kind": "Native",
	//                        "Name": "UInt32"
	//                    },
	//                    "Attrs": []
	//                    }
	//                ],
	//                "NestedTypes": []
	//                }
	//            ]
	//            },
	//            {
	//            "Name": "_FacialFeatures_e__Struct",
	//            "Architectures": [],
	//            "Platform": null,
	//            "Kind": "Struct",
	//            "Size": 0,
	//            "PackingSize": 0,
	//            "Fields": [
	//                {
	//                "Name": "Capabilities",
	//                "Type": {
	//                    "Kind": "Native",
	//                    "Name": "UInt32"
	//                },
	//                "Attrs": []
	//                },
	//                {
	//                "Name": "EnrollmentRequirements",
	//                "Type": {
	//                    "Kind": "ApiRef",
	//                    "Name": "_EnrollmentRequirements_e__Struct",
	//                    "TargetKind": "Default",
	//                    "Api": "Devices.BiometricFramework",
	//                    "Parents": [
	//                    "_Specific_e__Union",
	//                    "_FacialFeatures_e__Struct"
	//                    ]
	//                },
	//                "Attrs": []
	//                }
	//            ],
	//            "NestedTypes": [
	//                {
	//                "Name": "_EnrollmentRequirements_e__Struct",
	//                "Architectures": [],
	//                "Platform": null,
	//                "Kind": "Struct",
	//                "Size": 0,
	//                "PackingSize": 0,
	//                "Fields": [
	//                    {
	//                    "Name": "Null",
	//                    "Type": {
	//                        "Kind": "Native",
	//                        "Name": "UInt32"
	//                    },
	//                    "Attrs": []
	//                    }
	//                ],
	//                "NestedTypes": []
	//                }
	//            ]
	//            }
	//        ]
	//        }
	//    ]
	//    }

	type1 := StructOrUnionType{
		name: 'WINBIO_EXTENDED_ENGINE_INFO'
		architectures: []
		platform: none
		kind: 'Struct'
		size: 0
		packing_size: 0
		fields: [
			FieldOrParam{
				name: 'GenericEngineCapabilities'
				@type: NativeType{
					kind: 'Native'
					name: 'UInt32'
				}
				attrs: []
			},
			FieldOrParam{
				name: 'Factor'
				@type: NativeType{
					kind: 'Native'
					name: 'UInt32'
				}
				attrs: []
			},
			FieldOrParam{
				name: 'Specific'
				@type: ApiRefType{
					kind: 'ApiRef'
					name: '_Specific_e__Union'
					target_kind: 'Default'
					api: 'Devices.BiometricFramework'
					parents: []
				}
				attrs: []
			},
		]
		nested_types: [
			StructOrUnionType{
				name: '_Specific_e__Union'
				architectures: []
				platform: none
				kind: 'Union'
				size: 0
				packing_size: 0
				fields: [
					FieldOrParam{
						name: 'Null'
						@type: NativeType{
							kind: 'Native'
							name: 'UInt32'
						}
						attrs: []
					},
					FieldOrParam{
						name: 'FacialFeatures'
						@type: ApiRefType{
							kind: 'ApiRef'
							name: '_FacialFeatures_e__Struct'
							target_kind: 'Default'
							api: 'Foundation'
							parents: ['_Specific_e__Union']
						}
						attrs: []
					},
					FieldOrParam{
						name: 'Fingerprint'
						@type: ApiRefType{
							kind: 'ApiRef'
							name: '_Fingerprint_e__Struct'
							target_kind: 'Default'
							api: 'Devices.BiometricFramework'
							parents: ['_Specific_e__Union']
						}
						attrs: []
					},
					FieldOrParam{
						name: 'Iris'
						@type: ApiRefType{
							kind: 'ApiRef'
							name: '_Iris_e__Struct'
							target_kind: 'Default'
							api: 'Devices.BiometricFramework'
							parents: ['_Specific_e__Union']
						}
						attrs: []
					},
					FieldOrParam{
						name: 'Voice'
						@type: ApiRefType{
							kind: 'ApiRef'
							name: '_Voice_e__Struct'
							target_kind: 'Default'
							api: 'Devices.BiometricFramework'
							parents: ['_Specific_e__Union']
						}
						attrs: []
					},
					FieldOrParam{
						name: 'Voice'
						@type: ApiRefType{
							kind: 'ApiRef'
							name: '_Voice_e__Struct'
							target_kind: 'Default'
							api: 'Devices.BiometricFramework'
							parents: ['_Specific_e__Union']
						}
						attrs: []
					},
				]
				nested_types: [
					StructOrUnionType{
						name: '_Voice_e__Struct'
						architectures: []
						platform: none
						kind: 'Struct'
						size: 0
						packing_size: 0
						fields: [FieldOrParam{
							name: 'Capabilities'
							@type: NativeType{
								kind: 'Native'
								name: 'UInt32'
							}
							attrs: []
						}, FieldOrParam{
							name: 'EnrollmentRequirements'
							@type: ApiRefType{
								kind: 'ApiRef'
								name: '_EnrollmentRequirements_e__Struct'
								target_kind: 'Default'
								api: 'Devices.BiometricFramework'
								parents: ['_Specific_e__Union', '_Voice_e__Struct']
							}
							attrs: []
						}]
						nested_types: [StructOrUnionType{
							name: '_EnrollmentRequirements_e__Struct'
							architectures: []
							platform: none
							kind: 'Struct'
							size: 0
							packing_size: 0
							fields: [FieldOrParam{
								name: 'Null'
								@type: NativeType{
									kind: 'Native'
									name: 'UInt32'
								}
								attrs: []
							}]
							nested_types: []
						}]
					},
					StructOrUnionType{
						name: '_Iris_e__Struct'
						architectures: []
						platform: none
						kind: 'Struct'
						size: 0
						packing_size: 0
						fields: [FieldOrParam{
							name: 'Capabilities'
							@type: NativeType{
								kind: 'Native'
								name: 'UInt32'
							}
							attrs: []
						}, FieldOrParam{
							name: 'EnrollmentRequirements'
							@type: ApiRefType{
								kind: 'ApiRef'
								name: '_EnrollmentRequirements_e__Struct'
								target_kind: 'Default'
								api: 'Devices.BiometricFramework'
								parents: ['_Specific_e__Union', '_Voice_e__Struct']
							}
							attrs: []
						}]
						nested_types: [StructOrUnionType{
							name: '_EnrollmentRequirements_e__Struct'
							architectures: []
							platform: none
							kind: 'Struct'
							size: 0
							packing_size: 0
							fields: [FieldOrParam{
								name: 'Null'
								@type: NativeType{
									kind: 'Native'
									name: 'UInt32'
								}
								attrs: []
							}]
							nested_types: []
						}]
					},
					StructOrUnionType{
						name: '_Fingerprint_e__Struct'
						architectures: []
						platform: none
						kind: 'Struct'
						size: 0
						packing_size: 0
						fields: [FieldOrParam{
							name: 'Capabilities'
							@type: NativeType{
								kind: 'Native'
								name: 'UInt32'
							}
							attrs: []
						}, FieldOrParam{
							name: 'EnrollmentRequirements'
							@type: ApiRefType{
								kind: 'ApiRef'
								name: '_EnrollmentRequirements_e__Struct'
								target_kind: 'Default'
								api: 'Devices.BiometricFramework'
								parents: ['_Specific_e__Union', '_Fingerprint_e__Struct']
							}
							attrs: []
						}]
						nested_types: [StructOrUnionType{
							name: '_EnrollmentRequirements_e__Struct'
							architectures: []
							platform: none
							kind: 'Struct'
							size: 0
							packing_size: 0
							fields: [FieldOrParam{
								name: 'GeneralSamples'
								@type: NativeType{
									kind: 'Native'
									name: 'UInt32'
								}
								attrs: []
							}, FieldOrParam{
								name: 'Center'
								@type: NativeType{
									kind: 'Native'
									name: 'UInt32'
								}
								attrs: []
							}, FieldOrParam{
								name: 'TopEdge'
								@type: NativeType{
									kind: 'Native'
									name: 'UInt32'
								}
								attrs: []
							}, FieldOrParam{
								name: 'BottomEdge'
								@type: NativeType{
									kind: 'Native'
									name: 'UInt32'
								}
								attrs: []
							}, FieldOrParam{
								name: 'LeftEdge'
								@type: NativeType{
									kind: 'Native'
									name: 'UInt32'
								}
								attrs: []
							}, FieldOrParam{
								name: 'RightEdge'
								@type: NativeType{
									kind: 'Native'
									name: 'UInt32'
								}
								attrs: []
							}]
							nested_types: []
						}]
					},
					StructOrUnionType{
						name: '_FacialFeatures_e__Struct'
						architectures: []
						platform: none
						kind: 'Struct'
						size: 0
						packing_size: 0
						fields: [FieldOrParam{
							name: 'Capabilities'
							@type: NativeType{
								kind: 'Native'
								name: 'UInt32'
							}
							attrs: []
						}, FieldOrParam{
							name: 'EnrollmentRequirements'
							@type: ApiRefType{
								kind: 'ApiRef'
								name: '_EnrollmentRequirements_e__Struct'
								target_kind: 'Default'
								api: 'Devices.BiometricFramework'
								parents: ['_Specific_e__Union', '_FacialFeatures_e__Struct']
							}
							attrs: []
						}]
						nested_types: [StructOrUnionType{
							name: '_EnrollmentRequirements_e__Struct'
							architectures: []
							platform: none
							kind: 'Struct'
							size: 0
							packing_size: 0
							fields: [FieldOrParam{
								name: 'Null'
								@type: NativeType{
									kind: 'Native'
									name: 'UInt32'
								}
								attrs: []
							}]
							nested_types: []
						}]
					},
				]
			},
		]
	}

	mut writer := JsonWriter.new()

	// for c in type_json.types {
	// 	writer.write_constant(c)
	// }
	writer.write_type(type1)
	println(writer.buf.str())
}
