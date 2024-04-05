module writer

// import json

pub fn test_bcryptalghandle_constant() {
	// Don't worry about encoding/decoding json, it's not 100% functional yet.
	// constant_json := json.decode(Declaration, '{
	// 	"Constants":[
	//  ,{
	//  	"Name":"BCRYPT_RSA_ALG_HANDLE"
	//  	,"Type":{"Kind":"ApiRef","Name":"BCRYPT_ALG_HANDLE","TargetKind":"Default","Api":"Security.Cryptography","Parents":[]}
	//  	,"ValueType":"UInt32"
	//  	,"Value":225
	//  	,"Attrs":[]
	//  }
	//  ,{
	//  	"Name":"BCRYPT_ECDSA_ALG_HANDLE"
	//  	,"Type":{"Kind":"ApiRef","Name":"BCRYPT_ALG_HANDLE","TargetKind":"Default","Api":"Security.Cryptography","Parents":[]}
	//  	,"ValueType":"UInt32"
	//  	,"Value":241
	//  	,"Attrs":[]
	//  }
	// 	]
	// }')!

	constant1 := BcryptAlgHandleConstant{
		name: 'BCRYPT_RSA_ALG_HANDLE'
		@type: ApiRefType{
			kind: 'ApiRef'
			name: 'BCRYPT_ALG_HANDLE'
			target_kind: 'Default'
			api: 'Security.Cryptography'
			parents: []
		}
		value_type: 'UInt32'
		value: 225
		attrs: []
	}

	constant2 := BcryptAlgHandleConstant{
		name: 'BCRYPT_ECDSA_ALG_HANDLE'
		@type: ApiRefType{
			kind: 'ApiRef'
			name: 'BCRYPT_ALG_HANDLE'
			target_kind: 'Default'
			api: 'Security.Cryptography'
			parents: []
		}
		value_type: 'UInt32'
		value: 241
		attrs: []
	}

	mut writer := JsonWriter.new()
	// for c in constant_json.constants {
	// 	writer.write_constant(c)
	// }
	writer.write_constant(constant1)
	writer.write_constant(constant2)
	println(writer.buf.str())
}

pub fn test_byte_constant() {
	// Don't worry about encoding/decoding json, it's not 100% functional yet.
	// constant_json := json.decode(Declaration, '{
	// 	"Constants":[
	//     {
	//     "Name": "ALLJOYN_MEMBER_ANNOTATE_DEPRECATED",
	//     "Type": {
	//         "Kind": "Native",
	//         "Name": "Byte"
	//     },
	//     "ValueType": "Byte",
	//     "Value": 2,
	//     "Attrs": []
	//     }
	//     {
	//     "Name": "ALLJOYN_MEMBER_ANNOTATE_SESSIONCAST",
	//     "Type": {
	//         "Kind": "Native",
	//         "Name": "Byte"
	//     },
	//     "ValueType": "Byte",
	//     "Value": 4,
	//     "Attrs": []
	//     }
	// 	]
	// }')!

	constant1 := ByteConstant{
		name: 'ALLJOYN_MEMBER_ANNOTATE_DEPRECATED'
		@type: NativeType{
			kind: 'Native'
			name: 'Byte'
		}
		value_type: 'Byte'
		value: 2
		attrs: []
	}

	constant2 := ByteConstant{
		name: 'ALLJOYN_MEMBER_ANNOTATE_SESSIONCAST'
		@type: NativeType{
			kind: 'Native'
			name: 'Byte'
		}
		value_type: 'Byte'
		value: 4
		attrs: []
	}

	mut writer := JsonWriter.new()
	// for c in constant_json.constants {
	// 	writer.write_constant(c)
	// }
	writer.write_constant(constant1)
	writer.write_constant(constant2)
	println(writer.buf.str())
}

