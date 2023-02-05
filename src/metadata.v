module metadata

// For information about the metadata API
// https://learn.microsoft.com/en-us/windows/win32/api/rometadataapi/
// Section II.22 of https://www.ecma-international.org/wp-content/uploads/ECMA-335_6th_edition_june_2012.pdf

//////////
// IIDs //
//////////

pub struct Guid {
	data1 u32
	data2 u16
	data3 u16
	data4 [8]u8
}

const clsid_metadata_dispenser = Guid{0xe5cb7a31, 0x7512, 0x11d2, [u8(0x89), 0xce, 0x0, 0x80, 0xc7,
	0x92, 0xe5, 0xd8]!}

const iid_metadata_dispenser_ex = Guid{0x31bcfce2, 0xdafb, 0x11d2, [u8(0x9f), 0x81, 0x0, 0xc0,
	0x4f, 0x79, 0xa0, 0xa3]!}

const iid_metadata_import2 = Guid{0xfce5efa0, 0x8bba, 0x4f8e, [u8(0xa0), 0x36, 0x8f, 0x20, 0x22,
	0xb0, 0x84, 0x66]!}

const iid_metadata_assembly_import = Guid{0xee62470b, 0xe94b, 0x424e, [u8(0x9b), 0x7c, 0x2f, 0x0,
	0xc9, 0x24, 0x9f, 0x93]!}

const iid_metadata_tables2 = Guid{0xbadb5f70, 0x58da, 0x43a9, [u8(0xa1), 0xc6, 0xd7, 0x48, 0x19,
	0xf1, 0x9b, 0x15]!}

struct MetaData {
pub:
	dispenser MetaDataDispenser
	@import   MetaDataImport
	table     MetaDataTables
	assembly  MetaDataAssemblyImport
}

const scope_name = 'C:/dev/v/winmd/winmd_files/Windows.AI.winmd'

[unsafe]
pub fn metadata() MetaData {
	unsafe {
		// Poor man's singleton
		mut static md := &MetaData(nil)

		if md != nil {
			return *md
		}

		dispenser_ptr := get_dispenser_ptr()
		import_ptr := get_import_ptr(dispenser_ptr, metadata.scope_name)
		table_ptr := get_table_ptr(dispenser_ptr, metadata.scope_name)
		assembly_ptr := get_assembly_ptr(dispenser_ptr, metadata.scope_name)

		*md = MetaData{
			dispenser: MetaDataDispenser{
				ptr: dispenser_ptr
			}
			@import: MetaDataImport{
				ptr: import_ptr
			}
			table: MetaDataTables{
				ptr: table_ptr
			}
			assembly: MetaDataAssemblyImport{
				ptr: assembly_ptr
			}
		}

		return *md
	}
}

[unsafe]
fn get_dispenser_ptr() &C.IMetaDataDispenserEx {
	unsafe {
		mut dispenser_ptr := &C.IMetaDataDispenserEx(nil)

		match C.MetaDataGetDispenser(&metadata.clsid_metadata_dispenser, &metadata.iid_metadata_dispenser_ex,
			&dispenser_ptr) {
			.e_nointerface { println("The dispenser doesn't support this interface") }
			else {}
		}

		return dispenser_ptr
	}
}

[unsafe]
fn get_import_ptr(dispenser_ptr &C.IMetaDataDispenserEx, scope_name string) &C.IMetaDataImport2 {
	unsafe {
		mut import_ptr := &C.IMetaDataImport2(nil)

		match dispenser_ptr.lpVtbl.OpenScope(dispenser_ptr, scope_name.to_wide(), 0, &metadata.iid_metadata_import2,
			&import_ptr) {
			.e_nointerface { println("The dispenser doesn't support this interface") }
			else {}
		}

		return import_ptr
	}
}

[unsafe]
fn get_table_ptr(dispenser_ptr &C.IMetaDataDispenserEx, scope_name string) &C.IMetaDataTables2 {
	unsafe {
		mut table_ptr := &C.IMetaDataTables2(nil)

		match dispenser_ptr.lpVtbl.OpenScope(dispenser_ptr, scope_name.to_wide(), 0, &metadata.iid_metadata_tables2,
			&table_ptr) {
			.e_nointerface { println("The dispenser doesn't support this interface") }
			else {}
		}

		return table_ptr
	}
}

type OpenScopeIID = C.IMetaDataAssemblyImport | C.IMetaDataImport2 | C.IMetaDataTables2

[unsafe]
fn get_assembly_ptr(dispenser_ptr &C.IMetaDataDispenserEx, scope_name string) &C.IMetaDataAssemblyImport {
	unsafe {
		mut assembly_ptr := &C.IMetaDataAssemblyImport(nil)

		match dispenser_ptr.lpVtbl.OpenScope(dispenser_ptr, scope_name.to_wide(), 0, &metadata.iid_metadata_assembly_import,
			&assembly_ptr) {
			.e_nointerface { println("The dispenser doesn't support this interface") }
			else {}
		}

		return assembly_ptr
	}
}

////////////
// Tokens //
////////////

// struct AssemblyRef {}
// struct ExportedTypeToken {}
// struct FileToken {}
// struct ManifestResourceToken {}

struct AssemblyRef {
	token   usize
	offset  usize
	version ?&u8
}

struct TypeRef {
	token            usize
	offset           usize
	resolution_scope AssemblyRef
}

