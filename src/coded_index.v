module main

import math

fn decode_coded_index(value u32, num_tables u32) (u32, u32) {
	tag_bits := u32(math.ceil(math.log2(num_tables)))
	tag_mask := (u32(1) << tag_bits) - 1

	tag := value & tag_mask
	row_index := value >> tag_bits

	return tag, row_index
}

fn decode_type_def_or_ref(coded_index u32) u32 {
	// TypeDefOrRef may reference the tables:
	// `TypeDef` | 0
	// `TypeRef` | 1
	// `TypeSpec` | 2
	tag, row_index := decode_coded_index(coded_index, 3)

	table_type := match tag {
		0 { u32(Tables.type_def) }
		1 { u32(Tables.type_ref) }
		2 { u32(Tables.type_spec) }
		else { panic('decode_type_def_or_ref encountered an invalid tag') }
	}

	return (table_type << 24) | row_index
}

fn get_type_def_or_ref_size(tables TablesStream) u32 {
	if tables.num_rows[.type_def] > 0x4000 {
		return 4
	}
	if tables.num_rows[.type_ref] > 0x4000 {
		return 4
	}
	if tables.num_rows[.type_spec] > 0x4000 {
		return 4
	}
	return 2
}

fn decode_has_constant(coded_index u32) u32 {
	// HasConstant may reference the tables:
	// `Field` | 0
	// `Param` | 1
	// `Property` | 2
	tag, row_index := decode_coded_index(coded_index, 3)

	table_type := match tag {
		0 { u32(Tables.field) }
		1 { u32(Tables.param) }
		2 { u32(Tables.property) }
		else { panic('decode_has_constant encountered an invalid tag') }
	}

	return (table_type << 24) | row_index
}

fn get_has_constant_size(tables TablesStream) u32 {
	if tables.num_rows[.field] > 0x4000 {
		return 4
	}
	if tables.num_rows[.param] > 0x4000 {
		return 4
	}
	if tables.num_rows[.property] > 0x4000 {
		return 4
	}
	return 2
}

fn decode_has_custom_attribute(coded_index u32) u32 {
	// HasCustomAttribute may reference the tables:
	// `MethodDef` | 0
	// `Field` | 1
	// `TypeRef` | 2
	// `TypeDef` | 3
	// `Param` | 4
	// `InterfaceImpl` | 5
	// `MemberRef` | 6
	// `Module` | 7
	// `Permission` | 8
	// `Property` | 9
	// `Event` | 10
	// `StandAloneSig` | 11
	// `ModuleRef` | 12
	// `TypeSpec` | 13
	// `Assembly` | 14
	// `AssemblyRef` | 15
	// `File` | 16
	// `ExportedType` | 17
	// `ManifestResource` | 18
	// `GenericParam` | 19
	// `GenericParamConstraint` | 20
	// `MethodSpec` | 21
	tag, row_index := decode_coded_index(coded_index, 22)

	table_type := match tag {
		0 { u32(Tables.method_def) }
		1 { u32(Tables.field) }
		2 { u32(Tables.type_ref) }
		3 { u32(Tables.type_def) }
		4 { u32(Tables.param) }
		5 { u32(Tables.interface_impl) }
		6 { u32(Tables.member_ref) }
		7 { u32(Tables.module) }
		// 8 { u32(Tables.permission) }
		9 { u32(Tables.property) }
		10 { u32(Tables.event) }
		11 { u32(Tables.stand_alone_sig) }
		12 { u32(Tables.module_ref) }
		13 { u32(Tables.type_spec) }
		14 { u32(Tables.assembly) }
		15 { u32(Tables.assembly_ref) }
		16 { u32(Tables.file) }
		17 { u32(Tables.exported_type) }
		18 { u32(Tables.manifest_resource) }
		19 { u32(Tables.generic_param) }
		20 { u32(Tables.generic_param_constraint) }
		21 { u32(Tables.method_spec) }
		else { panic('decode_has_custom_attribute encountered an invalid tag') }
	}

	return (table_type << 24) | row_index
}

