# vim: set nu ai sw=4 ts=4 :
# coding: utf-8
# frozen_string_literal: true

require 'strscan'

require 'umu/common'
require 'umu/lexical/location'
require 'umu/lexical/token'



module Umu

module Lexical

module Lexer

class Separator < Abstract
	def lex(scanner)
		ASSERT.kind_of scanner, ::StringScanner

		case
		# Begin-Comment
		when scanner.scan(/\(#/)
			[
				:BeginComment,

				scanner.matched,

				nil,

				__make_comment__(
					self.loc,	# Save current location
					1,
					''
				)
			]

		# New-line with optional Line-comment
		when scanner.scan(/(#.*)?\n/)
			[
				:NewLine,

				scanner.matched,

				LT.make_newline(loc, scanner.matched),

				__make_separator__(self.loc.next_line_num)
			]

		# Other white-chars -- space, tab, or carriage-return
		when scanner.scan(/[ \t\r]+/)
			[
				:White,

				scanner.matched,

				LT.make_white(loc, scanner.matched),

				self
			]

		# Unmatched
		else
			[
				:Unmatched,

				'',
				
				nil,

				__make_token__
			]
		end
	end
end

end # Umu::Lexical::Lexer

end # Umu::Lexical

end # Umu