struct TypeDef {
pub:
	token     usize
	offset    usize
	name      string
	namespace string
	base_type TypeRef
pub mut:
	fields  FieldsIter
	members MembersIter
	// attributes AttributesIter
	// custom_attributes CustomAttributesIter
}

struct TypeDefsIter {
	type_def u32
mut:
	current_type_def usize
}

pub fn (mut iter TypeDefsIter) next() ?TypeDef {
	md := metadata()
	next_type_def := md.@import.enum_type_defs(&iter.current_type_def)?

	return TypeDef{
		token: next_type_def
	}
}

struct Field {
pub:
	token usize
// pub mut:
	// custom_attributes CustomAttributesIter
}

struct FieldsIter {
	type_def u32
mut:
	current_field usize
}

pub fn (mut iter FieldsIter) next() ?Field {
	mut field := u32(0)

	md := metadata()
	next_type_def := md.@import.enum_fields(&iter.current_field, iter.type_def)?

	return Field{
		token: field
	}
}

struct Param {
pub:
	token    usize
	type_def u32
	// pub mut:
	// props ParamPropsIter
}

struct ParamsIter {
	type_def u32
	method_def u32
mut:
	current_param usize
}

pub fn (mut iter ParamsIter) next() ?Param {
	md := metadata()
	param := md.@import.enum_params(&iter.current_param, iter.method_def)?

	return Param{
		token: param
		type_def: iter.type_def
	}
}

struct MembersIter {
pub:
	type_def u32
pub mut:
	current_member usize
}

pub fn (mut iter MembersIter) next() ?u32 {
	md := metadata()
	member := md.@import.enum_members(&iter.current_member, iter.type_def)?

	// if member is a field
	return if member & 0xFF000000 == 0x04000000 {
		return Param{
			token: member
			type_def: iter.type_def
		}
	}
	// otherwise it'll be a method
	else {
		return Method{
			token: member
			type_def: iter.type_def
		}
	}
}

struct Method {
pub:
	token    usize
	type_def u32
	// pub mut:
	params ParamsIter
}

struct MethodsIter {
	type_def u32
mut:
	params ParamsIter
	current_method usize
}

pub fn (mut iter MethodsIter) next() ?u32 {
	md := metadata()
	method := md.@import.enum_methods(&iter.current_method, iter.type_def)?

	return Method{
		token: method
		type_def: iter.type_def
		params: ParamsIter{
			type_def: iter.type_def
			method_def: method
		}
	}
}

////////////////////////
// Metadata dispenser //
////////////////////////

pub struct MetaDataDispenser {
	ptr &C.IMetaDataDispenserEx
}

enum GetMetadataDispenserResult as u32 {
	s_ok = 0
	e_nointerface = 0x80004002
}

enum OpenScopeResult as u32 {
	s_ok = 0
	e_nointerface = 0x80004002
}

// pub fn (md MetaDataDispenser) open_scope(scope_name string) MetaDataImport {
// 	import_ptr := unsafe { nil }
// 	table_ptr := unsafe { nil }
// 	assembly_ptr := unsafe { nil }
// 	// TODO: Make function idiomatic to V
// 	md.dispenser_ptr.lpVtbl.OpenScope(md.dispenser_ptr, scope_name.to_wide(), 0, &metadata.iid_metadata_import2,
// 		&import_ptr)
// 	md.dispenser_ptr.lpVtbl.OpenScope(md.dispenser_ptr, scope_name.to_wide(), 0, &metadata.iid_metadata_tables2,
// 		&table_ptr)
// 	md.dispenser_ptr.lpVtbl.OpenScope(md.dispenser_ptr, scope_name.to_wide(), 0, &metadata.iid_metadata_assembly_import,
// 		&assembly_ptr)
// 	return MetaDataImport{
// 		import_ptr: import_ptr
// 		type_defs: TypeDefsIter{
// 			import_ptr: import_ptr
// 			table_ptr: import_ptr
// 		}
// 	}
// }

// pub fn (md MetaDataDispenser) define_scope(rclsid u32, dwCreateFlags u32, riid voidptr, ppIUnk &voidptr) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.dispenser_ptr.lpVtbl.DefineScope(md.dispenser_ptr, rclsid, dwCreateFlags, riid, ppIUnk)
// }
//
// pub fn (md MetaDataDispenser) find_assembly(szAppBase &u16, szPrivateBin &u16, szBlobalBin &u16, szAssemblyName &u16, szName &u16, cchName u32, pchName &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.dispenser_ptr.lpVtbl.FindAssembly(md.dispenser_ptr, szAppBase, szPrivateBin, szBlobalBin,
// 		szAssemblyName, szName, cchName, pchName)
// }
//
// pub fn (md MetaDataDispenser) find_assembly_module(szAppBase &u16, szPrivateBin string, szGlobalBin string, szAssemblyName string, szModuleName string, szName string, cchName u32, pcName &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.dispenser_ptr.lpVtbl.FindAssemblyModule(md.dispenser_ptr, szAppBase, szPrivateBin, szGlobalBin,
// 		szAssemblyName, szModuleName, szName, cchName, pcName)
// }
//
// pub fn (md MetaDataDispenser) get_cor_system_directory(szBuffer &u16, cchBuffer u32, pchBuffer &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.dispenser_ptr.lpVtbl.GetCORSystemDirectory(md.dispenser_ptr, szBuffer, cchBuffer, pchBuffer)
// }
//
// pub fn (md MetaDataDispenser) get_option(optionId &Guid, pValue voidptr) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.dispenser_ptr.lpVtbl.GetOption(md.dispenser_ptr, optionId, pValue)
// }
// pub fn (md MetaDataDispenser) open_scope_on_itype_info(pITI voidptr, dwOpenFlags u32, riid voidptr, ppIUnk voidptr) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.dispenser_ptr.lpVtbl.OpenScopeOnITypeInfo(md.dispenser_ptr, pITI, dwOpenFlags, riid, ppIUnk)
// }
//
// pub fn (md MetaDataDispenser) open_scope_on_memory(pData &u8, cbData u32, dwOpenFlags u32, riid voidptr, ppIUnk &voidptr) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.dispenser_ptr.lpVtbl.OpenScopeOnMemory(md.dispenser_ptr, pData, cbData, dwOpenFlags, riid,
// 		ppIUnk)
// }
//
// pub fn (md MetaDataDispenser) set_option(optionId voidptr, pValue voidptr) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.dispenser_ptr.lpVtbl.SetOption(md.dispenser_ptr, optionId, pValue)
// }

