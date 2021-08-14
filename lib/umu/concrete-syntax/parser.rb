require 'umu/common'
require 'umu/lexical/lexer'
require 'umu/concrete-syntax'
require 'umu/concrete-syntax/grammar.tab'



module Umu

module ConcreteSyntax

class Parser
	attr_reader	:tokens


	def parse(tokens)
		ASSERT.kind_of tokens, ::Array

		@tokens = tokens.reject { |token|
			ASSERT.kind_of token, LT::Abstraction::Abstract

			token.separator?
		}.to_enum

		syntaxes = do_parse
		ASSERT.kind_of syntaxes, ::Array
	end


	def next_token
		begin
			token = self.tokens.next

			[token.to_racc_token, token]

		rescue ::StopIteration
			[false, nil]
		end
	end


	def on_error(racc_token_id, token, _stack)
		ASSERT.kind_of		racc_token_id,	::Integer
		ASSERT.opt_kind_of	token,			LT::Abstraction::Abstract
=begin
		STDERR.printf("Error Token: %s\n",
			{
				:racc_token	=> token_to_str(racc_token_id),
				:token		=> token
			}.inspect
		)
=end
		raise (
			if token
				X::SyntaxError.new(
					token.pos,
					"Syntax error near: %s", token.to_s
				)
			else
				X::SyntaxErrorWithoutPosition.new "Syntax error"
			end
		)
	end
end

end # Umu::ConcreteSyntax

end # Umu
