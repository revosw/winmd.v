module writer

// the typename "Type" is taken. ApiType was
// the best name I could think of at the time
pub type ApiType = ComClassIDType
	| ComType
	| EnumType
	| FunctionPointerType
	| NativeTypedefType
	| StructOrUnionType

pub struct ComClassIDType {
pub:
	name          string @[json: Name]
	architectures string @[json: Architectures]
	platform      string @[json: Platform]
	kind          string @[json: Kind]
	guid          string @[json: Guid]
}

pub struct ComInterface {
pub:
	kind        string   @[json: Kind]
	name        string   @[json: Name]
	target_kind string   @[json: TargetKind]
	api         string   @[json: Api]
	parents     []string @[json: Parents]
}

pub struct ComMethod {
pub:
	name           string         @[json: Name]
	set_last_error bool           @[json: SetLastError]
	return_type    DataType       @[json: ReturnType]
	return_attrs   []string       @[json: ReturnAttrs]
	architectures  []string       @[json: Architectures]
	platform       ?string        @[json: Platform]
	attrs          []string       @[json: Attrs]
	params         []FieldOrParam @[json: Params]
}

pub struct FieldOrParam {
pub:
	name  string   @[json: Name]
	@type DataType @[json: Type]
	attrs []string @[json: Attrs]
}

pub struct ComType {
pub:
	name          string       @[json: Name]
	architectures []u8         @[json: Architectures]
	platform      ?string      @[json: Platform]
	kind          string       @[json: Kind]
	guid          string       @[json: Guid]
	attrs         []string     @[json: Attrs]
	interface     ComInterface @[json: Interface]
	methods       []ComMethod  @[json: Methods]
}

pub struct EnumValue {
pub:
	name  string @[json: Name]
	value u32    @[json: Value]
}

pub struct EnumType {
	name          string      @[json: Name]
	architectures []u8        @[json: Architectures]
	platform      ?string     @[json: Platform]
	kind          string      @[json: Kind]
	flags         bool        @[json: Flags]
	scoped        bool        @[json: Scoped]
	values        []EnumValue @[json: Values]
	integer_base  string      @[json: IntegerBase]
}

pub struct FunctionPointerType {
pub:
	name           string         @[json: Name]
	architectures  []u8           @[json: Architectures]
	platform       ?string        @[json: Platform]
	kind           string         @[json: Kind]
	set_last_error bool
	return_type    DataType
	return_attrs   []string
	attrs          []string
	params         []FieldOrParam
}

pub struct NativeTypedefType {
pub:
	name                 string   @[json: Name]
	architectures        []string @[json: Architectures]
	platform             ?string  @[json: Platform]
	kind                 string   @[json: Kind]
	also_usable_for      ?string  @[json: AlsoUsableFor]
	def                  DataType @[json: Def]
	free_func            ?string  @[json: FreeFunc]
	invalid_handle_value ?u8      @[json: InvalidHandleValue]
}

pub struct StructOrUnionType {
pub:
	name          string              @[json: Name]
	architectures []string            @[json: Architectures]
	platform      ?string             @[json: Platform]
	kind          string              @[json: Kind]
	size          u32                 @[json: Size]
	packing_size  u32                 @[json: PackingSize]
	fields        []FieldOrParam      @[json: Fields]
	nested_types  []StructOrUnionType @[json: NestedTypes]
}
