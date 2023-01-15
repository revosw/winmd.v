module com

import main {
	MdToken,
	HCorEnum,
}

// [in] hEnum
// The handle of the enumerator to close.
fn C.CloseEnum(hEnum u32)

// [in] hEnum
// The handle for the enumerator.
// [out, retval] pulCount
// The number of elements enumerated.
fn C.CountEnum(hEnum HCorEnum, pulCount &u32)

// [in, out] phEnum
// A pointer to the returned enumerator.
// [in] tk
// A token for the scope of the enumeration, or zero for all custom attributes.
// [in] tkType
// A token for the type of the attributes to be enumerated, or zero for all types.
// [out] rgCustomAttributes
// An array of custom attribute tokens.
// [in] cMax
// The maximum size of the rgCustomAttributes array.
// [out] pcCustomAttributes
// The actual number of token values returned in rgCustomAttributes.
fn C.EnumCustomAttributes(phEnum &u32, tk voidptr, tkType voidptr, rgCustomAttributes []voidptr, cMax u32, pcCustomAttributes &u32) u32

// [in, out] phEnum
// A pointer to the enumerator.
// [in] tkTypDef
// The TypeDef token whose event definitions are to be enumerated.
// [out] rgEvents
// The array of returned events.
// [in] cMax
// The maximum size of the rgEvents array.
// [out] pcEvents
// The actual number of events returned in rgEvents.
fn C.EnumEvents(phEnum &u32, tkTypDef voidptr, rgEvents []voidptr, cMax u32, pcEvents &u32) u32

// [in, out] phEnum
// A pointer to the enumerator.
// [in] tkTypeDef
// The TypeDef token of the class whose fields are to be enumerated.
// [out] rgFields
// The list of FieldDef tokens.
// [in] cMax
// The maximum size of the rgFields array.
// [out] pcTokens
// The actual number of FieldDef tokens returned in rgFields.
fn C.EnumFields(phEnum &u32, tkTypeDef voidptr, rgFields []voidptr, cMax u32, pcTokens &u32) u32

// [in, out] phEnum
// A pointer to the enumerator.
// [in] tkTypeDef
// The token of the type whose fields are to be enumerated.
// [in] szName
// The field name that limits the scope of the enumeration.
// [out] rFields
// Array used to store the FieldDef tokens.
// [in] cMax
// The maximum size of the rFields array.
// [out] pcTokens
// The actual number of FieldDef tokens returned in rFields.
fn C.EnumFieldsWithName(phEnum &u32, tkTypeDef voidptr, szName string, rFields []voidptr, cMax u32, pcTokens &u32) u32

// [in, out] phEnum
// A pointer to the enumerator.
// [in] td
// The token of the TypeDef whose MethodDef tokens representing interface implementations are to be enumerated.
// [out] rImpls
// The array used to store the MethodDef tokens.
// [in] cMax
// The maximum size of the rImpls array.
// [out, retval] pcImpls
// The actual number of tokens returned in rImpls.
fn C.EnumInterfaceImpls(phEnum &u32, td voidptr, rImpls []voidptr, cMax u32, pcImpls &u32) u32

// [in, out] phEnum
// A pointer to the enumerator.
// [in] tkParent
// A TypeDef, TypeRef, MethodDef, or ModuleRef token for the type whose members are to be enumerated.
// [out] rgMemberRefs
// The array used to store MemberRef tokens.
// [in] cMax
// The maximum size of the rgMemberRefs array.
// [out] pcTokens
// The actual number of MemberRef tokens returned in rgMemberRefs.
fn C.EnumMemberRefs(phEnum &u32, tkParent voidptr, rgMemberRefs []voidptr, cMax u32, pcTokens &u32) u32

// [in, out] phEnum
// A pointer to the enumerator.
// [in] tkTypeDef
// A TypeDef token representing the type whose members are to be enumerated.
// [out] rgMembers
// The array used to hold the MemberDef tokens.
// [in] cMax
// The maximum size of the rgMembers array.
// [out] pcTokens
// The actual number of MemberDef tokens returned in rgMembers.
fn C.EnumMembers(phEnum &u32, tkTypeDef voidptr, rgMembers []voidptr, cMax u32, pcTokens &u32) u32

