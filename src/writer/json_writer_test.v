module writer

// import json
import os

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
		@type: _VAnonStruct1{
			kind: 'Native'
			name: 'String'
		}
		value_type: 'String'
		value: '__GDF_XML'
		attrs: []
	}

	constant2 := StringConstant{
		name: 'ID_GDF_THUMBNAIL_STR'
		@type: _VAnonStruct1{
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
		@type: _VAnonStruct2{
			kind: 'Native'
			name: 'Int32'
		}
		value_type: 'Int32'
		value: 19
		attrs: []
	}

	constant2 := Int32Constant{
		name: 'ID_GDF_THUMBNAIL_STR'
		@type: _VAnonStruct2{
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
		@type: _VAnonStruct3{
			kind: 'Native'
			name: 'UInt32'
		}
		value_type: 'UInt32'
		value: 33554432
		attrs: []
	}

	constant2 := UInt32Constant{
		name: 'HHWIN_PROP_TAB_CUSTOM8'
		@type: _VAnonStruct3{
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
		@type: _VAnonStruct4{
			kind: 'Native'
			name: 'UInt16'
		}
		value_type: 'UInt16'
		value: 4
		attrs: []
	}

	constant2 := UInt16Constant{
		name: 'ALLJOYN_CRED_PRIVATE_KEY'
		@type: _VAnonStruct4{
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
		@type: _VAnonStruct5{
			kind: 'Native'
			name: 'Byte'
		}
		value_type: 'Byte'
		value: 2
		attrs: []
	}

	constant2 := ByteConstant{
		name: 'ALLJOYN_MEMBER_ANNOTATE_SESSIONCAST'
		@type: _VAnonStruct5{
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
		@type: _VAnonStruct6{
			kind: 'Native'
			name: 'Guid'
		}
		value_type: 'String'
		value: '4662daaf-d393-11d0-9a56-00c04fb68bf7'
		attrs: []
	}

	constant2 := GuidConstant{
		name: 'CLSID_ITEngStemmer'
		@type: _VAnonStruct6{
			kind: 'Native'
			name: 'Guid'
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
		@type: _VAnonStruct7{
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
		@type: _VAnonStruct7{
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
}
