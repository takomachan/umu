require 'strscan'

require 'umu/common'
require 'umu/lexical/position'
require 'umu/lexical/token'



module Umu

module Lexical

module Lexer

class Abstract < Abstraction::Record
	attr_reader	:pos
	attr_reader	:braket_stack


	def self.deconstruct_keys
		{
			:pos			=> L::Position,
			:braket_stack	=> ::Array
		}
	end


	def initialize(pos, braket_stack)
		ASSERT.kind_of pos,				L::Position
		ASSERT.kind_of braket_stack,	::Array

		@pos			= pos
		@braket_stack	= braket_stack
	end


	def to_s
		format("%s {braket_stack=%s} -- %s",
			E::Tracer.class_to_string(self.class),
			self.braket_stack.inspect,
			self.pos.to_s
		)
	end


	def comment_depth
		0
	end


	def braket_depth
		self.braket_stack.length
	end


	def in_comment?
		false
	end


	def in_braket?
		not self.braket_stack.empty?
	end


	def between_braket?
		if self.in_comment?
			false
		elsif self.in_braket?
			false
		else
			true
		end
	end


	def lex(scanner)
		raise X::SubclassResponsibility
	end


private

	def __make_separator__(
		pos				= self.pos,
		braket_stack	= self.braket_stack
	)
		ASSERT.kind_of pos, L::Position

		Separator.new(
			pos, braket_stack.freeze
		).freeze
	end


	def __make_comment__(
		saved_pos,
		comment_depth,
		buf,
		pos				= self.pos,
		braket_stack	= self.braket_stack
	)
		ASSERT.kind_of saved_pos,		L::Position
		ASSERT.kind_of comment_depth,	::Integer
		ASSERT.kind_of buf,				::String
		ASSERT.kind_of pos,				L::Position

		Comment.new(
			pos, braket_stack.freeze, buf.freeze, saved_pos, comment_depth
		).freeze
	end


	def __make_token__(
		pos				= self.pos,
		braket_stack	= self.braket_stack
	)
		ASSERT.kind_of pos, L::Position

		Token.new(
			pos, braket_stack.freeze
		).freeze
	end


	def __make_string__(
		buf,
		pos				= self.pos,
		braket_stack	= self.braket_stack
	)
		ASSERT.kind_of buf, ::String
		ASSERT.kind_of pos, L::Position

		String::Basic.new(
			pos, braket_stack.freeze, buf.freeze
		).freeze
	end


	def __make_symbolized_string__(
		buf,
		pos				= self.pos,
		braket_stack	= self.braket_stack
	)
		ASSERT.kind_of buf, ::String
		ASSERT.kind_of pos, L::Position

		String::Symbolized.new(
			pos, braket_stack.freeze, buf.freeze
		).freeze
	end
end

end # Umu::Lexical::Lexer

end # Umu::Lexical

end # Umu
