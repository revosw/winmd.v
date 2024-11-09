module winmd

// Raw table row structures
pub struct ModuleRowRaw {
pub mut:
	generation      u16
	name_idx        u32
	mvid_idx        u32
	enc_id_idx      u32
	enc_base_id_idx u32
	row_id          u32
}

pub struct TypeDefRowRaw {
pub mut:
	flags         u32
	name_idx      u32
	namespace_idx u32
	extends       u32
	field_list    u32
	method_list   u32
	row_id        u32
}

pub struct TypeRefRowRaw {
pub mut:
	resolution_scope u32
	name_idx         u32
	namespace_idx    u32
	row_id           u32
}

pub struct FieldRowRaw {
pub mut:
	flags     u32
	name_idx  u32
	signature u32
	row_id    u32
}

pub struct MethodDefRowRaw {
pub mut:
	rva        u32
	impl_flags u16
	flags      u16
	name_idx   u32
	signature  u32
	param_list u32
	row_id     u32
}

pub struct ParamRowRaw {
pub mut:
	flags    u32
	sequence u16
	name_idx u32
	row_id   u32
}

pub struct InterfaceImplRowRaw {
pub mut:
	class     u32
	interface u32
	row_id    u32
}

pub struct MemberRefRowRaw {
pub mut:
	class     u32
	name_idx  u32
	signature u32
	row_id    u32
}

pub struct ConstantRowRaw {
pub mut:
	type_     u8
	padding   u8
	parent    u32
	value_idx u32
	row_id    u32
}

pub struct CustomAttributeRowRaw {
pub mut:
	parent    u32
	type_     u32
	value_idx u32
	row_id    u32
}

pub struct PropertyMapRowRaw {
pub mut:
	parent        u32
	property_list u32
	row_id        u32
}

pub struct PropertyRowRaw {
pub mut:
	flags    u32
	name_idx u32
	type_sig u32
	row_id   u32
}

pub struct MethodSemanticsRowRaw {
pub mut:
	semantic    u16
	method      u32
	association u32
	row_id      u32
}

pub struct EventMapRowRaw {
pub mut:
	parent     u32
	event_list u32
	row_id     u32
}

pub struct EventRowRaw {
pub mut:
	flags      u32
	name_idx   u32
	event_type u32
	row_id     u32
}

// Resolved structures
pub struct Module {
pub mut:
	generation  u16
	name        string
	mvid        GUID
	enc_id      GUID
	enc_base_id GUID
	row_id      u32
}

pub struct TypeDef {
pub mut:
	flags       u32
	name        string
	namespace   string
	extends     u32
	field_list  u32
	method_list u32
	row_id      u32
}

pub struct TypeRef {
pub mut:
	resolution_scope u32
	name             string
	namespace        string
	row_id           u32
}

pub struct Field {
pub mut:
	flags          u32
	name           string
	signature      TypeSig
	row_id         u32
	type_name      string
	is_static      bool
	is_literal     bool
	is_init_only   bool
	constant_value ?string
}

pub struct MethodDef {
pub mut:
	rva         u32
	impl_flags  u16
	flags       MethodFlags
	name        string
	signature   MethodSig
	param_list  u32
	row_id      u32
	parameters  []Param
	parent_type string
	is_public   bool
	is_static   bool
	is_virtual  bool
	is_abstract bool
}

pub struct Param {
pub mut:
	flags         u32
	sequence      u16
	name          string
	type_name     string
	row_id        u32
	is_in         bool
	is_out        bool
	is_optional   bool
	default_value ?string
}

pub struct InterfaceImpl {
pub mut:
	class     TypeDef
	interface TypeRef
	row_id    u32
}

pub struct MemberRef {
pub mut:
	class     u32
	// Parent token
	name      string
	signature MemberSig
	row_id    u32
}

pub struct Constant {
pub mut:
	type_  ElementType
	parent u32
	value  string
	row_id u32
}

pub struct PropertyMap {
pub mut:
	parent        TypeDef
	property_list u32
	row_id        u32
}

