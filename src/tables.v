module main

// When viewing tables in ILSpy, you can see a rid, token and offset
// column.

// 0x00
// ✅Layout verified
struct Module {
	rid    u32
	token  u32
	offset int

	// Generation (a 2-byte value, reserved, shall be zero)
	generation u32
	// Name (an index into the String heap)
	name u32
	// Mvid (an index into the Guid heap; simply a Guid used to distinguish between two versions of the same module)
	mvid u32
	// EncId (an index into the Guid heap; reserved, shall be zero)
	enc_id u32
	// EncBaseId (an index into the Guid heap; reserved, shall be zero)
	enc_base_id u32
}

@[inline]
fn Module.row_size(tables TablesStream) u32 {
	generation_size := u32(2)

	name_size := if tables.heap_sizes.has(.strings) { u32(4) } else { 2 }

	mvid_size := if tables.heap_sizes.has(.guid) { u32(4) } else { 2 }

	enc_id_size := if tables.heap_sizes.has(.guid) { u32(4) } else { 2 }

	enc_base_id_size := if tables.heap_sizes.has(.guid) { u32(4) } else { 2 }

	return generation_size + name_size + mvid_size + enc_id_size + enc_base_id_size
}

// 0x01
// ✅Layout verified
struct TypeRef {
	rid    u32
	token  u32
	offset int

	// ResolutionScope (an index into a Module, ModuleRef, AssemblyRef or TypeRef table, or null; more precisely, a ResolutionScope (§II.24.2.6) coded index)
	resolution_scope u32
	// TypeName (an index into the String heap)
	name u32
	// TypeNamespace (an index into the String heap)
	namespace u32
}

pub fn (td TypeRef) str() string {
	return 'TypeRef{\n\t${td.rid.hex_full()} rid\n\t${td.offset.hex_full()} offset\n\t${td.token.hex_full()} token\n\t${td.resolution_scope.hex_full()} resolution_scope\n\t${td.name.hex_full()} name\n\t${td.namespace.hex_full()} namespace\n}'
}

@[inline]
fn TypeRef.row_size(tables TablesStream) u32 {
	resolution_scope_size := get_resolution_scope_size(tables)

	name_size := if tables.heap_sizes.has(.strings) { u32(4) } else { 2 }

	namespace_size := if tables.heap_sizes.has(.strings) { u32(4) } else { 2 }

	return resolution_scope_size + name_size + namespace_size
}

// 0x02
// ✅Layout verified
struct TypeDef {
	rid    u32
	token  u32
	offset int

	// Flags (a 4-byte bitmask of type TypeAttributes, §II.23.1.15)
	flags u32
	// TypeName (an index into the String heap)
	name u32
	// TypeNamespace (an index into the String heap)
	namespace u32
	// Extends (an index into the TypeDef, TypeRef, or TypeSpec table; more precisely, a TypeDefOrRef (§II.24.2.6) coded index)
	base_type u32
	// FieldList (an index into the Field table; it marks the first of a contiguous run of Fields owned by this Type). The run continues to the smaller of:
	// - the last row of the Field table
	// - the next run of Fields, found by inspecting the FieldList of the next row in this TypeDef table
	field_list u32
	// MethodList (an index into the MethodDef table; it marks the first of a continguous run of Methods owned by this Type). The run continues to the smaller of:
	// - the last row of the MethodDef table
	// - the next run of Methods, found by inspecting the MethodList of the next row in this TypeDef table
	// The first row of the TypeDef table represents the pseudo class that acts as parent for functions and variables defined at module scope.
	method_list u32
}

pub fn (td TypeDef) str() string {
	return 'TypeDef{\n\t${td.rid.hex_full()} rid\n\t${td.offset.hex_full()} offset\n\t${td.token.hex_full()} token\n\t${td.flags.hex_full()} flags\n\t${td.name.hex_full()} name\n\t${td.namespace.hex_full()} namespace\n\t${td.base_type.hex_full()} base_type\n\t${td.field_list.hex_full()} field_list\n\t${td.method_list.hex_full()} method_list\n}'
}

@[inline]
fn TypeDef.row_size(tables TablesStream) u32 {
	flags_size := u32(4)

	name_size := if tables.heap_sizes.has(.strings) { u32(4) } else { 2 }

	namespace_size := if tables.heap_sizes.has(.strings) { u32(4) } else { 2 }

	base_type_size := get_type_def_or_ref_size(tables)

	field_list_size := if tables.num_rows[.field] > 0xFFFF { u32(4) } else { 2 }

	method_list_size := if tables.num_rows[.method_def] > 0xFFFF { u32(4) } else { 2 }

	return flags_size + name_size + namespace_size + base_type_size + field_list_size +
		method_list_size
}

// 0x03 FieldPtr is unused

