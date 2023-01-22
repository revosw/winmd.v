module metadata

#flag -IC:/Program Files (x86)/Windows Kits/10/Include/10.0.22000.0/shared
#flag -IC:/Program Files (x86)/Windows Kits/10/Include/10.0.22000.0/winrt
#include <roapi.h>
#include <RoMetadataApi.h>
#include <rometadata.h>

pub const clsid_metadata_dispenser = Guid{0xe5cb7a31, 0x7512, 0x11d2, [u8(0x89), 0xce, 0x0, 0x80,
	0xc7, 0x92, 0xe5, 0xd8]!}

pub const iid_metadata_dispenser_ex = Guid{0x31bcfce2, 0xdafb, 0x11d2, [u8(0x9f), 0x81, 0x0, 0xc0,
	0x4f, 0x79, 0xa0, 0xa3]!}

[callconv: 'stdcall']
fn C.MetaDataGetDispenser(clsid &Guid, iid &Guid, dispenser_ptr_ptr &&C.IMetaDataDispenserEx) Errorcode

enum Errorcode as u32 {
	s_ok = 0
	e_nointerface = 0x80004002
}

pub fn get_metadata_dispenser() MetaDataDispenser {
	mut dispenser := MetaDataDispenser{}

	match C.MetaDataGetDispenser(&metadata.clsid_metadata_dispenser, &metadata.iid_metadata_dispenser_ex,
		&dispenser.dispenser_ptr) {
		.e_nointerface { println("The dispenser doesn't support this interface") }
		else {}
	}

	return dispenser
}

pub struct MetaDataDispenser {
	dispenser_ptr &C.IMetaDataDispenserEx
}

pub fn (md MetaDataDispenser) define_scope(rclsid u32, dwCreateFlags u32, riid voidptr, ppIUnk &voidptr) u32 {
	// TODO: Make function idiomatic to V
	return md.dispenser_ptr.lpVtbl.DefineScope(md.dispenser_ptr, rclsid, dwCreateFlags, riid, ppIUnk)
}

pub fn (md MetaDataDispenser) find_assembly(szAppBase string, szPrivateBin string, szBlobalBin string, szAssemblyName string, szName string, cchName u32, pchName &u32) u32 {
	// TODO: Make function idiomatic to V
	return md.dispenser_ptr.lpVtbl.FindAssembly(md.dispenser_ptr, szAppBase, szPrivateBin, szBlobalBin,
		szAssemblyName, szName, cchName, pchName)
}

pub fn (md MetaDataDispenser) find_assembly_module(szAppBase string, szPrivateBin string, szGlobalBin string, szAssemblyName string, szModuleName string, szName string, cchName u32, pcName &u32) u32 {
	// TODO: Make function idiomatic to V
	return md.dispenser_ptr.lpVtbl.FindAssemblyModule(md.dispenser_ptr, szAppBase, szPrivateBin, szGlobalBin,
		szAssemblyName, szModuleName, szName, cchName, pcName)
}

pub fn (md MetaDataDispenser) get_cor_system_directory(szBuffer string, cchBuffer u32, pchBuffer &u32) u32 {
	// TODO: Make function idiomatic to V
	return md.dispenser_ptr.lpVtbl.GetCORSystemDirectory(md.dispenser_ptr, szBuffer, cchBuffer, pchBuffer)
}

pub fn (md MetaDataDispenser) get_option(optionId voidptr, pValue voidptr) u32 {
	// TODO: Make function idiomatic to V
	return md.dispenser_ptr.lpVtbl.GetOption(md.dispenser_ptr, optionId, pValue)
}

// open_scope
// It is currently hardcoded to
pub fn (md MetaDataDispenser) open_scope(scope_name string, ) MetaDataImport {
	metadata_import := MetaDataImport{}
	// TODO: Make function idiomatic to V
	md.dispenser_ptr.lpVtbl.OpenScope(md.dispenser_ptr, scope_name, 0, &iid_metadata_import2, &metadata_import.import_ptr)
	return metadata_import
}

pub fn (md MetaDataDispenser) open_scope_on_itype_info(pITI voidptr, dwOpenFlags u32, riid voidptr, ppIUnk voidptr) u32 {
	// TODO: Make function idiomatic to V
	return md.dispenser_ptr.lpVtbl.OpenScopeOnITypeInfo(md.dispenser_ptr, pITI, dwOpenFlags, riid, ppIUnk)
}

pub fn (md MetaDataDispenser) open_scope_on_memory(pData &u8, cbData u32, dwOpenFlags u32, riid voidptr, ppIUnk &voidptr) u32 {
	// TODO: Make function idiomatic to V
	return md.dispenser_ptr.lpVtbl.OpenScopeOnMemory(md.dispenser_ptr, pData, cbData, dwOpenFlags, riid,
		ppIUnk)
}

pub fn (md MetaDataDispenser) set_option(optionId voidptr, pValue voidptr) u32 {
	// TODO: Make function idiomatic to V
	return md.dispenser_ptr.lpVtbl.SetOption(md.dispenser_ptr, optionId, pValue)
}

struct C.IMetaDataDispenserEx {
	lpVtbl &C.IMetaDataDispenserExVtbl
}