// [in, out] phEnum
// A pointer to the enumerator.
// [in] tkTypeDef
// A TypeDef token representing the type with members to enumerate.
// [in] szName
// The member name that limits the scope of the enumerator.
// [out] rgMembers
// The array used to store the MemberDef tokens.
// [in] cMax
// The maximum size of the rgMembers array.
// [out] pcTokens
// The actual number of MemberDef tokens returned in rgMembers.
fn C.EnumMembersWithName(phEnum &u32, tkTypeDef voidptr, szName string, rgMembers []voidptr, cMax u32, pcTokens &u32) u32

// [in, out] phEnum
// A pointer to the enumerator. This must be NULL for the first call of this method.
// [in] tkTypeDef
// A TypeDef token for the type whose method implementations to enumerate.
// [out] rMethodBody
// The array to store the MethodBody tokens.
// [out] rMethodDecl
// The array to store the MethodDeclaration tokens.
// [in] cMax
// The maximum size of the rMethodBody and rMethodDecl arrays.
// [out] pcTokens
// The actual number of methods returned in rMethodBody and rMethodDecl.
fn C.EnumMethodImpls(phEnum &u32, tkTypeDef voidptr, rMethodBody []voidptr, rMethodDecl []voidptr, cMax u32, pcTokens &u32) u32

// [in, out] phEnum
// A pointer to the enumerator. This must be NULL for the first call of this method.
// [in] tkTypeDef
// A TypeDef token representing the type with the methods to enumerate.
// [out] rgMethods
// The array to store the MethodDef tokens.
// [in] cMax
// The maximum size of the MethodDef rgMethods array.
// [out] pcTokens
// The number of MethodDef tokens returned in rgMethods.
fn C.EnumMethods(phEnum &u32, tkTypeDef voidptr, rgMethods []voidptr, cMax u32, pcTokens &u32) u32

// [in, out] phEnum
// A pointer to the enumerator. This must be NULL for the first call of this method.
// [in] tkMethodDef
// A MethodDef token that limits the scope of the enumeration.
// [out] rgEventProp
// The array used to store the events or properties.
// [in] cMax
// The maximum size of the rgEventProp array.
// [out] pcEventProp
// The number of events or properties returned in rgEventProp.
fn C.EnumMethodSemantics(phEnum &u32, tkMethodDef voidptr, rgEventProp []voidptr, cMax u32, pcEventProp &u32) u32

// [in, out] phEnum
// A pointer to the enumerator. This must be NULL for the first call of this method.
// [in] tkTypeDef
// A TypeDef token representing the type whose methods to enumerate.
// [in] szName
// The name that limits the scope of the enumeration.
// [out] rgMethods
// The array used to store the MethodDef tokens.
// [in] cMax
// The maximum size of the rgMethods array.
// [out] pcTokens
// The number of MethodDef tokens returned in rgMethods.
fn C.EnumMethodsWithName(phEnum &u32, tkTypeDef voidptr, szName string, rgMethods []voidptr, cMax u32, pcTokens &u32) u32

// [in, out] phEnum
// A pointer to the enumerator. This must be NULL for the first call of this method.
// [out] rgModuleRefs
// The array used to store the ModuleRef tokens.
// [in] cMax
// The maximum size of the rgModuleRefs array.
// [out] pcModuleRefs
// The number of ModuleRef tokens returned in rgModuleRefs.
fn C.EnumModuleRefs(phEnum &u32, rgModuleRefs []voidptr, cMax u32, pcModuleRefs &u32) u32

// [in, out] phEnum
// A pointer to the enumerator. This must be NULL for the first call of this method.
// [in] tkMethodDef
// A MethodDef token representing the method with the parameters to enumerate.
// [out] rParams
// The array used to store the ParamDef tokens.
// [in] cMax
// The maximum size of the rParams array.
// [out] pcTokens
// The number of ParamDef tokens returned in rParams.
fn C.EnumParams(phEnum &u32, tkMethodDef voidptr, rParams []voidptr, cMax u32, pcTokens &u32) u32