fn get_has_custom_attribute_size(tables TablesStream) u32 {
	if tables.num_rows[.method_def] > 0x4000 {
		return 4
	}
	if tables.num_rows[.field] > 0x4000 {
		return 4
	}
	if tables.num_rows[.type_ref] > 0x4000 {
		return 4
	}
	if tables.num_rows[.type_def] > 0x4000 {
		return 4
	}
	if tables.num_rows[.param] > 0x4000 {
		return 4
	}
	if tables.num_rows[.interface_impl] > 0x4000 {
		return 4
	}
	if tables.num_rows[.member_ref] > 0x4000 {
		return 4
	}
	if tables.num_rows[.module] > 0x4000 {
		return 4
	}

	// if tables.num_rows[.permission] > 0x4000 {
	// 	return 4
	// }
	if tables.num_rows[.property] > 0x4000 {
		return 4
	}
	if tables.num_rows[.event] > 0x4000 {
		return 4
	}
	if tables.num_rows[.stand_alone_sig] > 0x4000 {
		return 4
	}
	if tables.num_rows[.module_ref] > 0x4000 {
		return 4
	}
	if tables.num_rows[.type_spec] > 0x4000 {
		return 4
	}
	if tables.num_rows[.assembly] > 0x4000 {
		return 4
	}
	if tables.num_rows[.assembly_ref] > 0x4000 {
		return 4
	}
	if tables.num_rows[.file] > 0x4000 {
		return 4
	}
	if tables.num_rows[.exported_type] > 0x4000 {
		return 4
	}
	if tables.num_rows[.manifest_resource] > 0x4000 {
		return 4
	}
	if tables.num_rows[.generic_param] > 0x4000 {
		return 4
	}
	if tables.num_rows[.generic_param_constraint] > 0x4000 {
		return 4
	}
	if tables.num_rows[.method_spec] > 0x4000 {
		return 4
	}

	// If no table exceeds 0x4000 rows, the size is 2 bytes.
	return 2
}

fn decode_has_field_marshal(coded_index u32) u32 {
	// HasFieldMarshal may reference the tables:
	// `Field` | 0
	// `Param` | 1
	tag, row_index := decode_coded_index(coded_index, 2)

	table_type := match tag {
		0 { u32(Tables.field) }
		1 { u32(Tables.param) }
		else { panic('decode_has_field_marshal encountered an invalid tag') }
	}

	return (table_type << 24) | row_index
}

fn get_has_field_marshal_size(tables TablesStream) u32 {
	if tables.num_rows[.field] > 0x4000 {
		return 4
	}
	if tables.num_rows[.param] > 0x4000 {
		return 4
	}
	return 2
}

fn decode_has_decl_security(coded_index u32) u32 {
	// HasDeclSecurity may reference the tables:
	// `TypeDef` | 0
	// `MethodDef` | 1
	// `Assembly` | 2
	tag, row_index := decode_coded_index(coded_index, 3)

	table_type := match tag {
		0 { u32(Tables.type_def) }
		1 { u32(Tables.method_def) }
		2 { u32(Tables.assembly) }
		else { panic('decode_has_decl_security encountered an invalid tag') }
	}

	return (table_type << 24) | row_index
}

fn get_has_decl_security_size(tables TablesStream) u32 {
	if tables.num_rows[.type_def] > 0x4000 {
		return 4
	}
	if tables.num_rows[.method_def] > 0x4000 {
		return 4
	}
	if tables.num_rows[.assembly] > 0x4000 {
		return 4
	}
	return 2
}

fn decode_member_ref_parent(coded_index u32) u32 {
	// MemberRefParent may reference the tables:
	// `TypeDef` | 0
	// `TypeRef` | 1
	// `ModuleRef` | 2
	// `MethodDef` | 3
	// `TypeSpec` | 4
	tag, row_index := decode_coded_index(coded_index, 5)

	table_type := match tag {
		0 { u32(Tables.type_def) }
		1 { u32(Tables.type_ref) }
		2 { u32(Tables.module_ref) }
		3 { u32(Tables.method_def) }
		4 { u32(Tables.type_spec) }
		else { panic('decode_member_ref_parent encountered an invalid tag') }
	}

	return (table_type << 24) | row_index
}

fn get_member_ref_parent_size(tables TablesStream) u32 {
	if tables.num_rows[.type_def] > 0x4000 {
		return 4
	}
	if tables.num_rows[.type_ref] > 0x4000 {
		return 4
	}
	if tables.num_rows[.module_ref] > 0x4000 {
		return 4
	}
	if tables.num_rows[.method_def] > 0x4000 {
		return 4
	}
	if tables.num_rows[.type_spec] > 0x4000 {
		return 4
	}
	return 2
}

fn decode_has_semantics(coded_index u32) u32 {
	// HasSemantics may reference the tables:
	// `Event` | 0
	// `Property` | 1
	tag, row_index := decode_coded_index(coded_index, 2)

	table_type := match tag {
		0 { u32(Tables.event) }
		1 { u32(Tables.property) }
		else { panic('decode_has_semantics encountered an invalid tag') }
	}

	return (table_type << 24) | row_index
}

fn get_has_semantics_size(tables TablesStream) u32 {
	if tables.num_rows[.event] > 0x4000 {
		return 4
	}
	if tables.num_rows[.property] > 0x4000 {
		return 4
	}
	return 2
}

fn decode_method_def_or_ref(coded_index u32) u32 {
	// MethodDefOrRef may reference the tables:
	// `MethodDef` | 0
	// `MemberRef` | 1
	tag, row_index := decode_coded_index(coded_index, 2)

	table_type := match tag {
		0 { u32(Tables.method_def) }
		1 { u32(Tables.member_ref) }
		else { panic('decode_method_def_or_ref encountered an invalid tag') }
	}

	return (table_type << 24) | row_index
}

