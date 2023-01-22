module metadata

#flag -IC:/Program Files (x86)/Windows Kits/10/Include/10.0.22000.0/shared
#flag -IC:/Program Files (x86)/Windows Kits/10/Include/10.0.22000.0/winrt
#include <roapi.h>
#include <RoMetadataApi.h>
#include <rometadata.h>

const iid_metadata_import2 = Guid{0xfce5efa0, 0x8bba, 0x4f8e, [u8(0xa0), 0x36, 0x8f, 0x20, 0x22,
	0xb0, 0x84, 0x66]!}

pub struct MetaDataImport {
	import_ptr &C.IMetaDataImport2
}

pub fn (md MetaDataImport) close_enum(hEnum u32) {
	// TODO: Make function idiomatic to V
	md.import_ptr.lpVtbl.CloseEnum(md.import_ptr, hEnum)
}

pub fn (md MetaDataImport) count_enum(hEnum u32, pulCount &u32) u32 {
	// TODO: Make function idiomatic to V
	return md.import_ptr.lpVtbl.CountEnum(md.import_ptr, hEnum, pulCount)
}

pub fn (md MetaDataImport) enum_custom_attributes(phEnum &u32, tk voidptr, tkType voidptr, rgCustomAttributes []voidptr, cMax u32, pcCustomAttributes &u32) u32 {
	// TODO: Make function idiomatic to V
	return md.import_ptr.lpVtbl.EnumCustomAttributes(md.import_ptr, phEnum, tk, tkType, rgCustomAttributes,
		cMax, pcCustomAttributes)
}

pub fn (md MetaDataImport) enum_events(phEnum &u32, tkTypDef voidptr, rgEvents []voidptr, cMax u32, pcEvents &u32) u32 {
	// TODO: Make function idiomatic to V
	return md.import_ptr.lpVtbl.EnumEvents(md.import_ptr, phEnum, tkTypDef, rgEvents, cMax, pcEvents)
}

pub fn (md MetaDataImport) enum_fields(phEnum &u32, tkTypeDef voidptr, rgFields []voidptr, cMax u32, pcTokens &u32) u32 {
	// TODO: Make function idiomatic to V
	return md.import_ptr.lpVtbl.EnumFields(md.import_ptr, phEnum, tkTypeDef, rgFields, cMax, pcTokens)
}

pub fn (md MetaDataImport) enum_fields_with_name(phEnum &u32, tkTypeDef voidptr, szName string, rFields []voidptr, cMax u32, pcTokens &u32) u32 {
	// TODO: Make function idiomatic to V
	return md.import_ptr.lpVtbl.EnumFieldsWithName(md.import_ptr, phEnum, tkTypeDef, szName, rFields,
		cMax, pcTokens)
}

pub fn (md MetaDataImport) enum_generic_param_constraints(phEnum &u32, tk voidptr, rGenericParamConstraints []voidptr, cMax u32, pcGenericParamConstraints &u32) u32 {
	// TODO: Make function idiomatic to V
	return md.import_ptr.lpVtbl.EnumGenericParamConstraints(md.import_ptr, phEnum, tk, rGenericParamConstraints,
		cMax, pcGenericParamConstraints)
}

pub fn (md MetaDataImport) enum_generic_params(phEnum voidptr, tk voidptr, rGenericParams []voidptr, cMax u32, pcGenericParams &u32) u32 {
	// TODO: Make function idiomatic to V
	return md.import_ptr.lpVtbl.EnumGenericParams(md.import_ptr, phEnum, tk, rGenericParams, cMax, pcGenericParams)
}

pub fn (md MetaDataImport) enum_interface_impls(phEnum &u32, td voidptr, rImpls []voidptr, cMax u32, pcImpls &u32) u32 {
	// TODO: Make function idiomatic to V
	return md.import_ptr.lpVtbl.EnumInterfaceImpls(md.import_ptr, phEnum, td, rImpls, cMax, pcImpls)
}

pub fn (md MetaDataImport) enum_member_refs(phEnum &u32, tkParent voidptr, rgMemberRefs []voidptr, cMax u32, pcTokens &u32) u32 {
	// TODO: Make function idiomatic to V
	return md.import_ptr.lpVtbl.EnumMemberRefs(md.import_ptr, phEnum, tkParent, rgMemberRefs, cMax, pcTokens)
}

pub fn (md MetaDataImport) enum_members(phEnum &u32, tkTypeDef voidptr, rgMembers []voidptr, cMax u32, pcTokens &u32) u32 {
	// TODO: Make function idiomatic to V
	return md.import_ptr.lpVtbl.EnumMembers(md.import_ptr, phEnum, tkTypeDef, rgMembers, cMax, pcTokens)
}

pub fn (md MetaDataImport) enum_members_with_name(phEnum &u32, tkTypeDef voidptr, szName string, rgMembers []voidptr, cMax u32, pcTokens &u32) u32 {
	// TODO: Make function idiomatic to V
	return md.import_ptr.lpVtbl.EnumMembersWithName(md.import_ptr, phEnum, tkTypeDef, szName, rgMembers,
		cMax, pcTokens)
}