// [in, out] phEnum
// A pointer to the enumerator. This must be NULL for the first call of this method.
// [in] tk
// A metadata token that limits the scope of the search, or NULL to search the widest scope possible.
// [in] dwActions
// Flags representing the [SecurityAction](https://learn.microsoft.com/en-us/dotnet/api/system.security.permissions.securityaction) values to include in rPermission, or zero to return all actions.
// [out] rPermission
// The array used to store the Permission tokens.
// [in] cMax
// The maximum size of the rPermission array.
// [out] pcTokens
// The number of Permission tokens returned in rPermission.
fn C.EnumPermissionSets(phEnum &u32, tk voidptr, dwActions u32, rPermission []voidptr, cMax u32, pcTokens &u32) u32

// [in, out] phEnum
// A pointer to the enumerator. This must be NULL for the first call of this method.
// [in] tkTypDef
// A TypeDef token representing the type with properties to enumerate.
// [out] rgProperties
// The array used to store the PropertyDef tokens.
// [in] cMax
// The maximum size of the rgProperties array.
// [out] pcProperties
// The number of PropertyDef tokens returned in rgProperties.
fn C.EnumProperties(phEnum &u32, tkTypeDef voidptr, rgProperties []voidptr, cMax u32, pcProperties &u32) u32

// [in, out] phEnum
// A pointer to the enumerator. This must be NULL for the first call of this method.
// [out] rgSignatures
// The array used to store the Signature tokens.
// [in] cMax
// The maximum size of the rgSignatures array.
// [out] pcSignatures
// The number of Signature tokens returned in rgSignatures.
fn C.EnumSignatures(phEnum &u32, rgSignatures []voidptr, cMax u32, pcSignatures &u32) u32

// [in, out] phEnum
// A pointer to the new enumerator. This must be NULL for the first call of this method.
// [out] rgTypeDefs
// The array used to store the TypeDef tokens.
// [in] cMax
// The maximum size of the rgTypeDefs array.
// [out, retval] pcTypeDefs
// The number of TypeDef tokens returned in rgTypeDefs.
fn C.EnumTypeDefs(phEnum &u32, rgTypeDefs []voidptr, cMax u32, pcTokens &u32) u32

// [in, out] phEnum
// A pointer to the enumerator. This must be NULL for the first call of this method.
// [out] rgTypeRefs
// The array used to store the TypeRef tokens.
// [in] cMax
// The maximum size of the rgTypeRefs array.
// [out, retval] pcTypeRefs
// A pointer to the number of TypeRef tokens returned in rgTypeRefs.
fn C.EnumTypeRefs(phEnum &u32, rgTypeRefs []voidptr, cMax u32, pcTokens &u32) u32

// [in, out] phEnum
// A pointer to the enumerator. This value must be NULL for the first call of this method.
// [out] rgTypeSpecs
// The array used to store the TypeSpec tokens.
// [in] cMax
// The maximum size of the rgTypeSpecs array.
// [out] pcTypeSpecs
// The number of TypeSpec tokens returned in rgTypeSpecs.
fn C.EnumTypeSpecs(phEnum &u32, rgTypeSpecs []voidptr, cMax u32, pcTypeSpecs &u32) u32

// [in, out] phEnum
// A pointer to the enumerator. This must be NULL for the first call of this method.
// [out] rgMethods
// The array used to store the MemberDef tokens.
// [in] cMax
// The maximum size of the rgMethods array.
// [out] pcTokens
// The number of MemberDef tokens returned in rgMethods.
fn C.EnumUnresolvedMethods(phEnum &u32, rgTypeDefs []voidptr, cMax u32, pcTokens &u32) u32

