// test_winmd.v
module main

import os
import winmd

fn main() {
	if os.args.len < 2 {
		println('Usage: v run test_winmd.v <path_to_winmd_file>')
		return
	}

	winmd_path := os.args[1]

	// Create reader
	mut reader := winmd.new_reader(winmd_path) or {
		println('Failed to open WinMD file: ${err}')
		return
	}

	// Basic validation
	reader.validate() or {
		println('Invalid WinMD file: ${err}')
		return
	}

	// Create metadata collector
	mut collector := winmd.new_collector(reader)

	// Collect metadata
	collector.collect() or {
		println('Failed to collect metadata: ${err}')
		return
	}

	// Print what we found
	println('Types found:')
	for namespace, type_info in collector.types {
		println('\n${namespace}:')
		println('  Methods:')
		for method in type_info.methods {
			println('    ${method.name}')
		}
		println('  Properties:')
		for prop in type_info.properties {
			println('    ${prop.name}')
		}
		if type_info.runtime_class {
			println('  Runtime Features:')
			if type_info.factories.len > 0 {
				println('    Has activation factory')
			}
			if type_info.composable_factories.len > 0 {
				println('    Is composable')
			}
			if type_info.static_factories.len > 0 {
				println('    Has static members')
			}
		}
	}
}
