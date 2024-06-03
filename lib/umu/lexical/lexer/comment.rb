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

class Comment < Abstract
	attr_reader :buf
	attr_reader :saved_loc
	attr_reader :comment_depth


	def self.deconstruct_keys
		{
			:buf			=> ::String,
			:saved_loc		=> L::Location,
			:comment_depth	=> ::Integer
		}
	end


	def initialize(loc, braket_stack, buf, saved_loc, comment_depth)
		ASSERT.kind_of loc,				L::Location
		ASSERT.kind_of braket_stack,	::Array
		ASSERT.kind_of buf,				::String
		ASSERT.kind_of saved_loc,		L::Location
		ASSERT.kind_of comment_depth,	::Integer

		super(loc, braket_stack)

		@buf			= buf
		@saved_loc		= saved_loc
		@comment_depth	= comment_depth
	end


	def to_s
		format("%s {braket_stack=%s, buf=%s, saved_loc=%s} -- %s",
			E::Tracer.class_to_string(self.class),
			self.braket_stack.inspect,
			self.buf.inspect,
			self.saved_loc.to_s,
			self.loc.to_s
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
					self.saved_loc,
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
					self.saved_loc,	# Load Begin-Comment's location 
					self.buf
				),

				if self.comment_depth <= 1
					__make_separator__
				else
					__make_comment__(
						self.saved_loc,
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
					self.saved_loc,
					self.comment_depth,
					self.buf + scanner.matched,
					self.loc.next_line_num
				)
			]

		# Others
		when scanner.scan(/./)
			[
				:Other,

				scanner.matched,
				
				nil,

				__make_comment__(
					self.saved_loc,
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
