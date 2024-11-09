// Remove TypeSig from read_metadata_tables.v and metadata_tables.v
// Keep only this consolidated version in signatures.v
module winmd

pub struct TypeSig {
pub mut:
	element_type ElementType
	// Type of the element
	type_def     ?TypeDef
	// Referenced TypeDef
	type_ref     ?TypeRef
	// Referenced TypeRef
	class_name   string
	// Name of the type
	namespace    string
	// Namespace
	is_by_ref    bool
	array_rank   int
	generic_args []TypeSig
	element_sig  ?&TypeSig
}

pub struct MethodSig {
pub mut:
	calling_conv  u32
	generic_count u32
	param_count   u32
	ret_type      TypeSig
	params        []TypeSig
}

pub struct PropertySig {
pub mut:
	has_this    bool
	param_count u32
	ret_type    TypeSig
	params      []TypeSig
}

pub struct MemberSig {
pub mut:
	calling_conv u8
	param_count  u32
	ret_type     TypeSig
	params       []TypeSig
}
