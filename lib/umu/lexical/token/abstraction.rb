# vim: set nu ai sw=4 ts=4 :
# coding: utf-8
# frozen_string_literal: true

require 'umu/common'
require 'umu/lexical/location'



module Umu

module Lexical

module Token

module Abstraction

class Abstract < Umu::Abstraction::Model
	attr_reader :val


	def initialize(loc, val)
		ASSERT.kind_of loc,	L::Location
		ASSERT.kind_of val,	::Object

		super(loc)

		@val = val
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


	def initialize(loc, val)
		ASSERT.kind_of val, ::String

		super(loc, val.to_sym)
	end
end



class String < Abstract
	def initialize(loc, val)
		ASSERT.kind_of val, ::String

		super
	end
end

end # Umu::Lexical::Token::Abstraction

end # Umu::Lexical::Token

end # Umu::Lexical

end # Umu