// [in, out] phEnum
// A pointer to the enumerator. This must be NULL for the first call of this method.
// [out] rgStrings
// The array used to store the String tokens.
// [in] cMax
// The maximum size of the rgStrings array.
// [out] pcStrings
// The number of String tokens returned in rgStrings.
fn C.EnumUserStrings(phEnum &u32, rgStrings []voidptr, cMax u32, pcStrings &u32) u32

// [in] tkTypeRef
// The TypeRef token for the class or interface that encloses the member reference to search for. If this value is mdTokenNil, the lookup is done for a global variable or a global-function reference.
// [in] szName
// The name of the member reference to search for.
// [in] pvSigBlob
// A pointer to the binary metadata signature of the member reference.
// [in] cbSigBlob
// The size in bytes of pvSigBlob.
// [out] pMemberRef
// A pointer to the matching MemberRef token.
fn C.FindMemberRef(tkTypeRef voidptr, szName string, pvSigBlob voidptr, cbSigBlob u32, pMemberRef voidptr) u32

// [in] szTypeDef
// The name of the type for which to get the TypeDef token.
// [in] tkEnclosingClass
// A TypeDef or TypeRef token representing the enclosing class. If the type to find is not a nested class, set this value to NULL.
// [out, retval] ptkTypeDef
// A pointer to the matching TypeDef token.
fn C.FindTypeDefByName(szTypeDef string, tkEnclosingClass voidptr, ptkTypeDef voidptr) u32

// [in] tkResolutionScope
// A ModuleRef, AssemblyRef, or TypeRef token that specifies the module, assembly, or type, respectively, in which the type reference is defined.
// [in] szName
// The name of the type reference to search for.
// [out] tkTypeRef
// A pointer to the matching TypeRef token.
fn C.FindTypeRef(tkResolutionScope voidptr, szName string, tkTypeRef voidptr) u32

// [in] cv
// A metadata token that represents the custom attribute to be retrieved.
// [out] ptkObj
// A metadata token representing the object that the custom attribute modifies. This value can be any type of metadata token except mdCustomAttribute. See Metadata Tokens for more information about the token types.
// [out] ptkType
// An mdMethodDef or mdMemberRef metadata token representing the Type of the returned custom attribute.
// [out] ppBlob
// A pointer to an array of data that is the value of the custom attribute.
// [out] pcbBlob
// The size in bytes of the data returned in const.
fn C.GetCustomAttributeProps(cv voidptr, ptkObj voidptr, ptkType voidptr, ppBlob &&u8, pcbBlob &u32) u32

// [in] tk
// The metadata token that represents the field to get interop marshaling information for.
// [out] ppvNativeType
// A pointer to the metadata signature of the field's native type.
// [out] pcbNativeType
// The size in bytes of ppvNativeType.
fn C.GetFieldMarshal(tk MdToken, ppvNativeType voidptr, pcbNativeType &u32) u32

// [in] tkFieldDef
// A FieldDef token that represents the field to get associated metadata for.
// [out] ptkTypeDef
// A pointer to a TypeDef token that represents the type of the class that the field belongs to.
// [out] szField
// The name of the field.
// [in] cchField
// The size in wide characters of the buffer for szField.
// [out] pchField
// The actual size of the returned buffer.
// [out] pdwAttr
// Flags associated with the field's metadata.
// [out] ppvSigBlob
// A pointer to the binary metadata value that describes the field.
// [out] pcbSigBlob
// The size in bytes of ppvSigBlob.
// [out] pdwCPlusTypeFlag
// A flag that specifies the value type of the field.
// [out] ppValue
// A constant value for the field.
// [out] pcchValue
// The size in chars of ppValue, or zero if no string exists.
fn C.GetFieldProps(tkFieldDef voidptr, ptkTypeDef voidptr, szField string, cchField u32, pchFIeld &u32, pdwAttr &u32, ppvSigBlob voidptr, pcbSigBlob &u32, pdwCPlusTypeFlag &u32, ppValue voidptr, pcchValue &u32) u32

// [in] tkInterfaceImpl
// The metadata token representing the method to return the class and interface tokens for.
// [out] ptkClass
// The metadata token representing the class that implements the method.
// [out] ptkIface
// The metadata token representing the interface that defines the implemented method.
fn C.GetInterfaceImplProps(tkInterfaceImpl voidptr, ptkClass voidptr, ptkIface voidptr) u32