pub fn test_dpiawarenesscontext_constant() {
	// Don't worry about encoding/decoding json, it's not 100% functional yet.
	// constant_json := json.decode(Declaration, '{
	// 	"Constants":[
	//   ,{
	//   	"Name":"DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE"
	//   	,"Type":{"Kind":"ApiRef","Name":"DPI_AWARENESS_CONTEXT","TargetKind":"Default","Api":"UI.HiDpi","Parents":[]}
	//   	,"ValueType":"Int32"
	//   	,"Value":-3
	//   	,"Attrs":[]
	//   }
	//   ,{
	//   	"Name":"DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2"
	//   	,"Type":{"Kind":"ApiRef","Name":"DPI_AWARENESS_CONTEXT","TargetKind":"Default","Api":"UI.HiDpi","Parents":[]}
	//   	,"ValueType":"Int32"
	//   	,"Value":-4
	//   	,"Attrs":[]
	//   }
	// 	]
	// }')!

	constant1 := DpiAwarenessContextConstant{
		name: 'DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE'
		@type: ApiRefType{
			kind: 'ApiRef'
			name: 'DPI_AWARENESS_CONTEXT'
			target_kind: 'Default'
			api: 'UI.HiDpi'
			parents: []
		}
		value_type: 'Int32'
		value: -3
		attrs: []
	}

	constant2 := DpiAwarenessContextConstant{
		name: 'DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2'
		@type: ApiRefType{
			kind: 'ApiRef'
			name: 'DPI_AWARENESS_CONTEXT'
			target_kind: 'Default'
			api: 'UI.HiDpi'
			parents: []
		}
		value_type: 'Int32'
		value: -4
		attrs: []
	}

	mut writer := JsonWriter.new()
	// for c in constant_json.constants {
	// 	writer.write_constant(c)
	// }
	writer.write_constant(constant1)
	writer.write_constant(constant2)
	println(writer.buf.str())
}

pub fn test_guid_constant() {
	// Don't worry about encoding/decoding json, it's not 100% functional yet.
	// constant_json := json.decode(Declaration, '{
	// 	"Constants":[
	//     {
	//     "Name": "CLSID_ITStdBreaker",
	//     "Type": {
	//         "Kind": "Native",
	//         "Name": "Guid"
	//     },
	//     "ValueType": "String",
	//     "Value": "4662daaf-d393-11d0-9a56-00c04fb68bf7",
	//     "Attrs": []
	//     }
	//     {
	//     "Name": "CLSID_ITEngStemmer",
	//     "Type": {
	//         "Kind": "Native",
	//         "Name": "Guid"
	//     },
	//     "ValueType": "String",
	//     "Value": "8fa0d5a8-dedf-11d0-9a61-00c04fb68bf7",
	//     "Attrs": []
	//     }
	// 	]
	// }')!

	constant1 := GuidConstant{
		name: 'CLSID_ITStdBreaker'
		@type: NativeType{
			kind: 'Native'
			name: 'Guid'
		}
		value_type: 'String'
		value: '4662daaf-d393-11d0-9a56-00c04fb68bf7'
		attrs: []
	}

	constant2 := GuidConstant{
		name: 'CLSID_ITEngStemmer'
		@type: NativeType{
			kind: 'Native'
			name: 'Guid'
		}
		value_type: 'String'
		value: '8fa0d5a8-dedf-11d0-9a61-00c04fb68bf7'
		attrs: []
	}

	mut writer := JsonWriter.new()
	// for c in constant_json.constants {
	// 	writer.write_constant(c)
	// }
	writer.write_constant(constant1)
	writer.write_constant(constant2)
	println(writer.buf.str())
}

pub fn test_handle_constant() {
	// Don't worry about encoding/decoding json, it's not 100% functional yet.
	// constant_json := json.decode(Declaration, '{
	// 	"Constants":[
	//  {
	//    "Name": "INVALID_HANDLE_VALUE",
	//    "Type": {
	//      "Kind": "ApiRef",
	//      "Name": "HANDLE",
	//      "TargetKind": "Default",
	//      "Api": "Foundation",
	//      "Parents": []
	//    },
	//    "ValueType": "Int32",
	//    "Value": -1,
	//    "Attrs": []
	//  }
	// 	]
	// }')!

	// This is the only HANDLE constant that exists in the entire API
	constant := HandleConstant{
		name: 'INVALID_HANDLE_VALUE'
		@type: ApiRefType{
			kind: 'ApiRef'
			name: 'HANDLE'
			target_kind: 'Default'
			api: 'Foundation'
			parents: []
		}
		value_type: 'Int32'
		value: -1
		attrs: []
	}

	mut writer := JsonWriter.new()
	// for c in constant_json.constants {
	// 	writer.write_constant(c)
	// }
	writer.write_constant(constant)
	println(writer.buf.str())
}