pub struct Property {
pub mut:
	flags           u32
	name            string
	type_sig        PropertySig
	row_id          u32
	get_method      ?MethodDef
	set_method      ?MethodDef
	is_static       bool
	is_special_name bool
}

pub struct MethodSemantics {
pub mut:
	semantic    MethodSemanticsFlag
	method      MethodDef
	association u32
	row_id      u32
}

pub struct EventMap {
pub mut:
	parent     TypeDef
	event_list u32
	row_id     u32
}

pub struct Event {
pub mut:
	flags         u32
	name          string
	event_type    TypeRef
	row_id        u32
	add_method    MethodDef
	remove_method MethodDef
	invoke_method ?MethodDef
}

pub struct CustomAttribute {
pub mut:
	parent u32
	// Keep as token since it can refer to different table types
	type_  u32
	// Keep as token since we resolve on demand
	value  CustomAttributeValue
	row_id u32
}

// CustomAttributeValue structure
pub struct CustomAttributeValue {
pub mut:
	constructor_args []CustomAttributeArg
	named_args       map[string]CustomAttributeArg
}

pub struct CustomAttributeArg {
pub mut:
	type_ ElementType
	value string
}

// Resolver methods
pub fn (mut r WinMDReader) resolve_module(raw ModuleRowRaw) !Module {
	return Module{
		generation:  raw.generation
		name:        r.get_string(raw.name_idx)!
		mvid:        r.get_type_guid(raw.mvid_idx)!
		enc_id:      r.get_type_guid(raw.enc_id_idx)!
		enc_base_id: r.get_type_guid(raw.enc_base_id_idx)!
		row_id:      raw.row_id
	}
}

pub fn (mut r WinMDReader) resolve_typedef(raw TypeDefRowRaw) !TypeDef {
	return TypeDef{
		flags:       raw.flags
		name:        r.get_string(raw.name_idx)!
		namespace:   r.get_string(raw.namespace_idx)!
		extends:     raw.extends
		field_list:  raw.field_list
		method_list: raw.method_list
		row_id:      raw.row_id
	}
}

pub fn (mut r WinMDReader) resolve_typeref(raw TypeRefRowRaw) !TypeRef {
	return TypeRef{
		resolution_scope: raw.resolution_scope
		name:             r.get_string(raw.name_idx)!
		namespace:        r.get_string(raw.namespace_idx)!
		row_id:           raw.row_id
	}
}

pub fn (mut r WinMDReader) resolve_field(raw FieldRowRaw) !Field {
	return Field{
		flags:     raw.flags
		name:      r.get_string(raw.name_idx)!
		signature: r.resolve_type_signature(raw.signature)!
		row_id:    raw.row_id
	}
}

pub fn (mut r WinMDReader) resolve_methoddef(raw MethodDefRowRaw) !MethodDef {
	return MethodDef{
		rva:        raw.rva
		impl_flags: raw.impl_flags
		flags:      raw.flags
		name:       r.get_string(raw.name_idx)!
		signature:  r.resolve_method_signature(raw.signature)!
		param_list: raw.param_list
		row_id:     raw.row_id
	}
}

pub fn (mut r WinMDReader) resolve_param(raw ParamRowRaw) !Param {
	return Param{
		flags:    raw.flags
		sequence: raw.sequence
		name:     r.get_string(raw.name_idx)!
		row_id:   raw.row_id
	}
}

pub fn (mut r WinMDReader) resolve_interfaceimpl(raw InterfaceImplRowRaw) !InterfaceImpl {
	return InterfaceImpl{
		class:     r.read_typedef_entry(raw.class)!
		interface: r.read_typeref_entry(raw.interface)!
		row_id:    raw.row_id
	}
}

pub fn (mut r WinMDReader) resolve_memberref(raw MemberRefRowRaw) !MemberRef {
	return MemberRef{
		class:     raw.class
		name:      r.get_string(raw.name_idx)!
		signature: r.resolve_member_signature(raw.signature)!
		row_id:    raw.row_id
	}
}