// [in] tkMember
// The token that references the member to get the associated metadata for.
// [out] ptkTypeDef
// A pointer to the metadata token that represents the class of the member.
// [out] szMember
// The name of the member.
// [in] cchMember
// The size in wide characters of the szMember buffer.
// [out] pchMember
// The size in wide characters of the returned name.
// [out] pdwAttr
// Any flag values applied to the member.
// [out] ppvSigBlob
// A pointer to the binary metadata signature of the member.
// [out] pcbSigBlob
// The size in bytes of ppvSigBlob.
// [out] pulCodeRVA
// A pointer to the relative virtual address of the member.
// [out] pdwImplFlags
// Any method implementation flags associated with the member.
// [out] pdwCPlusTypeFlag
// A flag that marks a ValueType.
// [out] ppValue
// A constant string value returned by this member.
// [out] pcchValue
// The size in characters of ppValue, or zero if ppValue does not hold a string.
fn C.GetMemberProps(tkMember voidptr, ptkTypeDef voidptr, szMember string, cchMember u32, pchMember &u32, pdwAttr &u32, ppvSigBlob voidptr, pcbSigBlob &u32, pulCodeRVA &u32, pdwImplFlags &u32, pdwCPlusTypeFlag &u32, ppValue voidptr, pcchValue &u32) u32


// [in] tkMemberRef
// The MemberRef token to return associated metadata for.
// [out] ptk
// A TypeDef or TypeRef, or TypeSpec token that represents the class that declares the member, or a ModuleRef token that represents the module class that declares the member, or a MethodDef that represents the member.
// [out] szMember
// A string buffer for the member's name.
// [in] cchMember
// The requested size in wide characters of szMember.
// [out] pchMember
// The returned size in wide characters of szMember.
// [out] ppvSigBlob
// A pointer to the binary metadata signature for the member.
// [out] pcbSigBlob
// The size in bytes of ppvSigBlob.
fn C.GetMemberRefProps(tkMemberRef voidptr, ptk voidptr, szMember string, cchMember u32, pchMember &u32, ppvSigBlob voidptr, pcbSigBlob &u32) u32

// [in] tkMethodDef
// The MethodDef token that represents the method to return metadata for.
// [out] ptkClass
// A Pointer to a TypeDef token that represents the type that implements the method.
// [out] szMethod
// A Pointer to a buffer that has the method's name.
// [in] cchMethod
// The requested size of szMethod.
// [out] pchMethod
// A pointer to the size in wide characters of szMethod, or in the case of truncation, the actual number of wide characters in the method name.
// [out] pdwAttr
// A pointer to any flags associated with the method.
// [out] ppvSigBlob
// A pointer to the binary metadata signature of the method.
// [out] pcbSigBlob
// A pointer to the size in bytes of ppvSigBlob.
// [out] pulCodeRVA
// A pointer to the relative virtual address of the method.
// [out] pdwImplFlags
// A pointer to any implementation flags for the method.
fn C.GetMethodProps(tkMethodDef voidptr, ptkClass voidptr, szMethod string, cchMethod u32, pchMethod &u32, pdwAttr &u32, ppvSigBlob voidptr, pcbSigBlob &u32, pulCodeRVA &u32, pdwImplFlags &u32) u32

// [in] tkMethodDef
// A MethodDef token representing the method to get the semantic role information for.
// [in] tkEventProp
// A token representing the paired property and event for which to get the method's role.
// [out] pdwSemanticsFlags
// A pointer to the associated semantics flags. This value is a bitmask from the CorMethodSemanticsAttr enumeration.
fn C.GetMethodSemantics(tkMethodDef voidptr, tkEventProp voidptr, pdwSemanticsFlags &u32) u32

// [out] ptkModule
// A pointer to the token representing the module referenced in the current metadata scope.
fn C.GetModuleFromScope(ptkModule voidptr) u32

