module main

// 0x00
// ✅Layout verified
struct Module {
	rid                u32
	token              u32
	offset             u32
	generation         u32
	name               u32
	mvid               u32
	generation_id      u32
	base_generation_id u32
}

@[inline]
fn Module.row_size(heap_sizes HeapSizeFlags) int {
	string_size := if heap_sizes.has(.strings) { 4 } else { 2 }
	return 12 + string_size * 2
}

// 0x01
// ✅Layout verified
struct TypeRef {
	rid              u32
	token            u32
	offset           u32
	resolution_scope u32
	name             u32
	namespace        u32
}

@[inline]
fn TypeRef.row_size(heap_sizes HeapSizeFlags) int {
	string_size := if heap_sizes.has(.strings) { 4 } else { 2 }
	return 4 + string_size * 2
}

// 0x02
// ✅Layout verified
struct TypeDef {
	rid         u32
	token       u32
	offset      u32
	attributes  u32
	name        u32
	namespace   u32
	base_type   u32
	field_list  u32
	method_list u32
}

@[inline]
fn TypeDef.row_size(heap_sizes HeapSizeFlags) int {
	string_size := if heap_sizes.has(.strings) { 4 } else { 2 }
	return 8 + string_size * 2 + 8
}

// 0x03 FieldPtr is unused

// 0x04
// ✅Layout verified
struct Field {
	rid        u32
	token      u32
	offset     u32
	attributes u32
	name       u32
	signature  u32
}

@[inline]
fn Field.row_size(heap_sizes HeapSizeFlags) int {
	string_size := if heap_sizes.has(.strings) { 4 } else { 2 }
	return 4 + string_size * 2
}

// 0x05 MethodPtr is unused

// 0x06
// ✅Layout verified
struct Method {
	rid             u32
	token           u32
	offset          u32
	attributes      u32
	impl_attributes u32
	rva             u32
	name            u32
	signature       u32
}

@[inline]
fn Method.row_size(heap_sizes HeapSizeFlags) int {
	string_size := if heap_sizes.has(.strings) { 4 } else { 2 }
	return 12 + string_size * 2
}

// 0x07 ParamPtr is unused

// 0x08
// ✅Layout verified
struct Param {
	rid        u32
	token      u32
	offset     u32
	attributes u32
	name       u32
	sequence   u32
}

@[inline]
fn Param.row_size(heap_sizes HeapSizeFlags) int {
	string_size := if heap_sizes.has(.strings) { 4 } else { 2 }
	return 4 + string_size * 2
}

// 0x09
// ✅Layout verified
struct InterfaceImpl {
	rid       u32
	token     u32
	offset    u32
	class     u32
	interface u32
}

@[inline]
fn InterfaceImpl.row_size(heap_sizes HeapSizeFlags) int {
	return 8
}

// 0x0A
// ✅Layout verified
struct MemberRef {
	rid       u32
	token     u32
	offset    u32
	parent    u32
	name      u32
	signature u32
}