pub fn (md MetaDataImport) enum_method_impls(phEnum &u32, tkTypeDef voidptr, rMethodBody []voidptr, rMethodDecl []voidptr, cMax u32, pcTokens &u32) u32 {
	// TODO: Make function idiomatic to V
	return md.import_ptr.lpVtbl.EnumMethodImpls(md.import_ptr, phEnum, tkTypeDef, rMethodBody, rMethodDecl,
		cMax, pcTokens)
}

pub fn (md MetaDataImport) enum_method_semantics(phEnum &u32, tkMethodDef voidptr, rgEventProp []voidptr, cMax u32, pcEventProp &u32) u32 {
	// TODO: Make function idiomatic to V
	return md.import_ptr.lpVtbl.EnumMethodSemantics(md.import_ptr, phEnum, tkMethodDef, rgEventProp,
		cMax, pcEventProp)
}

pub fn (md MetaDataImport) enum_method_specs(phEnum &u32, tkTypeDef voidptr, rgMethods []voidptr, cMax u32, pcTokens &u32) u32 {
	// TODO: Make function idiomatic to V
	return md.import_ptr.lpVtbl.EnumMethodSpecs(md.import_ptr, phEnum, tkTypeDef, rgMethods, cMax, pcTokens)
}

pub fn (md MetaDataImport) enum_methods(phEnum &u32, tkTypeDef voidptr, rgMethods []voidptr, cMax u32, pcTokens &u32) u32 {
	// TODO: Make function idiomatic to V
	return md.import_ptr.lpVtbl.EnumMethods(md.import_ptr, phEnum, tkTypeDef, rgMethods, cMax, pcTokens)
}

pub fn (md MetaDataImport) enum_methods_with_name(phEnum &u32, tkTypeDef voidptr, szName string, rgMethods []voidptr, cMax u32, pcTokens &u32) u32 {
	// TODO: Make function idiomatic to V
	return md.import_ptr.lpVtbl.EnumMethodsWithName(md.import_ptr, phEnum, tkTypeDef, szName, rgMethods,
		cMax, pcTokens)
}

pub fn (md MetaDataImport) enum_module_refs(phEnum &u32, rgModuleRefs []voidptr, cMax u32, pcModuleRefs &u32) u32 {
	// TODO: Make function idiomatic to V
	return md.import_ptr.lpVtbl.EnumModuleRefs(md.import_ptr, phEnum, rgModuleRefs, cMax, pcModuleRefs)
}

pub fn (md MetaDataImport) enum_params(phEnum &u32, tkMethodDef voidptr, rParams []voidptr, cMax u32, pcTokens &u32) u32 {
	// TODO: Make function idiomatic to V
	return md.import_ptr.lpVtbl.EnumParams(md.import_ptr, phEnum, tkMethodDef, rParams, cMax, pcTokens)
}

pub fn (md MetaDataImport) enum_permission_sets(phEnum &u32, tk voidptr, dwActions u32, rPermission []voidptr, cMax u32, pcTokens &u32) u32 {
	// TODO: Make function idiomatic to V
	return md.import_ptr.lpVtbl.EnumPermissionSets(md.import_ptr, phEnum, tk, dwActions, rPermission,
		cMax, pcTokens)
}

pub fn (md MetaDataImport) enum_properties(phEnum &u32, tkTypeDef voidptr, rgProperties []voidptr, cMax u32, pcProperties &u32) u32 {
	// TODO: Make function idiomatic to V
	return md.import_ptr.lpVtbl.EnumProperties(md.import_ptr, phEnum, tkTypeDef, rgProperties, cMax,
		pcProperties)
}

pub fn (md MetaDataImport) enum_signatures(phEnum &u32, rgSignatures []voidptr, cMax u32, pcSignatures &u32) u32 {
	// TODO: Make function idiomatic to V
	return md.import_ptr.lpVtbl.EnumSignatures(md.import_ptr, phEnum, rgSignatures, cMax, pcSignatures)
}

pub fn (md MetaDataImport) enum_type_defs(phEnum &u32, rgTypeDefs []voidptr, cMax u32, pcTokens &u32) u32 {
	// TODO: Make function idiomatic to V
	return md.import_ptr.lpVtbl.EnumTypeDefs(md.import_ptr, phEnum, rgTypeDefs, cMax, pcTokens)
}

pub fn (md MetaDataImport) enum_type_refs(phEnum &u32, rgTypeRefs []voidptr, cMax u32, pcTokens &u32) u32 {
	// TODO: Make function idiomatic to V
	return md.import_ptr.lpVtbl.EnumTypeRefs(md.import_ptr, phEnum, rgTypeRefs, cMax, pcTokens)
}

pub fn (md MetaDataImport) enum_type_specs(phEnum &u32, rgTypeSpecs []voidptr, cMax u32, pcTypeSpecs &u32) u32 {
	// TODO: Make function idiomatic to V
	return md.import_ptr.lpVtbl.EnumTypeSpecs(md.import_ptr, phEnum, rgTypeSpecs, cMax, pcTypeSpecs)
}

pub fn (md MetaDataImport) enum_unresolved_methods(phEnum &u32, rgTypeDefs []voidptr, cMax u32, pcTokens &u32) u32 {
	// TODO: Make function idiomatic to V
	return md.import_ptr.lpVtbl.EnumUnresolvedMethods(md.import_ptr, phEnum, rgTypeDefs, cMax, pcTokens)
}