pub fn test_hbitmap_constant() {
	// Don't worry about encoding/decoding json, it's not 100% functional yet.
	// constant_json := json.decode(Declaration, '{
	// 	"Constants":[
	//  ,{
	//  	"Name":"HBMMENU_CALLBACK"
	//  	,"Type":{"Kind":"ApiRef","Name":"HBITMAP","TargetKind":"Default","Api":"Graphics.Gdi","Parents":[]}
	//  	,"ValueType":"Int32"
	//  	,"Value":-1
	//  	,"Attrs":[]
	//  }
	//  ,{
	//  	"Name":"HBMMENU_SYSTEM"
	//  	,"Type":{"Kind":"ApiRef","Name":"HBITMAP","TargetKind":"Default","Api":"Graphics.Gdi","Parents":[]}
	//  	,"ValueType":"Int32"
	//  	,"Value":1
	//  	,"Attrs":[]
	//  }
	// 	]
	// }')!

	constant1 := HbitmapConstant{
		name: 'HBMMENU_CALLBACK'
		@type: ApiRefType{
			kind: 'ApiRef'
			name: 'HBITMAP'
			target_kind: 'Default'
			api: 'Graphics.Gdi'
			parents: []
		}
		value_type: 'Int32'
		value: -1
		attrs: []
	}

	constant2 := HbitmapConstant{
		name: 'HBMMENU_SYSTEM'
		@type: ApiRefType{
			kind: 'ApiRef'
			name: 'HBITMAP'
			target_kind: 'Default'
			api: 'Graphics.Gdi'
			parents: []
		}
		value_type: 'Int32'
		value: 1
		attrs: []
	}

	mut writer := JsonWriter.new()
	// for c in constant_json.constants {
	// 	writer.write_constant(c)
	// }
	writer.write_constant(constant1)
	writer.write_constant(constant2)
	println(writer.buf.str())
}

pub fn test_hkey_constant() {
	// Don't worry about encoding/decoding json, it's not 100% functional yet.
	// constant_json := json.decode(Declaration, '{
	// 	"Constants":[
	//  {
	//    "Name": "HKEY_PERFORMANCE_TEXT",
	//    "Type": {
	//      "Kind": "ApiRef",
	//      "Name": "HKEY",
	//      "TargetKind": "Default",
	//      "Api": "System.Registry",
	//      "Parents": []
	//    },
	//    "ValueType": "Int32",
	//    "Value": -2147483568,
	//    "Attrs": []
	//  }
	//  {
	//    "Name": "HKEY_PERFORMANCE_NLSTEXT",
	//    "Type": {
	//      "Kind": "ApiRef",
	//      "Name": "HKEY",
	//      "TargetKind": "Default",
	//      "Api": "System.Registry",
	//      "Parents": []
	//    },
	//    "ValueType": "Int32",
	//    "Value": -2147483552,
	//    "Attrs": []
	//  }
	// 	]
	// }')!

	constant1 := HkeyConstant{
		name: 'HKEY_PERFORMANCE_TEXT'
		@type: ApiRefType{
			kind: 'ApiRef'
			name: 'HKEY'
			target_kind: 'Default'
			api: 'System.Registry'
			parents: []
		}
		value_type: 'Int32'
		value: -2147483568
		attrs: []
	}

	constant2 := HkeyConstant{
		name: 'HKEY_PERFORMANCE_NLSTEXT'
		@type: ApiRefType{
			kind: 'ApiRef'
			name: 'HKEY'
			target_kind: 'Default'
			api: 'System.Registry'
			parents: []
		}
		value_type: 'Int32'
		value: -2147483552
		attrs: []
	}

	mut writer := JsonWriter.new()
	// for c in constant_json.constants {
	// 	writer.write_constant(c)
	// }
	writer.write_constant(constant1)
	writer.write_constant(constant2)
	println(writer.buf.str())
}