// [in] tkModuleRef
// The ModuleRef metadata token that references the module to get metadata information for.
// [out] szName
// A buffer to hold the module name.
// [in] cchName
// The requested size of szName in wide characters.
// [out] pchName
// The returned size of szName in wide characters.
fn C.GetModuleRefProps(tkModuleRef voidptr, szName string, cchName u32, pchName &u32) u32

// [in] tk
// The token representing the object to return the name for.
// [out] pszUtf8NamePtr
// A pointer to the UTF-8 object name in the heap.
fn C.GetNameFromToken(tk voidptr, pszUtf8NamePtr voidptr) u32

// [in] tdNestedClass
// A TypeDef token representing the Type to return the parent class token for.
// [out] ptdEnclosingClass
// A pointer to the TypeDef token for the Type that tdNestedClass is nested in.
fn C.GetNestedClassProps(tdNestedClass voidptr, ptdEnclosingClass voidptr) u32

// [in] tkMethodDef
// A token that represents the method to return the parameter token for.
// [in] ulParamSeq
// The ordinal position in the parameter list where the requested parameter occurs. Parameters are numbered starting from one, with the method's return value in position zero.
// [out] ptkParamDef
// A pointer to a ParamDef token that represents the requested parameter.
fn C.GetParamForMethodIndex(tkMethodDef voidptr, ulParamSeq u32, ptkParamDef voidptr) u32

// [in] tkParamDef
// A ParamDef token that represents the parameter to return metadata for.
// [out] ptkMethodDef
// A pointer to a MethodDef token representing the method that takes the parameter.
// [out] pulSequence
// The ordinal position of the parameter in the method argument list.
// [out] szName
// A buffer to hold the name of the parameter.
// [in] cchName
// The requested size in wide characters of szName.
// [out] pchName
// The returned size in wide characters of szName.
// [out] pdwAttr
// A pointer to any attribute flags associated with the parameter.
// [out] pdwCPlusTypeFlag
// A pointer to a flag specifying that the parameter is a ValueType.
// [out] ppValue
// A pointer to a constant string returned by the parameter.
// [out] pcchValue
// The size of ppValue in wide characters, or zero if ppValue does not hold a string.
fn C.GetParamProps(tkParamDef voidptr, ptkMethodDef voidptr, pulSequence &u32, szName string, cchName u32, pchName &u32, pdwAttr &u32, pdwCPlusTypeFlag &u32, ppValue voidptr, pcchValue &u32) u32

// [in] tk
// The Permission metadata token that represents the permission set to get the metadata properties for.
// [out] pdwAction
// A pointer to the permission set.
// [out] ppvPermission
// A pointer to the binary metadata signature of the permission set.
// [out] pcbPermission
// The size in bytes of const.
fn C.GetPermissionSetProps(tk voidptr, pdwAction &u32, ppvPermission &&u8, pcbPermission &u32) u32

// [in] tk
// A FieldDef or MethodDef token to get the PInvoke mapping metadata for.
// [out] pdwMappingFlags
// A pointer to flags used for mapping. This value is a bitmask from the CorPinvokeMap enumeration.
// [out] szImportName
// The name of the unmanaged target DLL.
// [in] cchImportName
// The size in wide characters of szImportName.
// [out] pchImportName
// The number of wide characters returned in szImportName.
// [out] ptkImportDLL
// A pointer to a ModuleRef token that represents the unmanaged target object library.
fn C.GetPinvokeMap(tk voidptr, pdwMappingFlags &u32, szImportName string, cchImportNAme u32, pchImportName &u32, ptkImportDLL voidptr) u32

// [in] tk
// A MethodDef or FieldDef metadata token that represents the code object to return the RVA for. If the token is a FieldDef, the field must be a global variable.
// [out] pulCodeRVA
// A pointer to the relative virtual address of the code object represented by the token.
// [out] pdwImplFlags
// A pointer to the implementation flags for the method. This value is a bitmask from the [CorMethodImpl](https://learn.microsoft.com/en-us/dotnet/framework/unmanaged-api/metadata/cormethodimpl-enumeration) enumeration. The value of pdwImplFlags is valid only if tk is a MethodDef token.
fn C.GetRVA(tk voidptr, pulCodeRVA &u32, pdwImplFlags &u32) u32

