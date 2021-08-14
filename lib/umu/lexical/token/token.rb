require 'umu/common'
require 'umu/lexical/position'



module Umu

module Lexical

module Token

class ReservedWord < Abstraction::Symbol
	def initialize(pos, val)
		ASSERT.kind_of val, ::String

		super(pos, val.upcase)
	end


	def to_s
		self.sym.to_s
	end


	alias to_racc_token sym
end



class ReservedSymbol < Abstraction::Symbol
	def to_s
		format "'%s'", self.sym
	end


	def to_racc_token
		self.sym.to_s
	end
end



class UserSymbol < Abstraction::Symbol
	def to_s
		format "SYMBOL(%s)", self.sym
	end


	def to_racc_token
		:SYMBOL
	end
end



class Identifier < Abstraction::Symbol
	def to_s
		format "ID(%s)", self.sym
	end


	def to_racc_token
		:ID
	end
end



class String < Abstraction::String
	def initialize(pos, val)
		ASSERT.kind_of val, ::String

		super
	end


	def to_s
		format "STRING(\"%s\")", L::Escape.unescape(self.val)
	end


	def to_racc_token
		:STRING
	end
end



class Int < Abstraction::Abstract
	def initialize(pos, val)
		ASSERT.kind_of val, ::Integer

		super
	end


	def to_s
		format "INT(%d)", self.val
	end


	def to_racc_token
		:INT
	end
end



class Real < Abstraction::Abstract
	def initialize(pos, val)
		ASSERT.kind_of val, ::Float

		super
	end


	def to_s
		format "REAL(%d)", self.val
	end


	def to_racc_token
		:REAL
	end
end



module_function

	def make_reserved_word(pos, val)
		ASSERT.kind_of pos, L::Position
		ASSERT.kind_of val, ::String

		ReservedWord.new(pos, val.freeze).freeze
	end


	def make_reserved_symbol(pos, val)
		ASSERT.kind_of pos, L::Position
		ASSERT.kind_of val, ::String

		ReservedSymbol.new(pos, val.freeze).freeze
	end


	def make_user_symbol(pos, val)
		ASSERT.kind_of pos, L::Position
		ASSERT.kind_of val, ::String

		UserSymbol.new(pos, val.freeze).freeze
	end


	def make_identifier(pos, val)
		ASSERT.kind_of pos, L::Position
		ASSERT.kind_of val, ::String

		Identifier.new(pos, val.freeze).freeze
	end


	def make_string(pos, val)
		ASSERT.kind_of pos, L::Position
		ASSERT.kind_of val, ::String

		String.new(pos, val.freeze).freeze
	end


	def make_int(pos, val)
		ASSERT.kind_of pos, L::Position
		ASSERT.kind_of val, ::Integer

		Int.new(pos, val).freeze
	end


	def make_real(pos, val)
		ASSERT.kind_of pos, L::Position
		ASSERT.kind_of val, ::Float

		Real.new(pos, val).freeze
	end

end # Umu::Lexical::Token

end # Umu::Lexical

end # Umu