struct C.IMetaDataDispenserExVtbl {
	// [in] rclsid
	// The CLSID of the version of metadata structures to be created.
	// [in] dwCreateFlags
	// Flags that specify options.
	// [in] riid
	// The IID of the desired metadata interface to be returned. The caller will use the interface to create the new metadata.
	// The value of riid must specify one of the "emit" interfaces. Valid values are IID_IMetaDataEmit, IID_IMetaDataAssemblyEmit, or IID_IMetaDataEmit2.
	// [out] ppIUnk
	// The pointer to the returned interface.
	DefineScope fn (this &C.IMetaDataDispenserEx, rclsid u32, dwCreateFlags u32, riid voidptr, ppIUnk &voidptr) u32
	// [out] szBuffer
	// The buffer to receive the directory name.
	// [in] cchBuffer
	// The size, in bytes, of szBuffer.
	// [out] pchBuffer
	// The number of bytes actually returned in szBuffer.
	GetCORSystemDirectory fn (this &C.IMetaDataDispenserEx, szBuffer string, cchBuffer u32, pchBuffer &u32) u32
	// [in] optionId
	// A pointer to a GUID that specifies the option to be retrieved. See the Remarks section for a list of supported GUIDs.
	// [out] pValue
	// The value of the returned option. The type of this value will be a variant of the specified option's type.
	GetOption fn (this &C.IMetaDataDispenserEx, optionId voidptr, pValue voidptr) u32
	// [in] szAppBase
	// Not used.
	// [in] szPrivateBin
	// Not used.
	// [in] szGlobalBin
	// Not used.
	// [in] szAssemblyName
	// The assembly to be found.
	// [out] szName
	// The simple name of the assembly.
	// [in] cchName
	// The size, in bytes, of szName.
	// [out] pcName
	// The number of characters actually returned in szName.
	FindAssembly fn (this &C.IMetaDataDispenserEx, szAppBase string, szPrivateBin string, szBlobalBin string, szAssemblyName string, szName string, cchName u32, pchName &u32) u32
	// [in] szAppBase
	// Not used.
	// [in] szPrivateBin
	// Not used.
	// [in] szGlobalBin
	// Not used.
	// [in] szAssemblyName
	// The assembly to be found.
	// [in] szModuleName
	// The name of the module.
	// [out] szName
	// The simple name of the assembly.
	// [in] cchName
	// The size, in bytes, of szName.
	// [out] pcName
	// The number of characters actually returned in szName.
	FindAssemblyModule fn (this &C.IMetaDataDispenserEx, szAppBase string, szPrivateBin string, szGlobalBin string, szAssemblyName string, szModuleName string, szName string, cchName u32, pcName &u32) u32
	// [in] szScope
	// The name of the file to be opened. The file must contain common language runtime (CLR) metadata.
	// [in] dwOpenFlags
	// Specifies the mode (read, and so on) for opening. This is a value of the CorOpenFlags enumeration. You can only import (read) from the file, not emit (write) to it.
	// [in] riid
	// The IID of the desired metadata interface to be returned; the caller will use the interface to import (read) metadata.
	// Valid values for riid include IID_IUnknown, IID_IMetaDataImport, IID_IMetaDataImport2, IID_IMetaDataAssemblyImport, IID_IMetaDataTables, and IID_IMetaDataTables2.
	// [out] ppIUnk
	// The pointer to the returned interface.
	OpenScope fn (this &C.IMetaDataDispenserEx, szScope string, dwOpenFlags u32, riid voidptr, ppIUnk &&voidptr) u32
	// [in] pITI
	// Pointer to an ITypeInfo interface that provides the type information on which to open the scope.
	// [in] dwOpenFlags
	// The open mode flags.
	// [in] riid
	// The desired interface.
	// [out] ppIUnk
	// Pointer to a pointer to the returned interface.
	OpenScopeOnITypeInfo fn (this &C.IMetaDataDispenserEx, pITI voidptr, dwOpenFlags u32, riid voidptr, ppIUnk voidptr) u32
	// [in] pData
	// A pointer that specifies the starting address of the memory area
	// [in] cbData
	// The size of the memory area, in bytes.
	// [in] dwOpenFlags
	// A value of the CorOpenFlags enumeration to specify the mode (read, write, and so on) for opening.
	// [in] riid
	// The IID of the desired metadata interface to be returned; the caller will use the interface to import (read) or emit (write) metadata.
	// The value of riid must specify one of the "import" or "emit" interfaces. Valid values are IID_IMetaDataEmit, IID_IMetaDataImport, IID_IMetaDataAssemblyEmit, IID_IMetaDataAssemblyImport, IID_IMetaDataEmit2, or IID_IMetaDataImport2.
	// [out] ppIUnk
	// The pointer to the returned interface.
	OpenScopeOnMemory fn (this &C.IMetaDataDispenserEx, pData &u8, cbData u32, dwOpenFlags u32, riid voidptr, ppIUnk &voidptr) u32
	// [in] optionId
	// A pointer to a GUID that specifies the option to be set.
	// [in] pValue
	// The value to use to set the option. The type of this value must be a variant of the specified option's type.
	SetOption fn (this &C.IMetaDataDispenserEx, optionId voidptr, pValue voidptr) u32
}