// 0x04
// ✅Layout verified
struct Field {
	rid    u32
	token  u32
	offset int

	// Flags (a 2-byte bitmask of type FieldAttributes, II.23.1.5)
	flags u32
	// Name (an index into the String heap)
	name u32
	// Signature (an index into the Blob heap)
	//  * _FieldSig_
	signature u32
}

@[inline]
fn Field.row_size(tables TablesStream) u32 {
	flags_size := u32(2)

	name_size := if tables.heap_sizes.has(.strings) { u32(4) } else { 2 }

	signature_size := if tables.heap_sizes.has(.blob) { u32(4) } else { 2 }

	return flags_size + name_size + signature_size
}

// 0x05 MethodPtr is unused

// 0x06
// ✅Layout verified
struct MethodDef {
	rid    u32
	token  u32
	offset int

	// RVA (a 4-byte constant)
	rva u32
	// ImplFlags (a 2-byte bitmask of type MethodImplAttributes, §II.23.1.11)
	impl_flags u32
	// Flags (a 2-byte bitmask of type MethodAttributes, §II.23.1.10)
	flags u32
	// Name (an index into the String heap)
	name u32
	// Signature (an index into the Blob heap)
	//  * _MethodDefSig_
	signature u32
	// ParamList (an index into the Param table). It marks the first of a contiguous run of Parameters owned by this method. The run continues to the smaller of:
	// - the last row of the Param table
	// - the next run of Parameters, found by inspecting the ParamList of the next row in the MethodDef table
	param_list u32
}

pub fn (td MethodDef) str() string {
	return 'MethodDef{\n\t${td.rid.hex_full()} rid\n\t${td.offset.hex_full()} offset\n\t${td.token.hex_full()} token\n\t${td.rva.hex_full()} rva\n\t${td.impl_flags.hex_full()} impl_flags\n\t${td.flags.hex_full()} flags\n\t${td.name.hex_full()} name\n\t${td.signature.hex_full()} signature\n\t${td.param_list.hex_full()} param_list\n}'
}

@[inline]
fn MethodDef.row_size(tables TablesStream) u32 {
	rva_size := u32(4)

	impl_flags_size := u32(2)

	flags_size := u32(2)

	name_size := if tables.heap_sizes.has(.strings) { u32(4) } else { 2 }

	signature_size := if tables.heap_sizes.has(.blob) { u32(4) } else { 2 }

	param_list_size := if tables.num_rows[.param] > 0xFFFF { u32(4) } else { 2 }

	return rva_size + impl_flags_size + flags_size + name_size + signature_size + param_list_size
}

// 0x07 ParamPtr is unused

// 0x08
// ✅Layout verified
struct Param {
	rid    u32
	token  u32
	offset int

	// Flags a (2-byte bitmask of type ParamAttributes, §II.23.1.13)
	flags u32
	// Sequence (a 2-byte constant)
	sequence u32
	// Name (an index into the String heap)
	name u32
}

@[inline]
fn Param.row_size(tables TablesStream) u32 {
	flags_size := u32(2)

	sequence_size := u32(2)

	name_size := if tables.heap_sizes.has(.strings) { u32(4) } else { 2 }

	return flags_size + sequence_size + name_size
}

// 0x09
// ✅Layout verified
struct InterfaceImpl {
	rid    u32
	token  u32
	offset int

	// Class (an index into the _TypeDef_ table)
	class u32
	// Interface (an index into the TypeDef, TypeRef, or TypeSpec table; more precisely, a TypeDefOrRef (§II.24.2.6) coded index)
	interface u32
}

@[inline]
fn InterfaceImpl.row_size(tables TablesStream) u32 {
	class_size := if tables.num_rows[.type_def] > 0xFFFF { u32(4) } else { 2 }

	interface_size := get_type_def_or_ref_size(tables)

	return class_size + interface_size
}

// 0x0A
// ✅Layout verified
struct MemberRef {
	rid    u32
	token  u32
	offset int

	// Class (an index into the MethodDef, ModuleRef, TypeDef, TypeRef, or TypeSpec tables; more precisely, a _MemberRefParent_ (§[II.24.2.6](ii.24.2.6-metadata-stream.md)) coded index)
	parent u32
	// Name (an index into the String heap)
	name u32
	// Signature (an index into the Blob heap)
	// * _MethodRefSig_ (differs from a _MethodDefSig_ only for `VARARG` calls)
	signature u32
}

@[inline]
fn MemberRef.row_size(tables TablesStream) u32 {
	parent_size := get_member_ref_parent_size(tables)

	name_size := if tables.heap_sizes.has(.strings) { u32(4) } else { 2 }

	signature_size := if tables.heap_sizes.has(.blob) { u32(4) } else { 2 }

	return parent_size + name_size + signature_size
}

