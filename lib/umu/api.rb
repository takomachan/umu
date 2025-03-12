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

        Interpreter.new env
    end


    attr_reader :env, :parser

    def initialize(env)
        ASSERT.kind_of env, E::Entry

        @env    = env
        @parser = CS::Parser.new
    end


    def eval_decls(source, file_name, init_line_num)
        ASSERT.kind_of source,          ::String
        ASSERT.kind_of file_name,       ::String
        ASSERT.kind_of init_line_num,   ::Integer

        tokens, lexed_env = __transform_source_to_tokens__(
                                source, file_name, self.env, init_line_num
                            )

        csyn_stmts = self.parser.parse tokens

        final_env = csyn_stmts.inject(lexed_env) { |env, csyn_stmt|
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

        Api.make_interpreter final_env
    end


    def eval_expr(source, file_name, init_line_num)
        ASSERT.kind_of source,          ::String
        ASSERT.kind_of file_name,       ::String
        ASSERT.kind_of init_line_num,   ::Integer

        tokens, lexed_env = __transform_source_to_tokens__(
                                source, file_name, self.env, init_line_num
                            )

        csyn_stmts = self.parser.parse tokens
        unless csyn_stmts.count == 1
            raise X::CommandError.new(
                "Unexpected multiple expressions: %s", csyn_stmts.to_s
            )
        end
        csyn_stmt = csyn_stmts[0]
        ASSERT.kind_of csyn_stmt, CS::Abstract

        result = Umu::Commander.execute(csyn_stmt, lexed_env)
        ASSERT.kind_of result, ASR::Abstract

        value = case result
                when ASR::Value
                    result.value
                when ASR::Environment
                    raise X::CommandError.new(
                        "Unexpected environment: %s", result.env.inspect
                    )
                else
                    ASSERT.abort result.inspect
                end

        ASSERT.kind_of value, VC::Top
    end


private

    def __transform_source_to_tokens__(
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

    def setup(opts = [])
        ASSERT.kind_of opts, ::Array

        Interpreter.setup opts
    end


    def make_interpreter(opts = [])
        ASSERT.kind_of opts, ::Array

        Interpreter.setup opts
    end


    def eval_decls(interp, source, file_name = '<_>', init_line_num = 0)
        ASSERT.kind_of interp,          Interpreter
        ASSERT.kind_of source,          ::String
        ASSERT.kind_of file_name,       ::String
        ASSERT.kind_of init_line_num,   ::Integer

        interp.eval_decls source, file_name, init_line_num
    end


    def eval_expr(interp, source, file_name = '<_>', init_line_num = 0)
        ASSERT.kind_of interp,          Interpreter
        ASSERT.kind_of source,          ::String
        ASSERT.kind_of file_name,       ::String
        ASSERT.kind_of init_line_num,   ::Integer

        interp.eval_expr source, file_name, init_line_num
    end

end # Umu::Api

end # Umu