pub fn test_hresult_constant() {
	// Don't worry about encoding/decoding json, it's not 100% functional yet.
	// constant_json := json.decode(Declaration, '{
	// 	"Constants":[
	//     {
	//     "Name": "E_WORDTOOLONG",
	//     "Type": {
	//         "Kind": "ApiRef",
	//         "Name": "HRESULT",
	//         "TargetKind": "Default",
	//         "Api": "Foundation",
	//         "Parents": []
	//     },
	//     "ValueType": "Int32",
	//     "Value": -2147479457,
	//     "Attrs": []
	//     }
	//     {
	//     "Name": "E_BADINDEXFLAGS",
	//     "Type": {
	//         "Kind": "ApiRef",
	//         "Name": "HRESULT",
	//         "TargetKind": "Default",
	//         "Api": "Foundation",
	//         "Parents": []
	//     },
	//     "ValueType": "Int32",
	//     "Value": -2147479456,
	//     "Attrs": []
	//     }
	// 	]
	// }')!

	constant1 := HresultConstant{
		name: 'E_WORDTOOLONG'
		@type: ApiRefType{
			kind: 'ApiRef'
			name: 'HRESULT'
			target_kind: 'Default'
			api: 'Foundation'
			parents: []
		}
		value_type: 'Int32'
		value: -2147479457
		attrs: []
	}

	constant2 := HresultConstant{
		name: 'E_BADINDEXFLAGS'
		@type: ApiRefType{
			kind: 'ApiRef'
			name: 'HRESULT'
			target_kind: 'Default'
			api: 'Foundation'
			parents: []
		}
		value_type: 'Int32'
		value: -2147479456
		attrs: []
	}

	mut writer := JsonWriter.new()
	// for c in constant_json.constants {
	// 	writer.write_constant(c)
	// }
	writer.write_constant(constant1)
	writer.write_constant(constant2)
	println(writer.buf.str())
}

pub fn test_htreeitem_constant() {
	// Don't worry about encoding/decoding json, it's not 100% functional yet.
	// constant_json := json.decode(Declaration, '{
	// 	"Constants":[
	//  ,{
	//  	"Name":"TVI_FIRST"
	//  	,"Type":{"Kind":"ApiRef","Name":"HTREEITEM","TargetKind":"Default","Api":"UI.Controls","Parents":[]}
	//  	,"ValueType":"Int32"
	//  	,"Value":-65535
	//  	,"Attrs":[]
	//  }
	//  ,{
	//  	"Name":"TVI_LAST"
	//  	,"Type":{"Kind":"ApiRef","Name":"HTREEITEM","TargetKind":"Default","Api":"UI.Controls","Parents":[]}
	//  	,"ValueType":"Int32"
	//  	,"Value":-65534
	//  	,"Attrs":[]
	//  }
	// 	]
	// }')!

	constant1 := HtreeitemConstant{
		name: 'TVI_FIRST'
		@type: ApiRefType{
			kind: 'ApiRef'
			name: 'HTREEITEM'
			target_kind: 'Default'
			api: 'UI.Controls'
			parents: []
		}
		value_type: 'Int32'
		value: -65535
		attrs: []
	}

	constant2 := HtreeitemConstant{
		name: 'TVI_LAST'
		@type: ApiRefType{
			kind: 'ApiRef'
			name: 'HTREEITEM'
			target_kind: 'Default'
			api: 'UI.Controls'
			parents: []
		}
		value_type: 'Int32'
		value: -65534
		attrs: []
	}

	mut writer := JsonWriter.new()
	// for c in constant_json.constants {
	// 	writer.write_constant(c)
	// }
	writer.write_constant(constant1)
	writer.write_constant(constant2)
	println(writer.buf.str())
}

