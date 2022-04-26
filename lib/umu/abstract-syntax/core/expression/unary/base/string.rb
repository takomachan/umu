require 'umu/common'
require 'umu/lexical/escape'


module Umu

module AbstractSyntax

module Core

module Expression

module Unary

module Base

class String < Abstract
	def initialize(pos, obj)
		ASSERT.kind_of obj, ::String

		super
	end


	def to_s
		'"' + L::Escape.unescape(self.obj) + '"'
	end


	def __evaluate__(_env, _event)
		VC.make_string self.pos, self.obj
	end
end

end # Umu::AbstractSyntax::Core::Expression::Unary::Base

end # Umu::AbstractSyntax::Core::Expression::Unary


module_function

	def make_string(pos, obj)
		ASSERT.kind_of pos,	L::Position
		ASSERT.kind_of obj,	::String

		Unary::Base::String.new(pos, obj.freeze).freeze
	end

end	# Umu::AbstractSyntax::Core::Expression

end	# Umu::AbstractSyntax::Core

end	# Umu::AbstractSyntax

end	# Umu
