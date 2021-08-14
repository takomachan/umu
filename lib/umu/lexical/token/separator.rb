require 'umu/common'
require 'umu/lexical/position'



module Umu

module Lexical

module Token

module Separator

class Newline < Abstraction::Abstract
	alias opt_val val


	def initialize(pos, opt_val)
		ASSERT.opt_kind_of opt_val, ::String

		super
	end


	def to_s
		if self.opt_val
			format "NEWLINE(%s)", self.val.inspect
		else
			"NEWLINE"
		end
	end


	def separator?
		true
	end
end



class Comment < Abstraction::String
	def to_s
		format "COMMENT(%s)", self.val.inspect
	end


	def separator?
		true
	end
end



class White < Abstraction::String
	def to_s
		format "WHITE(%s)", self.val.inspect
	end


	def separator?
		true
	end
end

end # Umu::Lexical::Token::Separator



module_function

	def make_newline(pos, opt_val)
		ASSERT.kind_of		pos,		L::Position
		ASSERT.opt_kind_of	opt_val,	::String

		Separator::Newline.new(pos, opt_val.freeze).freeze
	end


	def make_comment(pos, val)
		ASSERT.kind_of pos,	L::Position
		ASSERT.kind_of val,	::String

		Separator::Comment.new(pos, val.freeze).freeze
	end


	def make_white(pos, val)
		ASSERT.kind_of pos,	L::Position
		ASSERT.kind_of val,	::String

		Separator::White.new(pos, val.freeze).freeze
	end

end # Umu::Lexical::Token

end # Umu::Lexical

end # Umu