pub fn test_hwnd_constant() {
	// Don't worry about encoding/decoding json, it's not 100% functional yet.
	// constant_json := json.decode(Declaration, '{
	// 	"Constants":[
	//  {
	//    "Name": "HWND_DESKTOP",
	//    "Type": {
	//      "Kind": "ApiRef",
	//      "Name": "HWND",
	//      "TargetKind": "Default",
	//      "Api": "Foundation",
	//      "Parents": []
	//    },
	//    "ValueType": "Int32",
	//    "Value": 0,
	//    "Attrs": []
	//  }
	//  {
	//    "Name": "HWND_TOP",
	//    "Type": {
	//      "Kind": "ApiRef",
	//      "Name": "HWND",
	//      "TargetKind": "Default",
	//      "Api": "Foundation",
	//      "Parents": []
	//    },
	//    "ValueType": "Int32",
	//    "Value": 0,
	//    "Attrs": []
	//  }
	// 	]
	// }')!

	constant1 := HwndConstant{
		name: 'HWND_DESKTOP'
		@type: ApiRefType{
			kind: 'ApiRef'
			name: 'HWND'
			target_kind: 'Default'
			api: 'Foundation'
			parents: []
		}
		value_type: 'Int32'
		value: 0
		attrs: []
	}

	constant2 := HwndConstant{
		name: 'HWND_TOP'
		@type: ApiRefType{
			kind: 'ApiRef'
			name: 'HWND'
			target_kind: 'Default'
			api: 'Foundation'
			parents: []
		}
		value_type: 'Int32'
		value: 0
		attrs: []
	}

	mut writer := JsonWriter.new()
	// for c in constant_json.constants {
	// 	writer.write_constant(c)
	// }
	writer.write_constant(constant1)
	writer.write_constant(constant2)
	println(writer.buf.str())
}

pub fn test_int32_constant() {
	// Don't worry about encoding/decoding json, it's not 100% functional yet.
	// constant_json := json.decode(Declaration, '{
	// 	"Constants":[
	//    {
	//    "Name": "HHACT_ZOOM",
	//    "Type": {
	//        "Kind": "Native",
	//        "Name": "Int32"
	//    },
	//    "ValueType": "Int32",
	//    "Value": 19,
	//    "Attrs": []
	//    }
	//    {
	//    "Name": "HHACT_TOC_NEXT",
	//    "Type": {
	//        "Kind": "Native",
	//        "Name": "Int32"
	//    },
	//    "ValueType": "Int32",
	//    "Value": 20,
	//    "Attrs": []
	//    }
	// 	]
	// }')!

	constant1 := Int32Constant{
		name: 'HHACT_ZOOM'
		@type: NativeType{
			kind: 'Native'
			name: 'Int32'
		}
		value_type: 'Int32'
		value: 19
		attrs: []
	}

	constant2 := Int32Constant{
		name: 'ID_GDF_THUMBNAIL_STR'
		@type: NativeType{
			kind: 'Native'
			name: 'Int32'
		}
		value_type: 'Int32'
		value: 20
		attrs: []
	}

	mut writer := JsonWriter.new()
	// for c in constant_json.constants {
	// 	writer.write_constant(c)
	// }
	writer.write_constant(constant1)
	writer.write_constant(constant2)
	println(writer.buf.str())
}

pub fn test_ntstatus_constant() {
	// Don't worry about encoding/decoding json, it's not 100% functional yet.
	// constant_json := json.decode(Declaration, '{
	// 	"Constants":[
	//  ,{
	//  	"Name":"MCA_MICROCODE_ROM_PARITY_ERROR"
	//  	,"Type":{"Kind":"ApiRef","Name":"NTSTATUS","TargetKind":"Default","Api":"Foundation","Parents":[]}
	//  	,"ValueType":"Int32"
	//  	,"Value":-1073414018
	//  	,"Attrs":[]
	//  }
	//  ,{
	//  	"Name":"MCA_EXTERNAL_ERROR"
	//  	,"Type":{"Kind":"ApiRef","Name":"NTSTATUS","TargetKind":"Default","Api":"Foundation","Parents":[]}
	//  	,"ValueType":"Int32"
	//  	,"Value":-1073414017
	//  	,"Attrs":[]
	//  }
	// 	]
	// }')!

	constant1 := NtStatusConstant{
		name: 'MCA_MICROCODE_ROM_PARITY_ERROR'
		@type: ApiRefType{
			kind: 'ApiRef'
			name: 'NTSTATUS'
			target_kind: 'Default'
			api: 'Foundation'
			parents: []
		}
		value_type: 'Int32'
		value: -1073414018
		attrs: []
	}

	constant2 := NtStatusConstant{
		name: 'MCA_EXTERNAL_ERROR'
		@type: ApiRefType{
			kind: 'ApiRef'
			name: 'NTSTATUS'
			target_kind: 'Default'
			api: 'Foundation'
			parents: []
		}
		value_type: 'Int32'
		value: -1073414017
		attrs: []
	}

	mut writer := JsonWriter.new()
	// for c in constant_json.constants {
	// 	writer.write_constant(c)
	// }
	writer.write_constant(constant1)
	writer.write_constant(constant2)
	println(writer.buf.str())
}