fn get_method_def_or_ref_size(tables TablesStream) u32 {
	if tables.num_rows[.method_def] > 0x4000 {
		return 4
	}
	if tables.num_rows[.member_ref] > 0x4000 {
		return 4
	}
	return 2
}

fn decode_member_forwarded(coded_index u32) u32 {
	// MemberForwarded may reference the tables:
	// `Field` | 0
	// `MethodDef` | 1
	tag, row_index := decode_coded_index(coded_index, 2)

	table_type := match tag {
		0 { u32(Tables.field) }
		1 { u32(Tables.method_def) }
		else { panic('decode_member_forwarded encountered an invalid tag') }
	}

	return (table_type << 24) | row_index
}

fn get_member_forwarded_size(tables TablesStream) u32 {
	// The current version of the specification says:
	//
	// >  MemberForwarded (an index into the _Field_ or _MethodDef_ table; more precisely,
	//    a _MemberForwarded_  (§[II.24.2.6](ii.24.2.6-metadata-stream.md)) coded index).
	//    However, it only ever indexes the _MethodDef_ table, since _Field_ export is not supported.
	//
	// What this means is that although the MemberForwarded coded index is for
	// Field and MethodDef, we should only ever check MethodDef. I assume it's for
	// possible future extensibility.

	// Don't consider the number of entries in Field (yet?)
	// if tables.num_rows[.field] > 0x4000 {
	// 	return 4
	// }
	if tables.num_rows[.method_def] > 0x4000 {
		return 4
	}
	return 2
}

fn decode_implementation(coded_index u32) u32 {
	// Implementation may reference the tables:
	// `File` | 0
	// `AssemblyRef` | 1
	// `ExportedType` | 2
	tag, row_index := decode_coded_index(coded_index, 3)

	table_type := match tag {
		0 { u32(Tables.file) }
		1 { u32(Tables.assembly_ref) }
		2 { u32(Tables.exported_type) }
		else { panic('decode_implementation encountered an invalid tag') }
	}

	return (table_type << 24) | row_index
}

fn get_implementation_size(tables TablesStream) u32 {
	if tables.num_rows[.file] > 0x4000 {
		return 4
	}
	if tables.num_rows[.assembly_ref] > 0x4000 {
		return 4
	}
	if tables.num_rows[.exported_type] > 0x4000 {
		return 4
	}
	return 2
}

fn decode_custom_attribute_type(coded_index u32) u32 {
	// CustomAttributeType may reference the tables:
	// Not used | 0
	// Not used | 1
	// `MethodDef` | 2
	// `MemberRef` | 3
	// Not used | 4
	tag, row_index := decode_coded_index(coded_index, 5)

	table_type := match tag {
		2 { u32(Tables.method_def) }
		3 { u32(Tables.member_ref) }
		else { panic('decode_custom_attribute_type encountered an invalid tag') }
	}

	return (table_type << 24) | row_index
}

fn get_custom_attribute_type_size(tables TablesStream) u32 {
	if tables.num_rows[.method_def] > 0x4000 {
		return 4
	}
	if tables.num_rows[.member_ref] > 0x4000 {
		return 4
	}
	return 2
}

fn decode_resolution_scope(coded_index u32) u32 {
	// ResolutionScope may reference the tables:
	// `Module` | 0
	// `ModuleRef` | 1
	// `AssemblyRef` | 2
	// `TypeRef` | 3
	tag, row_index := decode_coded_index(coded_index, 4)

	table_type := match tag {
		0 { u32(Tables.module) }
		1 { u32(Tables.module_ref) }
		2 { u32(Tables.assembly_ref) }
		3 { u32(Tables.type_ref) }
		else { panic('decode_resolution_scope encountered an invalid tag') }
	}

	return (table_type << 24) | row_index
}

fn get_resolution_scope_size(tables TablesStream) u32 {
	if tables.num_rows[.module] > 0x4000 {
		return 4
	}
	if tables.num_rows[.module_ref] > 0x4000 {
		return 4
	}
	if tables.num_rows[.assembly_ref] > 0x4000 {
		return 4
	}
	if tables.num_rows[.type_ref] > 0x4000 {
		return 4
	}
	return 2
}

fn decode_type_or_method_def(coded_index u32) u32 {
	// TypeOrMethodDef may reference the tables:
	// `TypeDef` | 0
	// `MethodDef` | 1
	tag, row_index := decode_coded_index(coded_index, 2)

	table_type := match tag {
		0 { u32(Tables.type_def) }
		1 { u32(Tables.method_def) }
		else { panic('decode_type_or_method_def encountered an invalid tag') }
	}

	return (table_type << 24) | row_index
}

fn get_type_or_method_def_size(tables TablesStream) u32 {
	if tables.num_rows[.type_def] > 0x4000 {
		return 4
	}
	if tables.num_rows[.method_def] > 0x4000 {
		return 4
	}
	return 2
}
