module winmd

fn main() ! {
	mut reader := new_reader('path/to/your.winmd')!

	is_valid := reader.validate() or {
		println('Invalid WinMD file: ${err}')
		return
	}

	if is_valid {
		// 3. Create metadata collector
		mut collector := new_collector(reader)

		// 4. Collect all metadata
		collector.collect()!

		// 5. Setup code generator
		mut generator := new_code_generator(collector, 'generated')

		// 6. Generate V code with error handling
		generator.generate() or {
			println('Code generation failed: ${err}')
			return
		}
	}
}

// Update validate method to initialize heaps
pub fn (mut r WinMDReader) validate() !bool {
	r.read_dos_header()!
	r.read_pe_header()!
	r.read_optional_header()!
	r.read_section_headers()!
	r.read_cli_header()!
	r.read_metadata_header()!
	r.read_stream_headers()!
	r.read_tables_header()!
	r.init_heaps()!
	return true
}