pub fn test_propertykey_constant() {
	// Don't worry about encoding/decoding json, it's not 100% functional yet.
	// constant_json := json.decode(Declaration, '{
	// 	"Constants":[
	//     {
	//     "Name": "DEVPKEY_WIA_DeviceType",
	//     "Type": {
	//         "Kind": "ApiRef",
	//         "Name": "PROPERTYKEY",
	//         "TargetKind": "Default",
	//         "Api": "UI.Shell.PropertiesSystem",
	//         "Parents": []
	//     },
	//     "ValueType": "PropertyKey",
	//     "Value": {
	//         "Fmtid": "6bdd1fc6-810f-11d0-bec7-08002be2092f",
	//         "Pid": 2
	//     },
	//     "Attrs": []
	//     }
	//     {
	//     "Name": "DEVPKEY_WIA_USDClassId",
	//     "Type": {
	//         "Kind": "ApiRef",
	//         "Name": "PROPERTYKEY",
	//         "TargetKind": "Default",
	//         "Api": "UI.Shell.PropertiesSystem",
	//         "Parents": []
	//     },
	//     "ValueType": "PropertyKey",
	//     "Value": {
	//         "Fmtid": "6bdd1fc6-810f-11d0-bec7-08002be2092f",
	//         "Pid": 3
	//     },
	//     "Attrs": []
	//     }
	// 	]
	// }')!

	constant1 := PropertyKeyConstant{
		name: 'DEVPKEY_WIA_DeviceType'
		@type: ApiRefType{
			kind: 'ApiRef'
			name: 'PROPERTYKEY'
			target_kind: 'Default'
			api: 'UI.Shell.PropertiesSystem'
			parents: []
		}
		value_type: 'PropertyKey'
		value: PropertyKeyValue{
			fmtid: '6bdd1fc6-810f-11d0-bec7-08002be2092f'
			pid: 2
		}
		attrs: []
	}

	constant2 := PropertyKeyConstant{
		name: 'E_BADINDEXFLAGS'
		@type: ApiRefType{
			kind: 'ApiRef'
			name: 'PROPERTYKEY'
			target_kind: 'Default'
			api: 'UI.Shell.PropertiesSystem'
			parents: []
		}
		value_type: 'PropertyKey'
		value: PropertyKeyValue{
			fmtid: '6bdd1fc6-810f-11d0-bec7-08002be2092f'
			pid: 3
		}
		attrs: []
	}

	mut writer := JsonWriter.new()
	// for c in constant_json.constants {
	// 	writer.write_constant(c)
	// }
	writer.write_constant(constant1)
	writer.write_constant(constant2)
	println(writer.buf.str())
}

pub fn test_pstr_constant() {
	// Don't worry about encoding/decoding json, it's not 100% functional yet.
	// constant_json := json.decode(Declaration, '{
	// 	"Constants":[
	//  ,{
	//  	"Name":"MCA_MICROCODE_ROM_PARITY_ERROR"
	//  	,"Type":{"Kind":"ApiRef","Name":"PSTR","TargetKind":"Default","Api":"Foundation","Parents":[]}
	//  	,"ValueType":"Int32"
	//  	,"Value":-1073414018
	//  	,"Attrs":[]
	//  }
	//  ,{
	//  	"Name":"MCA_EXTERNAL_ERROR"
	//  	,"Type":{"Kind":"ApiRef","Name":"PSTR","TargetKind":"Default","Api":"Foundation","Parents":[]}
	//  	,"ValueType":"Int32"
	//  	,"Value":-1073414017
	//  	,"Attrs":[]
	//  }
	// 	]
	// }')!

	constant1 := PstrConstant{
		name: 'MCA_MICROCODE_ROM_PARITY_ERROR'
		@type: ApiRefType{
			kind: 'ApiRef'
			name: 'PSTR'
			target_kind: 'Default'
			api: 'Foundation'
			parents: []
		}
		value_type: 'Int32'
		value: -1073414018
		attrs: []
	}

	constant2 := PstrConstant{
		name: 'MCA_EXTERNAL_ERROR'
		@type: ApiRefType{
			kind: 'ApiRef'
			name: 'PSTR'
			target_kind: 'Default'
			api: 'Foundation'
			parents: []
		}
		value_type: 'Int32'
		value: -1073414017
		attrs: []
	}

	mut writer := JsonWriter.new()
	// for c in constant_json.constants {
	// 	writer.write_constant(c)
	// }
	writer.write_constant(constant1)
	writer.write_constant(constant2)
	println(writer.buf.str())
}

