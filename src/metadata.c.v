module metadata

#flag -IC:/Program Files (x86)/Windows Kits/10/Include/10.0.22000.0/shared
#flag -IC:/Program Files (x86)/Windows Kits/10/Include/10.0.22000.0/winrt
#include <roapi.h>
#include <RoMetadataApi.h>
#include <rometadata.h>

////////////////////////
// Metadata dispenser //
////////////////////////

[callconv: 'stdcall']
fn C.MetaDataGetDispenser(clsid &Guid, iid &Guid, dispenser_ptr_ptr &&C.IMetaDataDispenserEx) GetMetadataDispenserResult

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
	GetCORSystemDirectory fn (this &C.IMetaDataDispenserEx, szBuffer &u16, cchBuffer u32, pchBuffer &u32) u32
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
	FindAssembly fn (this &C.IMetaDataDispenserEx, szAppBase &u16, szPrivateBin &u16, szBlobalBin &u16, szAssemblyName &u16, szName &u16, cchName u32, pchName &u32) u32
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
	FindAssemblyModule fn (this &C.IMetaDataDispenserEx, szAppBase &u16, szPrivateBin &u16, szGlobalBin &u16, szAssemblyName &u16, szModuleName &u16, szName &u16, cchName u32, pcName &u32) u32
	// [in] szScope
	// The name of the file to be opened. The file must contain common language runtime (CLR) metadata.
	// [in] dwOpenFlags
	// Specifies the mode (read, and so on) for opening. This is a value of the CorOpenFlags enumeration. You can only import (read) from the file, not emit (write) to it.
	// [in] riid
	// The IID of the desired metadata interface to be returned; the caller will use the interface to import (read) metadata.
	// Valid values for riid include IID_IUnknown, IID_IMetaDataImport, IID_IMetaDataImport2, IID_IMetaDataAssemblyImport, IID_IMetaDataTables, and IID_IMetaDataTables2.
	// [out] ppIUnk
	// The pointer to the returned interface.
	OpenScope fn (this &C.IMetaDataDispenserEx, szScope &u16, dwOpenFlags u32, riid voidptr, ppIUnk OpenScopeIID) OpenScopeResult
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

/////////////////////
// Metadata import //
/////////////////////

struct C.IMetaDataImport2 {
pub:
	lpVtbl &C.IMetaDataImport2Vtbl
}

