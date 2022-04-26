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



class Atom < Abstraction::Symbol
	def to_s
		format "ATOM(%s)", self.sym
	end


	def to_racc_token
		:ATOM
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



class Integer < Abstraction::Abstract
	def initialize(pos, val)
		ASSERT.kind_of val, ::Integer

		super
	end


	def to_s
		format "INTEGER(%d)", self.val
	end


	def to_racc_token
		:INTEGER
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


	def make_atom(pos, val)
		ASSERT.kind_of pos, L::Position
		ASSERT.kind_of val, ::String

		Atom.new(pos, val.freeze).freeze
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


	def make_integer(pos, val)
		ASSERT.kind_of pos, L::Position
		ASSERT.kind_of val, ::Integer

		Integer.new(pos, val).freeze
	end


	def make_real(pos, val)
		ASSERT.kind_of pos, L::Position
		ASSERT.kind_of val, ::Float

		Real.new(pos, val).freeze
	end

end # Umu::Lexical::Token

end # Umu::Lexical

end # Umu