// 0x0B
// ✅Layout verified
// 1. Type shall be exactly one of:
// 		- ELEMENT_TYPE_BOOLEAN
// 		- ELEMENT_TYPE_CHAR
// 		- ELEMENT_TYPE_I1
// 		- ELEMENT_TYPE_U1
// 		- ELEMENT_TYPE_I2
// 		- ELEMENT_TYPE_U2
// 		- ELEMENT_TYPE_I4
// 		- ELEMENT_TYPE_U4
// 		- ELEMENT_TYPE_I8
// 		- ELEMENT_TYPE_U8
// 		- ELEMENT_TYPE_R4
// 		- ELEMENT_TYPE_R8
// 		- ELEMENT_TYPE_STRING;
// 		OR
// 		- ELEMENT_TYPE_CLASS with a Value of zero  (§II.23.1.16) [ERROR]
// 2. Type shall not be any of: ELEMENT_TYPE_I1, ELEMENT_TYPE_U2, ELEMENT_TYPE_U4, or ELEMENT_TYPE_U8 (§II.23.1.16)  [CLS]
// 3. Parent shall index a valid row in the Field, Property, or Param table.  [ERROR]
// 4. There shall be no duplicate rows, based upon Parent  [ERROR]
// 5. Type shall match exactly the declared type of the Param, Field, or Property identified by Parent (in the case where the parent is an enum, it shall match exactly the underlying type of that enum).  [CLS]
struct Constant {
	rid    u32
	token  u32
	offset int

	// Type is a 1-byte constant, followed by a 1-byte padding zero; see §II.23.1.16.
	// The encoding of Type for the nullref value for FieldInit in ilasm (§II.16.2) is
	// ELEMENT_TYPE_CLASS with a Value of a 4-byte zero. Unlike uses of
	// ELEMENT_TYPE_CLASS in signatures, this one is not followed by a type token.
	type u32

	// Parent is an index into the Param, Field, or Property table;
	// more precisely, a HasConstant (§II.24.2.6) coded index
	parent u32

	// Value is an index into the Blob heap
	value u32
}

fn Constant.new(winmd_bytes []u8, pos int, tables TablesStream) Constant {
	return Constant{}
}

@[inline]
fn Constant.row_size(tables TablesStream) u32 {
	type_size := u32(2)

	parent_size := get_has_constant_size(tables)

	value_size := if tables.heap_sizes.has(.strings) { u32(4) } else { 2 }

	return type_size + parent_size + value_size
}

fn (c Constant) resolve(winmd_bytes []u8, stream TablesStream) {
	match c.type {
		0x00 { '' } // ELEMENT_TYPE_END
		0x01 { '' } // ELEMENT_TYPE_VOID
		0x02 { 'bool' } // ELEMENT_TYPE_BOOLEAN
		0x03 { 'u8' } // ELEMENT_TYPE_CHAR
		0x04 { 'i8' } // ELEMENT_TYPE_I1
		0x05 { 'u8' } // ELEMENT_TYPE_U1
		0x06 { 'i16' } // ELEMENT_TYPE_I2
		0x07 { 'u16' } // ELEMENT_TYPE_U2
		0x08 { 'i32' } // ELEMENT_TYPE_I4
		0x09 { 'u32' } // ELEMENT_TYPE_U4
		0x0A { 'i64' } // ELEMENT_TYPE_I8
		0x0B { 'u64' } // ELEMENT_TYPE_U8
		0x0C { 'f32' } // ELEMENT_TYPE_R4 (R meaning Real)
		0x0D { 'f64' } // ELEMENT_TYPE_R8
		0x0E { 'string' } // ELEMENT_TYPE_STRING
		0x0F { 'voidptr' } // ELEMENT_TYPE_PTR, followed by type
		0x10 { '&' } // ELEMENT_TYPE_BYREF, followed by type
		0x11 { '' } // ELEMENT_TYPE_VALUETYPE, followed by TypeDef or TypeRef token
		0x12 { '' } // ELEMENT_TYPE_CLASS, followed by TypeDef or TypeRef token
		0x13 { '' } // ELEMENT_TYPE_VAR, Generic parameter in a generic type definition, represented as number (compressed unsigned integer)
		0x14 { '' } // ELEMENT_TYPE_ARRAY
		0x15 { '' } // ELEMENT_TYPE_GENERICINST
		0x16 { '' } // ELEMENT_TYPE_TYPEDBYREF
		// 0x17 not defined
		0x18 { '' } // ELEMENT_TYPE_I, System.IntPtr
		0x19 { '' } // ELEMENT_TYPE_U, System.UIntPtr
		// 0x1A not defined
		0x1B { '' } // ELEMENT_TYPE_FNPTR, followed by full method signature
		0x1C { '' } // ELEMENT_TYPE_OBJECT, System.Object
		0x1D { '' } // ELEMENT_TYPE_SZARRAY, single-dimension array with 0 lower bound
		0x1E { '' } // ELEMENT_TYPE_MVAR, Generic parameter in a generic type definition, represented as number (compressed unsigned integer)
		0x1F { '' } // ELEMENT_TYPE_CMOD_REQD, Required modifier; followed by a TypeDef or TypeRef token
		0x20 { '' } // ELEMENT_TYPE_CMOD_OPT, Optional modifier; followed by a TypeDef or TypeRef token
		0x21 { '' } // ELEMENT_TYPE_INTERNAL, Implemented within the CLI
		// 0x22..0x3F not defined
		0x40 { '' } // ELEMENT_TYPE_MODIFIER, Or'd with following element types
		0x41 { '' } // ELEMENT_TYPE_SENTINEL, Sentinel for vararg method signature
		0x45 { '' } // ELEMENT_TYPE_PINNED, Denotes a local variable that points at a pinned object
		0x50 { '' } // Indicates an argument of type System.Type
		0x51 { '' } // Used in custom attributes to specify a boxed object (§II.23.3)
		// 0x52 Reserved
		0x53 { '' } // Used in custom attributes to specify a FIELD (§II.23.3)
		0x54 { '' } // Used in custom attributes to indicate a PROPERTY (§II.22.10, II.23.3)
		0x55 { '' } // Used in custom attributes to specify an enum (§II.23.3)
		else { '' }
	}
}