pub fn (md MetaDataImport) enum_user_strings(phEnum &u32, rgStrings []voidptr, cMax u32, pcStrings &u32) u32 {
	// TODO: Make function idiomatic to V
	return md.import_ptr.lpVtbl.EnumUserStrings(md.import_ptr, phEnum, rgStrings, cMax, pcStrings)
}

pub fn (md MetaDataImport) find_member_ref(tkTypeRef voidptr, szName string, pvSigBlob voidptr, cbSigBlob u32, pMemberRef voidptr) u32 {
	// TODO: Make function idiomatic to V
	return md.import_ptr.lpVtbl.FindMemberRef(md.import_ptr, tkTypeRef, szName, pvSigBlob, cbSigBlob,
		pMemberRef)
}

pub fn (md MetaDataImport) find_type_def_by_name(szTypeDef string, tkEnclosingClass voidptr, ptkTypeDef voidptr) u32 {
	// TODO: Make function idiomatic to V
	return md.import_ptr.lpVtbl.FindTypeDefByName(md.import_ptr, szTypeDef, tkEnclosingClass, ptkTypeDef)
}

pub fn (md MetaDataImport) find_type_ref(tkResolutionScope voidptr, szName string, tkTypeRef voidptr) u32 {
	// TODO: Make function idiomatic to V
	return md.import_ptr.lpVtbl.FindTypeRef(md.import_ptr, tkResolutionScope, szName, tkTypeRef)
}

pub fn (md MetaDataImport) get_custom_attribute_props(cv voidptr, ptkObj voidptr, ptkType voidptr, ppBlob &&u8, pcbBlob &u32) u32 {
	// TODO: Make function idiomatic to V
	return md.import_ptr.lpVtbl.GetCustomAttributeProps(md.import_ptr, cv, ptkObj, ptkType, ppBlob, pcbBlob)
}

pub fn (md MetaDataImport) get_field_marshal(tk u32, ppvNativeType voidptr, pcbNativeType &u32) u32 {
	// TODO: Make function idiomatic to V
	return md.import_ptr.lpVtbl.GetFieldMarshal(md.import_ptr, tk, ppvNativeType, pcbNativeType)
}

pub fn (md MetaDataImport) get_field_props(tkFieldDef voidptr, ptkTypeDef voidptr, szField string, cchField u32, pchFIeld &u32, pdwAttr &u32, ppvSigBlob voidptr, pcbSigBlob &u32, pdwCPlusTypeFlag &u32, ppValue voidptr, pcchValue &u32) u32 {
	// TODO: Make function idiomatic to V
	return md.import_ptr.lpVtbl.GetFieldProps(md.import_ptr, tkFieldDef, ptkTypeDef, szField, cchField,
		pchFIeld, pdwAttr, ppvSigBlob, pcbSigBlob, pdwCPlusTypeFlag, ppValue, pcchValue)
}

pub fn (md MetaDataImport) get_generic_param_constraint_props(gpc voidptr, ptGenericParam voidptr, ptkConstraintType voidptr) u32 {
	// TODO: Make function idiomatic to V
	return md.import_ptr.lpVtbl.GetGenericParamConstraintProps(md.import_ptr, gpc, ptGenericParam, ptkConstraintType)
}

pub fn (md MetaDataImport) get_generic_param_props(gp voidptr, pulParamSeq &u32, pdwParamFlags &i32, ptOwner voidptr, reserved voidptr, wzname string, cchName u32, pchName &u32) u32 {
	// TODO: Make function idiomatic to V
	return md.import_ptr.lpVtbl.GetGenericParamProps(md.import_ptr, gp, pulParamSeq, pdwParamFlags, ptOwner,
		reserved, wzname, cchName, pchName)
}

pub fn (md MetaDataImport) get_interface_impl_props(tkInterfaceImpl voidptr, ptkClass voidptr, ptkIface voidptr) u32 {
	// TODO: Make function idiomatic to V
	return md.import_ptr.lpVtbl.GetInterfaceImplProps(md.import_ptr, tkInterfaceImpl, ptkClass, ptkIface)
}

pub fn (md MetaDataImport) get_member_props(tkMember voidptr, ptkTypeDef voidptr, szMember string, cchMember u32, pchMember &u32, pdwAttr &u32, ppvSigBlob voidptr, pcbSigBlob &u32, pulCodeRVA &u32, pdwImplFlags &u32, pdwCPlusTypeFlag &u32, ppValue voidptr, pcchValue &u32) u32 {
	// TODO: Make function idiomatic to V
	return md.import_ptr.lpVtbl.GetMemberProps(md.import_ptr, tkMember, ptkTypeDef, szMember, cchMember,
		pchMember, pdwAttr, ppvSigBlob, pcbSigBlob, pulCodeRVA, pdwImplFlags, pdwCPlusTypeFlag,
		ppValue, pcchValue)
}

pub fn (md MetaDataImport) get_member_ref_props(tkMemberRef voidptr, ptk voidptr, szMember string, cchMember u32, pchMember &u32, ppvSigBlob voidptr, pcbSigBlob &u32) u32 {
	// TODO: Make function idiomatic to V
	return md.import_ptr.lpVtbl.GetMemberRefProps(md.import_ptr, tkMemberRef, ptk, szMember, cchMember,
		pchMember, ppvSigBlob, pcbSigBlob)
}

