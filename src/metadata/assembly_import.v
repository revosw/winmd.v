module metadata

#flag -IC:/Program Files (x86)/Windows Kits/10/Include/10.0.22000.0/shared
#flag -IC:/Program Files (x86)/Windows Kits/10/Include/10.0.22000.0/winrt
#include <roapi.h>
#include <RoMetadataApi.h>
#include <rometadata.h>

const iid_metadata_assembly_import = Guid{0xee62470b, 0xe94b, 0x424e, [u8(0x9b), 0x7c, 0x2f, 0x0,
	0xc9, 0x24, 0x9f, 0x93]!}

pub struct MetaDataAssemblyImport {
	metadata_ptr &C.IMetaDataAssemblyImport
}

// close_enum releases a reference to the specified enumeration instance.
pub fn (md &MetaDataAssemblyImport) close_enum(enum_instance u32) {
	// TODO: Make function idiomatic to V
	md.metadata_ptr.lpVtbl.CloseEnum(md.metadata_ptr, enum_instance)
}

pub fn (md &MetaDataAssemblyImport) enum_assembly_refs(phEnum voidptr, rAssemblyRefs []voidptr, cMax u32, pcTokens &u32) u32 {
	// TODO: Make function idiomatic to V
	return md.metadata_ptr.lpVtbl.EnumAssemblyRefs(md.metadata_ptr, phEnum, rAssemblyRefs, cMax, pcTokens)
}

pub fn (md &MetaDataAssemblyImport) enum_exported_types(phEnum &u32, rExportedTypes []voidptr, cMax u32, pcTokens &u32) u32 {
	// TODO: Make function idiomatic to V
	return md.metadata_ptr.lpVtbl.EnumExportedTypes(md.metadata_ptr, phEnum, rExportedTypes, cMax, pcTokens)
}

pub fn (md &MetaDataAssemblyImport) enum_files(phEnum &u32, rFiles []voidptr, cMax u32, pcTokens &u32) u32 {
	// TODO: Make function idiomatic to V
	return md.metadata_ptr.lpVtbl.EnumFiles(md.metadata_ptr, phEnum, rFiles, cMax, pcTokens)
}

pub fn (md &MetaDataAssemblyImport) enum_manifest_resources(phEnum &u32, rManifestResources []voidptr, cMax u32, pcTokens &u32) u32 {
	// TODO: Make function idiomatic to V
	return md.metadata_ptr.lpVtbl.EnumManifestResources(md.metadata_ptr, phEnum, rManifestResources, cMax,
		pcTokens)
}

pub fn (md &MetaDataAssemblyImport) find_assemblies_by_name(szAppBase string, szPrivateBin string, szAssemblyName string, ppIUnk &voidptr, cMax u32, pcAssemblies &u32) u32 {
	// TODO: Make function idiomatic to V
	return md.metadata_ptr.lpVtbl.FindAssembliesByName(md.metadata_ptr, szAppBase, szPrivateBin, szAssemblyName,
		ppIUnk, cMax, pcAssemblies)
}

pub fn (md &MetaDataAssemblyImport) find_exported_type_by_name(szName string, mdtExportedType voidptr, ptkExportedType &voidptr) u32 {
	// TODO: Make function idiomatic to V
	return md.metadata_ptr.lpVtbl.FindExportedTypeByName(md.metadata_ptr, szName, mdtExportedType, ptkExportedType)
}

pub fn (md &MetaDataAssemblyImport) find_manifest_resource_by_name(szName string, ptkManifestResource voidptr) u32 {
	// TODO: Make function idiomatic to V
	return md.metadata_ptr.lpVtbl.FindManifestResourceByName(md.metadata_ptr, szName, ptkManifestResource)
}

pub fn (md &MetaDataAssemblyImport) get_assembly_from_scope(ptkAssembly voidptr) u32 {
	// TODO: Make function idiomatic to V
	return md.metadata_ptr.lpVtbl.GetAssemblyFromScope(md.metadata_ptr, ptkAssembly)
}

pub fn (md &MetaDataAssemblyImport) get_assembly_props(mds voidptr, ppbPublicKey &&u8, pcbPublicKey &u32, pulHashALgId &u32, szName string, cchName u32, pchName &u32, pMetaData voidptr, pdwAssemblyFlags &u32) u32 {
	// TODO: Make function idiomatic to V
	return md.metadata_ptr.lpVtbl.GetAssemblyProps(md.metadata_ptr, mds, ppbPublicKey, pcbPublicKey, pulHashALgId,
		szName, cchName, pchName, pMetaData, pdwAssemblyFlags)
}