pub fn (mut r WinMDReader) resolve_constant(raw ConstantRowRaw) !Constant {
	blob := r.get_blob(raw.value_idx)!
	return Constant{
		type_:  unsafe { ElementType(raw.type_) }
		parent: raw.parent
		value:  r.decode_constant_value(raw.type_, blob)!
		row_id: raw.row_id
	}
}

pub fn (mut r WinMDReader) resolve_customattribute(raw CustomAttributeRowRaw) !CustomAttribute {
	return CustomAttribute{
		parent: raw.parent
		type_:  raw.type_
		value:  r.parse_custom_attribute(raw.value_idx)!
		row_id: raw.row_id
	}
}

pub fn (mut r WinMDReader) resolve_propertymap(raw PropertyMapRowRaw) !PropertyMap {
	return PropertyMap{
		parent:        r.read_typedef_entry(raw.parent)!
		property_list: raw.property_list
		row_id:        raw.row_id
	}
}

pub fn (mut r WinMDReader) resolve_property(raw PropertyRowRaw) !Property {
	return Property{
		flags:    raw.flags
		name:     r.get_string(raw.name_idx)!
		type_sig: r.resolve_property_signature(raw.type_sig)!
		row_id:   raw.row_id
	}
}

pub fn (mut r WinMDReader) resolve_methodsemantics(raw MethodSemanticsRowRaw) !MethodSemantics {
	return MethodSemantics{
		semantic:    unsafe { MethodSemanticsFlag(raw.semantic) }
		method:      r.read_methoddef_entry(raw.method)!
		association: raw.association
		row_id:      raw.row_id
	}
}

pub fn (mut r WinMDReader) resolve_eventmap(raw EventMapRowRaw) !EventMap {
	return EventMap{
		parent:     r.read_typedef_entry(raw.parent)!
		event_list: raw.event_list
		row_id:     raw.row_id
	}
}

pub fn (mut r WinMDReader) resolve_event(raw EventRowRaw) !Event {
	return Event{
		flags:      raw.flags
		name:       r.get_string(raw.name_idx)!
		event_type: r.read_typeref_entry(raw.event_type)!
		row_id:     raw.row_id
	}
}

// Table reading methods
pub fn (mut r WinMDReader) read_module_entry(row_idx u32) !Module {
	pos := r.file.tell()!
	offset := r.get_table_offset(.module)! + (u64(row_idx - 1) * 10)
	r.file.seek(i64(offset), .start)!

	raw := ModuleRowRaw{
		generation:      r.read_u16()!
		name_idx:        r.read_string_index()!
		mvid_idx:        r.read_guid_index()!
		enc_id_idx:      r.read_guid_index()!
		enc_base_id_idx: r.read_guid_index()!
		row_id:          row_idx
	}

	r.file.seek(pos, .start)!
	return r.resolve_module(raw)
}

pub fn (mut r WinMDReader) read_typedef_entry(row_idx u32) !TypeDef {
	pos := r.file.tell()!
	offset := r.get_table_offset(.type_def)! + (u64(row_idx - 1) * 24)
	r.file.seek(i64(offset), .start)!

	raw := TypeDefRowRaw{
		flags:         r.read_u32()!
		name_idx:      r.read_string_index()!
		namespace_idx: r.read_string_index()!
		extends:       r.read_coded_index(.type_def_or_ref)!
		field_list:    r.read_u32()!
		method_list:   r.read_u32()!
		row_id:        row_idx
	}

	r.file.seek(pos, .start)!
	return r.resolve_typedef(raw)
}

pub fn (mut r WinMDReader) read_typeref_entry(row_idx u32) !TypeRef {
	pos := r.file.tell()!
	offset := r.get_table_offset(.type_ref)! + (u64(row_idx - 1) * 6)
	r.file.seek(i64(offset), .start)!

	raw := TypeRefRowRaw{
		resolution_scope: r.read_coded_index(.resolution_scope)!
		name_idx:         r.read_string_index()!
		namespace_idx:    r.read_string_index()!
		row_id:           row_idx
	}

	r.file.seek(pos, .start)!
	return r.resolve_typeref(raw)
}

