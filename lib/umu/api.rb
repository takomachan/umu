# coding: utf-8
# frozen_string_literal: true

require 'pp'



module Umu

module Api

class Interpreter
    def self.setup(opts)
        ASSERT.kind_of opts, ::Array

        env, file_names = Umu::Commander.setup opts

        unless file_names.empty?
            raise X::CommandError.new('Does not exists input files')
        end

        Interpreter.new(env).freeze
    end


    attr_reader :env, :parser

    def initialize(env)
        ASSERT.kind_of env, E::Entry

        @env    = env
        @parser = CS::Parser.new
    end


    def eval_decls(source, opts)
        ASSERT.kind_of source, ::String
        ASSERT.kind_of opts,   ::Hash

        file_name, init_line_num, bindings = __parse_option__ opts

        tokens, lexed_env = __lex_source__(
                                source, file_name, self.env, init_line_num
                            )

        csyn_stmts = self.parser.parse tokens

        new_env = lexed_env.va_extend_values bindings

        final_env = csyn_stmts.inject(new_env) { |env, csyn_stmt|
            ASSERT.kind_of env,         E::Entry
            ASSERT.kind_of csyn_stmt,   CS::Abstract

            result = Umu::Commander.execute(csyn_stmt, env)
            ASSERT.kind_of result, ASR::Abstract

            case result
            when ASR::Value
                raise X::CommandError.new(
                    "Unexpected expression: %s", csyn_stmt.to_s
                )
            when ASR::Environment
                result.env
            else
                ASSERT.abort result.inspect
            end
        }

        Interpreter.new(final_env).freeze
    end


    def eval_expr(source, opts)
        ASSERT.kind_of source, ::String
        ASSERT.kind_of opts,   ::Hash

        file_name, init_line_num, bindings = __parse_option__ opts

        tokens, lexed_env = __lex_source__(
                                source, file_name, self.env, init_line_num
                            )

        csyn_stmts = self.parser.parse tokens
        csyn_stmt = case csyn_stmts.count
                    when 0
                        raise X::CommandError.new "No input expression"
                    when 1
                        csyn_stmts[0]
                    else
                        raise X::CommandError.new(
                            "Unexpected multiple statements: %s",
                            csyn_stmts.map(&:to_s).join(' ')
                        )
                    end
        ASSERT.kind_of csyn_stmt, CS::Abstract

        new_env = lexed_env.va_extend_values bindings

        result = Umu::Commander.execute(csyn_stmt, new_env)
        ASSERT.kind_of result, ASR::Abstract

        value = case result
                when ASR::Value
                    result.value
                when ASR::Environment
                    raise X::CommandError.new(
                        "Unexpected declaration: %s", csyn_stmt.to_s
                    )
                else
                    ASSERT.abort result.inspect
                end

        ASSERT.kind_of value, VC::Top
    end


private

    def __parse_option__(opts)
        ASSERT.kind_of opts, ::Hash

        triple = opts.inject(
                 ['<_>',  0,   {}]
            ) { |(name,   num, bs), (key, val)|
                ASSERT.kind_of key, ::Symbol

                case key
                when :_file_name
                    ASSERT.kind_of val, ::String

                    [val,  num, bs]
                when :_line_num
                    ASSERT.kind_of val, ::Integer

                    [name, val, bs]
                else
                    ASSERT.kind_of val, VC::Top

                    new_bs = bs.merge(key => val) {
                        ASSERT.abort "Duplicated key: '%s'", key.to_s
                    }

                    [name, num, new_bs]
                end
            }

        ASSERT.tuple_of triple, [::String, ::Integer, ::Hash]
    end


    def __lex_source__(
        source, file_name, env, init_line_num = 0
    )
        ASSERT.kind_of source,          ::String
        ASSERT.kind_of file_name,       ::String
        ASSERT.kind_of env,             E::Entry
        ASSERT.kind_of init_line_num,   ::Integer

        pref = env.pref

        if pref.dump_mode?
            STDERR.puts
            STDERR.printf "________ Source: '%s' ________\n", file_name
            source.each_line.with_index do |line, index|
                STDERR.printf "%04d: %s", index + 1, line
            end
        end

        if pref.dump_mode?
            STDERR.puts
            STDERR.printf "________ Tokens: '%s' ________", file_name
        end

        init_tokens = []
        init_lexer  = LL.make_initial_lexer file_name, init_line_num
        scanner     = ::StringScanner.new source
        tokens, _lexer = LL.lex(
            init_tokens, init_lexer, scanner, pref
        ) do |_event, _matched, output_tokens, _lexer, before_line_num|

            if pref.dump_mode?
                output_tokens.each do |token|
                    tk_line_num = token.loc.line_num

                    if tk_line_num != before_line_num
                        STDERR.printf "\n%04d: ", tk_line_num + 1
                    end

                    unless token && token.separator?
                        STDERR.printf "%s ", token.to_s
                        STDERR.flush
                    end
                end
            end
        end

        if pref.dump_mode?
            STDERR.puts
        end

        [
            tokens,
            env.update_source(file_name, source, init_line_num)
        ]
    end
end


module_function

    def setup_interpreter(*opts)
        ASSERT.kind_of opts, ::Array

        Interpreter.setup opts
    end


    def va_context(interp)
        ASSERT.kind_of interp, Interpreter

        interp.env.va_context
    end


    def eval_decls(interp, source, opts = {})
        ASSERT.kind_of interp, Interpreter
        ASSERT.kind_of source, ::String
        ASSERT.kind_of opts,   ::Hash

        interp.eval_decls source, opts
    end


    def eval_expr(interp, source, opts = {})
        ASSERT.kind_of interp, Interpreter
        ASSERT.kind_of source, ::String
        ASSERT.kind_of opts,   ::Hash

        interp.eval_expr source, opts
    end

end # Umu::Api

end # Umu