pub fn (md MetaDataImport) get_method_props(tkMethodDef voidptr, ptkClass voidptr, szMethod string, cchMethod u32, pchMethod &u32, pdwAttr &u32, ppvSigBlob voidptr, pcbSigBlob &u32, pulCodeRVA &u32, pdwImplFlags &u32) u32 {
	// TODO: Make function idiomatic to V
	return md.import_ptr.lpVtbl.GetMethodProps(md.import_ptr, tkMethodDef, ptkClass, szMethod, cchMethod,
		pchMethod, pdwAttr, ppvSigBlob, pcbSigBlob, pulCodeRVA, pdwImplFlags)
}

pub fn (md MetaDataImport) get_method_semantics(tkMethodDef voidptr, tkEventProp voidptr, pdwSemanticsFlags &u32) u32 {
	// TODO: Make function idiomatic to V
	return md.import_ptr.lpVtbl.GetMethodSemantics(md.import_ptr, tkMethodDef, tkEventProp, pdwSemanticsFlags)
}

pub fn (md MetaDataImport) get_method_spec_props(mi voidptr, tkParent voidptr, ppvSigBlob voidptr, pcbSigBlob &u32) u32 {
	// TODO: Make function idiomatic to V
	return md.import_ptr.lpVtbl.GetMethodSpecProps(md.import_ptr, mi, tkParent, ppvSigBlob, pcbSigBlob)
}

pub fn (md MetaDataImport) get_module_from_scope(ptkModule voidptr) u32 {
	// TODO: Make function idiomatic to V
	return md.import_ptr.lpVtbl.GetModuleFromScope(md.import_ptr, ptkModule)
}

pub fn (md MetaDataImport) get_module_ref_props(tkModuleRef voidptr, szName string, cchName u32, pchName &u32) u32 {
	// TODO: Make function idiomatic to V
	return md.import_ptr.lpVtbl.GetModuleRefProps(md.import_ptr, tkModuleRef, szName, cchName, pchName)
}

pub fn (md MetaDataImport) get_name_from_token(tk voidptr, pszUtf8NamePtr voidptr) u32 {
	// TODO: Make function idiomatic to V
	return md.import_ptr.lpVtbl.GetNameFromToken(md.import_ptr, tk, pszUtf8NamePtr)
}

pub fn (md MetaDataImport) get_nested_class_props(tdNestedClass voidptr, ptdEnclosingClass voidptr) u32 {
	// TODO: Make function idiomatic to V
	return md.import_ptr.lpVtbl.GetNestedClassProps(md.import_ptr, tdNestedClass, ptdEnclosingClass)
}

pub fn (md MetaDataImport) get_param_for_method_index(tkMethodDef voidptr, ulParamSeq u32, ptkParamDef voidptr) u32 {
	// TODO: Make function idiomatic to V
	return md.import_ptr.lpVtbl.GetParamForMethodIndex(md.import_ptr, tkMethodDef, ulParamSeq, ptkParamDef)
}

pub fn (md MetaDataImport) get_param_props(tkParamDef voidptr, ptkMethodDef voidptr, pulSequence &u32, szName string, cchName u32, pchName &u32, pdwAttr &u32, pdwCPlusTypeFlag &u32, ppValue voidptr, pcchValue &u32) u32 {
	// TODO: Make function idiomatic to V
	return md.import_ptr.lpVtbl.GetParamProps(md.import_ptr, tkParamDef, ptkMethodDef, pulSequence, szName,
		cchName, pchName, pdwAttr, pdwCPlusTypeFlag, ppValue, pcchValue)
}

pub fn (md MetaDataImport) get_pe_kind(pwdPEKind &u32, pdwMachine &u32) u32 {
	// TODO: Make function idiomatic to V
	return md.import_ptr.lpVtbl.GetPEKind(md.import_ptr, pwdPEKind, pdwMachine)
}

pub fn (md MetaDataImport) get_permission_set_props(tk voidptr, pdwAction &u32, ppvPermission &&u8, pcbPermission &u32) u32 {
	// TODO: Make function idiomatic to V
	return md.import_ptr.lpVtbl.GetPermissionSetProps(md.import_ptr, tk, pdwAction, ppvPermission, pcbPermission)
}

pub fn (md MetaDataImport) get_pinvoke_map(tk voidptr, pdwMappingFlags &u32, szImportName string, cchImportNAme u32, pchImportName &u32, ptkImportDLL voidptr) u32 {
	// TODO: Make function idiomatic to V
	return md.import_ptr.lpVtbl.GetPinvokeMap(md.import_ptr, tk, pdwMappingFlags, szImportName, cchImportNAme,
		pchImportName, ptkImportDLL)
}

pub fn (md MetaDataImport) get_rva(tk voidptr, pulCodeRVA &u32, pdwImplFlags &u32) u32 {
	// TODO: Make function idiomatic to V
	return md.import_ptr.lpVtbl.GetRVA(md.import_ptr, tk, pulCodeRVA, pdwImplFlags)
}

pub fn (md MetaDataImport) get_scope_props(szName string, cchName u32, pchName &u32, pmvid voidptr) u32 {
	// TODO: Make function idiomatic to V
	return md.import_ptr.lpVtbl.GetScopeProps(md.import_ptr, szName, cchName, pchName, pmvid)
}

