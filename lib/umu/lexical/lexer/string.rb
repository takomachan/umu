require 'strscan'

require 'umu/common'
require 'umu/lexical/location'
require 'umu/lexical/token'
require 'umu/lexical/escape'



module Umu

module Lexical

module Lexer

module String

class Abstract < Lexer::Abstract
	attr_reader :buf


	def self.deconstruct_keys
		{
			:buf => ::String
		}
	end


	def initialize(loc, braket_stack, buf)
		ASSERT.kind_of loc,				L::Location
		ASSERT.kind_of braket_stack,	::Array
		ASSERT.kind_of buf,				::String

		super(loc, braket_stack)

		@buf = buf
	end


	def to_s
		format("%s {braket_stack=%s, buf=%s} -- %s",
			E::Tracer.class_to_string(self.class),
			self.braket_stack.inspect,
			self.buf.inspect,
			self.loc.to_s
		)
	end


	def lex(scanner)
		ASSERT.kind_of scanner, ::StringScanner

		case
		# End-String
		when scanner.scan(/"/)
			[
				:EndString,

				scanner.matched,

				__make_token__(loc, self.buf),

				__make_separator__
			]

		# New-line
		when scanner.skip(/\n/)
			raise X::LexicalError.new(
				loc,
				"Unexpected end-string: '\"%s'", self.buf
			)

		# Escapes
		when scanner.scan(/\\./)
			opt_esc = L::Escape.opt_escape scanner.matched
			unless opt_esc
				raise X::LexicalError.new(
					loc,
					"Unknown escape-character: '%s' after '\"%s'",
												scanner.matched, self.buf
				)
			end

			[
				:Escape,

				scanner.matched,

				nil,

				__make_state__(self.buf + opt_esc)
			]

		# Others
		when scanner.scan(/./)
			[
				:Other,

				scanner.matched,
				
				nil,

				__make_state__(self.buf + scanner.matched)
			]

		else
			ASSERT.abort scanner.inspect
		end
	end


private

	def __make_token__(loc, val)
		ASSERT.kind_of loc, L::Location
		ASSERT.kind_of val, ::String

		raise X::SubclassResponsibility
	end


	def __make_state__(buf)
		ASSERT.kind_of buf, ::String

		raise X::SubclassResponsibility
	end
end



class Basic < Abstract
	def __make_token__(loc, val)
		ASSERT.kind_of loc, L::Location
		ASSERT.kind_of val, ::String

		LT.make_string loc, val
	end


	def __make_state__(buf)
		ASSERT.kind_of buf, ::String

		__make_string__ buf
	end
end



class Symbolized < Abstract
	def __make_token__(loc, val)
		ASSERT.kind_of loc, L::Location
		ASSERT.kind_of val, ::String

		esc_char = L::Escape.find_escape val
		if esc_char
			raise X::LexicalError.new(
					loc,
					"Escape character in symbolized string: '%s'",
						L::Escape.unescape(esc_char)
				)
		end

		LT.make_symbol loc, val
	end


	def __make_state__(buf)
		ASSERT.kind_of buf, ::String

		__make_symbolized_string__ buf
	end
end

end # Umu::Lexical::Lexer::String

end # Umu::Lexical::Lexer

end # Umu::Lexical

end # Umu