struct C.IMetaDataImport2Vtbl {
pub:
	// [in] hEnum
	// The handle of the enumerator to close.
	CloseEnum fn (this &C.IMetaDataImport2, hEnum u32)
	// [in] hEnum
	// The handle for the enumerator.
	// [out, retval] pulCount
	// The number of elements enumerated.
	CountEnum fn (this &C.IMetaDataImport2, hEnum u32, pulCount &u32) u32
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
	EnumCustomAttributes fn (this &C.IMetaDataImport2, phEnum &usize, tk u32, tkType u32, rgCustomAttributes &u32, cMax u32, pcCustomAttributes &u32) u32
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
	EnumEvents fn (this &C.IMetaDataImport2, phEnum &usize, tkTypDef u32, rgEvents &u32, cMax u32, pcEvents &u32) u32
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
	EnumFields fn (this &C.IMetaDataImport2, phEnum &usize, tkTypeDef u32, rgFields &u32, cMax u32, pcTokens &u32) u32
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
	EnumFieldsWithName fn (this &C.IMetaDataImport2, phEnum &usize, tkTypeDef u32, szName &u16, rFields &u32, cMax u32, pcTokens &u32) u32
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
	EnumGenericParamConstraints fn (this &C.IMetaDataImport2, phEnum &usize, tk u32, rGenericParamConstraints &u32, cMax u32, pcGenericParamConstraints &u32) u32
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
	EnumGenericParams fn (this &C.IMetaDataImport2, phEnum &usize, tk u32, rGenericParams &u32, cMax u32, pcGenericParams &u32) u32
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
	EnumInterfaceImpls fn (this &C.IMetaDataImport2, phEnum &usize, td voidptr, rImpls &u32, cMax u32, pcImpls &u32) u32
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
	EnumMemberRefs fn (this &C.IMetaDataImport2, phEnum &usize, tkParent u32, rgMemberRefs &u32, cMax u32, pcTokens &u32) u32
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
	EnumMembers fn (this &C.IMetaDataImport2, phEnum &usize, tkTypeDef u32, rgMembers &u32, cMax u32, pcTokens &u32) u32
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
	EnumMembersWithName fn (this &C.IMetaDataImport2, phEnum &usize, tkTypeDef u32, szName &u16, rgMembers &u32, cMax u32, pcTokens &u32) u32
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
	EnumMethodImpls fn (this &C.IMetaDataImport2, phEnum &usize, tkTypeDef u32, rMethodBody &u32, rMethodDecl &u32, cMax u32, pcTokens &u32) u32
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
	EnumMethodSemantics fn (this &C.IMetaDataImport2, phEnum &usize, tkMethodDef u32, rgEventProp &u32, cMax u32, pcEventProp &u32) u32
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
	EnumMethods fn (this &C.IMetaDataImport2, phEnum &usize, tkTypeDef u32, rgMethods &u32, cMax u32, pcTokens &u32) u32
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
	EnumMethodSpecs fn (this &C.IMetaDataImport2, phEnum &usize, tk u32, rMethodSpecs &u32, cMax u32, pcMethodSpecs &u32) u32
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
	EnumMethodsWithName fn (this &C.IMetaDataImport2, phEnum &usize, tkTypeDef u32, szName &u16, rgMethods &u32, cMax u32, pcTokens &u32) u32
	// [in, out] phEnum
	// A pointer to the enumerator. This must be NULL for the first call of this method.
	// [out] rgModuleRefs
	// The array used to store the ModuleRef tokens.
	// [in] cMax
	// The maximum size of the rgModuleRefs array.
	// [out] pcModuleRefs
	// The number of ModuleRef tokens returned in rgModuleRefs.
	EnumModuleRefs fn (this &C.IMetaDataImport2, phEnum &usize, rgModuleRefs &u32, cMax u32, pcModuleRefs &u32) u32
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
	EnumParams fn (this &C.IMetaDataImport2, phEnum &usize, tkMethodDef u32, rParams &u32, cMax u32, pcTokens &u32) u32
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
	EnumPermissionSets fn (this &C.IMetaDataImport2, phEnum &usize, tk u32, dwActions u32, rPermission &u32, cMax u32, pcTokens &u32) u32
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
	EnumProperties fn (this &C.IMetaDataImport2, phEnum &usize, tkTypeDef u32, rgProperties &u32, cMax u32, pcProperties &u32) u32
	// [in, out] phEnum
	// A pointer to the enumerator. This must be NULL for the first call of this method.
	// [out] rgSignatures
	// The array used to store the Signature tokens.
	// [in] cMax
	// The maximum size of the rgSignatures array.
	// [out] pcSignatures
	// The number of Signature tokens returned in rgSignatures.
	EnumSignatures fn (this &C.IMetaDataImport2, phEnum &usize, rgSignatures &u32, cMax u32, pcSignatures &u32) u32
	// [in, out] phEnum
	// A pointer to the new enumerator. This must be NULL for the first call of this method.
	// [out] rgTypeDefs
	// The array used to store the TypeDef tokens.
	// [in] cMax
	// The maximum size of the rgTypeDefs array.
	// [out, retval] pcTypeDefs
	// The number of TypeDef tokens returned in rgTypeDefs.
	EnumTypeDefs fn (this &C.IMetaDataImport2, phEnum &usize, rgTypeDefs &u32, cMax u32, pcTokens &u32) u32
	// [in, out] phEnum
	// A pointer to the enumerator. This must be NULL for the first call of this method.
	// [out] rgTypeRefs
	// The array used to store the TypeRef tokens.
	// [in] cMax
	// The maximum size of the rgTypeRefs array.
	// [out, retval] pcTypeRefs
	// A pointer to the number of TypeRef tokens returned in rgTypeRefs.
	EnumTypeRefs fn (this &C.IMetaDataImport2, phEnum &usize, rgTypeRefs &u32, cMax u32, pcTokens &u32) u32
	// [in, out] phEnum
	// A pointer to the enumerator. This value must be NULL for the first call of this method.
	// [out] rgTypeSpecs
	// The array used to store the TypeSpec tokens.
	// [in] cMax
	// The maximum size of the rgTypeSpecs array.
	// [out] pcTypeSpecs
	// The number of TypeSpec tokens returned in rgTypeSpecs.
	EnumTypeSpecs fn (this &C.IMetaDataImport2, phEnum &usize, rgTypeSpecs &u32, cMax u32, pcTypeSpecs &u32) u32
	// [in, out] phEnum
	// A pointer to the enumerator. This must be NULL for the first call of this method.
	// [out] rgMethods
	// The array used to store the MemberDef tokens.
	// [in] cMax
	// The maximum size of the rgMethods array.
	// [out] pcTokens
	// The number of MemberDef tokens returned in rgMethods.
	EnumUnresolvedMethods fn (this &C.IMetaDataImport2, phEnum &usize, rgTypeDefs &u32, cMax u32, pcTokens &u32) u32
	// [in, out] phEnum
	// A pointer to the enumerator. This must be NULL for the first call of this method.
	// [out] rgStrings
	// The array used to store the String tokens.
	// [in] cMax
	// The maximum size of the rgStrings array.
	// [out] pcStrings
	// The number of String tokens returned in rgStrings.
	EnumUserStrings fn (this &C.IMetaDataImport2, phEnum &usize, rgStrings &u32, cMax u32, pcStrings &u32) u32
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
	FindMemberRef fn (this &C.IMetaDataImport2, tkTypeRef u32, szName &u16, pvSigBlob voidptr, cbSigBlob u32, pMemberRef voidptr) u32
	// [in] szTypeDef
	// The name of the type for which to get the TypeDef token.
	// [in] tkEnclosingClass
	// A TypeDef or TypeRef token representing the enclosing class. If the type to find is not a nested class, set this value to NULL.
	// [out, retval] ptkTypeDef
	// A pointer to the matching TypeDef token.
	FindTypeDefByName fn (this &C.IMetaDataImport2, szTypeDef &u16, tkEnclosingClass u32, ptkTypeDef &u32) u32
	// [in] tkResolutionScope
	// A ModuleRef, AssemblyRef, or TypeRef token that specifies the module, assembly, or type, respectively, in which the type reference is defined.
	// [in] szName
	// The name of the type reference to search for.
	// [out] tkTypeRef
	// A pointer to the matching TypeRef token.
	FindTypeRef fn (this &C.IMetaDataImport2, tkResolutionScope u32, szName &u16, tkTypeRef u32) u32
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
	GetCustomAttributeProps fn (this &C.IMetaDataImport2, cv voidptr, ptkObj &u32, ptkType &u32, ppBlob &&u8, pcbBlob &u32) u32
	// [in] tk
	// The metadata token that represents the field to get interop marshaling information for.
	// [out] ppvNativeType
	// A pointer to the metadata signature of the field's native type.
	// [out] pcbNativeType
	// The size in bytes of ppvNativeType.
	GetFieldMarshal fn (this &C.IMetaDataImport2, tk u32, ppvNativeType voidptr, pcbNativeType &u32) u32
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
	GetFieldProps fn (this &C.IMetaDataImport2, tkFieldDef u32, ptkTypeDef &u32, szField &u16, cchField u32, pchFIeld &u32, pdwAttr &u32, ppvSigBlob voidptr, pcbSigBlob &u32, pdwCPlusTypeFlag &u32, ppValue voidptr, pcchValue &u32) u32
	// [in] gpc
	// The token to the generic parameter constraint for which to return the metadata.
	// [out] ptGenericParam
	// A pointer to the token that represents the generic parameter that is constrained.
	// [out] ptkConstraintType
	// A pointer to a TypeDef, TypeRef, or TypeSpec token that represents a constraint on ptGenericParam.
	GetGenericParamConstraintProps fn (this &C.IMetaDataImport2, gpc u32, ptGenericParam &u32, ptkConstraintType &u32) u32
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
	GetGenericParamProps fn (this &C.IMetaDataImport2, gp u32, pulParamSeq &u32, pdwParamFlags &i32, ptOwner &u32, reserved voidptr, wzname string, cchName u32, pchName &u32) u32
	// [in] tkInterfaceImpl
	// The metadata token representing the method to return the class and interface tokens for.
	// [out] ptkClass
	// The metadata token representing the class that implements the method.
	// [out] ptkIface
	// The metadata token representing the interface that defines the implemented method.
	GetInterfaceImplProps fn (this &C.IMetaDataImport2, tkInterfaceImpl u32, ptkClass &u32, ptkIface &u32) u32
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
	GetMemberProps fn (this &C.IMetaDataImport2, tkMember u32, ptkTypeDef &u32, szMember &u16, cchMember u32, pchMember &u32, pdwAttr &u32, ppvSigBlob voidptr, pcbSigBlob &u32, pulCodeRVA &u32, pdwImplFlags &u32, pdwCPlusTypeFlag &u32, ppValue voidptr, pcchValue &u32) u32
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
	GetMemberRefProps fn (this &C.IMetaDataImport2, tkMemberRef u32, ptk &u32, szMember &u16, cchMember u32, pchMember &u32, ppvSigBlob voidptr, pcbSigBlob &u32) u32
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
	GetMethodProps fn (this &C.IMetaDataImport2, tkMethodDef u32, ptkClass &u32, szMethod &u16, cchMethod u32, pchMethod &u32, pdwAttr &u32, ppvSigBlob voidptr, pcbSigBlob &u32, pulCodeRVA &u32, pdwImplFlags &u32) u32
	// [in] tkMethodDef
	// A MethodDef token representing the method to get the semantic role information for.
	// [in] tkEventProp
	// A token representing the paired property and event for which to get the method's role.
	// [out] pdwSemanticsFlags
	// A pointer to the associated semantics flags. This value is a bitmask from the CorMethodSemanticsAttr enumeration.
	GetMethodSemantics fn (this &C.IMetaDataImport2, tkMethodDef u32, tkEventProp u32, pdwSemanticsFlags &u32) u32
	// [in] mi
	// A MethodSpec token that represents the instantiation of the method.
	// [out] tkParent
	// A pointer to the MethodDef or MethodRef token that represents the method definition.
	// [out] ppvSigBlob
	// A pointer to the binary metadata signature of the method.
	// [out] pcbSigBlob
	// The size, in bytes, of ppvSigBlob.
	GetMethodSpecProps fn (this &C.IMetaDataImport2, mi u32, tkParent u32, ppvSigBlob voidptr, pcbSigBlob &u32) u32
	// [out] ptkModule
	// A pointer to the token representing the module referenced in the current metadata scope.
	GetModuleFromScope fn (this &C.IMetaDataImport2, ptkModule &u32) u32
	// [in] tkModuleRef
	// The ModuleRef metadata token that references the module to get metadata information for.
	// [out] szName
	// A buffer to hold the module name.
	// [in] cchName
	// The requested size of szName in wide characters.
	// [out] pchName
	// The returned size of szName in wide characters.
	GetModuleRefProps fn (this &C.IMetaDataImport2, tkModuleRef u32, szName &u16, cchName u32, pchName &u32) u32
	// [in] tk
	// The token representing the object to return the name for.
	// [out] pszUtf8NamePtr
	// A pointer to the UTF-8 object name in the heap.
	GetNameFromToken fn (this &C.IMetaDataImport2, tk u32, pszUtf8NamePtr voidptr) u32
	// [in] tdNestedClass
	// A TypeDef token representing the Type to return the parent class token for.
	// [out] ptdEnclosingClass
	// A pointer to the TypeDef token for the Type that tdNestedClass is nested in.
	GetNestedClassProps fn (this &C.IMetaDataImport2, tdNestedClass u32, ptdEnclosingClass &u32) u32
	// [in] tkMethodDef
	// A token that represents the method to return the parameter token for.
	// [in] ulParamSeq
	// The ordinal position in the parameter list where the requested parameter occurs. Parameters are numbered starting from one, with the method's return value in position zero.
	// [out] ptkParamDef
	// A pointer to a ParamDef token that represents the requested parameter.
	GetParamForMethodIndex fn (this &C.IMetaDataImport2, tkMethodDef u32, ulParamSeq u32, ptkParamDef &u32) u32
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
	GetParamProps fn (this &C.IMetaDataImport2, tkParamDef u32, ptkMethodDef &u32, pulSequence &u32, szName &u16, cchName u32, pchName &u32, pdwAttr &u32, pdwCPlusTypeFlag &u32, ppValue voidptr, pcchValue &u32) u32
	// [out] pdwPEKind
	// A pointer to a value of the CorPEKind enumeration that describes the PE file.
	// [out] pdwMAchine
	// A pointer to a value that identifies the architecture of the machine. See the next section for possible values.
	GetPEKind fn (this &C.IMetaDataImport2, pwdPEKind &u32, pdwMachine &u32) u32
	// [in] tk
	// The Permission metadata token that represents the permission set to get the metadata properties for.
	// [out] pdwAction
	// A pointer to the permission set.
	// [out] ppvPermission
	// A pointer to the binary metadata signature of the permission set.
	// [out] pcbPermission
	// The size in bytes of const.
	GetPermissionSetProps fn (this &C.IMetaDataImport2, tk u32, pdwAction &u32, ppvPermission &&u8, pcbPermission &u32) u32
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
	GetPinvokeMap fn (this &C.IMetaDataImport2, tk u32, pdwMappingFlags &u32, szImportName &u16, cchImportNAme u32, pchImportName &u32, ptkImportDLL &u32) u32
	// [in] tk
	// A MethodDef or FieldDef metadata token that represents the code object to return the RVA for. If the token is a FieldDef, the field must be a global variable.
	// [out] pulCodeRVA
	// A pointer to the relative virtual address of the code object represented by the token.
	// [out] pdwImplFlags
	// A pointer to the implementation flags for the method. This value is a bitmask from the [CorMethodImpl](https://learn.microsoft.com/en-us/dotnet/framework/unmanaged-api/metadata/cormethodimpl-enumeration) enumeration. The value of pdwImplFlags is valid only if tk is a MethodDef token.
	GetRVA fn (this &C.IMetaDataImport2, tk u32, pulCodeRVA &u32, pdwImplFlags &u32) u32
	// [out] szName
	// A buffer for the assembly or module name.
	// [in] cchName
	// The size in wide characters of szName.
	// [out] pchName
	// The number of wide characters returned in szName.
	// [out] pmvid
	// A pointer to a GUID that uniquely identifies the version of the assembly or module.
	GetScopeProps fn (this &C.IMetaDataImport2, szName &u16, cchName u32, pchName &u32, pmvid voidptr) u32
	// [in] tkSignature
	// The token to return the binary metadata signature for.
	// [out] ppvSig
	// A pointer to the returned metadata signature.
	// [out] pcbSig
	// The size in bytes of the binary metadata signature.
	GetSigFromToken fn (this &C.IMetaDataImport2, tkSignature u32, ppvSig voidptr, pcbSig &u32) u32
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
	GetTypeDefProps fn (this &C.IMetaDataImport2, tkTypeDef u32, szTypeDef &u16, cchTypeDef u32, pchTypeDef &u32, pdwTypeDefFlags &u32, ptkExtends &u32) u32
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
	GetTypeRefProps fn (this &C.IMetaDataImport2, tkTypeRef u32, ptkResolutionScope &u32, szName &u16, cchName u32, pchName &u32) u32
	// [in] tkTypeSpec
	// The TypeSpec token associated with the requested metadata signature.
	// [out] ppvSig
	// A pointer to the binary metadata signature.
	// [out] pcbSig
	// The size, in bytes, of the metadata signature.
	GetTypeSpecFromToken fn (this &C.IMetaDataImport2, tkTypeSpec u32, ppvSig voidptr, pcbSig &u32) u32
	// [in] tkString
	// The String token to return the associated string for.
	// [out] szString
	// A copy of the requested string.
	// [in] cchString
	// The maximum size in wide characters of the requested szString.
	// [out] pchString
	// The size in wide characters of the returned szString.
	GetUserString fn (this &C.IMetaDataImport2, tkString u32, szString &u16, cchString u32, pchString &u32) u32
	// [out] pwzBuf
	// An array to store the string that specifies the version.
	// [in] ccBufSize
	// The size, in wide characters, of the pwzBuf array.
	// [out] pccBufSize
	// The number of wide characters, including a null terminator, returned in the pwzBuf array.
	GetVersionString fn (this &C.IMetaDataImport2, pwzBuf string, ccBufSize u32, pccBufSize &u32) u32
	// [in] tk
	// A metadata token that represents a type, field, or method.
	// [out] pbIsGlobal
	// 1 if the object has global scope; otherwise, 0 (zero).
	IsGlobal fn (this &C.IMetaDataImport2, tk u32, pbIsGlobal &i32) u32
	// [in] tk
	// The token to check the reference validity for.
	IsValidToken fn (this &C.IMetaDataImport2, tk u32) bool
	// [in] hEnum
	// The enumerator to reset.
	// [in] ulPos
	// The new position at which to place the enumerator.
	ResetEnum fn (this &C.IMetaDataImport2, hEnum u32, ulPos u32) u32
	// [in] tkTypeRef
	// The TypeRef metadata token to return the referenced type information for.
	// [in] riid
	// The IID of the interface to return in ppIScope. Typically, this would be IID_IMetaDataImport.
	// [out] ppIScope
	// An interface to the module scope in which the referenced type is defined.
	// [out, retval] ptkTypeDef
	// A pointer to a TypeDef token that represents the referenced type.
	ResolveTypeRef fn (this &C.IMetaDataImport2, tkTypeRef u32, riid voidptr, ppIScope voidptr, ptkTypeDef &u32) u32
}