/////////////////////
// Metadata import //
/////////////////////

pub struct MetaDataImport {
	ptr &C.IMetaDataImport2
pub mut:
	type_defs TypeDefsIter
}

// pub fn (md MetaDataImport) close_enum(hEnum u32) {
// 	// TODO: Make function idiomatic to V
// 	md.import_ptr.lpVtbl.CloseEnum(md.import_ptr, hEnum)
// }
//
// pub fn (md MetaDataImport) count_enum(hEnum u32, pulCount &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.import_ptr.lpVtbl.CountEnum(md.import_ptr, hEnum, pulCount)
// }
//
// pub fn (md MetaDataImport) enum_custom_attributes(phEnum &usize, tk u32, tkType u32, rgCustomAttributes &u32, cMax u32, pcCustomAttributes &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.import_ptr.lpVtbl.EnumCustomAttributes(md.import_ptr, phEnum, tk, tkType, rgCustomAttributes,
// 		cMax, pcCustomAttributes)
// }
//
// pub fn (md MetaDataImport) enum_events(phEnum &usize, tkTypeDef u32, rgEvents &u32, cMax u32, pcEvents &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.import_ptr.lpVtbl.EnumEvents(md.import_ptr, phEnum, tkTypeDef, rgEvents, cMax, pcEvents)
// }
//
pub fn (md MetaDataImport) enum_fields(phEnum &usize, tkTypeDef u32) ?u32 {
	unsafe {
		mut next_field := &u32(nil)
		// TODO: Make function idiomatic to V
		return match md.ptr.lpVtbl.EnumFields(md.ptr, phEnum, tkTypeDef, next_field, 1,
			nil) {
			0 { none }
			else { *next_field }
		}
	}
}

//
// pub fn (md MetaDataImport) enum_fields_with_name(phEnum &usize, tkTypeDef &u32, szName string, rFields &u32, cMax u32, pcTokens &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.import_ptr.lpVtbl.EnumFieldsWithName(md.import_ptr, phEnum, tkTypeDef, szName, rFields,
// 		cMax, pcTokens)
// }
//
// pub fn (md MetaDataImport) enum_generic_param_constraints(phEnum &usize, tk u32, rGenericParamConstraints &u32, cMax u32, pcGenericParamConstraints &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.import_ptr.lpVtbl.EnumGenericParamConstraints(md.import_ptr, phEnum, tk, rGenericParamConstraints,
// 		cMax, pcGenericParamConstraints)
// }
//
// pub fn (md MetaDataImport) enum_generic_params(phEnum &usize, tk u32, rGenericParams &u32, cMax u32, pcGenericParams &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.import_ptr.lpVtbl.EnumGenericParams(md.import_ptr, phEnum, tk, rGenericParams, cMax, pcGenericParams)
// }
//
// pub fn (md MetaDataImport) enum_interface_impls(phEnum &usize, td u32, rImpls &u32, cMax u32, pcImpls &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.import_ptr.lpVtbl.EnumInterfaceImpls(md.import_ptr, phEnum, td, rImpls, cMax, pcImpls)
// }
//
// pub fn (md MetaDataImport) enum_member_refs(phEnum &usize, tkParent u32, rgMemberRefs &u32, cMax u32, pcTokens &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.import_ptr.lpVtbl.EnumMemberRefs(md.import_ptr, phEnum, tkParent, rgMemberRefs, cMax, pcTokens)
// }
//
pub fn (md MetaDataImport) enum_members(phEnum &usize, tkTypeDef u32) ?u32 {
	unsafe {
		mut next_member := &u32(nil)
		return match md.ptr.lpVtbl.EnumMethods(md.ptr, phEnum, tkTypeDef, next_member,
			1, nil) {
			0 { none }
			else { *next_member }
		}
	}
}

