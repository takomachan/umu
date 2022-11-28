require 'umu/common'
require 'umu/lexical/location'



module Umu

module Lexical

module Token

class ReservedWord < Abstraction::Symbol
	def initialize(loc, val)
		ASSERT.kind_of val, ::String

		super(loc, val.upcase)
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



class Symbol < Abstraction::Symbol
	def to_s
		format "SYM(%s)", self.sym
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
	def initialize(loc, val)
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
	def initialize(loc, val)
		ASSERT.kind_of val, ::Integer

		super
	end


	def to_s
		format "INTEGER(%s)", self.val.to_s
	end


	def to_racc_token
		:INTEGER
	end
end



class Float < Abstraction::Abstract
	def initialize(loc, val)
		ASSERT.kind_of val, ::Float

		super
	end


	def to_s
		format "FLOAT(%s)", self.val.to_s
	end


	def to_racc_token
		:FLOAT
	end
end



module_function

	def make_reserved_word(loc, val)
		ASSERT.kind_of loc, L::Location
		ASSERT.kind_of val, ::String

		ReservedWord.new(loc, val.freeze).freeze
	end


	def make_reserved_symbol(loc, val)
		ASSERT.kind_of loc, L::Location
		ASSERT.kind_of val, ::String

		ReservedSymbol.new(loc, val.freeze).freeze
	end


	def make_symbol(loc, val)
		ASSERT.kind_of loc, L::Location
		ASSERT.kind_of val, ::String

		Symbol.new(loc, val.freeze).freeze
	end


	def make_identifier(loc, val)
		ASSERT.kind_of loc, L::Location
		ASSERT.kind_of val, ::String

		Identifier.new(loc, val.freeze).freeze
	end


	def make_string(loc, val)
		ASSERT.kind_of loc, L::Location
		ASSERT.kind_of val, ::String

		String.new(loc, val.freeze).freeze
	end


	def make_integer(loc, val)
		ASSERT.kind_of loc, L::Location
		ASSERT.kind_of val, ::Integer

		Integer.new(loc, val).freeze
	end


	def make_float(loc, val)
		ASSERT.kind_of loc, L::Location
		ASSERT.kind_of val, ::Float

		Float.new(loc, val).freeze
	end

end # Umu::Lexical::Token

end # Umu::Lexical

end # Umu