//////////////////////////////
// Metadata assembly import //
//////////////////////////////

struct C.OSINFO {
	dwOSPlatformId   u32
	dwOSMajorVersion u32
	dwOSMinorVersion u32
}

struct C.ASSEMBLYMETADATA {
	usMajorVersion   u16
	usMinorVersion   u16
	usBuildNumber    u16
	usRevisionNumber u16
	szLocale         &u16
	cbLocale         u32
	rdwProcessor     &u32
	ulProcessor      u32
	rOS              []C.OSINFO
	ulOS             u32
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
	EnumAssemblyRefs fn (this &C.IMetaDataAssemblyImport, phEnum &usize, rAssemblyRefs &u32, cMax u32, pcTokens &u32) u32
	// [in, out] phEnum
	// A pointer to the enumerator. This must be a null value when the EnumExportedTypes method is called for the first time.
	// [out] rExportedTypes
	// The enumeration of mdExportedType metadata tokens.
	// [in] cMax
	// The maximum number of mdExportedType tokens that can be placed in the rExportedTypes array.
	// [out] pcTokens
	// The number of mdExportedType tokens actually placed in rExportedTypes.
	EnumExportedTypes fn (this &C.IMetaDataAssemblyImport, phEnum &usize, rExportedTypes &u32, cMax u32, pcTokens &u32) u32
	// [in, out] phEnum
	// A pointer to the enumerator. This must be a null value for the first call of this method.
	// [out] rFiles
	// The array used to store the mdFile metadata tokens.
	// [in] cMax
	// The maximum number of mdFile tokens that can be placed in rFiles.
	// [out] pcTokens
	// The number of mdFile tokens actually placed in rFiles.
	EnumFiles fn (this &C.IMetaDataAssemblyImport, phEnum &usize, rFiles &u32, cMax u32, pcTokens &u32) u32
	// [in, out] phEnum
	// A pointer to the enumerator. This must be a null value when the EnumManifestResources method is called for the first time.
	// [out] rManifestResources
	// The array used to store the mdManifestResource metadata tokens.
	// [in] cMax
	// The maximum number of mdManifestResource tokens that can be placed in rManifestResources.
	// [out] pcTokens
	// The number of mdManifestResource tokens actually placed in rManifestResources.
	EnumManifestResources fn (this &C.IMetaDataAssemblyImport, phEnum &usize, rManifestResources &u32, cMax u32, pcTokens &u32) u32
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
	FindExportedTypeByName fn (this &C.IMetaDataAssemblyImport, szName string, mdtExportedType u32, ptkExportedType &u32) u32
	// [in] szName
	// The name of the resource.
	// [out] ptkManifestResource
	// The array used to store the mdManifestResource metadata tokens, each of which represents a manifest resource.
	FindManifestResourceByName fn (this &C.IMetaDataAssemblyImport, szName string, ptkManifestResource &u32) u32
	// [out] ptkAssembly
	// A pointer to the retrieved mdAssembly token that identifies the assembly.
	GetAssemblyFromScope fn (this &C.IMetaDataAssemblyImport, ptkAssembly &u32) u32
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
	GetAssemblyProps fn (this &C.IMetaDataAssemblyImport, mds u32, ppbPublicKey &&u8, pcbPublicKey &u32, pulHashALgId &u32, szName string, cchName u32, pchName &u32, pMetaData &C.ASSEMBLYMETADATA, pdwAssemblyFlags &u32) u32
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
	GetAssemblyRefProps fn (this &C.IMetaDataAssemblyImport, mdar u32, ppbPublicKeyOrToken &&u8, pcbPublicKeyOrToken &u32, szName string, cchName u32, pchName &u32, pMetaData &C.ASSEMBLYMETADATA, ppbHashValue &&u8, pcbHashValue u32, pdwAssemblyRefFlags &u32) u32
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
	GetExportedTypeProps fn (this &C.IMetaDataAssemblyImport, mdct u32, szName string, cchName u32, pchName &u32, ptkImplementation &u32, ptkTypeDef &u32, pdwExportedTypeFlags &u32) u32
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
	GetFileProps fn (this &C.IMetaDataAssemblyImport, mdf u32, szName string, cchName u32, pchName &u32, ppbHashValue &&u8, pcbHashValue &u32, pdwFileFlags &u32) u32
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
	GetManifestResourceProps fn (this &C.IMetaDataAssemblyImport, mdmr u32, szName string, cchName u32, pchName &u32, ptkImplementation &u32, pdwOffset &u32, pdwResourceFlags &u32) u32
}

