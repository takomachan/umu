module Umu

module Commander

unless ::Object.new.respond_to?(:yield_self)	# Ruby 2.5 or after
	class ::Object
		def yield_self
			yield self
		end
	end
end


module_function

begin
	require 'reline'		# Ruby 2.7 or after

	def input(prompt)
		Reline.readline(prompt, true)
	end

rescue ::LoadError
	begin
		require 'readline'	# Ruby 2.6 or before

		def input(prompt)
			Readline.readline(prompt, true)
		end

	rescue ::LoadError
		def input(prompt)
			STDERR.print prompt; STDERR.flush

			STDIN.gets
		end
	end
end


	STDIN_FILE_NAME = '<stdin>'

	PARSER = SC::Parser.new


	def main(args)
		ASSERT.kind_of args, ::Array

		exit_code = begin
			prelude_env = Commander.process_file(
							Prelude::SOURCE_TEXT,
							Prelude::FILE_NAME,
							E.setup(E::INITIAL_PREFERENCE),
							Prelude::START_LINE_NUM
						)
			pref, file_names = Commander.parse_option args, prelude_env.pref
			init_env = prelude_env.update_preference pref

			if pref.interactive_mode?
				env = unless file_names.empty?
							Commander.process_files file_names, init_env
						else
							init_env
						end

				Commander.interact env
			else
				if file_names.empty?
					raise X::CommandError.new('No input files')
				end

				Commander.process_files file_names, init_env
			end

			0
		rescue X::Abstraction::RuntimeError => e
			e.print_backtrace
			STDERR.puts
			STDERR.puts e.to_s

			1
		rescue X::Abstraction::Expected, ::SystemCallError => e
			STDERR.puts
			STDERR.puts e.to_s

			1
		rescue ::Interrupt
			1
		end

		ASSERT.kind_of exit_code, ::Integer
	end


	def interact(init_env)
		ASSERT.kind_of init_env, E::Entry

		init_tokens	= []
		init_lexer	= LL.make_initial_lexer STDIN_FILE_NAME, 1
		final_env = loop.inject(
			 [1,        init_tokens, init_lexer, init_env]
		) { |(line_num, tokens,      lexer,      env     ), _|
			ASSERT.kind_of line_num,	::Integer
			ASSERT.kind_of tokens,		::Array
			ASSERT.kind_of lexer,		LL::Abstract
			ASSERT.kind_of env,			E::Entry

			prompt = format(
				"%04d%s%s%s ",

				line_num,

				if lexer.in_braket?
					format(":%s:%d",
							lexer.braket_stack.reverse.map { |bb|
								format("%-2s", bb)
							}.join('.'),
							lexer.braket_stack.length
					)
				else
					''
				end,

				if lexer.in_comment?
					format(":%s:%d",
							'(*' * lexer.comment_depth,
							lexer.comment_depth
					)
				else
					''
				end,

				if lexer.in_comment?
					'*'
				elsif lexer.in_braket?
					'|'
				else
					'>'
				end
			)
			opt_line = Commander.input prompt

			break env if opt_line.nil?
			line = opt_line

			next_tokens, next_lexer, next_env = begin
				if lexer.between_braket? && /^:/ =~ line
					[
						[],
						init_lexer,
						Subcommand.execute(line, line_num, env)
					]
				else
					Commander.process_line(
						line + "\n",
						line_num,
						tokens,
						lexer,
						env.update_line(STDIN_FILE_NAME, line_num, line)
					)
				end
			rescue X::Abstraction::RuntimeError => e
				e.print_backtrace
				STDERR.puts
				STDERR.puts e.to_s

				[[], init_lexer, env]
			rescue X::Abstraction::Expected, ::SystemCallError => e
				STDERR.puts
				STDERR.puts e.to_s

				[[], init_lexer, env]
			rescue ::Interrupt
				STDERR.puts
				STDERR.puts 'Interrupt!!'

				[[], init_lexer, env]
			end

			[line_num + 1, next_tokens, next_lexer, next_env]
		}

		ASSERT.kind_of final_env, E::Entry
	end


	def process_line(line, line_num, tokens, lexer, env)
		ASSERT.kind_of line,		::String
		ASSERT.kind_of line_num,	::Integer
		ASSERT.kind_of tokens,		::Array
		ASSERT.kind_of lexer,		LL::Abstract
		ASSERT.kind_of env,			E::Entry

		pref		= env.pref
		file_name	= STDIN_FILE_NAME

		if pref.trace_mode?
			STDERR.puts
			STDERR.printf "________ Source: '%s' ________\n", file_name
			STDERR.printf "%04d: %s", line_num, line
		end

		if pref.trace_mode?
			STDERR.puts
			STDERR.printf "________ Tokens: '%s' ________", file_name
		end

		scanner = ::StringScanner.new line
		next_tokens, next_lexer = LL.lex(
			tokens, lexer, 0, scanner, pref
		) do |token, before_line_num|

			if pref.trace_mode?
				line_num = token.pos.line_num

				if line_num != before_line_num
					STDERR.printf "\n%04d: ", line_num
				end

				unless token && token.separator?
					STDERR.printf "%s ", token.to_s
					STDERR.flush
				end
			end
		end

		if pref.trace_mode?
			STDERR.puts
		end

		if next_lexer.between_braket?
			[
				[],
				next_lexer,
				Commander.execute(next_tokens, env)
			]
		else
			[
				next_tokens,
				next_lexer,
				env
			]
		end
	end


	def process_files(file_names, init_env)
		ASSERT.kind_of file_names,	::Array
		ASSERT.kind_of init_env,	E::Entry

		final_env = file_names.inject(init_env) { |env, file_name|
			ASSERT.kind_of env,			E::Entry
			ASSERT.kind_of file_name,	::String

			source = ::File.open(file_name) { |io| io.read }

			Commander.process_file(
				source,
				file_name,
				env.update_source(file_name, source)
			)
		}

		ASSERT.kind_of final_env, E::Entry
	end


	def process_file(source, file_name, env, init_line_num = 1)
		ASSERT.kind_of source,			::String
		ASSERT.kind_of file_name,		::String
		ASSERT.kind_of env,				E::Entry
		ASSERT.kind_of init_line_num,	::Integer

		pref = env.pref

		if pref.trace_mode?
			STDERR.puts
			STDERR.printf "________ Source: '%s' ________\n", file_name
			source.each_line.with_index do |line, index|
				STDERR.printf "%04d: %s", index + 1, line
			end
		end

		if pref.trace_mode?
			STDERR.puts
			STDERR.printf "________ Tokens: '%s' ________", file_name
		end

		init_tokens	= []
		init_lexer	= LL.make_initial_lexer file_name, init_line_num
		scanner		= ::StringScanner.new source
		tokens, _lexer = LL.lex(
			init_tokens, init_lexer, 0, scanner, pref
		) do |token, before_line_num|

			if pref.trace_mode?
				line_num = token.pos.line_num

				if line_num != before_line_num
					STDERR.printf "\n%04d: ", line_num
				end

				unless token && token.separator?
					STDERR.printf "%s ", token.to_s
					STDERR.flush
				end
			end
		end

		if pref.trace_mode?
			STDERR.puts
		end

		Commander.execute(tokens, env)
	end


	def execute(tokens, init_env)
		ASSERT.kind_of tokens,		::Array
		ASSERT.kind_of init_env,	E::Entry

		con_syntaxes = PARSER.parse tokens

		final_env = con_syntaxes.inject(init_env) { |env, con_syntax|
			ASSERT.kind_of env,			E::Entry
			ASSERT.kind_of con_syntax,	SC::Abstract

			pref = env.pref

			con_syntax.tap { |csyn|
				ASSERT.kind_of csyn, SC::Abstract

				if pref.trace_mode?
					STDERR.puts
					STDERR.printf(
						"________ Concrete Syntax: #%d in '%s' ________\n",
						csyn.pos.line_num,
						csyn.pos.file_name
					)
					STDERR.puts csyn.to_s
				end

				if pref.trace_mode?
					STDERR.puts
					STDERR.puts "________ Desugar Trace ________"
				end
			}.desugar(env).tap { |asyn|
				ASSERT.kind_of asyn, SA::Abstract

				if pref.trace_mode?
					STDERR.puts
					STDERR.printf(
						"________ Abstract Syntax: #%d in '%s' ________\n",
						asyn.pos.line_num,
						asyn.pos.file_name
					)
					STDERR.puts asyn.to_s
				end

				if pref.trace_mode?
					STDERR.puts
					STDERR.puts "________ Evaluator Trace ________"
				end
			}.evaluate(env).yield_self { |result|
				ASSERT.kind_of result, SAR::Abstract

				case result
				when SAR::Value
					value = result.value

					STDERR.puts
					STDERR.printf("-> %s : %s\n",
									value.to_s,
									value.type_sym.to_s
					)

					env
				when SAR::Environment
					result.env
				else
					ASSERT.abort result.inspect
				end
			}
		}

		ASSERT.kind_of final_env, E::Entry
	end

end # Umu::Commander

end # Umu