//
// pub fn (md MetaDataImport) enum_members_with_name(phEnum &usize, tkTypeDef u32, szName string, rgMembers &u32, cMax u32, pcTokens &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.import_ptr.lpVtbl.EnumMembersWithName(md.import_ptr, phEnum, tkTypeDef, szName, rgMembers,
// 		cMax, pcTokens)
// }
//
// pub fn (md MetaDataImport) enum_method_impls(phEnum &usize, tkTypeDef u32, rMethodBody &u32, rMethodDecl &u32, cMax u32, pcTokens &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.import_ptr.lpVtbl.EnumMethodImpls(md.import_ptr, phEnum, tkTypeDef, rMethodBody, rMethodDecl,
// 		cMax, pcTokens)
// }
//
// pub fn (md MetaDataImport) enum_method_semantics(phEnum &usize, tkMethodDef u32, rgEventProp &u32, cMax u32, pcEventProp &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.import_ptr.lpVtbl.EnumMethodSemantics(md.import_ptr, phEnum, tkMethodDef, rgEventProp,
// 		cMax, pcEventProp)
// }
//
// pub fn (md MetaDataImport) enum_method_specs(phEnum &usize, tkTypeDef u32, rgMethods &u32, cMax u32, pcTokens &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.import_ptr.lpVtbl.EnumMethodSpecs(md.import_ptr, phEnum, tkTypeDef, rgMethods, cMax, pcTokens)
// }
//
pub fn (md MetaDataImport) enum_methods(phEnum &usize, tkTypeDef u32) u32 {
	// TODO: Make function idiomatic to V
	unsafe {
		mut next_method := &u32(nil)
		// TODO: Make function idiomatic to V
		return match md.ptr.lpVtbl.EnumFields.EnumMethods(md.ptr, phEnum, tkTypeDef, next_method,
			1, nil) {
			0 { none }
			else { *next_method }
		}
	}
	return md.ptr.lpVtbl.EnumFields.EnumMethods(md.ptr, phEnum, tkTypeDef, rgMethods,
		cMax, pcTokens)
}

//
// pub fn (md MetaDataImport) enum_methods_with_name(phEnum &usize, tkTypeDef u32, szName string, rgMethods &u32, cMax u32, pcTokens &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.import_ptr.lpVtbl.EnumMethodsWithName(md.import_ptr, phEnum, tkTypeDef, szName, rgMethods,
// 		cMax, pcTokens)
// }
//
// pub fn (md MetaDataImport) enum_module_refs(phEnum &usize, rgModuleRefs &u32, cMax u32, pcModuleRefs &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.import_ptr.lpVtbl.EnumModuleRefs(md.import_ptr, phEnum, rgModuleRefs, cMax, pcModuleRefs)
// }
//
pub fn (md MetaDataImport) enum_params(phEnum &usize, tkMethodDef u32, rParams &u32) u32 {
	// TODO: Make function idiomatic to V
	unsafe {
		mut next_param := &u32(nil)
		// TODO: Make function idiomatic to V
		return match md.ptr.lpVtbl.EnumFieldsEnumParams(md.ptr, phEnum, tkMethodDef, rParams, 1, nil) {
			0 { none }
			else { *next_param }
		}
	}
}
//
// pub fn (md MetaDataImport) enum_permission_sets(phEnum &usize, tk u32, dwActions u32, rPermission &u32, cMax u32, pcTokens &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.import_ptr.lpVtbl.EnumPermissionSets(md.import_ptr, phEnum, tk, dwActions, rPermission,
// 		cMax, pcTokens)
// }
//
// pub fn (md MetaDataImport) enum_properties(phEnum &usize, tkTypeDef u32, rgProperties &u32, cMax u32, pcProperties &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.import_ptr.lpVtbl.EnumProperties(md.import_ptr, phEnum, tkTypeDef, rgProperties, cMax,
// 		pcProperties)
// }
//
// pub fn (md MetaDataImport) enum_signatures(phEnum &usize, rgSignatures &u32, cMax u32, pcSignatures &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.import_ptr.lpVtbl.EnumSignatures(md.import_ptr, phEnum, rgSignatures, cMax, pcSignatures)
// }

pub fn (@import MetaDataImport) enum_type_defs(phEnum &usize) ?u32 {
	// TODO: Make function idiomatic to V
	unsafe {
		mut next_type_def := &u32(nil)
		return match @import.ptr.lpVtbl.EnumTypeDefs(@import.ptr, phEnum, next_type_def,
			1, nil) {
			0 { none }
			else { *next_type_def }
		}
	}
}

