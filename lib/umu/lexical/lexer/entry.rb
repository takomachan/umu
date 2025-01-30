# coding: utf-8
# frozen_string_literal: true



module Umu

module Lexical

module Lexer

module_function

    def make_initial_lexer(file_name, line_num)
        ASSERT.kind_of file_name,   ::String
        ASSERT.kind_of line_num,    ::Integer

        loc = LOC.make_location file_name, line_num

        Separator.new(loc, [].freeze).freeze
    end


    def lex(init_tokens, init_lexer, scanner, pref)
        ASSERT.kind_of init_tokens,     ::Array
        ASSERT.kind_of init_lexer,      LL::Abstract
        ASSERT.kind_of scanner,         ::StringScanner
        ASSERT.kind_of pref,            E::Preference

        pair = loop.inject(
             [init_tokens, init_lexer, 0  ]
        ) { |(tokens,      lexer,      before_line_num), _|

            break [tokens, lexer] if scanner.eos?

            event, matched, output_tokens, next_lexer = lexer.lex scanner
            ASSERT.kind_of event,           ::Symbol
            ASSERT.kind_of matched,         ::String
            ASSERT.kind_of output_tokens,   ::Array
            ASSERT.kind_of next_lexer,      LL::Abstract

            if block_given?
                yield event, matched, output_tokens,
                      next_lexer, before_line_num
            end


            [
                tokens + output_tokens,

                next_lexer,

                if output_tokens.empty?
                    before_line_num
                else
                    output_tokens[0].loc.line_num
                end
            ]
        }.freeze

        ASSERT.tuple_of pair, [::Array, LL::Abstract]
    end

end # Umu::Lexical::Lexer

end # Umu::Lexical

end # Umu