pub fn (mut r WinMDReader) read_field_entry(row_idx u32) !Field {
	pos := r.file.tell()!
	offset := r.get_table_offset(.field_def)! + (u64(row_idx - 1) * 8)
	r.file.seek(i64(offset), .start)!

	raw := FieldRowRaw{
		flags:     r.read_u32()!
		name_idx:  r.read_string_index()!
		signature: r.read_blob_index()!
		row_id:    row_idx
	}

	r.file.seek(pos, .start)!
	return r.resolve_field(raw)
}

pub fn (mut r WinMDReader) read_methoddef_entry(row_idx u32) !MethodDef {
	pos := r.file.tell()!
	offset := r.get_table_offset(.method_def)! + (u64(row_idx - 1) * 14)
	r.file.seek(i64(offset), .start)!

	raw := MethodDefRowRaw{
		rva:        r.read_u32()!
		impl_flags: r.read_u16()!
		flags:      r.read_u16()!
		name_idx:   r.read_string_index()!
		signature:  r.read_blob_index()!
		param_list: r.read_u32()!
		row_id:     row_idx
	}

	r.file.seek(pos, .start)!
	return r.resolve_methoddef(raw)
}

pub fn (mut r WinMDReader) read_param_entry(row_idx u32) !Param {
	pos := r.file.tell()!
	offset := r.get_table_offset(.param)! + (u64(row_idx - 1) * 6)
	r.file.seek(i64(offset), .start)!

	raw := ParamRowRaw{
		flags:    r.read_u32()!
		sequence: r.read_u16()!
		name_idx: r.read_string_index()!
		row_id:   row_idx
	}

	r.file.seek(pos, .start)!
	return r.resolve_param(raw)
}

pub fn (mut r WinMDReader) read_interfaceimpl_entry(row_idx u32) !InterfaceImpl {
	pos := r.file.tell()!
	offset := r.get_table_offset(.interface_impl)! + (u64(row_idx - 1) * 4)
	r.file.seek(i64(offset), .start)!

	raw := InterfaceImplRowRaw{
		class:     r.read_coded_index(.type_def_or_ref)!
		interface: r.read_coded_index(.type_def_or_ref)!
		row_id:    row_idx
	}

	r.file.seek(pos, .start)!
	return r.resolve_interfaceimpl(raw)
}

pub fn (mut r WinMDReader) read_memberref_entry(row_idx u32) !MemberRef {
	pos := r.file.tell()!
	offset := r.get_table_offset(.member_ref)! + (u64(row_idx - 1) * 6)
	r.file.seek(i64(offset), .start)!

	raw := MemberRefRowRaw{
		class:     r.read_coded_index(.member_ref_parent)!
		name_idx:  r.read_string_index()!
		signature: r.read_blob_index()!
		row_id:    row_idx
	}

	r.file.seek(pos, .start)!
	return r.resolve_memberref(raw)
}

pub fn (mut r WinMDReader) read_constant_entry(row_idx u32) !Constant {
	pos := r.file.tell()!
	offset := r.get_table_offset(.constant)! + (u64(row_idx - 1) * 8)
	r.file.seek(i64(offset), .start)!

	raw := ConstantRowRaw{
		type_:     r.read_u8()!
		padding:   r.read_u8()!
		parent:    r.read_coded_index(.has_constant)!
		value_idx: r.read_blob_index()!
		row_id:    row_idx
	}

	r.file.seek(pos, .start)!
	return r.resolve_constant(raw)
}

pub fn (mut r WinMDReader) read_customattribute_entry(row_idx u32) !CustomAttribute {
	pos := r.file.tell()!
	offset := r.get_table_offset(.custom_attribute)! + (u64(row_idx - 1) * 6)
	r.file.seek(i64(offset), .start)!

	raw := CustomAttributeRowRaw{
		parent:    r.read_coded_index(.has_custom_attribute)!
		type_:     r.read_coded_index(.custom_attribute_type)!
		value_idx: r.read_blob_index()!
		row_id:    row_idx
	}

	r.file.seek(pos, .start)!
	return r.resolve_customattribute(raw)
}