@[inline]
fn MemberRef.row_size(heap_sizes HeapSizeFlags) int {
	string_size := if heap_sizes.has(.strings) { 4 } else { 2 }
	return 4 + string_size * 2
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
	offset u32

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

@[inline]
fn Constant.row_size(heap_sizes HeapSizeFlags) int {
	return 12
}

fn (c Constant) resolve(winmd_bytes []u8, stream TablesStream) {
	a, b := decode_unsigned(c.token) or { u32(0), 0 }

	println('a: ${a}, b: ${b}')

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
	rid         u32
	token       u32
	offset      u32
	parent      u32
	constructor u32
	value       u32
}

@[inline]
fn CustomAttribute.row_size(heap_sizes HeapSizeFlags) int {
	return 12
}

// 0x0D
// ⚠️Layout not verified - struct generated by copilot
struct FieldMarshal {
	rid         u32
	token       u32
	offset      u32
	parent      u32
	native_type u32
}

@[inline]
fn FieldMarshal.row_size(heap_sizes HeapSizeFlags) int {
	return 8
}

// 0x0E
// ⚠️Layout not verified - struct generated by copilot
struct DeclSecurity {
	rid            u32
	token          u32
	offset         u32
	action         u32
	parent         u32
	permission_set u32
}

@[inline]
fn DeclSecurity.row_size(heap_sizes HeapSizeFlags) int {
	return 12
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
	offset u32

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
fn ClassLayout.row_size(heap_sizes HeapSizeFlags) int {
	return 10
}

// 0x10
// ✅Layout verified
struct FieldLayout {
	rid          u32
	token        u32
	offset       u32
	field        u32
	field_offset u32
}

@[inline]
fn FieldLayout.row_size(heap_sizes HeapSizeFlags) int {
	return 8
}

// 0x11
// ⚠️Layout not verified - struct generated by copilot
struct StandAloneSig {
	rid       u32
	token     u32
	offset    u32
	signature u32
}

@[inline]
fn StandAloneSig.row_size(heap_sizes HeapSizeFlags) int {
	return if heap_sizes.has(.blob) { 4 } else { 2 }
}

// 0x12
// ✅Layout verified
struct EventMap {
	rid        u32
	token      u32
	offset     u32
	parent     u32
	event_list u32
}

@[inline]
fn EventMap.row_size(heap_sizes HeapSizeFlags) int {
	return 8
}

// 0x13 EventPtr is unused

// 0x14
// ✅Layout verified
struct Event {
	rid        u32
	token      u32
	offset     u32
	attributes u32
	name       u32
	type       u32
}

@[inline]
fn Event.row_size(heap_sizes HeapSizeFlags) int {
	string_size := if heap_sizes.has(.strings) { 4 } else { 2 }
	return 4 + string_size * 2
}

// 0x15
// ✅Layout verified
struct PropertyMap {
	rid           u32
	token         u32
	offset        u32
	parent        u32
	property_list u32
}

@[inline]
fn PropertyMap.row_size(heap_sizes HeapSizeFlags) int {
	return 8
}

// 0x16 PropertyPtr is unused

// 0x17
// ✅Layout verified
struct Property {
	rid        u32
	token      u32
	offset     u32
	attributes u32
	name       u32
	signature  u32
}

@[inline]
fn Property.row_size(heap_sizes HeapSizeFlags) int {
	string_size := if heap_sizes.has(.strings) { 4 } else { 2 }
	return 4 + string_size * 2
}

// 0x18
// ✅Layout verified
struct MethodSemantics {
	rid         u32
	token       u32
	offset      u32
	semantics   u32
	method      u32
	association u32
}

@[inline]
fn MethodSemantics.row_size(heap_sizes HeapSizeFlags) int {
	return 12
}

// 0x19
// ✅Layout verified
struct MethodImpl {
	rid                u32
	token              u32
	offset             u32
	method_declaration u32
	method_body        u32
	type               u32
}

@[inline]
fn MethodImpl.row_size(heap_sizes HeapSizeFlags) int {
	return 12
}

// 0x1A
// ✅Layout verified
struct ModuleRef {
	rid    u32
	token  u32
	offset u32
	name   u32
}

@[inline]
fn ModuleRef.row_size(heap_sizes HeapSizeFlags) int {
	string_size := if heap_sizes.has(.strings) { 4 } else { 2 }
	return string_size
}

// 0x1B
// ✅Layout verified
struct TypeSpec {
	rid       u32
	token     u32
	offset    u32
	signature u32
}

@[inline]
fn TypeSpec.row_size(heap_sizes HeapSizeFlags) int {
    // TODO: 4 or 2 bytes based on blob heap size?
	return 4
}

// 0x1C
// ✅Layout verified
struct ImplMap {
	rid              u32
	token            u32
	offset           u32
	mapping_flags    u32
	member_forwarded u32
	import_scope     u32
	import_name      u32
}

@[inline]
fn ImplMap.row_size(heap_sizes HeapSizeFlags) int {
	string_size := if heap_sizes.has(.strings) { 4 } else { 2 }
	return 8 + string_size * 2
}

// 0x1D
// ⚠️Layout not verified - struct generated by copilot
struct FieldRVA {
	rid    u32
	token  u32
	offset u32
	rva    u32
	field  u32
}

@[inline]
fn FieldRVA.row_size(heap_sizes HeapSizeFlags) int {
	return 8
}

// 0x1E Edit-and-continue log is unused

// 0x1F Edit-and-continue mapping is unused

// 0x20
// ✅Layout verified
struct Assembly {
	rid    u32
	token  u32
	offset u32

	// HashAlgId is a 4-byte constant of type AssemblyHashAlgorithm, §II.23.1.1
	hash_algorithm u32

	// Flags is a 4-byte bitmask of type AssemblyFlags, §II.23.1.2
	// (0x0001) PublicKey
	// (0x0010) Retargetable
	// (0x0100) DisableJITcompileOptimizer
	// (0x1000) EnableJITcompileTracking
	flags u32

	// MajorVersion, MinorVersion, BuildNumber, RevisionNumber (each being 2-byte constants)
	version u32

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
fn Assembly.row_size(heap_sizes HeapSizeFlags) int {
	string_size := if heap_sizes.has(.strings) { 4 } else { 2 }
	return 8 + string_size * 2
}

// 0x21
// ⚠️Layout not verified - struct generated by copilot
struct AssemblyProcessor {
	rid       u32
	token     u32
	offset    u32
	processor u32
}

@[inline]
fn AssemblyProcessor.row_size(heap_sizes HeapSizeFlags) int {
	return 4
}

// 0x22
// ⚠️Layout not verified - struct generated by copilot
struct AssemblyOS {
	rid              u32
	token            u32
	offset           u32
	os_platform_id   u32
	os_major_version u32
	os_minor_version u32
}

@[inline]
fn AssemblyOS.row_size(heap_sizes HeapSizeFlags) int {
	return 12
}

// 0x23
// ✅Layout verified
struct AssemblyRef {
	rid                 u32
	token               u32
	offset              u32
	version             u32
	flags               u32
	public_key_or_token u32
	name                u32
	culture             u32
}

@[inline]
fn AssemblyRef.row_size(heap_sizes HeapSizeFlags) int {
	string_size := if heap_sizes.has(.strings) { 4 } else { 2 }
	return 8 + string_size * 3
}

// 0x24
// ⚠️Layout not verified - struct generated by copilot
struct AssemblyRefProcessor {
	rid          u32
	token        u32
	offset       u32
	processor    u32
	assembly_ref u32
}

@[inline]
fn AssemblyRefProcessor.row_size(heap_sizes HeapSizeFlags) int {
	return 8
}

// 0x25
// ⚠️Layout not verified - struct generated by copilot
struct AssemblyRefOS {
	rid              u32
	token            u32
	offset           u32
	os_platform_id   u32
	os_major_version u32
	os_minor_version u32
	assembly_ref     u32
}

@[inline]
fn AssemblyRefOS.row_size(heap_sizes HeapSizeFlags) int {
	return 16
}

// 0x26
// ⚠️Layout not verified - struct generated by copilot
struct File {
	rid        u32
	token      u32
	offset     u32
	flags      u32
	name       u32
	hash_value u32
}

@[inline]
fn File.row_size(heap_sizes HeapSizeFlags) int {
	string_size := if heap_sizes.has(.strings) { 4 } else { 2 }
	return 4 + string_size * 2
}

// 0x27
// ⚠️Layout not verified - struct generated by copilot
struct ExportedType {
	rid            u32
	token          u32
	offset         u32
	flags          u32
	type_def_id    u32
	name           u32
	namespace      u32
	implementation u32
}

@[inline]
fn ExportedType.row_size(heap_sizes HeapSizeFlags) int {
	string_size := if heap_sizes.has(.strings) { 4 } else { 2 }
	return 12 + string_size * 2
}

// 0x28
// ⚠️Layout not verified - struct generated by copilot
struct ManifestResource {
	rid            u32
	token          u32
	offset         u32
	flags          u32
	name           u32
	implementation u32
}

@[inline]
fn ManifestResource.row_size(heap_sizes HeapSizeFlags) int {
	string_size := if heap_sizes.has(.strings) { 4 } else { 2 }
	return 4 + string_size
}

// 0x29
// ✅Layout verified
struct NestedClass {
	rid             u32
	token           u32
	offset          u32
	nested_class    u32
	enclosing_class u32
}

@[inline]
fn NestedClass.row_size(heap_sizes HeapSizeFlags) int {
	return 8
}

// 0x2A
// ⚠️Layout not verified - struct generated by copilot
struct GenericParam {
	rid    u32
	token  u32
	offset u32
	number u32
	flags  u32
	owner  u32
	name   u32
}

@[inline]
fn GenericParam.row_size(heap_sizes HeapSizeFlags) int {
	string_size := if heap_sizes.has(.strings) { 4 } else { 2 }
	return 8 + string_size
}

// 0x2B
// ⚠️Layout not verified - struct generated by copilot
struct MethodSpec {
	rid           u32
	token         u32
	offset        u32
	method        u32
	instantiation u32
}

@[inline]
fn MethodSpec.row_size(heap_sizes HeapSizeFlags) int {
	return 8
}

// 0x2C
// ⚠️Layout not verified - struct generated by copilot
struct GenericParamConstraint {
	rid        u32
	token      u32
	offset     u32
	owner      u32
	constraint u32
}

@[inline]
fn GenericParamConstraint.row_size(heap_sizes HeapSizeFlags) int {
	return 8
}
