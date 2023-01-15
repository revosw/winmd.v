module com

// [in, out] phEnum
// A pointer to the enumerator.
// [in] tk
// A token that represents the generic parameter whose constraints are to be enumerated.
// [out] rGenericParamConstraints
// The array of generic parameter constraints to enumerate.
// [in] cMax
// The requested maximum number of tokens to place in rGenericParamConstraints.
// [out] pcGenericParamConstraints
// A pointer to the number of tokens placed in rGenericParamConstraints.
fn C.EnumGenericParamConstraints(phEnum &u32, tk voidptr, rGenericParamConstraints []voidptr, cMax u32, pcGenericParamConstraints &u32) u32

// [in, out] phEnum
// A pointer to the enumerator.
// [in] tk
// The TypeDef or MethodDef token whose generic parameters are to be enumerated.
// [out] rGenericParams
// The array of generic parameters to enumerate.
// [in] cMax
// The requested maximum number of tokens to place in rGenericParams.
// [out] pcGenericParams
// The returned number of tokens placed in rGenericParams.
fn C.EnumGenericParams(phEnum voidptr, tk voidptr, rGenericParams []voidptr, cMax u32, pcGenericParams &u32) u32

// [in, out] phEnum
// pointer to the enumerator for rMethodSpecs.
// [in] tk
// The MemberRef or MethodDef token that represents the method whose MethodSpec tokens are to be enumerated. If the value of tk is 0 (zero), all MethodSpec tokens in the scope will be enumerated.
// [out] rMethodSpecs
// The array of MethodSpec tokens to enumerate.
// [in] cMax
// The requested maximum number of tokens to place in rMethodSpecs.
// [out] pcMethodSpecs
// The returned number of tokens placed in rMethodSpecs.
fn C.EnumMethodSpecs(phEnum voidptr, tk voidptr, rMethodSpecs []voidptr, cMax u32, pcMethodSpecs &u32) u32

// [in] gpc
// The token to the generic parameter constraint for which to return the metadata.
// [out] ptGenericParam
// A pointer to the token that represents the generic parameter that is constrained.
// [out] ptkConstraintType
// A pointer to a TypeDef, TypeRef, or TypeSpec token that represents a constraint on ptGenericParam.
fn C.GetGenericParamConstraintProps(gpc voidptr, ptGenericParam voidptr, ptkConstraintType voidptr) u32


// [in] gp
// The token that represents the generic parameter for which to return metadata.
// [out] pulParamSeq
// The ordinal position of the Type parameter in the parent constructor or method.
// [out] pdwParamFlags
// A value of the CorGenericParamAttr enumeration that describes the Type for the generic parameter.
// [out] ptOwner
// A TypeDef or MethodDef token that represents the owner of the parameter.
// [out] reserved
// Reserved for future extensibility.
// [out] wzname
// The name of the generic parameter.
// [in] cchName
// The size of the wzName buffer.
// [out] pchName
// The returned size of the name, in wide characters.
fn C.GetGenericParamProps(gp voidptr, pulParamSeq &u32, pdwParamFlags &i32, ptOwner voidptr, reserved voidptr, wzname string, cchName u32, pchName &u32) u32

// [in] mi
// A MethodSpec token that represents the instantiation of the method.
// [out] tkParent
// A pointer to the MethodDef or MethodRef token that represents the method definition.
// [out] ppvSigBlob
// A pointer to the binary metadata signature of the method.
// [out] pcbSigBlob
// The size, in bytes, of ppvSigBlob.
fn C.GetMethodSpecProps(mi voidptr, tkParent voidptr, ppvSigBlob voidptr, pcbSigBlob &u32) u32

// [out] pdwPEKind
// A pointer to a value of the CorPEKind enumeration that describes the PE file.
// [out] pdwMAchine
// A pointer to a value that identifies the architecture of the machine. See the next section for possible values.
fn C.GetPEKind(pwdPEKind &u32, pdwMachine &u32) u32

// [out] pwzBuf
// An array to store the string that specifies the version.
// [in] ccBufSize
// The size, in wide characters, of the pwzBuf array.
// [out] pccBufSize
// The number of wide characters, including a null terminator, returned in the pwzBuf array.
fn C.GetVersionString(pwzBuf string, ccBufSize u32, pccBufSize &u32) u32
