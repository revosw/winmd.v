module com

// [in] szAppBase
// Not used.
// [in] szPrivateBin
// Not used.
// [in] szGlobalBin
// Not used.
// [in] szAssemblyName
// The name of the assembly to find.
// [out] szName
// The simple name of the assembly.
// [in] cchName
// The size, in bytes, of szName.
// [out] pchName
// The number of characters actually returned in szName.
fn C.FindAssembly(szAppBase string, szPrivateBin string, szBlobalBin string, szAssemblyName string, szName string, cchName u32, pchName &u32) u32

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
fn C.FindAssemblyModule(szAppBase string, szPrivateBin string, szBlobalBin string, szAssemblyName string, szName string, cchName u32, pcName &u32) u32

// [out] szBuffer
// The buffer to receive the directory name.
// [in] cchBuffer
// The size, in bytes, of szBuffer.
// [out] pchBuffer
// The number of bytes actually returned in szBuffer.
fn C.GetCORSystemDirectory(szBuffer string, cchBuffer u32, pchBuffer &u32) u32

// [in] optionId
// A pointer to a GUID that specifies the option to be retrieved. See the Remarks section for a list of supported GUIDs.
// [out] pValue
// The value of the returned option. The type of this value will be a variant of the specified option's type.
fn C.GetOption(optionId voidptr, pValue voidptr) u32

// [in] pITI
// Pointer to an ITypeInfo interface that provides the type information on which to open the scope.
// [in] dwOpenFlags
// The open mode flags.
// [in] riid
// The desired interface.
// [out] ppIUnk
// Pointer to a pointer to the returned interface.
fn C.OpenScopeOnITypeInfo(pITI voidptr, dwOpenFlags u32, riid voidptr, ppIUnk voidptr) u32

// [in] optionId
// A pointer to a GUID that specifies the option to be set.
// [in] pValue
// The value to use to set the option. The type of this value must be a variant of the specified option's type.
fn C.SetOption(optionId voidptr, pValue voidptr) u32

