module writer

pub struct Function {
pub:
	name           string         @[json: Name]
	set_last_error bool           @[json: SetLastError]
	dll_import     string         @[json: DllImport]
	return_type    ApiRefType     @[json: ReturnType]
	return_attrs   []string       @[json: ReturnAttrs]
	architectures  []string       @[json: Architectures]
	platform       ?string        @[json: Platform]
	attrs          []string       @[json: Attrs]
	params         []FieldOrParam @[json: Params]
}
