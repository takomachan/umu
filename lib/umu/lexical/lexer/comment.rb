require 'strscan'

require 'umu/common'
require 'umu/lexical/position'
require 'umu/lexical/token'



module Umu

module Lexical

module Lexer

class Comment < Abstract
	attr_reader :buf, :saved_pos, :comment_depth


	def initialize(pos, braket_stack, buf, saved_pos, comment_depth)
		ASSERT.kind_of pos,				L::Position
		ASSERT.kind_of braket_stack,	::Array
		ASSERT.kind_of buf,				::String
		ASSERT.kind_of saved_pos,		L::Position
		ASSERT.kind_of comment_depth,	::Integer

		super(pos, braket_stack)

		@buf			= buf
		@saved_pos		= saved_pos
		@comment_depth	= comment_depth
	end


	def to_s
		format("%s {braket_stack=%s, buf=%s, saved_pos=%s} -- %s",
			E::Tracer.class_to_string(self.class),
			self.braket_stack.inspect,
			self.buf.inspect,
			self.saved_pos.to_s,
			self.pos.to_s
		)
	end


	def in_comment?
		self.comment_depth != 0
	end


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
					self.saved_pos,
					self.comment_depth + 1,
					self.buf + scanner.matched
				)
			]

		# End-Comment
		when scanner.scan(/#\)/)
			[
				:EndComment,

				scanner.matched,

				LT.make_comment(
					self.saved_pos,	# Load Begin-Comment's position 
					self.buf
				),

				if self.comment_depth <= 1
					__make_separator__
				else
					__make_comment__(
						self.saved_pos,
						self.comment_depth - 1,
						self.buf + scanner.matched
					)
				end
			]

		# New-line
		when scanner.skip(/\n/)
			[
				:NewLine,

				scanner.matched,

				nil,

				__make_comment__(
					self.saved_pos,
					self.comment_depth,
					self.buf + scanner.matched,
					self.pos.next_line_num
				)
			]

		# Others
		when scanner.scan(/./)
			[
				:Other,

				scanner.matched,
				
				nil,

				__make_comment__(
					self.saved_pos,
					self.comment_depth,
					self.buf + scanner.matched
				)
			]

		else
			ASSERT.abort scanner.inspect
		end
	end
end

end # Umu::Lexical::Lexer

end # Umu::Lexical

end # Umu
