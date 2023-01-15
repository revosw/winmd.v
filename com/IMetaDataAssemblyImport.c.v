module com

import time

// [in] hEnum
// The enumeration instance to be closed.
fn C.CloseEnum(hEnum u32)

// [in, out] phEnum
// A pointer to the enumerator. This must be a null value when the EnumAssemblyRefs method is called for the first time.
// [out] rAssemblyRefs
// The enumeration of mdAssemblyRef metadata tokens.
// [in] cMax
// The maximum number of tokens that can be placed in the rAssemblyRefs array.
// [out] pcTokens
// The number of tokens actually placed in rAssemblyRefs.
fn C.EnumAssemblyRefs(phEnum &u32, rAssemblyRefs []voidptr, cMax u32, pcTokens &u32) u32

// [in, out] phEnum
// A pointer to the enumerator. This must be a null value when the EnumExportedTypes method is called for the first time.
// [out] rExportedTypes
// The enumeration of mdExportedType metadata tokens.
// [in] cMax
// The maximum number of mdExportedType tokens that can be placed in the rExportedTypes array.
// [out] pcTokens
// The number of mdExportedType tokens actually placed in rExportedTypes.
fn C.EnumExportedTypes(phEnum &u32, rExportedTypes []voidptr, cMax u32, pcTokens &u32) u32

// [in, out] phEnum
// A pointer to the enumerator. This must be a null value for the first call of this method.
// [out] rFiles
// The array used to store the mdFile metadata tokens.
// [in] cMax
// The maximum number of mdFile tokens that can be placed in rFiles.
// [out] pcTokens
// The number of mdFile tokens actually placed in rFiles.
fn C.EnumFiles(phEnum &u32, rFiles []voidptr, cMax u32, pcTokens &u32) u32

// [in, out] phEnum
// A pointer to the enumerator. This must be a null value when the EnumManifestResources method is called for the first time.
// [out] rManifestResources
// The array used to store the mdManifestResource metadata tokens.
// [in] cMax
// The maximum number of mdManifestResource tokens that can be placed in rManifestResources.
// [out] pcTokens
// The number of mdManifestResource tokens actually placed in rManifestResources.
fn C.EnumManifestResources(phEnum &u32, rManifestResources []voidptr, cMax u32, pcTokens &u32) u32

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
fn C.FindAssembliesByName(szAppBase string, szPrivateBin string, szAssemblyName string, ppIUnk &voidptr, cMax u32, pcAssemblies &u32) u32

// [in] szName
// The name of the exported type.
// [in] mdtExportedType
// The metadata token for the enclosing class of the exported type. This value is mdExportedTypeNil if the requested exported type is not a nested type.
// [out] ptkExportedType
// A pointer to the mdExportedType token that represents the exported type.
fn C.FindExportedTypeByName(szName string, mdtExportedType voidptr, ptkExportedType &voidptr) u32

// [in] szName
// The name of the resource.
// [out] ptkManifestResource
// The array used to store the mdManifestResource metadata tokens, each of which represents a manifest resource.
fn C.FindManifestResourceByName(szName string, ptkManifestResource voidptr) u32

// [out] ptkAssembly
// A pointer to the retrieved mdAssembly token that identifies the assembly.
fn C.GetAssemblyFromScope(ptkAssembly voidptr) u32

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
fn C.GetAssemblyProps(mds voidptr, ppbPublicKey &&u8, pcbPublicKey &u32, pulHashALgId &u32, szName string, cchName u32, pchName &u32, pMetaData voidptr, pdwAssemblyFlags &u32) u32

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
fn C.GetAssemblyRefProps(mdar voidptr, ppbPublicKeyOrToken &&u8, pcbPublicKeyOrToken &u32, szName string, cchName u32, pchName &u32, pMetaData voidptr, ppbHashValue &&u8, pcbHashValue u32, pdwAssemblyRefFlags &u32)

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
fn C.GetExportedTypeProps(mdct voidptr, szName string, cchName u32, pchName &u32, ptkImplementation voidptr, ptkTypeDef voidptr, pdwExportedTypeFlags &u32) u32

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
fn C.GetFileProps(mdf voidptr, szName string, cchName u32, pchName &u32, ppbHashValue &&u8, pcbHashValue &u32, pdwFileFlags &u32) u32

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
fn C.GetManifestResourceProps(mdmr voidptr, szName string, cchName u32, pchName &u32, ptkImplementation voidptr, pdwOffset &u32, pdwResourceFlags &u32) u32