// pub fn (md MetaDataImport) enum_type_refs(phEnum &usize, rgTypeRefs &u32, cMax u32, pcTokens &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.import_ptr.lpVtbl.EnumTypeRefs(md.import_ptr, phEnum, rgTypeRefs, cMax, pcTokens)
// }
//
// pub fn (md MetaDataImport) enum_type_specs(phEnum &usize, rgTypeSpecs &u32, cMax u32, pcTypeSpecs &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.import_ptr.lpVtbl.EnumTypeSpecs(md.import_ptr, phEnum, rgTypeSpecs, cMax, pcTypeSpecs)
// }
//
// pub fn (md MetaDataImport) enum_unresolved_methods(phEnum &usize, rgTypeDefs &u32, cMax u32, pcTokens &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.import_ptr.lpVtbl.EnumUnresolvedMethods(md.import_ptr, phEnum, rgTypeDefs, cMax, pcTokens)
// }
//
// pub fn (md MetaDataImport) enum_user_strings(phEnum &usize, rgStrings &u32, cMax u32, pcStrings &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.import_ptr.lpVtbl.EnumUserStrings(md.import_ptr, phEnum, rgStrings, cMax, pcStrings)
// }
//
// pub fn (md MetaDataImport) find_member_ref(tkTypeRef u32, szName string, pvSigBlob voidptr, cbSigBlob u32, pMemberRef voidptr) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.import_ptr.lpVtbl.FindMemberRef(md.import_ptr, tkTypeRef, szName, pvSigBlob, cbSigBlob,
// 		pMemberRef)
// }
//
// pub fn (md MetaDataImport) find_type_def_by_name(szTypeDef &u16, tkEnclosingClass u32, ptkTypeDef &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.import_ptr.lpVtbl.FindTypeDefByName(md.import_ptr, szTypeDef, tkEnclosingClass, ptkTypeDef)
// }
//
// pub fn (md MetaDataImport) find_type_ref(tkResolutionScope u32, szName string, tkTypeRef u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.import_ptr.lpVtbl.FindTypeRef(md.import_ptr, tkResolutionScope, szName, tkTypeRef)
// }
//
// pub fn (md MetaDataImport) get_custom_attribute_props(cv voidptr, ptkObj &u32, ptkType &u32, ppBlob &&u8, pcbBlob &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.import_ptr.lpVtbl.GetCustomAttributeProps(md.import_ptr, cv, ptkObj, ptkType, ppBlob, pcbBlob)
// }
//
// pub fn (md MetaDataImport) get_field_marshal(tk u32, ppvNativeType voidptr, pcbNativeType &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.import_ptr.lpVtbl.GetFieldMarshal(md.import_ptr, tk, ppvNativeType, pcbNativeType)
// }
//
// pub fn (md MetaDataImport) get_field_props(tkFieldDef u32, ptkTypeDef &u32, szField string, cchField u32, pchFIeld &u32, pdwAttr &u32, ppvSigBlob voidptr, pcbSigBlob &u32, pdwCPlusTypeFlag &u32, ppValue voidptr, pcchValue &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.import_ptr.lpVtbl.GetFieldProps(md.import_ptr, tkFieldDef, ptkTypeDef, szField, cchField,
// 		pchFIeld, pdwAttr, ppvSigBlob, pcbSigBlob, pdwCPlusTypeFlag, ppValue, pcchValue)
// }
//
// pub fn (md MetaDataImport) get_generic_param_constraint_props(gpc voidptr, ptGenericParam &u32, ptkConstraintType &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.import_ptr.lpVtbl.GetGenericParamConstraintProps(md.import_ptr, gpc, ptGenericParam, ptkConstraintType)
// }
//
// pub fn (md MetaDataImport) get_generic_param_props(gp voidptr, pulParamSeq &u32, pdwParamFlags &i32, ptOwner &u32, reserved voidptr, wzname string, cchName u32, pchName &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.import_ptr.lpVtbl.GetGenericParamProps(md.import_ptr, gp, pulParamSeq, pdwParamFlags, ptOwner,
// 		reserved, wzname, cchName, pchName)
// }
//
// pub fn (md MetaDataImport) get_interface_impl_props(tkInterfaceImpl u32, ptkClass &u32, ptkIface &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.import_ptr.lpVtbl.GetInterfaceImplProps(md.import_ptr, tkInterfaceImpl, ptkClass, ptkIface)
// }
//
// pub fn (md MetaDataImport) get_member_props(tkMember u32, ptkTypeDef &u32, szMember string, cchMember u32, pchMember &u32, pdwAttr &u32, ppvSigBlob voidptr, pcbSigBlob &u32, pulCodeRVA &u32, pdwImplFlags &u32, pdwCPlusTypeFlag &u32, ppValue voidptr, pcchValue &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.import_ptr.lpVtbl.GetMemberProps(md.import_ptr, tkMember, ptkTypeDef, szMember, cchMember,
// 		pchMember, pdwAttr, ppvSigBlob, pcbSigBlob, pulCodeRVA, pdwImplFlags, pdwCPlusTypeFlag,
// 		ppValue, pcchValue)
// }
//
// pub fn (md MetaDataImport) get_member_ref_props(tkMemberRef u32, ptk &u32, szMember string, cchMember u32, pchMember &u32, ppvSigBlob voidptr, pcbSigBlob &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.import_ptr.lpVtbl.GetMemberRefProps(md.import_ptr, tkMemberRef, ptk, szMember, cchMember,
// 		pchMember, ppvSigBlob, pcbSigBlob)
// }
//
// pub fn (md MetaDataImport) get_method_props(tkMethodDef u32, ptkClass &u32, szMethod string, cchMethod u32, pchMethod &u32, pdwAttr &u32, ppvSigBlob voidptr, pcbSigBlob &u32, pulCodeRVA &u32, pdwImplFlags &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.import_ptr.lpVtbl.GetMethodProps(md.import_ptr, tkMethodDef, ptkClass, szMethod, cchMethod,
// 		pchMethod, pdwAttr, ppvSigBlob, pcbSigBlob, pulCodeRVA, pdwImplFlags)
// }
//
// pub fn (md MetaDataImport) get_method_semantics(tkMethodDef u32, tkEventProp u32, pdwSemanticsFlags &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.import_ptr.lpVtbl.GetMethodSemantics(md.import_ptr, tkMethodDef, tkEventProp, pdwSemanticsFlags)
// }
//
// pub fn (md MetaDataImport) get_method_spec_props(mi voidptr, tkParent u32, ppvSigBlob voidptr, pcbSigBlob &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.import_ptr.lpVtbl.GetMethodSpecProps(md.import_ptr, mi, tkParent, ppvSigBlob, pcbSigBlob)
// }
//
// pub fn (md MetaDataImport) get_module_from_scope(ptkModule &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.import_ptr.lpVtbl.GetModuleFromScope(md.import_ptr, ptkModule)
// }
//
// pub fn (md MetaDataImport) get_module_ref_props(tkModuleRef u32, szName string, cchName u32, pchName &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.import_ptr.lpVtbl.GetModuleRefProps(md.import_ptr, tkModuleRef, szName, cchName, pchName)
// }
//
// pub fn (md MetaDataImport) get_name_from_token(tk u32, pszUtf8NamePtr voidptr) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.import_ptr.lpVtbl.GetNameFromToken(md.import_ptr, tk, pszUtf8NamePtr)
// }
//
// pub fn (md MetaDataImport) get_nested_class_props(tdNestedClass voidptr, ptdEnclosingClass &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.import_ptr.lpVtbl.GetNestedClassProps(md.import_ptr, tdNestedClass, ptdEnclosingClass)
// }
//
// pub fn (md MetaDataImport) get_param_for_method_index(tkMethodDef u32, ulParamSeq u32, ptkParamDef &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.import_ptr.lpVtbl.GetParamForMethodIndex(md.import_ptr, tkMethodDef, ulParamSeq, ptkParamDef)
// }
//
// pub fn (md MetaDataImport) get_param_props(tkParamDef u32, ptkMethodDef &u32, pulSequence &u32, szName string, cchName u32, pchName &u32, pdwAttr &u32, pdwCPlusTypeFlag &u32, ppValue voidptr, pcchValue &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.import_ptr.lpVtbl.GetParamProps(md.import_ptr, tkParamDef, ptkMethodDef, pulSequence, szName,
// 		cchName, pchName, pdwAttr, pdwCPlusTypeFlag, ppValue, pcchValue)
// }
//
// pub fn (md MetaDataImport) get_pe_kind(pwdPEKind &u32, pdwMachine &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.import_ptr.lpVtbl.GetPEKind(md.import_ptr, pwdPEKind, pdwMachine)
// }
//
// pub fn (md MetaDataImport) get_permission_set_props(tk u32, pdwAction &u32, ppvPermission &&u8, pcbPermission &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.import_ptr.lpVtbl.GetPermissionSetProps(md.import_ptr, tk, pdwAction, ppvPermission, pcbPermission)
// }
//
// pub fn (md MetaDataImport) get_pinvoke_map(tk u32, pdwMappingFlags &u32, szImportName string, cchImportNAme u32, pchImportName &u32, ptkImportDLL &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.import_ptr.lpVtbl.GetPinvokeMap(md.import_ptr, tk, pdwMappingFlags, szImportName, cchImportNAme,
// 		pchImportName, ptkImportDLL)
// }
//
// pub fn (md MetaDataImport) get_rva(tk u32, pulCodeRVA &u32, pdwImplFlags &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.import_ptr.lpVtbl.GetRVA(md.import_ptr, tk, pulCodeRVA, pdwImplFlags)
// }
//
// pub fn (md MetaDataImport) get_scope_props(szName &u16, cchName u32, pchName &u32, pmvid voidptr) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.import_ptr.lpVtbl.GetScopeProps(md.import_ptr, szName, cchName, pchName, pmvid)
// }
//
// pub fn (md MetaDataImport) get_sig_from_token(tkSignature u32, ppvSig voidptr, pcbSig &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.import_ptr.lpVtbl.GetSigFromToken(md.import_ptr, tkSignature, ppvSig, pcbSig)
// }
//
// pub fn (md MetaDataImport) get_type_def_props(tkTypeDef u32, szTypeDef string, cchTypeDef u32, pchTypeDef &u32, pdwTypeDefFlags &u32, ptkExtends &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.import_ptr.lpVtbl.GetTypeDefProps(md.import_ptr, tkTypeDef, szTypeDef, cchTypeDef, pchTypeDef,
// 		pdwTypeDefFlags, ptkExtends)
// }
//
// pub fn (md MetaDataImport) get_type_ref_props(tkTypeRef u32, ptkResolutionScope &u32, szName string, cchName u32, pchName &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.import_ptr.lpVtbl.GetTypeRefProps(md.import_ptr, tkTypeRef, ptkResolutionScope, szName,
// 		cchName, pchName)
// }
//
// pub fn (md MetaDataImport) get_type_spec_from_token(tkTypeSpec u32, ppvSig voidptr, pcbSig &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.import_ptr.lpVtbl.GetTypeSpecFromToken(md.import_ptr, tkTypeSpec, ppvSig, pcbSig)
// }
//
// pub fn (md MetaDataImport) get_user_string(tkString u32, szString string, cchString u32, pchString &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.import_ptr.lpVtbl.GetUserString(md.import_ptr, tkString, szString, cchString, pchString)
// }
//
// pub fn (md MetaDataImport) get_version_string(pwzBuf string, ccBufSize u32, pccBufSize &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.import_ptr.lpVtbl.GetVersionString(md.import_ptr, pwzBuf, ccBufSize, pccBufSize)
// }
//
// pub fn (md MetaDataImport) is_global(tk u32, pbIsGlobal &i32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.import_ptr.lpVtbl.IsGlobal(md.import_ptr, tk, pbIsGlobal)
// }
//
// pub fn (md MetaDataImport) is_valid_token(tk u32) bool {
// 	// TODO: Make function idiomatic to V
// 	return md.import_ptr.lpVtbl.IsValidToken(md.import_ptr, tk)
// }
//
// pub fn (md MetaDataImport) reset_enum(hEnum u32, ulPos u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.import_ptr.lpVtbl.ResetEnum(md.import_ptr, hEnum, ulPos)
// }
//
// pub fn (md MetaDataImport) resolve_type_ref(tkTypeRef u32, riid voidptr, ppIScope voidptr, ptkTypeDef &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.import_ptr.lpVtbl.ResolveTypeRef(md.import_ptr, tkTypeRef, riid, ppIScope, ptkTypeDef)
// }