pub fn (md &MetaDataAssemblyImport) get_assembly_ref_props(mdar voidptr, ppbPublicKeyOrToken &&u8, pcbPublicKeyOrToken &u32, szName string, cchName u32, pchName &u32, pMetaData voidptr, ppbHashValue &&u8, pcbHashValue u32, pdwAssemblyRefFlags &u32) u32 {
	// TODO: Make function idiomatic to V
	return md.metadata_ptr.lpVtbl.GetAssemblyRefProps(md.metadata_ptr, mdar, ppbPublicKeyOrToken, pcbPublicKeyOrToken,
		szName, cchName, pchName, pMetaData, ppbHashValue, pcbHashValue, pdwAssemblyRefFlags)
}

pub fn (md &MetaDataAssemblyImport) get_exported_type_props(mdct voidptr, szName string, cchName u32, pchName &u32, ptkImplementation voidptr, ptkTypeDef voidptr, pdwExportedTypeFlags &u32) u32 {
	// TODO: Make function idiomatic to V
	return md.metadata_ptr.lpVtbl.GetExportedTypeProps(md.metadata_ptr, mdct, szName, cchName, pchName,
		ptkImplementation, ptkTypeDef, pdwExportedTypeFlags)
}

pub fn (md &MetaDataAssemblyImport) get_file_props(mdf voidptr, szName string, cchName u32, pchName &u32, ppbHashValue &&u8, pcbHashValue &u32, pdwFileFlags &u32) u32 {
	// TODO: Make function idiomatic to V
	return md.metadata_ptr.lpVtbl.GetFileProps(md.metadata_ptr, mdf, szName, cchName, pchName, ppbHashValue,
		pcbHashValue, pdwFileFlags)
}

pub fn (md &MetaDataAssemblyImport) get_manifest_resource_props(mdmr voidptr, szName string, cchName u32, pchName &u32, ptkImplementation voidptr, pdwOffset &u32, pdwResourceFlags &u32) u32 {
	// TODO: Make function idiomatic to V
	return md.metadata_ptr.lpVtbl.GetManifestResourceProps(md.metadata_ptr, mdmr, szName, cchName, pchName,
		ptkImplementation, pdwOffset, pdwResourceFlags)
}

struct C.IMetaDataAssemblyImport {
	lpVtbl &C.IMetaDataAssemblyImportVtbl
}