pub fn test_pwstr_constant() {
	// Don't worry about encoding/decoding json, it's not 100% functional yet.
	// constant_json := json.decode(Declaration, '{
	// 	"Constants":[
	//  {
	//    "Name": "RT_STRING",
	//    "Type": {
	//      "Kind": "ApiRef",
	//      "Name": "PWSTR",
	//      "TargetKind": "Default",
	//      "Api": "Foundation",
	//      "Parents": []
	//    },
	//    "ValueType": "Int32",
	//    "Value": 6,
	//    "Attrs": []
	//  }
	//  {
	//    "Name": "RT_RCDATA",
	//    "Type": {
	//      "Kind": "ApiRef",
	//      "Name": "PWSTR",
	//      "TargetKind": "Default",
	//      "Api": "Foundation",
	//      "Parents": []
	//    },
	//    "ValueType": "Int32",
	//    "Value": 10,
	//    "Attrs": []
	//  }
	// 	]
	// }')!

	constant1 := PwstrConstant{
		name: 'RT_STRING'
		@type: ApiRefType{
			kind: 'ApiRef'
			name: 'PWSTR'
			target_kind: 'Default'
			api: 'Foundation'
			parents: []
		}
		value_type: 'Int32'
		value: 6
		attrs: []
	}

	constant2 := PwstrConstant{
		name: 'RT_RCDATA'
		@type: ApiRefType{
			kind: 'ApiRef'
			name: 'PWSTR'
			target_kind: 'Default'
			api: 'Foundation'
			parents: []
		}
		value_type: 'Int32'
		value: 10
		attrs: []
	}

	mut writer := JsonWriter.new()
	// for c in constant_json.constants {
	// 	writer.write_constant(c)
	// }
	writer.write_constant(constant1)
	writer.write_constant(constant2)
	println(writer.buf.str())
}

pub fn test_socket_constant() {
	// Don't worry about encoding/decoding json, it's not 100% functional yet.
	// constant_json := json.decode(Declaration, '{
	// 	"Constants":[
	//  {
	//    "Name": "INVALID_SOCKET",
	//    "Type": {
	//      "Kind": "ApiRef",
	//      "Name": "SOCKET",
	//      "TargetKind": "Default",
	//      "Api": "Networking.WinSock",
	//      "Parents": []
	//    },
	//    "ValueType": "UInt32",
	//    "Value": 4294967295,
	//    "Attrs": []
	//  }
	// 	]
	// }')!

	constant := SocketConstant{
		name: 'INVALID_SOCKET'
		@type: ApiRefType{
			kind: 'ApiRef'
			name: 'SOCKET'
			target_kind: 'Default'
			api: 'Networking.WinSock'
			parents: []
		}
		value_type: 'UInt32'
		value: 4294967295
		attrs: []
	}

	mut writer := JsonWriter.new()
	// for c in constant_json.constants {
	// 	writer.write_constant(c)
	// }
	writer.write_constant(constant)
	println(writer.buf.str())
}