// 0x0C
// ✅Layout verified
struct CustomAttribute {
	rid    u32
	token  u32
	offset int

	// _Parent_ (an index into a metadata table that has an associated _HasCustomAttribute_ (§[II.24.2.6](ii.24.2.6-metadata-stream.md)) coded index).
	parent u32
	// _Type_ (an index into the _MethodDef_ or _MemberRef_ table; more precisely, a _CustomAttributeType_ (§[II.24.2.6](ii.24.2.6-metadata-stream.md)) coded index).
	constructor u32
	// Value (Index into the blob heap)
	value u32
}

@[inline]
fn CustomAttribute.row_size(tables TablesStream) u32 {
	parent_size := get_has_custom_attribute_size(tables)

	constructor_size := get_custom_attribute_type_size(tables)

	value_size := if tables.heap_sizes.has(.blob) { u32(4) } else { 2 }

	return parent_size + constructor_size + value_size
}

// 0x0D
// ⚠️Layout not verified - struct generated by copilot
struct FieldMarshal {
	rid    u32
	token  u32
	offset int

	parent      u32
	native_type u32
}

@[inline]
fn FieldMarshal.row_size(tables TablesStream) u32 {
	parent_size := get_has_decl_security_size(tables)

	native_type_size := if tables.heap_sizes.has(.blob) { u32(4) } else { 2 }

	return parent_size + native_type_size
}

// 0x0E
// ⚠️Layout not verified - struct generated by copilot
struct DeclSecurity {
	rid    u32
	token  u32
	offset int

	action         u32
	parent         u32
	permission_set u32
}

@[inline]
fn DeclSecurity.row_size(tables TablesStream) u32 {
	action_size := u32(2)

	parent_size := get_has_decl_security_size(tables)

	permission_set_size := if tables.heap_sizes.has(.blob) { u32(4) } else { 2 }
	return action_size + parent_size + permission_set_size
}

// 0x0F
// ✅Layout verified
//
// 1. A ClassLayout table can contain zero or more rows
// 2. Parent shall index a valid row in the TypeDef table, corresponding to a Class or ValueType (but not to an Interface)  [ERROR]
// 3. The Class or ValueType indexed by Parent shall be SequentialLayout or ExplicitLayout (§II.23.1.15). (That is, AutoLayout types shall not own any rows in the ClassLayout table.) [ERROR]
// 4. If Parent indexes a SequentialLayout type, then:
// 	- PackingSize shall be one of {0, 1, 2, 4, 8, 16, 32, 64, 128}.  (0 means use the default pack size for the platform on which the application is running.)  [ERROR]
// 	- If Parent indexes a ValueType, then ClassSize shall be less than 1 MByte 0x100000 bytes).  [ERROR]
// 5. If Parent indexes an ExplicitLayout type, then
// 	- if Parent indexes a ValueType, then ClassSize shall be less than 1 MByte (0x100000 bytes)  [ERROR]
// 	- PackingSize shall be 0. (It makes no sense to provide explicit offsets for each field, as well as a packing size.)  [ERROR]
// 6. Note that an ExplicitLayout type might result in a verifiable type, provided the layout does not create a type whose fields overlap.
// 7. Layout along the length of an inheritance chain shall follow the rules specified above (starting at ‘highest’ Type, with no ‘holes’, etc.) [ERROR]
struct ClassLayout {
	rid    u32
	token  u32
	offset int

