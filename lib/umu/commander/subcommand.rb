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
					Subcommand.print_class_tree(
									env.ty_context.root_class_spec
								)
				when 1
					class_spec = env.ty_lookup(
						args[0].to_sym,
						L.make_location(STDIN_FILE_NAME, line_num)
					)

					Subcommand.print_class class_spec, env
				else
					raise X::CommandError.new "Syntax error"
				end

				env
			else
				raise X::CommandError.new "Unknown command: '%s'", line
			end

		ASSERT.kind_of new_env, E::Entry
	end


	def print_class_tree(class_spec, nest = 0)
		ASSERT.kind_of class_spec,	ECTSC::Base
		ASSERT.kind_of nest,		::Integer

		printf "%s%s\n", '    ' * nest, class_spec.to_sym

		class_spec.subclasses.sort.each do |subclass_spec|
			print_class_tree subclass_spec, nest + 1
		end
	end


	def print_class(class_spec, env, nest = 0)
		ASSERT.kind_of class_spec,	ECTSC::Base
		ASSERT.kind_of env,			E::Entry
		ASSERT.kind_of nest,		::Integer

		indent_0 = '    ' * nest
		indent_1 = '    ' * (nest + 1)

		opt_superclass = class_spec.opt_superclass
		if opt_superclass
			superclass = opt_superclass

			printf "%sSUPERCLASS: %s\n", indent_0, superclass.to_sym
		end

		subclasses = class_spec.subclasses
		unless subclasses.empty?
			printf("%sSUBCLASSES: %s\n",
				indent_0,
				subclasses.map(&:to_sym).join(', ')
			)
		end

		ancestors = class_spec.ancestors
		unless ancestors.empty?
			printf("%sANCESTORS: %s\n",
				indent_0,
				ancestors.map(&:to_sym).join(', ')
			)
		end

		descendants = class_spec.descendants
		unless descendants.empty?
			printf("%sDESCENDANTS: %s\n",
				indent_0,
				descendants.map(&:to_sym).join(', ')
			)
		end

		unless class_spec.num_of_class_methods == 0
			printf "%sCLASS METHODS:\n", indent_0

			class_spec.each_class_method(env).sort.each do |meth_spec|
				printf("%s%s.%s : %s\n",
					indent_1,

					class_spec.symbol,

					meth_spec.symbol,

					(
						meth_spec.param_class_specs +
						[meth_spec.ret_class_spec.symbol]
					).map(&:to_sym).join(' -> ')
				)
			end
		end

		unless class_spec.num_of_instance_methods == 0
			printf "%sINSTANCE METHODS:\n", indent_0

			class_spec.each_instance_method(env).sort.each do |meth_spec|
				printf("%s%s#%s : %s\n",
					indent_1,

					class_spec.symbol,

					meth_spec.symbol,

					(
						meth_spec.param_class_specs +
						[meth_spec.ret_class_spec.symbol]
					).map(&:to_sym).join(' -> ')
				)
			end
		end
	end

end # Umu::Commander::Subcommand

end # Umu::Commander

end # Umu
