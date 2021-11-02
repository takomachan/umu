require 'umu/common/assertion'



module Umu

module Lexical

class Position < Abstraction::CartesianProduct
	attr_reader :file_name
	attr_reader :line_num


	def initialize(file_name, line_num)
		ASSERT.kind_of file_name, ::String
		ASSERT.kind_of line_num,  ::Integer

		@file_name = file_name
		@line_num  = line_num
	end


	def ==(other)
		other.kind_of?(self.class) &&
			self.file_name == other.file_name &&
			self.line_num == other.line_num
	end


	def to_s
		format "#%d in \"%s\"", self.line_num, self.file_name
	end


	def next_line_num(n = 1)
		ASSERT.kind_of n, ::Integer

		new_position = self.class.new self.file_name, self.line_num + n

		ASSERT.kind_of new_position, Position
	end
end


INITIAL_POSITION = Position.new '', 0


module_function

	def make_position(file_name, line_num)
		ASSERT.kind_of file_name, ::String
		ASSERT.kind_of line_num,  ::Integer

		Position.new(file_name.freeze, line_num).freeze
	end


	def make_initial_position
		INITIAL_POSITION
	end

end # Umu::Lexcical

end # Umu