	// An index into the TypeDef table
	parent u32
	// A 2-byte constant.
	packing_size u16
	// A 4-byte constant.
	// ClassSize of zero does not mean the class has zero size. It means that no .size directive was specified
	// at definition time, in which case, the actual size is calculated from the field types, taking account of
	// packing size (default or specified) and natural alignment on the target, runtime platform.
	class_size u32
}

@[inline]
fn ClassLayout.row_size(tables TablesStream) u32 {
	parent_size := if tables.num_rows[.type_def] > 0xFFFF { u32(4) } else { 2 }

	packing_size_size := u32(2)

	class_size_size := u32(4)

	return parent_size + packing_size_size + class_size_size
}

// 0x10
// ✅Layout verified
struct FieldLayout {
	rid    u32
	token  u32
	offset int

	// _Field_ (an index into the _Field_ table)
	field u32
	// _Offset_ (a 4-byte constant)
	field_offset u32
}

@[inline]
fn FieldLayout.row_size(tables TablesStream) u32 {
	field_size := u32(4)

	field_offset_size := if tables.num_rows[.field] > 0x4000 { u32(4) } else { 2 }

	return field_size + field_offset_size
}

// 0x11
// ⚠️Layout not verified - struct generated by copilot
struct StandAloneSig {
	rid    u32
	token  u32
	offset int

	//  * _LocalVarSig_
	signature u32
}

@[inline]
fn StandAloneSig.row_size(tables TablesStream) u32 {
	signature_size := if tables.heap_sizes.has(.blob) { u32(4) } else { 2 }

	return signature_size
}

// 0x12
// ✅Layout verified
struct EventMap {
	rid    u32
	token  u32
	offset int

	parent     u32
	event_list u32
}

@[inline]
fn EventMap.row_size(tables TablesStream) u32 {
	parent_size := if tables.num_rows[.type_def] > 0xFFFF { u32(4) } else { 2 }

	event_list_size := if tables.num_rows[.event] > 0xFFFF { u32(4) } else { 2 }

	return parent_size + event_list_size
}

// 0x13 EventPtr is unused

// 0x14
// ✅Layout verified
struct Event {
	rid    u32
	token  u32
	offset int

	flags u32
	name  u32
	type  u32
}

@[inline]
fn Event.row_size(tables TablesStream) u32 {
	flags_size := u32(2)

	name_size := if tables.heap_sizes.has(.strings) { u32(4) } else { 2 }

	type_size := get_type_def_or_ref_size(tables)

	return flags_size + name_size + type_size
}

// 0x15
// ✅Layout verified
struct PropertyMap {
	rid    u32
	token  u32
	offset int

	// _Parent_ (an index into the _TypeDef_ table)
	parent u32
	// _PropertyList_ (an index into the _Property_ table). It marks the first of a contiguous run of Properties owned by _Parent_. The run continues to the smaller of:
	// - the last row of the _Property_ table
	// - the next run of Properties, found by inspecting the _PropertyList_ of the next row in this _PropertyMap_ table
	property_list u32
}

@[inline]
fn PropertyMap.row_size(tables TablesStream) u32 {
	parent_size := if tables.num_rows[.type_def] > 0xFFFF { u32(4) } else { 2 }

	property_list_size := if tables.num_rows[.property] > 0x4000 { u32(4) } else { 2 }

	return parent_size + property_list_size
}

// 0x16 PropertyPtr is unused

// 0x17
// ✅Layout verified
struct Property {
	rid    u32
	token  u32
	offset int

	// Flags (a 2-byte bitmask of type PropertyAttributes, §II.23.1.14)
	flags u32
	// Name (an index into the String heap)
	name u32
	// Type (an index into the Blob heap) (The name of this column is misleading. It does not index a TypeDef or TypeRef table—instead it indexes the signature in the Blob heap of the Property)
	//  * _PropertySig_
	signature u32
}

@[inline]
fn Property.row_size(tables TablesStream) u32 {
	flags_size := u32(2)

	name_size := if tables.heap_sizes.has(.strings) { u32(4) } else { 2 }

	signature_size := if tables.heap_sizes.has(.blob) { u32(4) } else { 2 }

	return flags_size + name_size + signature_size
}

// 0x18
// ✅Layout verified
struct MethodSemantics {
	rid    u32
	token  u32
	offset int

	// Semantics (a 2-byte bitmask of type MethodSemanticsAttributes, §II.23.1.12)
	semantics u32
	// Method (an index into the MethodDef table)
	method u32
	// Association (an index into the Event or Property table; more precisely, a HasSemantics (§II.24.2.6) coded index)
	association u32
}

