module main

import x.json2
import strings

struct DocGen {
	docs map[string]json2.Any
}

fn (d DocGen) help_url(symbol_name string) string {
	doc := d.docs[symbol_name] or { return '' }
	return doc.arr()[0].str()
}

fn (d DocGen) description(symbol_name string) string {
	doc := d.docs[symbol_name] or { return '' }
	return doc.arr()[1].str()
}

fn (d DocGen) remarks(symbol_name string) string {
	doc := d.docs[symbol_name] or { return '' }
	return doc.arr()[2].str()
}

fn (d DocGen) params(symbol_name string) []string {
	doc := d.docs[symbol_name] or { return []string{} }
	mut params := []string{}
	for k, v in doc.arr()[3].as_map() {
		params << '${k} - ${v.str()}'
	}
	return params
}

fn (d DocGen) fields(symbol_name string) []string {
	doc := d.docs[symbol_name] or { return []string{} }

	mut fields := []string{}
	for k, v in doc.arr()[4].as_map() {
		fields << '${k} - ${v.str()}'
	}
	return fields
}

fn (d DocGen) return_description(symbol_name string) string {
	doc := d.docs[symbol_name] or { return '' }
	return doc.arr()[5].str()
}

fn (d DocGen) doc(symbol_name string) string {
	mut docstring := strings.new_builder(2048)
	docstring.write_string('// ${symbol_name}\n')

	docstring.write_string('// ' + d.help_url(symbol_name))
	docstring.write_string('\n')

	description := d.description(symbol_name)
	description_as_docstring := '// ${description}'
	docstring.write_string(description_as_docstring.replace('\n', '\n// '))
	docstring.write_string('\n')

	remarks := d.remarks(symbol_name)
	remarks_as_docstring := '// ${remarks}'
	docstring.write_string(remarks_as_docstring.replace('\n', '\n// '))
	docstring.write_string('\n')

	params := d.params(symbol_name)
	for param in params {
		param_as_docstring := '// ${param}'
		docstring.write_string(param_as_docstring.replace('\n', '\n// '))
		docstring.write_string('\n')
	}

	fields := d.fields(symbol_name)
	for field in fields {
		field_as_docstring := '// ${field}'
		docstring.write_string(field_as_docstring.replace('\n', '\n// '))
		docstring.write_string('\n')
	}

	return_description := d.return_description(symbol_name)
	return_description_as_docstring := '// ${return_description}'
	docstring.write_string(return_description_as_docstring.replace('\n', '\n// '))
	docstring.write_string('\n')

	return docstring.bytestr()
}