pub fn (md MetaDataImport) get_sig_from_token(tkSignature voidptr, ppvSig voidptr, pcbSig &u32) u32 {
	// TODO: Make function idiomatic to V
	return md.import_ptr.lpVtbl.GetSigFromToken(md.import_ptr, tkSignature, ppvSig, pcbSig)
}

pub fn (md MetaDataImport) get_type_def_props(tkTypeDef voidptr, szTypeDef string, cchTypeDef u32, pchTypeDef &u32, pdwTypeDefFlags &u32, ptkExtends voidptr) u32 {
	// TODO: Make function idiomatic to V
	return md.import_ptr.lpVtbl.GetTypeDefProps(md.import_ptr, tkTypeDef, szTypeDef, cchTypeDef, pchTypeDef,
		pdwTypeDefFlags, ptkExtends)
}

pub fn (md MetaDataImport) get_type_ref_props(tkTypeRef voidptr, ptkResolutionScope voidptr, szName string, cchName u32, pchName &u32) u32 {
	// TODO: Make function idiomatic to V
	return md.import_ptr.lpVtbl.GetTypeRefProps(md.import_ptr, tkTypeRef, ptkResolutionScope, szName,
		cchName, pchName)
}

pub fn (md MetaDataImport) get_type_spec_from_token(tkTypeSpec voidptr, ppvSig voidptr, pcbSig &u32) u32 {
	// TODO: Make function idiomatic to V
	return md.import_ptr.lpVtbl.GetTypeSpecFromToken(md.import_ptr, tkTypeSpec, ppvSig, pcbSig)
}

pub fn (md MetaDataImport) get_user_string(tkString voidptr, szString string, cchString u32, pchString &u32) u32 {
	// TODO: Make function idiomatic to V
	return md.import_ptr.lpVtbl.GetUserString(md.import_ptr, tkString, szString, cchString, pchString)
}

pub fn (md MetaDataImport) get_version_string(pwzBuf string, ccBufSize u32, pccBufSize &u32) u32 {
	// TODO: Make function idiomatic to V
	return md.import_ptr.lpVtbl.GetVersionString(md.import_ptr, pwzBuf, ccBufSize, pccBufSize)
}

pub fn (md MetaDataImport) is_global(tk voidptr, pbIsGlobal &i32) u32 {
	// TODO: Make function idiomatic to V
	return md.import_ptr.lpVtbl.IsGlobal(md.import_ptr, tk, pbIsGlobal)
}

pub fn (md MetaDataImport) is_valid_token(tk voidptr) bool {
	// TODO: Make function idiomatic to V
	return md.import_ptr.lpVtbl.IsValidToken(md.import_ptr, tk)
}

pub fn (md MetaDataImport) reset_enum(hEnum u32, ulPos u32) u32 {
	// TODO: Make function idiomatic to V
	return md.import_ptr.lpVtbl.ResetEnum(md.import_ptr, hEnum, ulPos)
}

pub fn (md MetaDataImport) resolve_type_ref(tkTypeRef voidptr, riid voidptr, ppIScope voidptr, ptkTypeDef voidptr) u32 {
	// TODO: Make function idiomatic to V
	return md.import_ptr.lpVtbl.ResolveTypeRef(md.import_ptr, tkTypeRef, riid, ppIScope, ptkTypeDef)
}

struct C.IMetaDataImport2 {
	lpVtbl &C.IMetaDataImport2Vtbl
}

