module Umu

module Commander

module Subcommand

module_function

	def execute(line, line_num, env)
		ASSERT.kind_of line,		::String
		ASSERT.kind_of line_num,	::Integer
		ASSERT.kind_of env,			E::Entry

		name, *args = line.split

		new_env = case name
		when ':trace'
			env.update_trace_mode true
		when ':notrace'
			env.update_trace_mode false
		when ':lextrace'
			env.update_lex_trace_mode true
		when ':nolextrace'
			env.update_lex_trace_mode false
		when ':class'
				case args.size
				when 0
					env.ty_context.root_class_spec.print_class_tree
				when 1
					class_spec = env.ty_lookup(
						args[0].to_sym,
						L.make_location(STDIN_FILE_NAME, line_num)
					)

					class_spec.print_class env
				else
					raise X::CommandError.new "Syntax error"
				end

				env
			else
				raise X::CommandError.new "Unknown command: '%s'", line
			end

		ASSERT.kind_of new_env, E::Entry
	end

end # Umu::Commander::Subcommand

end # Umu::Commander

end # Umu