pub fn test_string_constant() {
	// Don't worry about encoding/decoding json, it's not 100% functional yet.
	// constant_json := json.decode(Declaration, '{
	// 	"Constants":[
	// 		{
	// 			"Name":"ID_GDF_XML_STR"
	// 			,"Type":{"Kind":"Native","Name":"String"}
	// 			,"ValueType":"String"
	// 			,"Value":"__GDF_XML"
	// 			,"Attrs":[]
	// 		}
	// 		,{
	// 			"Name":"ID_GDF_THUMBNAIL_STR"
	// 			,"Type":{"Kind":"Native","Name":"String"}
	// 			,"ValueType":"String"
	// 			,"Value":"__GDF_THUMBNAIL"
	// 			,"Attrs":[]
	// 		}
	// 	]
	// }')!

	constant1 := StringConstant{
		name: 'ID_GDF_XML_STR'
		@type: NativeType{
			kind: 'Native'
			name: 'String'
		}
		value_type: 'String'
		value: '__GDF_XML'
		attrs: []
	}

	constant2 := StringConstant{
		name: 'ID_GDF_THUMBNAIL_STR'
		@type: NativeType{
			kind: 'Native'
			name: 'String'
		}
		value_type: 'String'
		value: '__GDF_THUMBNAIL'
		attrs: []
	}

	mut writer := JsonWriter.new()
	// for c in constant_json.constants {
	// 	writer.write_constant(c)
	// }
	writer.write_constant(constant1)
	writer.write_constant(constant2)
	println(writer.buf.str())
}

pub fn test_uint16_constant() {
	// Don't worry about encoding/decoding json, it's not 100% functional yet.
	// constant_json := json.decode(Declaration, '{
	// 	"Constants":[
	//     {
	//     "Name": "ALLJOYN_CRED_CERT_CHAIN",
	//     "Type": {
	//         "Kind": "Native",
	//         "Name": "UInt16"
	//     },
	//     "ValueType": "UInt16",
	//     "Value": 4,
	//     "Attrs": []
	//     }
	//     {
	//     "Name": "ALLJOYN_CRED_PRIVATE_KEY",
	//     "Type": {
	//         "Kind": "Native",
	//         "Name": "UInt16"
	//     },
	//     "ValueType": "UInt16",
	//     "Value": 8,
	//     "Attrs": []
	//     }
	// 	]
	// }')!

	constant1 := UInt16Constant{
		name: 'ALLJOYN_CRED_CERT_CHAIN'
		@type: NativeType{
			kind: 'Native'
			name: 'UInt16'
		}
		value_type: 'UInt16'
		value: 4
		attrs: []
	}

	constant2 := UInt16Constant{
		name: 'ALLJOYN_CRED_PRIVATE_KEY'
		@type: NativeType{
			kind: 'Native'
			name: 'UInt16'
		}
		value_type: 'UInt16'
		value: 8
		attrs: []
	}

	mut writer := JsonWriter.new()
	// for c in constant_json.constants {
	// 	writer.write_constant(c)
	// }
	writer.write_constant(constant1)
	writer.write_constant(constant2)
	println(writer.buf.str())
}

pub fn test_uint32_constant() {
	// Don't worry about encoding/decoding json, it's not 100% functional yet.
	// constant_json := json.decode(Declaration, '{
	// 	"Constants":[
	//     {
	//     "Name": "HHWIN_PROP_TAB_CUSTOM7",
	//     "Type": {
	//         "Kind": "Native",
	//         "Name": "UInt32"
	//     },
	//     "ValueType": "UInt32",
	//     "Value": 33554432,
	//     "Attrs": []
	//     }
	//     {
	//     "Name": "HHWIN_PROP_TAB_CUSTOM8",
	//     "Type": {
	//         "Kind": "Native",
	//         "Name": "UInt32"
	//     },
	//     "ValueType": "UInt32",
	//     "Value": 67108864,
	//     "Attrs": []
	//     }
	// 	]
	// }')!

	constant1 := UInt32Constant{
		name: 'HHWIN_PROP_TAB_CUSTOM7'
		@type: NativeType{
			kind: 'Native'
			name: 'UInt32'
		}
		value_type: 'UInt32'
		value: 33554432
		attrs: []
	}

	constant2 := UInt32Constant{
		name: 'HHWIN_PROP_TAB_CUSTOM8'
		@type: NativeType{
			kind: 'Native'
			name: 'UInt32'
		}
		value_type: 'UInt32'
		value: 67108864
		attrs: []
	}

	mut writer := JsonWriter.new()
	// for c in constant_json.constants {
	// 	writer.write_constant(c)
	// }
	writer.write_constant(constant1)
	writer.write_constant(constant2)
	println(writer.buf.str())
}
