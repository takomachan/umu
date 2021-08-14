require 'strscan'

require 'umu/common'
require 'umu/lexical/position'
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
				nil,

				__make_comment__(
					self.pos,	# Save current position
					1,
					''
				)
			]

		# New-line with optional Line-comment
		when scanner.scan(/(#.*)?\n/)
			[
				LT.make_newline(pos, scanner.matched),

				__make_separator__(self.pos.next_line_num)
			]

		# Other white-chars -- space, tab, or carriage-return
		when scanner.scan(/[ \t\r]+/)
			[
				LT.make_white(pos, scanner.matched),

				self
			]

		# Unmatched
		else
			[
				nil,

				__make_token__
			]
		end
	end
end

end # Umu::Lexical::Lexer

end # Umu::Lexical

end # Umu
