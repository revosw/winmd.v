// module com
// #flag -IC:/Program Files (x86)/Windows Kits/10/Include/10.0.22000.0/shared
// #flag -IC:/Program Files (x86)/Windows Kits/10/Include/10.0.22000.0/winrt
// #include <roapi.h>
// #include <RoMetadataApi.h>
// #include <rometadata.h>

// [typedef]
// struct C.GUID{}

// // struct Guid {
// // 	Data1 u16
// // 	Data2 u8
// // 	Data3 u16
// // 	Data4 u16
// // }

// // [in] rclsid
// // The CLSID of the version of metadata structures to be created.
// // [in] dwCreateFlags
// // Flags that specify options.
// // [in] riid
// // The IID of the desired metadata interface to be returned. The caller will use the interface to create the new metadata.
// // The value of riid must specify one of the "emit" interfaces. Valid values are IID_IMetaDataEmit, IID_IMetaDataAssemblyEmit, or IID_IMetaDataEmit2.
// // [out] ppIUnk
// // The pointer to the returned interface.
// fn C.DefineScope(rclsid u32, dwCreateFlags u32, riid voidptr, ppIUnk &voidptr) u32

// // [in] szScope
// // The name of the file to be opened. The file must contain common language runtime (CLR) metadata.
// // [in] dwOpenFlags
// // Specifies the mode (read, and so on) for opening. This is a value of the CorOpenFlags enumeration. You can only import (read) from the file, not emit (write) to it.
// // [in] riid
// // The IID of the desired metadata interface to be returned; the caller will use the interface to import (read) metadata.
// // Valid values for riid include IID_IUnknown, IID_IMetaDataImport, IID_IMetaDataImport2, IID_IMetaDataAssemblyImport, IID_IMetaDataTables, and IID_IMetaDataTables2.
// // [out] ppIUnk
// // The pointer to the returned interface.
// pub fn C.OpenScope(szScope string, dwOpenFlags u32, riid voidptr, ppIUnk &voidptr) u32

// // [in] pData
// // A pointer that specifies the starting address of the memory area
// // [in] cbData
// // The size of the memory area, in bytes.
// // [in] dwOpenFlags
// // A value of the CorOpenFlags enumeration to specify the mode (read, write, and so on) for opening.
// // [in] riid
// // The IID of the desired metadata interface to be returned; the caller will use the interface to import (read) or emit (write) metadata.
// // The value of riid must specify one of the "import" or "emit" interfaces. Valid values are IID_IMetaDataEmit, IID_IMetaDataImport, IID_IMetaDataAssemblyEmit, IID_IMetaDataAssemblyImport, IID_IMetaDataEmit2, or IID_IMetaDataImport2.
// // [out] ppIUnk
// // The pointer to the returned interface.
// fn C.OpenScopeOnMemory(pData &u8, cbData u32, dwOpenFlags u32, riid voidptr, ppIUnk &voidptr) u32