@[inline]
fn MethodSemantics.row_size(tables TablesStream) u32 {
	semantics_size := u32(2)

	method_size := if tables.num_rows[.method_def] > 0xFFFF { u32(4) } else { 2 }

	association_size := get_has_semantics_size(tables)

	return semantics_size + method_size + association_size
}

// 0x19
// ✅Layout verified
struct MethodImpl {
	rid    u32
	token  u32
	offset int

	// MethodDeclaration (an index into the MethodDef or MemberRef table; more precisely, a MethodDefOrRef (§II.24.2.6) coded index)
	method_declaration u32
	// MethodBody (an index into the MethodDef or MemberRef table; more precisely, a MethodDefOrRef (§II.24.2.6) coded index)
	method_body u32
	// Class (an index into the TypeDef table)
	class u32
}

@[inline]
fn MethodImpl.row_size(tables TablesStream) u32 {
	method_declaration_size := get_method_def_or_ref_size(tables)

	method_body_size := get_method_def_or_ref_size(tables)

	class_size := if tables.num_rows[.type_def] > 0xFFFF { u32(4) } else { 2 }

	return method_declaration_size + method_body_size + class_size
}

// 0x1A
// ✅Layout verified
struct ModuleRef {
	rid    u32
	token  u32
	offset int

	// Name (an index into the String heap)
	name u32
}

@[inline]
fn ModuleRef.row_size(tables TablesStream) u32 {
	name_size := if tables.heap_sizes.has(.strings) { u32(4) } else { 2 }

	return name_size
}

// 0x1B
// ✅Layout verified
struct TypeSpec {
	rid    u32
	token  u32
	offset int

	//  * _Signature_ (index into the Blob heap, where the blob is formatted as specified in §[II.23.2.14](ii.23.2.14-typespec.md))
	//  * _TypeSpec_
	signature u32
}

@[inline]
fn TypeSpec.row_size(tables TablesStream) u32 {
	signature_size := if tables.heap_sizes.has(.blob) { u32(4) } else { 2 }

	return signature_size
}

// 0x1C
// ✅Layout verified
struct ImplMap {
	rid    u32
	token  u32
	offset int

	// _MappingFlags_ (a 2-byte bitmask of type _PInvokeAttributes_, §[23.1.8](#todo-missing-hyperlink))
	mapping_flags u32
	// _MemberForwarded_ (an index into the _Field_ or _MethodDef_ table; more precisely, a _MemberForwarded_  (§[II.24.2.6](ii.24.2.6-metadata-stream.md)) coded index). However, it only ever indexes the _MethodDef_ table, since _Field_ export is not supported.
	member_forwarded u32
	// _ImportName_ (an index into the String heap)
	import_name u32
	// _ImportScope_ (an index into the _ModuleRef_ table)
	import_scope u32
}

@[inline]
fn ImplMap.row_size(tables TablesStream) u32 {
	mapping_flags_size := u32(2)

	member_forwarded_size := get_member_forwarded_size(tables)

	import_name_size := if tables.heap_sizes.has(.strings) { u32(4) } else { 2 }

	import_scope_size := if tables.num_rows[.module_ref] > 0xFFFF { u32(4) } else { 2 }

	return mapping_flags_size + member_forwarded_size + import_name_size + import_scope_size
}

// 0x1D
// ⚠️Layout not verified - struct generated by copilot
struct FieldRVA {
	rid    u32
	token  u32
	offset int

	// _RVA_ (a 4-byte constant)
	rva u32
	// _Field_ (an index into _Field_ table)
	field u32
}

@[inline]
fn FieldRVA.row_size(tables TablesStream) u32 {
	return 8
}

// 0x1E Edit-and-continue log is unused

// 0x1F Edit-and-continue mapping is unused

// 0x20
// ✅Layout verified
struct Assembly {
	rid    u32
	token  u32
	offset int

	// HashAlgId is a 4-byte constant of type AssemblyHashAlgorithm, §II.23.1.1
	hash_algorithm u32

	// Flags is a 4-byte bitmask of type AssemblyFlags, §II.23.1.2
	// (0x0001) PublicKey
	// (0x0010) Retargetable
	// (0x0100) DisableJITcompileOptimizer
	// (0x1000) EnableJITcompileTracking
	flags u32

	// MajorVersion, MinorVersion, BuildNumber, RevisionNumber (each being 2-byte constants)
	version u64

	// Name is an index into the String heap
	name u32