fn (mut r WinMDReader) find_type_guid_attribute(parent_idx u32, parent_type TokenType) !GUID {
    // Search CustomAttribute table in raw form
    if custom_attr_count := r.row_counts.counts[.custom_attribute] {
        for i := u32(0); i < custom_attr_count; i++ {
            raw_attr := r.read_custom_attribute_entry(i)!
            token_info := decode_token(raw_attr.parent)
            if token_info.index == parent_idx && token_info.token_type == parent_type {
                if is_guid_attribute(raw_attr, r)! {
                    return r.parse_guid_attribute(raw_attr)!
                }
            }
        }
    }
    return error('No GUID attribute found')
}

pub fn (mut r WinMDReader) read_propertymap_entry(row_idx u32) !PropertyMap {
	pos := r.file.tell()!
	offset := r.get_table_offset(.property_map)! + (u64(row_idx - 1) * 4)
	r.file.seek(i64(offset), .start)!

	raw := PropertyMapRowRaw{
		parent:        r.read_u32()!
		property_list: r.read_u32()!
		row_id:        row_idx
	}

	r.file.seek(pos, .start)!
	return r.resolve_propertymap(raw)
}

pub fn (mut r WinMDReader) read_property_entry(row_idx u32) !Property {
	pos := r.file.tell()!
	offset := r.get_table_offset(.property)! + (u64(row_idx - 1) * 6)
	r.file.seek(i64(offset), .start)!

	raw := PropertyRowRaw{
		flags:    r.read_u32()!
		name_idx: r.read_string_index()!
		type_sig: r.read_blob_index()!
		row_id:   row_idx
	}

	r.file.seek(pos, .start)!
	return r.resolve_property(raw)
}

pub fn (mut r WinMDReader) read_methodsemantics_entry(row_idx u32) !MethodSemantics {
	pos := r.file.tell()!
	offset := r.get_table_offset(.method_semantics)! + (u64(row_idx - 1) * 6)
	r.file.seek(i64(offset), .start)!

	raw := MethodSemanticsRowRaw{
		semantic:    r.read_u16()!
		method:      r.read_u32()!
		association: r.read_coded_index(.has_semantics)!
		row_id:      row_idx
	}

	r.file.seek(pos, .start)!
	return r.resolve_methodsemantics(raw)
}

pub fn (mut r WinMDReader) read_eventmap_entry(row_idx u32) !EventMap {
	pos := r.file.tell()!
	offset := r.get_table_offset(.event_map)! + (u64(row_idx - 1) * 4)
	r.file.seek(i64(offset), .start)!

	raw := EventMapRowRaw{
		parent:     r.read_u32()!
		event_list: r.read_u32()!
		row_id:     row_idx
	}

	r.file.seek(pos, .start)!
	return r.resolve_eventmap(raw)
}

pub fn (mut r WinMDReader) read_event_entry(row_idx u32) !Event {
	pos := r.file.tell()!
	offset := r.get_table_offset(.event)! + (u64(row_idx - 1) * 8)
	r.file.seek(i64(offset), .start)!

	raw := EventRowRaw{
		flags:      r.read_u32()!
		name_idx:   r.read_string_index()!
		event_type: r.read_coded_index(.type_def_or_ref)!
		row_id:     row_idx
	}

	r.file.seek(pos, .start)!
	return r.resolve_event(raw)
}

fn (mut r WinMDReader) resolve_cached_typedef(row_idx u32) !TypeDef {
	// Check cache first
	if cached := r.type_cache.typedefs[row_idx] {
		return cached
	}

	// Read and resolve
	typedef := r.read_typedef_entry(row_idx)!

	// Cache result
	r.type_cache.typedefs[row_idx] = typedef

	return typedef
}

fn (mut r WinMDReader) resolve_cached_typeref(row_idx u32) !TypeRef {
	if cached := r.type_cache.typerefs[row_idx] {
		return cached
	}

	typeref := r.read_typeref_entry(row_idx)!
	r.type_cache.typerefs[row_idx] = typeref

	return typeref
}