//////////////////////////////
// Metadata assembly import //
//////////////////////////////

pub struct MetaDataAssemblyImport {
	ptr &C.IMetaDataAssemblyImport
}

// // close_enum releases a reference to the specified enumeration instance.
// pub fn (md &MetaDataAssemblyImport) close_enum(enum_instance u32) {
// 	// TODO: Make function idiomatic to V
// 	md.metadata_ptr.lpVtbl.CloseEnum(md.metadata_ptr, enum_instance)
// }
//
// pub fn (md &MetaDataAssemblyImport) enum_assembly_refs(phEnum &usize, rAssemblyRefs &AssemblyRef, pcTokens &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.metadata_ptr.lpVtbl.EnumAssemblyRefs(md.metadata_ptr, phEnum, rAssemblyRefs, 1, pcTokens)
// }
//
// pub fn (md &MetaDataAssemblyImport) enum_exported_types(phEnum &usize, rExportedTypes &u32, pcTokens &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.metadata_ptr.lpVtbl.EnumExportedTypes(md.metadata_ptr, phEnum, rExportedTypes, 1, pcTokens)
// }
//
// pub fn (md &MetaDataAssemblyImport) enum_files(phEnum &usize, rFiles &u32, pcTokens &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.metadata_ptr.lpVtbl.EnumFiles(md.metadata_ptr, phEnum, rFiles, 1, pcTokens)
// }
//
// pub fn (md &MetaDataAssemblyImport) enum_manifest_resources(phEnum &usize, rManifestResources &ManifestResourceToken) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.metadata_ptr.lpVtbl.EnumManifestResources(md.metadata_ptr, phEnum, rManifestResources, 1,
// 		pcTokens)
// }
//
// pub fn (md &MetaDataAssemblyImport) find_assemblies_by_name(szAppBase string, szPrivateBin string, szAssemblyName string, ppIUnk &voidptr, pcAssemblies &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.metadata_ptr.lpVtbl.FindAssembliesByName(md.metadata_ptr, szAppBase.to_wide(), szPrivateBin.to_wide(), szAssemblyName.to_wide(),
// 		ppIUnk, 1, pcAssemblies)
// }
//
// pub fn (md &MetaDataAssemblyImport) find_exported_type_by_name(szName string, mdtExportedType u32, ptkExportedType &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.metadata_ptr.lpVtbl.FindExportedTypeByName(md.metadata_ptr, szName.to_wide(), mdtExportedType, ptkExportedType)
// }
//
// pub fn (md &MetaDataAssemblyImport) find_manifest_resource_by_name(szName string, ptkManifestResource &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.metadata_ptr.lpVtbl.FindManifestResourceByName(md.metadata_ptr, szName.to_wide(), ptkManifestResource)
// }
//
// pub fn (md &MetaDataAssemblyImport) get_assembly_from_scope(ptkAssembly &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.metadata_ptr.lpVtbl.GetAssemblyFromScope(md.metadata_ptr, ptkAssembly)
// }
//
// pub fn (md &MetaDataAssemblyImport) get_assembly_props(mds u32, ppbPublicKey &&u8, pcbPublicKey &u32, pulHashALgId &u32, szName string, cchName u32, pchName &u32, pMetaData &C.ASSEMBLYMETADATA, pdwAssemblyFlags &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.metadata_ptr.lpVtbl.GetAssemblyProps(md.metadata_ptr, mds, ppbPublicKey, pcbPublicKey, pulHashALgId,
// 		szName, cchName, pchName, pMetaData, pdwAssemblyFlags)
// }
//
// pub fn (md &MetaDataAssemblyImport) get_assembly_ref_props(mdar u32, ppbPublicKeyOrToken &&u8, pcbPublicKeyOrToken &u32, szName string, cchName u32, pchName &u32, pMetaData &C.ASSEMBLYMETADATA, ppbHashValue &&u8, pcbHashValue u32, pdwAssemblyRefFlags &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.metadata_ptr.lpVtbl.GetAssemblyRefProps(md.metadata_ptr, mdar, ppbPublicKeyOrToken, pcbPublicKeyOrToken,
// 		szName, cchName, pchName, pMetaData, ppbHashValue, pcbHashValue, pdwAssemblyRefFlags)
// }
//
// pub fn (md &MetaDataAssemblyImport) get_exported_type_props(mdct u32, szName string, cchName u32, pchName &u32, ptkImplementation &u32, ptkTypeDef &u32, pdwExportedTypeFlags &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.metadata_ptr.lpVtbl.GetExportedTypeProps(md.metadata_ptr, mdct, szName, cchName, pchName,
// 		ptkImplementation, ptkTypeDef, pdwExportedTypeFlags)
// }
//
// pub fn (md &MetaDataAssemblyImport) get_file_props(mdf u32, szName string, cchName u32, pchName &u32, ppbHashValue &&u8, pcbHashValue &u32, pdwFileFlags &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.metadata_ptr.lpVtbl.GetFileProps(md.metadata_ptr, mdf, szName, cchName, pchName, ppbHashValue,
// 		pcbHashValue, pdwFileFlags)
// }
//
// pub fn (md &MetaDataAssemblyImport) get_manifest_resource_props(mdmr u32, szName string, cchName u32, pchName &u32, ptkImplementation &u32, pdwOffset &u32, pdwResourceFlags &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.metadata_ptr.lpVtbl.GetManifestResourceProps(md.metadata_ptr, mdmr, szName, cchName, pchName,
// 		ptkImplementation, pdwOffset, pdwResourceFlags)
// }

