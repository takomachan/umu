require 'strscan'

require 'umu/common'
require 'umu/lexical/position'
require 'umu/lexical/token'



module Umu

module Lexical

module Lexer

module_function

	def make_initial_lexer(file_name, line_num)
		ASSERT.kind_of file_name,	::String
		ASSERT.kind_of line_num,	::Integer

		pos = L.make_position file_name, line_num

		Separator.new(pos, [].freeze).freeze
	end


	def lex(init_tokens, init_lexer, scanner, pref)
		ASSERT.kind_of init_tokens,		::Array
		ASSERT.kind_of scanner,			::StringScanner
		ASSERT.kind_of pref,			E::Preference

		pair = loop.inject(
			 [init_tokens, init_lexer, 0  ]
		) { |(tokens,      lexer,      before_line_num), _|

			break [tokens, lexer] if scanner.eos?

			event, matched, opt_token, next_lexer = lexer.lex scanner

			if block_given?
				yield event, matched, opt_token, next_lexer, before_line_num
			end

			if opt_token
				token = opt_token

				[tokens + [token], next_lexer, token.pos.line_num]
			else
				[tokens,           next_lexer, before_line_num]
			end
		}.freeze

		ASSERT.tuple_of pair, [::Array, LL::Abstract]
	end

end # Umu::Lexical::Lexer

end # Umu::Lexical

end # Umu