// [out] szName
// A buffer for the assembly or module name.
// [in] cchName
// The size in wide characters of szName.
// [out] pchName
// The number of wide characters returned in szName.
// [out] pmvid
// A pointer to a GUID that uniquely identifies the version of the assembly or module.
fn C.GetScopeProps(szName string, cchName u32, pchName &u32, pmvid voidptr) u32

// [in] tkSignature
// The token to return the binary metadata signature for.
// [out] ppvSig
// A pointer to the returned metadata signature.
// [out] pcbSig
// The size in bytes of the binary metadata signature.
fn C.GetSigFromToken(tkSignature voidptr, ppvSig voidptr, pcbSig &u32) u32

// [in] tkTypeDef
// The TypeDef token that represents the type to return metadata for.
// [out] szTypeDef
// A buffer containing the type name.
// [in] cchTypeDef
// The size in wide characters of szTypeDef.
// [out] pchTypeDef
// The number of wide characters returned in szTypeDef.
// [out] pdwTypeDefFlags
// A pointer to any flags that modify the type definition. This value is a bitmask from the [CorTypeAttr](https://learn.microsoft.com/en-us/dotnet/framework/unmanaged-api/metadata/cortypeattr-enumeration) enumeration.
// [out] ptkExtends
// A TypeDef or TypeRef metadata token that represents the base type of the requested type.
fn C.GetTypeDefProps(tkTypeDef voidptr, szTypeDef string, cchTypeDef u32, pchTypeDef &u32, pdwTypeDefFlags &u32, ptkExtends voidptr) u32

// [in] tkTypeRef
// The TypeRef token that represents the type to return metadata for.
// [out] ptkResolutionScope
// A pointer to the scope in which the reference is made. This value is an AssemblyRef or ModuleRef token.
// [out] szName
// A buffer containing the type name.
// [in] cchName
// The requested size in wide characters of szName.
// [out] pchName
// The returned size in wide characters of szName.
fn C.GetTypeRefProps(tkTypeRef voidptr, ptkResolutionScope voidptr, szName string, cchName u32, pchName &u32) u32

// [in] tkTypeSpec
// The TypeSpec token associated with the requested metadata signature.
// [out] ppvSig
// A pointer to the binary metadata signature.
// [out] pcbSig
// The size, in bytes, of the metadata signature.
fn C.GetTypeSpecFromToken(tkTypeSpec voidptr, ppvSig voidptr, pcbSig &u32) u32

// [in] tkString
// The String token to return the associated string for.
// [out] szString
// A copy of the requested string.
// [in] cchString
// The maximum size in wide characters of the requested szString.
// [out] pchString
// The size in wide characters of the returned szString.
fn C.GetUserString(tkString voidptr, szString string, cchString u32, pchString &u32) u32

// [in] tk
// A metadata token that represents a type, field, or method.
// [out] pbIsGlobal
// 1 if the object has global scope; otherwise, 0 (zero).
fn C.IsGlobal(tk voidptr, pbIsGlobal &i32) u32

// [in] tk
// The token to check the reference validity for.
fn C.IsValidToken(tk voidptr) bool

// [in] hEnum
// The enumerator to reset.
// [in] ulPos
// The new position at which to place the enumerator.
fn C.ResetEnum(hEnum u32, ulPos u32) u32

// [in] tkTypeRef
// The TypeRef metadata token to return the referenced type information for.
// [in] riid
// The IID of the interface to return in ppIScope. Typically, this would be IID_IMetaDataImport.
// [out] ppIScope
// An interface to the module scope in which the referenced type is defined.
// [out, retval] ptkTypeDef
// A pointer to a TypeDef token that represents the referenced type.
fn C.ResolveTypeRef(tkTypeRef voidptr, riid voidptr, ppIScope voidptr, ptkTypeDef voidptr) u32