struct C.IMetaDataAssemblyImportVtbl {
	// [in] hEnum
	// The enumeration instance to be closed.
	CloseEnum fn (this &C.IMetaDataAssemblyImport, hEnum u32)
	// [in, out] phEnum
	// A pointer to the enumerator. This must be a null value when the EnumAssemblyRefs method is called for the first time.
	// [out] rAssemblyRefs
	// The enumeration of mdAssemblyRef metadata tokens.
	// [in] cMax
	// The maximum number of tokens that can be placed in the rAssemblyRefs array.
	// [out] pcTokens
	// The number of tokens actually placed in rAssemblyRefs.
	EnumAssemblyRefs fn (this &C.IMetaDataAssemblyImport, phEnum voidptr, rAssemblyRefs []voidptr, cMax u32, pcTokens &u32) u32
	// [in, out] phEnum
	// A pointer to the enumerator. This must be a null value when the EnumExportedTypes method is called for the first time.
	// [out] rExportedTypes
	// The enumeration of mdExportedType metadata tokens.
	// [in] cMax
	// The maximum number of mdExportedType tokens that can be placed in the rExportedTypes array.
	// [out] pcTokens
	// The number of mdExportedType tokens actually placed in rExportedTypes.
	EnumExportedTypes fn (this &C.IMetaDataAssemblyImport, phEnum &u32, rExportedTypes []voidptr, cMax u32, pcTokens &u32) u32
	// [in, out] phEnum
	// A pointer to the enumerator. This must be a null value for the first call of this method.
	// [out] rFiles
	// The array used to store the mdFile metadata tokens.
	// [in] cMax
	// The maximum number of mdFile tokens that can be placed in rFiles.
	// [out] pcTokens
	// The number of mdFile tokens actually placed in rFiles.
	EnumFiles fn (this &C.IMetaDataAssemblyImport, phEnum &u32, rFiles []voidptr, cMax u32, pcTokens &u32) u32
	// [in, out] phEnum
	// A pointer to the enumerator. This must be a null value when the EnumManifestResources method is called for the first time.
	// [out] rManifestResources
	// The array used to store the mdManifestResource metadata tokens.
	// [in] cMax
	// The maximum number of mdManifestResource tokens that can be placed in rManifestResources.
	// [out] pcTokens
	// The number of mdManifestResource tokens actually placed in rManifestResources.
	EnumManifestResources fn (this &C.IMetaDataAssemblyImport, phEnum &u32, rManifestResources []voidptr, cMax u32, pcTokens &u32) u32
	// [in] szAppBase
	// The root directory in which to search for the given assembly. If this value is set to null, FindAssembliesByName will look only in the global assembly cache for the assembly.
	// [in] szPrivateBin
	// A list of semicolon-delimited subdirectories (for example, "bin;bin2"), under the root directory, in which to search for the assembly. These directories are probed in addition to those specified in the default probing rules.
	// [in] szAssemblyName
	// The name of the assembly to find. The format of this string is defined in the class reference page for AssemblyName
	// [out] ppIUnk
	// An array of type IUnknown in which to put the IMetadataAssemblyImport interface pointers.
	// [in] cMax
	// The maximum number of interface pointers that can be placed in ppIUnk.
	// [out] pcAssemblies
	// The number of interface pointers returned. That is, the number of interface pointers actually placed in ppIUnk.
	FindAssembliesByName fn (this &C.IMetaDataAssemblyImport, szAppBase string, szPrivateBin string, szAssemblyName string, ppIUnk &voidptr, cMax u32, pcAssemblies &u32) u32
	// [in] szName
	// The name of the exported type.
	// [in] mdtExportedType
	// The metadata token for the enclosing class of the exported type. This value is mdExportedTypeNil if the requested exported type is not a nested type.
	// [out] ptkExportedType
	// A pointer to the mdExportedType token that represents the exported type.
	FindExportedTypeByName fn (this &C.IMetaDataAssemblyImport, szName string, mdtExportedType voidptr, ptkExportedType &voidptr) u32
	// [in] szName
	// The name of the resource.
	// [out] ptkManifestResource
	// The array used to store the mdManifestResource metadata tokens, each of which represents a manifest resource.
	FindManifestResourceByName fn (this &C.IMetaDataAssemblyImport, szName string, ptkManifestResource voidptr) u32
	// [out] ptkAssembly
	// A pointer to the retrieved mdAssembly token that identifies the assembly.
	GetAssemblyFromScope fn (this &C.IMetaDataAssemblyImport, ptkAssembly voidptr) u32
	// [in] mda
	// The mdAssembly metadata token that represents the assembly for which to get the properties.
	// [out] ppbPublicKey
	// A pointer to the public key or the metadata token.
	// [out] pcbPublicKey
	// The number of bytes in the returned public key.
	// [out] pulHashAlgId
	// A pointer to the algorithm used to hash the files in the assembly.
	// [out] szName
	// The simple name of the assembly.
	// [in] cchName
	// The size, in wide chars, of szName.
	// [out] pchNam
	// The number of wide chars actually returned in szName.
	// [out] pMetaData
	// A pointer to an [ASSEMBLYMETADATA](https://learn.microsoft.com/en-us/dotnet/framework/unmanaged-api/metadata/assemblymetadata-structure) structure that contains the assembly metadata.
	// [out] pdwAssemblyFlags
	// Flags that describe the metadata applied to an assembly. This value is a combination of one or more [CorAssemblyFlags](https://learn.microsoft.com/en-us/dotnet/framework/unmanaged-api/metadata/corassemblyflags-enumeration) values.
	GetAssemblyProps fn (this &C.IMetaDataAssemblyImport, mds voidptr, ppbPublicKey &&u8, pcbPublicKey &u32, pulHashALgId &u32, szName string, cchName u32, pchName &u32, pMetaData voidptr, pdwAssemblyFlags &u32) u32
	// [in] mdar
	// The mdAssemblyRef metadata token that represents the assembly reference for which to get the properties.
	// [out] ppbPublicKeyOrToken
	// A pointer to the public key or the metadata token.
	// [out] pcbPublicKeyOrToken
	// The number of bytes in the returned public key or token.
	// [out] szName
	// The simple name of the assembly.
	// [in] cchName
	// The size, in wide chars, of szName.
	// [out] pchName
	// A pointer to the number of wide chars actually returned in szName.
	// [out] pMetaData
	// A pointer to an [ASSEMBLYMETADATA](https://learn.microsoft.com/en-us/dotnet/framework/unmanaged-api/metadata/assemblymetadata-structure) structure that contains the assembly metadata.
	// [out] ppbHashValue
	// A pointer to the hash value. This is the hash, using the SHA-1 algorithm, of the PublicKey property of the assembly being referenced, unless the arfFullOriginator flag of the [AssemblyRefFlags](https://learn.microsoft.com/en-us/dotnet/framework/unmanaged-api/metadata/assemblyrefflags-enumeration) enumeration is set.
	// [out] pcbHashValue
	// The number of wide chars in the returned hash value.
	// [out] pdwAssemblyRefFlags
	// A pointer to flags that describe the metadata applied to an assembly. The flags value is a combination of one or more [CorAssemblyFlags](https://learn.microsoft.com/en-us/dotnet/framework/unmanaged-api/metadata/corassemblyflags-enumeration) values.
	GetAssemblyRefProps fn (this &C.IMetaDataAssemblyImport, mdar voidptr, ppbPublicKeyOrToken &&u8, pcbPublicKeyOrToken &u32, szName string, cchName u32, pchName &u32, pMetaData voidptr, ppbHashValue &&u8, pcbHashValue u32, pdwAssemblyRefFlags &u32) u32
	// [in] mdct
	// An mdExportedType metadata token that represents the exported type.
	// [out] szName
	// The name of the exported type.
	// [in] cchName
	// The size, in wide characters, of szName.
	// [out] pchName
	// The number of wide characters actually returned in szName.
	// [out] ptkImplementation
	// An mdFile, mdAssemblyRef, or mdExportedType metadata token that contains or allows access to the properties of the exported type.
	// [out] ptkTypeDef
	// A pointer to an mdTypeDef token that represents a type in the file.
	// [out] pdwExportedTypeFlags
	// A pointer to the flags that describe the metadata applied to the exported type. The flags value can be one or more [CorTypeAttr](https://learn.microsoft.com/en-us/dotnet/framework/unmanaged-api/metadata/cortypeattr-enumeration) values.
	GetExportedTypeProps fn (this &C.IMetaDataAssemblyImport, mdct voidptr, szName string, cchName u32, pchName &u32, ptkImplementation voidptr, ptkTypeDef voidptr, pdwExportedTypeFlags &u32) u32
	// [in] mdf
	// The mdFile metadata token that represents the file for which to get the properties.
	// [out] szName
	// The simple name of the file.
	// [in] cchName
	// The size, in wide chars, of szName.
	// [out] pchName
	// The number of wide chars actually returned in szName.
	// [out] ppbHashValue
	// A pointer to the hash value. This is the hash, using the SHA-1 algorithm, of the file.
	// [out] pcbHashValue
	// The number of wide chars in the returned hash value.
	// [out] pdwFileFlags
	// A pointer to the flags that describe the metadata applied to a file. The flags value is a combination of one or more CorFileFlags values.
	GetFileProps fn (this &C.IMetaDataAssemblyImport, mdf voidptr, szName string, cchName u32, pchName &u32, ppbHashValue &&u8, pcbHashValue &u32, pdwFileFlags &u32) u32
	// [in] mdmr
	// An mdManifestResource token that represents the resource for which to get the properties.
	// [out] szName
	// The name of the resource.
	// [in] cchName
	// The size, in wide chars, of szName.
	// [out] pchName
	// A pointer to the number of wide chars actually returned in szName.
	// [out] ptkImplementation
	// A pointer to an mdFile token or an mdAssemblyRef token that represents the file or assembly, respectively, that contains the resource.
	// [out] pdwOffset
	// A pointer to a value that specifies the offset to the beginning of the resource within the file.
	// [out] pdwResourceFlags
	// A pointer to flags that describe the metadata applied to a resource. The flags value is a combination of one or more [CorManifestResourceFlags](https://learn.microsoft.com/en-us/dotnet/framework/unmanaged-api/metadata/cormanifestresourceflags-enumeration) values.
	GetManifestResourceProps fn (this &C.IMetaDataAssemblyImport, mdmr voidptr, szName string, cchName u32, pchName &u32, ptkImplementation voidptr, pdwOffset &u32, pdwResourceFlags &u32) u32
}