/////////////////////
// Metadata tables //
/////////////////////

struct C.IMetaDataTables2 {
	lpVtbl &C.IMetaDataTables2Vtbl
}

struct C.IMetaDataTables2Vtbl {
	// [in] ixBlob
	// The memory address from which to get ppData.
	// [out] pcbData
	// A pointer to the size, in bytes, of ppData.
	// [out] ppData
	// A pointer to a pointer to the binary data retrieved.
	GetBlob fn (this &C.IMetaDataTables2, ixBlob u32, pcbData &u32, ppData &&u8) u32
	// [out] pcbBlobs
	// A pointer to the size, in bytes, of the BLOB heap.
	GetBlobHeapSize fn (this &C.IMetaDataTables2, pcbBlobs &u32) u32
	// [in] ixCdTkn
	// The kind of coded token to return.
	// [out] pcTokens
	// A pointer to the length of ppTokens.
	// [out] ppTokens
	// A pointer to a pointer to an array that contains the list of returned tokens.
	// [out] ppName
	// A pointer to a pointer to the name of the token at ixCdTkn.
	GetCodedTokenInfo fn (this &C.IMetaDataTables2, ixCdTkn u32, pcTokens &u32, ppTokens &&u32, ppName &&u8) u32
	// [in] ixTbl
	// The index of the table.
	// [in] ixCol
	// The index of the column in the table.
	// [in] rid
	// The index of the row in the table.
	// [out] pVal
	// A pointer to the value in the cell.
	GetColumn fn (this &C.IMetaDataTables2, ixTbl u32, ixCol u32, rid u32, pVal &u32) u32
	// [in] ixTbl
	// The index of the desired table.
	// [in] ixCol
	// The index of the desired column.
	// [out] poCol
	// A pointer to the offset of the column in the row.
	// [out] pcbCol
	// A pointer to the size, in bytes, of the column.
	// [out] pType
	// A pointer to the type of the values in the column.
	// [out] ppName
	// A pointer to a pointer to the column name.
	GetColumnInfo fn (this &C.IMetaDataTables2, ixTbl u32, ixCol u32, poCol &u32, pcbCol &u32, pType &u32, ppName &&u8) u32
	// [in] ixGuid
	// The index of the row from which to get the GUID.
	// [out] ppGUID
	// A pointer to a pointer to the GUID.
	GetGuid fn (this &C.IMetaDataTables2, ixGuix u32, guid &&u32) u32
	// [out] pcbGuids
	// A pointer to the size, in bytes, of the GUID heap.
	GetGuidHeapSize fn (this &C.IMetaDataTables2, pcbGuids &u32) u32
	// [out] ppvMd
	// A pointer to a metadata section.
	// [out] pcbMd
	// The size of the metadata stream.
	GetMetaDataStorage fn (this &C.IMetaDataTables2, ppvMd &&u8, pcbMd &u32) u32
	// [in] ix
	// The index of the requested metadata stream.
	// [out] ppchName
	// A pointer to the name of the stream.
	// [out] ppv
	// A pointer to the metadata stream.
	// [out] pcb
	// The size, in bytes, of ppv.
	GetMetaDataStreamInfo fn (this &C.IMetaDataTables2, ix u32, ppchName &u8, ppv &&u8, pcb &u32) u32
	// [in] ixBlob
	// The index, as returned from a column of BLOBs.
	// [out] pNext
	// A pointer to the index of the next BLOB.
	GetNextBlob fn (this &C.IMetaDataTables2, ixBlob u32, pNext &u32) u32
	// [in] ixGuid
	// The index value from a GUID table column.
	// [out] pNext
	// A pointer to the index of the next GUID value.
	GetNextGuid fn (this &C.IMetaDataTables2, ixGuid u32, pNext &u32) u32
	// [in] ixString
	// The index value from a string table column.
	// [out] pNext
	// A pointer to the index of the next string in the column.
	GetNextString fn (this &C.IMetaDataTables2, ixString u32, pNext &u32) u32
	// [in] ixUserString
	// An index value from the current string column.
	// [out] pNext
	// A pointer to the row index of the next string in the column.
	GetNextUserString fn (this &C.IMetaDataTables2, ixUserString u32, pNext &u32) u32
	// [out] pcTables
	// A pointer to the number of tables in the current instance scope.
	GetNumTables fn (this &C.IMetaDataTables2, pcTables &u32) u32
	// [in] ixTbl
	// The index of the table from which the row will be retrieved.
	// [in] rid
	// The index of the row to get.
	// [out] ppRow
	// A pointer to a pointer to the row.
	GetRow fn (this &C.IMetaDataTables2, ixTbl u32, rid u32, ppRow &u8) u32
	// [in] ixString
	// The index at which to start to search for the next value.
	// [out] ppString
	// A pointer to a pointer to the returned string value.
	GetString fn (this &C.IMetaDataTables2, ixString u32, ppString &u8) u32
	// [out] pcbStrings
	// A pointer to the size, in bytes, of the string heap.
	GetStringHeapSize fn (this &C.IMetaDataTables2, pcbStrings &u32) u32
	// [in] token
	// The token that references the table.
	// [out] pixTbl
	// A pointer to the returned index for the referenced table.
	GetTableIndex fn (this &C.IMetaDataTables2, token u32, pixTbl &u32) u32
	// [in] ixTbl
	// The identifier of the table whose properties to return.
	// [out] pcbRow
	// A pointer to the size, in bytes, of a table row.
	// [out] pcRows
	// A pointer to the number of rows in the table.
	// [out] pcCols
	// A pointer to the number of columns in the table.
	// [out] piKey
	// A pointer to the index of the key column, or -1 if the table has no key column.
	// [out] ppName
	// A pointer to a pointer to the table name.
	GetTableInfo fn (this &C.IMetaDataTables2, ixTbl u32, pcbRow &u32, pcRows &u32, pcCols &u32, piKey &u32, ppName &&u8) u32
	// [in] ixUserString
	// The index value from which the hard-coded string will be retrieved.
	// [out] pcbData
	// A pointer to the size of ppData.
	// [out] ppData
	// A pointer to a pointer to the returned string.
	GetUserString fn (this &C.IMetaDataTables2, ixUserString u32, pcbData &u32, ppData &&u8) u32
	// [out] pcbUserStrings
	// A pointer to the size, in bytes, of the user string heap.
	GetUserStringHeapSize fn (this &C.IMetaDataTables2, pcbUserStrings &u32) u32
}