fn (mut r WinMDReader) resolve_generic_type(sig_blob u32) !TypeSig {
	blob := r.get_blob(sig_blob)!
	mut decoder := new_sig_decoder(blob, r)

	// Read element type
	element_type := unsafe { ElementType(decoder.read_u8()!) }

	mut sig := TypeSig{
		element_type: element_type
	}

	match element_type {
		.generic_inst {
			// Read generic type def/ref
			type_token := decoder.read_compressed_uint()!
			base_type := r.resolve_typedefref(type_token)!

			sig.type_ref = base_type

			// Read type arguments
			arg_count := decoder.read_compressed_uint()!
			for _ in 0 .. arg_count {
				arg := r.resolve_generic_type(sig_blob)!
				sig.generic_args << arg
			}
		}
		.class, .valuetype {
			type_token := decoder.read_compressed_uint()!
			sig.type_ref = r.resolve_typedefref(type_token)!
		}
		else {}
	}

	return sig
}

fn (mut r WinMDReader) get_type_hierarchy(type_def TypeDef) ![]TypeDef {
	mut hierarchy := []TypeDef{}
	mut current := type_def

	for {
		hierarchy << current

		if current.extends == 0 {
			break
		}

		// Resolve base type
		base_type := r.resolve_typedefref(current.extends)!
		base_def := r.find_typedef(base_type.name, base_type.namespace)!
		current = base_def
	}

	return hierarchy
}

fn (g &CodeGenerator) map_complex_type(sig TypeSig) !string {
	match sig.element_type {
		.generic_inst {
			if type_ref := sig.type_ref {
				base_name := g.map_type('${type_ref.namespace}.${type_ref.name}')

				if sig.generic_args.len > 0 {
					mut args := ''
					for i, arg in sig.generic_args {
						if i > 0 {
							args += ', '
						}
						args += g.map_complex_type(arg)!
					}
					return '${base_name}<${args}>'
				}
				return base_name
			}
		}
		.szarray {
			if base := sig.type_ref {
				base_type := g.map_complex_type(TypeSig{
					element_type: .class
					type_ref:     base
				})!
				return '[]${base_type}'
			}
		}
		else {
			if type_ref := sig.type_ref {
				return g.map_type('${type_ref.namespace}.${type_ref.name}')
			}

			// Map primitive types
			return match sig.element_type {
				.boolean { 'bool' }
				.char { 'rune' }
				.i1 { 'i8' }
				.u1 { 'u8' }
				.i2 { 'i16' }
				.u2 { 'u16' }
				.i4 { 'int' }
				.u4 { 'u32' }
				.i8 { 'i64' }
				.u8 { 'u64' }
				.r4 { 'f32' }
				.r8 { 'f64' }
				.string { 'string' }
				else { 'voidptr' }
			}
		}
	}
	return 'voidptr' // Default case
}

fn validate_generated_code(code string) ! {
	if code.len == 0 {
		return error('Generated code is empty')
	}

	// Basic syntax validation
	braces := 0
	for c in code {
		if c == `{` {
			braces++
		}
		if c == `}` {
			braces--
		}
		if braces < 0 {
			return error('Mismatched braces in generated code')
		}
	}
	if braces != 0 {
		return error('Unclosed braces in generated code')
	}
}

fn (mut g CodeGenerator) organize_interface_methods(methods []MethodDef) ![]MethodDef {
	mut ordered := methods.clone()

	// Sort by name for consistency
	ordered.sort_by_key(it.name)

	// Group getters/setters
	mut property_methods := map[string][]MethodDef{}
	mut other_methods := []MethodDef{}

	for method in ordered {
		if method.name.starts_with('get_') || method.name.starts_with('set_') {
			prop_name := method.name[4..] // Remove get_/set_ prefix
			property_methods[prop_name] << method
		} else {
			other_methods << method
		}
	}

	// Rebuild ordered list with properties together
	ordered.clear()
	for _, prop_methods in property_methods {
		ordered << prop_methods
	}
	ordered << other_methods

	return ordered
}