struct C.IMetaDataImport2Vtbl {
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
	EnumCustomAttributes fn (this &C.IMetaDataImport2, phEnum &u32, tk voidptr, tkType voidptr, rgCustomAttributes []voidptr, cMax u32, pcCustomAttributes &u32) u32
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
	EnumEvents fn (this &C.IMetaDataImport2, phEnum &u32, tkTypDef voidptr, rgEvents []voidptr, cMax u32, pcEvents &u32) u32
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
	EnumFields fn (this &C.IMetaDataImport2, phEnum &u32, tkTypeDef voidptr, rgFields []voidptr, cMax u32, pcTokens &u32) u32
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
	EnumFieldsWithName fn (this &C.IMetaDataImport2, phEnum &u32, tkTypeDef voidptr, szName string, rFields []voidptr, cMax u32, pcTokens &u32) u32
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
	EnumGenericParamConstraints fn (this &C.IMetaDataImport2, phEnum &u32, tk voidptr, rGenericParamConstraints []voidptr, cMax u32, pcGenericParamConstraints &u32) u32
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
	EnumGenericParams fn (this &C.IMetaDataImport2, phEnum voidptr, tk voidptr, rGenericParams []voidptr, cMax u32, pcGenericParams &u32) u32
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
	EnumInterfaceImpls fn (this &C.IMetaDataImport2, phEnum &u32, td voidptr, rImpls []voidptr, cMax u32, pcImpls &u32) u32
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
	EnumMemberRefs fn (this &C.IMetaDataImport2, phEnum &u32, tkParent voidptr, rgMemberRefs []voidptr, cMax u32, pcTokens &u32) u32
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
	EnumMembers fn (this &C.IMetaDataImport2, phEnum &u32, tkTypeDef voidptr, rgMembers []voidptr, cMax u32, pcTokens &u32) u32
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
	EnumMembersWithName fn (this &C.IMetaDataImport2, phEnum &u32, tkTypeDef voidptr, szName string, rgMembers []voidptr, cMax u32, pcTokens &u32) u32
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
	EnumMethodImpls fn (this &C.IMetaDataImport2, phEnum &u32, tkTypeDef voidptr, rMethodBody []voidptr, rMethodDecl []voidptr, cMax u32, pcTokens &u32) u32
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
	EnumMethodSemantics fn (this &C.IMetaDataImport2, phEnum &u32, tkMethodDef voidptr, rgEventProp []voidptr, cMax u32, pcEventProp &u32) u32
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
	EnumMethods fn (this &C.IMetaDataImport2, phEnum &u32, tkTypeDef voidptr, rgMethods []voidptr, cMax u32, pcTokens &u32) u32
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
	EnumMethodSpecs fn (this &C.IMetaDataImport2, phEnum voidptr, tk voidptr, rMethodSpecs []voidptr, cMax u32, pcMethodSpecs &u32) u32
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
	EnumMethodsWithName fn (this &C.IMetaDataImport2, phEnum &u32, tkTypeDef voidptr, szName string, rgMethods []voidptr, cMax u32, pcTokens &u32) u32
	// [in, out] phEnum
	// A pointer to the enumerator. This must be NULL for the first call of this method.
	// [out] rgModuleRefs
	// The array used to store the ModuleRef tokens.
	// [in] cMax
	// The maximum size of the rgModuleRefs array.
	// [out] pcModuleRefs
	// The number of ModuleRef tokens returned in rgModuleRefs.
	EnumModuleRefs fn (this &C.IMetaDataImport2, phEnum &u32, rgModuleRefs []voidptr, cMax u32, pcModuleRefs &u32) u32
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
	EnumParams fn (this &C.IMetaDataImport2, phEnum &u32, tkMethodDef voidptr, rParams []voidptr, cMax u32, pcTokens &u32) u32
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
	EnumPermissionSets fn (this &C.IMetaDataImport2, phEnum &u32, tk voidptr, dwActions u32, rPermission []voidptr, cMax u32, pcTokens &u32) u32
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
	EnumProperties fn (this &C.IMetaDataImport2, phEnum &u32, tkTypeDef voidptr, rgProperties []voidptr, cMax u32, pcProperties &u32) u32
	// [in, out] phEnum
	// A pointer to the enumerator. This must be NULL for the first call of this method.
	// [out] rgSignatures
	// The array used to store the Signature tokens.
	// [in] cMax
	// The maximum size of the rgSignatures array.
	// [out] pcSignatures
	// The number of Signature tokens returned in rgSignatures.
	EnumSignatures fn (this &C.IMetaDataImport2, phEnum &u32, rgSignatures []voidptr, cMax u32, pcSignatures &u32) u32
	// [in, out] phEnum
	// A pointer to the new enumerator. This must be NULL for the first call of this method.
	// [out] rgTypeDefs
	// The array used to store the TypeDef tokens.
	// [in] cMax
	// The maximum size of the rgTypeDefs array.
	// [out, retval] pcTypeDefs
	// The number of TypeDef tokens returned in rgTypeDefs.
	EnumTypeDefs fn (this &C.IMetaDataImport2, phEnum &u32, rgTypeDefs []voidptr, cMax u32, pcTokens &u32) u32
	// [in, out] phEnum
	// A pointer to the enumerator. This must be NULL for the first call of this method.
	// [out] rgTypeRefs
	// The array used to store the TypeRef tokens.
	// [in] cMax
	// The maximum size of the rgTypeRefs array.
	// [out, retval] pcTypeRefs
	// A pointer to the number of TypeRef tokens returned in rgTypeRefs.
	EnumTypeRefs fn (this &C.IMetaDataImport2, phEnum &u32, rgTypeRefs []voidptr, cMax u32, pcTokens &u32) u32
	// [in, out] phEnum
	// A pointer to the enumerator. This value must be NULL for the first call of this method.
	// [out] rgTypeSpecs
	// The array used to store the TypeSpec tokens.
	// [in] cMax
	// The maximum size of the rgTypeSpecs array.
	// [out] pcTypeSpecs
	// The number of TypeSpec tokens returned in rgTypeSpecs.
	EnumTypeSpecs fn (this &C.IMetaDataImport2, phEnum &u32, rgTypeSpecs []voidptr, cMax u32, pcTypeSpecs &u32) u32
	// [in, out] phEnum
	// A pointer to the enumerator. This must be NULL for the first call of this method.
	// [out] rgMethods
	// The array used to store the MemberDef tokens.
	// [in] cMax
	// The maximum size of the rgMethods array.
	// [out] pcTokens
	// The number of MemberDef tokens returned in rgMethods.
	EnumUnresolvedMethods fn (this &C.IMetaDataImport2, phEnum &u32, rgTypeDefs []voidptr, cMax u32, pcTokens &u32) u32
	// [in, out] phEnum
	// A pointer to the enumerator. This must be NULL for the first call of this method.
	// [out] rgStrings
	// The array used to store the String tokens.
	// [in] cMax
	// The maximum size of the rgStrings array.
	// [out] pcStrings
	// The number of String tokens returned in rgStrings.
	EnumUserStrings fn (this &C.IMetaDataImport2, phEnum &u32, rgStrings []voidptr, cMax u32, pcStrings &u32) u32
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
	FindMemberRef fn (this &C.IMetaDataImport2, tkTypeRef voidptr, szName string, pvSigBlob voidptr, cbSigBlob u32, pMemberRef voidptr) u32
	// [in] szTypeDef
	// The name of the type for which to get the TypeDef token.
	// [in] tkEnclosingClass
	// A TypeDef or TypeRef token representing the enclosing class. If the type to find is not a nested class, set this value to NULL.
	// [out, retval] ptkTypeDef
	// A pointer to the matching TypeDef token.
	FindTypeDefByName fn (this &C.IMetaDataImport2, szTypeDef string, tkEnclosingClass voidptr, ptkTypeDef voidptr) u32
	// [in] tkResolutionScope
	// A ModuleRef, AssemblyRef, or TypeRef token that specifies the module, assembly, or type, respectively, in which the type reference is defined.
	// [in] szName
	// The name of the type reference to search for.
	// [out] tkTypeRef
	// A pointer to the matching TypeRef token.
	FindTypeRef fn (this &C.IMetaDataImport2, tkResolutionScope voidptr, szName string, tkTypeRef voidptr) u32
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
	GetCustomAttributeProps fn (this &C.IMetaDataImport2, cv voidptr, ptkObj voidptr, ptkType voidptr, ppBlob &&u8, pcbBlob &u32) u32
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
	GetFieldProps fn (this &C.IMetaDataImport2, tkFieldDef voidptr, ptkTypeDef voidptr, szField string, cchField u32, pchFIeld &u32, pdwAttr &u32, ppvSigBlob voidptr, pcbSigBlob &u32, pdwCPlusTypeFlag &u32, ppValue voidptr, pcchValue &u32) u32
	// [in] gpc
	// The token to the generic parameter constraint for which to return the metadata.
	// [out] ptGenericParam
	// A pointer to the token that represents the generic parameter that is constrained.
	// [out] ptkConstraintType
	// A pointer to a TypeDef, TypeRef, or TypeSpec token that represents a constraint on ptGenericParam.
	GetGenericParamConstraintProps fn (this &C.IMetaDataImport2, gpc voidptr, ptGenericParam voidptr, ptkConstraintType voidptr) u32
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
	GetGenericParamProps fn (this &C.IMetaDataImport2, gp voidptr, pulParamSeq &u32, pdwParamFlags &i32, ptOwner voidptr, reserved voidptr, wzname string, cchName u32, pchName &u32) u32
	// [in] tkInterfaceImpl
	// The metadata token representing the method to return the class and interface tokens for.
	// [out] ptkClass
	// The metadata token representing the class that implements the method.
	// [out] ptkIface
	// The metadata token representing the interface that defines the implemented method.
	GetInterfaceImplProps fn (this &C.IMetaDataImport2, tkInterfaceImpl voidptr, ptkClass voidptr, ptkIface voidptr) u32
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
	GetMemberProps fn (this &C.IMetaDataImport2, tkMember voidptr, ptkTypeDef voidptr, szMember string, cchMember u32, pchMember &u32, pdwAttr &u32, ppvSigBlob voidptr, pcbSigBlob &u32, pulCodeRVA &u32, pdwImplFlags &u32, pdwCPlusTypeFlag &u32, ppValue voidptr, pcchValue &u32) u32
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
	GetMemberRefProps fn (this &C.IMetaDataImport2, tkMemberRef voidptr, ptk voidptr, szMember string, cchMember u32, pchMember &u32, ppvSigBlob voidptr, pcbSigBlob &u32) u32
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
	GetMethodProps fn (this &C.IMetaDataImport2, tkMethodDef voidptr, ptkClass voidptr, szMethod string, cchMethod u32, pchMethod &u32, pdwAttr &u32, ppvSigBlob voidptr, pcbSigBlob &u32, pulCodeRVA &u32, pdwImplFlags &u32) u32
	// [in] tkMethodDef
	// A MethodDef token representing the method to get the semantic role information for.
	// [in] tkEventProp
	// A token representing the paired property and event for which to get the method's role.
	// [out] pdwSemanticsFlags
	// A pointer to the associated semantics flags. This value is a bitmask from the CorMethodSemanticsAttr enumeration.
	GetMethodSemantics fn (this &C.IMetaDataImport2, tkMethodDef voidptr, tkEventProp voidptr, pdwSemanticsFlags &u32) u32
	// [in] mi
	// A MethodSpec token that represents the instantiation of the method.
	// [out] tkParent
	// A pointer to the MethodDef or MethodRef token that represents the method definition.
	// [out] ppvSigBlob
	// A pointer to the binary metadata signature of the method.
	// [out] pcbSigBlob
	// The size, in bytes, of ppvSigBlob.
	GetMethodSpecProps fn (this &C.IMetaDataImport2, mi voidptr, tkParent voidptr, ppvSigBlob voidptr, pcbSigBlob &u32) u32
	// [out] ptkModule
	// A pointer to the token representing the module referenced in the current metadata scope.
	GetModuleFromScope fn (this &C.IMetaDataImport2, ptkModule voidptr) u32
	// [in] tkModuleRef
	// The ModuleRef metadata token that references the module to get metadata information for.
	// [out] szName
	// A buffer to hold the module name.
	// [in] cchName
	// The requested size of szName in wide characters.
	// [out] pchName
	// The returned size of szName in wide characters.
	GetModuleRefProps fn (this &C.IMetaDataImport2, tkModuleRef voidptr, szName string, cchName u32, pchName &u32) u32
	// [in] tk
	// The token representing the object to return the name for.
	// [out] pszUtf8NamePtr
	// A pointer to the UTF-8 object name in the heap.
	GetNameFromToken fn (this &C.IMetaDataImport2, tk voidptr, pszUtf8NamePtr voidptr) u32
	// [in] tdNestedClass
	// A TypeDef token representing the Type to return the parent class token for.
	// [out] ptdEnclosingClass
	// A pointer to the TypeDef token for the Type that tdNestedClass is nested in.
	GetNestedClassProps fn (this &C.IMetaDataImport2, tdNestedClass voidptr, ptdEnclosingClass voidptr) u32
	// [in] tkMethodDef
	// A token that represents the method to return the parameter token for.
	// [in] ulParamSeq
	// The ordinal position in the parameter list where the requested parameter occurs. Parameters are numbered starting from one, with the method's return value in position zero.
	// [out] ptkParamDef
	// A pointer to a ParamDef token that represents the requested parameter.
	GetParamForMethodIndex fn (this &C.IMetaDataImport2, tkMethodDef voidptr, ulParamSeq u32, ptkParamDef voidptr) u32
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
	GetParamProps fn (this &C.IMetaDataImport2, tkParamDef voidptr, ptkMethodDef voidptr, pulSequence &u32, szName string, cchName u32, pchName &u32, pdwAttr &u32, pdwCPlusTypeFlag &u32, ppValue voidptr, pcchValue &u32) u32
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
	GetPermissionSetProps fn (this &C.IMetaDataImport2, tk voidptr, pdwAction &u32, ppvPermission &&u8, pcbPermission &u32) u32
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
	GetPinvokeMap fn (this &C.IMetaDataImport2, tk voidptr, pdwMappingFlags &u32, szImportName string, cchImportNAme u32, pchImportName &u32, ptkImportDLL voidptr) u32
	// [in] tk
	// A MethodDef or FieldDef metadata token that represents the code object to return the RVA for. If the token is a FieldDef, the field must be a global variable.
	// [out] pulCodeRVA
	// A pointer to the relative virtual address of the code object represented by the token.
	// [out] pdwImplFlags
	// A pointer to the implementation flags for the method. This value is a bitmask from the [CorMethodImpl](https://learn.microsoft.com/en-us/dotnet/framework/unmanaged-api/metadata/cormethodimpl-enumeration) enumeration. The value of pdwImplFlags is valid only if tk is a MethodDef token.
	GetRVA fn (this &C.IMetaDataImport2, tk voidptr, pulCodeRVA &u32, pdwImplFlags &u32) u32
	// [out] szName
	// A buffer for the assembly or module name.
	// [in] cchName
	// The size in wide characters of szName.
	// [out] pchName
	// The number of wide characters returned in szName.
	// [out] pmvid
	// A pointer to a GUID that uniquely identifies the version of the assembly or module.
	GetScopeProps fn (this &C.IMetaDataImport2, szName string, cchName u32, pchName &u32, pmvid voidptr) u32
	// [in] tkSignature
	// The token to return the binary metadata signature for.
	// [out] ppvSig
	// A pointer to the returned metadata signature.
	// [out] pcbSig
	// The size in bytes of the binary metadata signature.
	GetSigFromToken fn (this &C.IMetaDataImport2, tkSignature voidptr, ppvSig voidptr, pcbSig &u32) u32
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
	GetTypeDefProps fn (this &C.IMetaDataImport2, tkTypeDef voidptr, szTypeDef string, cchTypeDef u32, pchTypeDef &u32, pdwTypeDefFlags &u32, ptkExtends voidptr) u32
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
	GetTypeRefProps fn (this &C.IMetaDataImport2, tkTypeRef voidptr, ptkResolutionScope voidptr, szName string, cchName u32, pchName &u32) u32
	// [in] tkTypeSpec
	// The TypeSpec token associated with the requested metadata signature.
	// [out] ppvSig
	// A pointer to the binary metadata signature.
	// [out] pcbSig
	// The size, in bytes, of the metadata signature.
	GetTypeSpecFromToken fn (this &C.IMetaDataImport2, tkTypeSpec voidptr, ppvSig voidptr, pcbSig &u32) u32
	// [in] tkString
	// The String token to return the associated string for.
	// [out] szString
	// A copy of the requested string.
	// [in] cchString
	// The maximum size in wide characters of the requested szString.
	// [out] pchString
	// The size in wide characters of the returned szString.
	GetUserString fn (this &C.IMetaDataImport2, tkString voidptr, szString string, cchString u32, pchString &u32) u32
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
	IsGlobal fn (this &C.IMetaDataImport2, tk voidptr, pbIsGlobal &i32) u32
	// [in] tk
	// The token to check the reference validity for.
	IsValidToken fn (this &C.IMetaDataImport2, tk voidptr) bool
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
	ResolveTypeRef fn (this &C.IMetaDataImport2, tkTypeRef voidptr, riid voidptr, ppIScope voidptr, ptkTypeDef voidptr) u32
}
