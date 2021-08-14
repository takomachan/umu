require 'umu/common'
require 'umu/lexical/position'



module Umu

module Lexical

module Token

module Abstraction

class Abstract
	attr_reader :val
	attr_reader :pos


	def initialize(pos, val)
		ASSERT.kind_of pos,	L::Position
		ASSERT.kind_of val,	::Object

		@pos	= pos
		@val	= val
	end


	def to_s
		raise X::SubclassResponsibility
	end


	def to_racc_token
		raise X::SubclassResponsibility
	end


	def separator?
		false
	end
end



class Symbol < Abstract
	alias sym val


	def initialize(pos, val)
		ASSERT.kind_of val, ::String

		super(pos, val.to_sym)
	end
end



class String < Abstract
	def initialize(pos, val)
		ASSERT.kind_of val, ::String

		super
	end
end

end # Umu::Lexical::Token::Abstraction

end # Umu::Lexical::Token

end # Umu::Lexical

end # Umu