/////////////////////
// Metadata tables //
/////////////////////

pub struct MetaDataTables {
	ptr &C.IMetaDataTables2
}

// pub fn (md MetaDataTables) get_blob(ixBlob u32, pcbData &u32, ppData &&u8) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.tables_ptr.lpVtbl.GetBlob(md.tables_ptr, ixBlob, pcbData, ppData)
// }
//
// pub fn (md MetaDataTables) get_blob_heap_size(pcbBlobs &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.tables_ptr.lpVtbl.GetBlobHeapSize(md.tables_ptr, pcbBlobs)
// }
//
// pub fn (md MetaDataTables) get_coded_token_info(ixCdTkn u32, pcTokens &u32, ppTokens &&u32, ppName &string) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.tables_ptr.lpVtbl.GetCodedTokenInfo(md.tables_ptr, ixCdTkn, pcTokens, ppTokens, ppName)
// }
//
// pub fn (md MetaDataTables) get_column(ixTbl u32, ixCol u32, rid u32, pVal &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.tables_ptr.lpVtbl.GetColumn(md.tables_ptr, ixTbl, ixCol, rid, pVal)
// }
//
// pub fn (md MetaDataTables) get_column_info(ixTbl u32, ixCol u32, poCol &u32, pcbCol &u32, pType &u32, ppName &string) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.tables_ptr.lpVtbl.GetColumnInfo(md.tables_ptr, ixTbl, ixCol, poCol, pcbCol, pType, ppName)
// }
//
// pub fn (md MetaDataTables) get_guid(ixGuix u32, guid &&u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.tables_ptr.lpVtbl.GetGuid(md.tables_ptr, ixGuix, guid)
// }
//
// pub fn (md MetaDataTables) get_guid_heap_size(pcbGuids &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.tables_ptr.lpVtbl.GetGuidHeapSize(md.tables_ptr, pcbGuids)
// }
//
// pub fn (md MetaDataTables) get_metadata_storage(ppvMd &&u8, pcbMd &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.tables_ptr.lpVtbl.GetMetaDataStorage(md.tables_ptr, ppvMd, pcbMd)
// }
//
// pub fn (md MetaDataTables) get_metadata_stream_info(ix u32, ppchName &string, ppv &&u8, pcb &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.tables_ptr.lpVtbl.GetMetaDataStreamInfo(md.tables_ptr, ix, ppchName, ppv, pcb)
// }
//
// pub fn (md MetaDataTables) get_next_blob(ixBlob u32, pNext &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.tables_ptr.lpVtbl.GetNextBlob(md.tables_ptr, ixBlob, *pNext)
// }
//
// pub fn (md MetaDataTables) get_next_guid(ixGuid u32, pNext &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.tables_ptr.lpVtbl.GetNextGuid(md.tables_ptr, ixGuid, *pNext)
// }
//
// pub fn (md MetaDataTables) get_next_string(ixString u32, pNext &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.tables_ptr.lpVtbl.GetNextString(md.tables_ptr, ixString, *pNext)
// }
//
// pub fn (md MetaDataTables) get_next_user_string(ixUserString u32, pNext &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.tables_ptr.lpVtbl.GetNextUserString(md.tables_ptr, ixUserString, *pNext)
// }
//
// pub fn (md MetaDataTables) get_num_tables(pcTables &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.tables_ptr.lpVtbl.GetNumTables(md.tables_ptr, pcTables)
// }
//
// pub fn (md MetaDataTables) get_row(ixTbl u32, rid u32, ppRow &&u8) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.tables_ptr.lpVtbl.GetRow(md.tables_ptr, ixTbl, rid, ppRow)
// }
//
// pub fn (md MetaDataTables) get_string(ixString u32, ppString &string) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.tables_ptr.lpVtbl.GetString(md.tables_ptr, ixString, ppString)
// }
//
// pub fn (md MetaDataTables) get_string_heap_size(pcbStrings &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.tables_ptr.lpVtbl.GetStringHeapSize(md.tables_ptr, pcbStrings)
// }
//
// pub fn (md MetaDataTables) get_table_index(token u32, pixTbl &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.tables_ptr.lpVtbl.GetTableIndex(md.tables_ptr, token, *pixTbl)
// }
//
// pub fn (md MetaDataTables) get_table_info(ixTbl u32, pcbRow &u32, pcRows &u32, pcCols &u32, piKey &u32, ppName string) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.tables_ptr.lpVtbl.GetTableInfo(md.tables_ptr, ixTbl, pcbRow, pcRows, pcCols, piKey, ppName)
// }
//
// pub fn (md MetaDataTables) get_user_string(ixUserString u32, pcbData &u32, ppData &&u8) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.tables_ptr.lpVtbl.GetUserString(md.tables_ptr, ixUserString, pcbData, ppData)
// }
//
// pub fn (md MetaDataTables) get_user_string_heap_size(pcbUserStrings &u32) u32 {
// 	// TODO: Make function idiomatic to V
// 	return md.tables_ptr.lpVtbl.GetUserStringHeapSize(md.tables_ptr, pcbUserStrings)
// }