	// Culture is an index into the String heap. List of valid values are found in II.23.1.3.
	// Note on RFC 1766, Locale names: a typical string would be “en-US”.  The first part (“en” in the
	// example) uses ISO 639 characters (“Latin-alphabet characters in lowercase.  No diacritical marks of
	// modified characters are used”).  The second part (“US” in the example) uses ISO 3166 characters
	// (similar to ISO 639, but uppercase); that is, the familiar ASCII characters a–z and A–Z, respectively.
	// However, whilst RFC 1766 recommends the first part be lowercase and the second part be uppercase, it
	// allows mixed case.  Therefore,  the validation rule checks only that Culture is one of the strings in the
	// list above—but the check is totally case-blind—where case-blind is the familiar fold on values less than
	// U+0080
	culture u32
}

@[inline]
fn Assembly.row_size(tables TablesStream) u32 {
	hash_algorithm_size := u32(4)

	flags_size := u32(4)

	version_size := u32(8)

	name_size := if tables.heap_sizes.has(.strings) { u32(4) } else { 2 }

	culture_size := if tables.heap_sizes.has(.strings) { u32(4) } else { 2 }

	return hash_algorithm_size + flags_size + version_size + name_size + culture_size
}

// 0x21
// ⚠️Layout not verified - struct generated by copilot
struct AssemblyProcessor {
	rid    u32
	token  u32
	offset int

	processor u32
}

@[inline]
fn AssemblyProcessor.row_size(tables TablesStream) u32 {
	return 4
}

// 0x22
// ⚠️Layout not verified - struct generated by copilot
struct AssemblyOS {
	rid    u32
	token  u32
	offset int

	os_platform_id   u32
	os_major_version u32
	os_minor_version u32
}

@[inline]
fn AssemblyOS.row_size(tables TablesStream) u32 {
	return 12
}

// 0x23
// ✅Layout verified
struct AssemblyRef {
	rid    u32
	token  u32
	offset int

	// _MajorVersion_, _MinorVersion_, _BuildNumber_, _RevisionNumber_ (each being 2-byte constants)
	version u64
	// _Flags_ (a 4-byte bitmask of type _AssemblyFlags_, §[II.23.1.2](ii.23.1.2-values-for-assemblyflags.md))
	flags u32
	// _PublicKeyOrToken_ (an index into the Blob heap, indicating the public key or token that identifies the author of this Assembly)
	public_key_or_token u32
	// _Name_ (an index into the String heap)
	name u32
	// _Name_ (an index into the String heap)
	culture u32
	// _HashValue_ (an index into the String heap)
	hash_value u32
}

@[inline]
fn AssemblyRef.row_size(tables TablesStream) u32 {
	version_size := u32(8)

	flags_size := u32(4)

	public_key_or_token_size := if tables.heap_sizes.has(.blob) { u32(4) } else { 2 }

	name_size := if tables.heap_sizes.has(.strings) { u32(4) } else { 2 }

	culture_size := if tables.heap_sizes.has(.strings) { u32(4) } else { 2 }

	hash_value_size := if tables.heap_sizes.has(.strings) { u32(4) } else { 2 }

	return version_size + flags_size + public_key_or_token_size + name_size + culture_size +
		hash_value_size
}

// 0x24
// ⚠️Layout not verified - struct generated by copilot
struct AssemblyRefProcessor {
	rid    u32
	token  u32
	offset int

	processor    u32
	assembly_ref u32
}

@[inline]
fn AssemblyRefProcessor.row_size(tables TablesStream) u32 {
	processor_size := u32(4)

	assembly_ref_size := if tables.num_rows[.assembly_ref] > 0xFFFF { u32(4) } else { 2 }

	return processor_size + assembly_ref_size
}

// 0x25
// ⚠️Layout not verified - struct generated by copilot
struct AssemblyRefOS {
	rid    u32
	token  u32
	offset int

	os_platform_id   u32
	os_major_version u32
	os_minor_version u32
	assembly_ref     u32
}

@[inline]
fn AssemblyRefOS.row_size(tables TablesStream) u32 {
	os_platform_id_size := u32(4)

	os_major_version := u32(4)

	os_minor_version := u32(4)

	assembly_ref := if tables.num_rows[.assembly_ref] > 0xFFFF { u32(4) } else { 2 }

	return os_platform_id_size + os_major_version + os_minor_version + assembly_ref
}

// 0x26
// ⚠️Layout not verified - struct generated by copilot
struct File {
	rid    u32
	token  u32
	offset int

	flags      u32
	name       u32
	hash_value u32
}

@[inline]
fn File.row_size(tables TablesStream) u32 {
	flags_size := u32(4)

	name_size := if tables.heap_sizes.has(.strings) { u32(4) } else { 2 }

	hash_value_size := if tables.heap_sizes.has(.blob) { u32(4) } else { 2 }

	return flags_size + name_size + hash_value_size
}

// 0x27
// ⚠️Layout not verified - struct generated by copilot
struct ExportedType {
	rid    u32
	token  u32
	offset int

