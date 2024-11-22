module writer

// import json
pub fn test_setlasterror_function() {
	// Don't worry about encoding/decoding json, it's not 100% functional yet.
	// function_json := json.decode(Declaration, '{
	// 	"Functions":[
	// {
	//   "Name": "WaitCommEvent",
	//   "SetLastError": true,
	//   "DllImport": "KERNEL32",
	//   "ReturnType": {
	//     "Kind": "ApiRef",
	//     "Name": "BOOL",
	//     "TargetKind": "Default",
	//     "Api": "Foundation",
	//     "Parents": []
	//   },
	//   "ReturnAttrs": [],
	//   "Architectures": [],
	//   "Platform": "windows5.1.2600",
	//   "Attrs": [],
	//   "Params": [
	//     {
	//       "Name": "hFile",
	//       "Type": {
	//         "Kind": "ApiRef",
	//         "Name": "HANDLE",
	//         "TargetKind": "Default",
	//         "Api": "Foundation",
	//         "Parents": []
	//       },
	//       "Attrs": [
	//         "In"
	//       ]
	//     },
	//     {
	//       "Name": "lpEvtMask",
	//       "Type": {
	//         "Kind": "PointerTo",
	//         "Child": {
	//           "Kind": "ApiRef",
	//           "Name": "COMM_EVENT_MASK",
	//           "TargetKind": "Default",
	//           "Api": "Devices.Communication",
	//           "Parents": []
	//         }
	//       },
	//       "Attrs": [
	//         "In",
	//         "Out"
	//       ]
	//     },
	//     {
	//       "Name": "lpOverlapped",
	//       "Type": {
	//         "Kind": "PointerTo",
	//         "Child": {
	//           "Kind": "ApiRef",
	//           "Name": "OVERLAPPED",
	//           "TargetKind": "Default",
	//           "Api": "System.IO",
	//           "Parents": []
	//         }
	//       },
	//       "Attrs": [
	//         "In",
	//         "Out",
	//         "Optional"
	//       ]
	//     }
	//   ]
	// }
	// 	]
	// }')!
	function1 := Function{
		name:           'WaitCommEvent'
		set_last_error: true
		dll_import:     'KERNEL32'
		return_type:    ApiRefType{
			kind:        'ApiRef'
			name:        'BOOL'
			target_kind: 'Default'
			api:         'Foundation'
			parents:     []
		}
		return_attrs:   []
		architectures:  []
		platform:       'windows5.1.2600'
		attrs:          []
		params:         [
			FieldOrParam{
				name:  'hFile'
				@type: ApiRefType{
					kind:        'ApiRef'
					name:        'HANDLE'
					target_kind: 'Default'
					api:         'Foundation'
					parents:     []
				}
				attrs: ['In']
			},
			FieldOrParam{
				name:  'lpEvtMask'
				@type: PointerToType{
					kind:  'PointerTo'
					child: ApiRefType{
						kind:        'ApiRef'
						name:        'COMM_EVENT_MASK'
						target_kind: 'Default'
						api:         'Devices.Communication'
						parents:     []
					}
				}
				attrs: ['In', 'Out']
			},
			FieldOrParam{
				name:  'lpOverlapped'
				@type: PointerToType{
					kind:  'PointerTo'
					child: ApiRefType{
						kind:        'ApiRef'
						name:        'OVERLAPPED'
						target_kind: 'Default'
						api:         'System.IO'
						parents:     []
					}
				}
				attrs: ['In', 'Out', 'Optional']
			},
		]
	}

	mut writer := JsonWriter.new()

	// for c in function_json.functions {
	// 	writer.write_function(c)
	// }
	writer.write_function(function1)
	println(writer.buf.str())
}