	flags          u32
	type_def_id    u32
	name           u32
	namespace      u32
	implementation u32
}

@[inline]
fn ExportedType.row_size(tables TablesStream) u32 {
	flags_size := u32(4)

	type_def_id_size := u32(4)

	name_size := if tables.heap_sizes.has(.strings) { u32(4) } else { 2 }

	namespace_size := if tables.heap_sizes.has(.strings) { u32(4) } else { 2 }

	implementation_size := get_implementation_size(tables)

	return flags_size + type_def_id_size + name_size + namespace_size + implementation_size
}

// 0x28
// ⚠️Layout not verified - struct generated by copilot
struct ManifestResource {
	rid    u32
	token  u32
	offset int

	flags          u32
	name           u32
	implementation u32
}

@[inline]
fn ManifestResource.row_size(tables TablesStream) u32 {
	flags_size := u32(4)

	name_size := if tables.heap_sizes.has(.strings) { u32(4) } else { 2 }

	implementation_size := get_implementation_size(tables)

	return flags_size + name_size + implementation_size
}

// 0x29
// ✅Layout verified
struct NestedClass {
	rid    u32
	token  u32
	offset int

	// _NestedClass_ (an index into the _TypeDef_ table)
	nested_class u32
	// _EnclosingClass_ (an index into the _TypeDef_ table)
	enclosing_class u32
}

@[inline]
fn NestedClass.row_size(tables TablesStream) u32 {
	nested_class_size := if tables.num_rows[.type_def] > 0xFFFF { u32(4) } else { 2 }

	enclosing_class_size := if tables.num_rows[.type_def] > 0xFFFF { u32(4) } else { 2 }

	return nested_class_size + enclosing_class_size
}

// 0x2A
// ⚠️Layout not verified - struct generated by copilot
struct GenericParam {
	rid    u32
	token  u32
	offset int

	// _Number_ (the 2-byte index of the generic parameter, numbered left-to-right, from zero)
	number u32
	// _Flags_ (a 2-byte bitmask of type _GenericParamAttributes_, §[II.23.1.7](ii.23.1.7-flags-for-generic-parameters-genericparamattributes.md))
	flags u32
	// _Owner_ (an index into the _TypeDef_ or _MethodDef_ table, specifying the Type or Method to which this generic parameter applies; more precisely, a _TypeOrMethodDef_ (§[II.24.2.6](ii.24.2.6-metadata-stream.md)) coded index)
	owner u32
	// _Name_ (a non-null index into the String heap, giving the name for the generic parameter. This is purely descriptive and is used only by source language compilers and by Reflection)
	name u32
}

@[inline]
fn GenericParam.row_size(tables TablesStream) u32 {
	number_size := u32(2)

	flags_size := u32(2)

	owner_size := get_type_or_method_def_size(tables)

	name_size := if tables.heap_sizes.has(.strings) { u32(4) } else { 2 }

	return number_size + flags_size + owner_size + name_size
}

// 0x2B
// ⚠️Layout not verified - struct generated by copilot
struct MethodSpec {
	rid    u32
	token  u32
	offset int

	// _Method_ (an index into the _MethodDef_ or _MemberRef_ table, specifying to which generic method this row refers; that is, which generic method this row is an instantiation of; more precisely, a _MethodDefOrRef_ (§[II.24.2.6](ii.24.2.6-metadata-stream.md)) coded index)
	method u32
	// _Instantiation_ (an index into the Blob heap (§[II.23.2.15](ii.23.2.15-methodspec.md)), holding the signature of this instantiation)
	//  * _MethodSpec_
	instantiation u32
}

@[inline]
fn MethodSpec.row_size(tables TablesStream) u32 {
	method_size := get_method_def_or_ref_size(tables)

	instantiation_size := if tables.heap_sizes.has(.blob) { u32(4) } else { 2 }

	return method_size + instantiation_size
}

// 0x2C
// ⚠️Layout not verified - struct generated by copilot
struct GenericParamConstraint {
	rid    u32
	token  u32
	offset int

	// _Owner_ (an index into the _GenericParam_ table, specifying to which generic parameter this row refers)
	owner u32
	// _Constraint_ (an index into the _TypeDef_, _TypeRef_, or _TypeSpec_ tables, specifying from which class this generic parameter is constrained to derive; or which interface this generic parameter is constrained to implement; more precisely, a _TypeDefOrRef_ (§[II.24.2.6](ii.24.2.6-metadata-stream.md)) coded index)
	constraint u32
}

@[inline]
fn GenericParamConstraint.row_size(tables TablesStream) u32 {
	owner_size := if tables.num_rows[.generic_param] > 0xFFFF { u32(4) } else { 2 }

	constraint_size := get_type_def_or_ref_size(tables)
	return owner_size + constraint_size
}
