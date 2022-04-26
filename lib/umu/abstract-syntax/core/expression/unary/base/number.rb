require 'umu/common'


module Umu

module AbstractSyntax

module Core

module Expression

module Unary

module Base

module Number

class Abstract < Base::Abstract
	def initialize(pos, obj)
		ASSERT.kind_of obj, ::Numeric

		super
	end


	def to_s
		self.obj.to_s
	end
end


class Integer < Abstract
	def initialize(pos, obj)
		ASSERT.kind_of obj, ::Integer

		super
	end


	def __evaluate__(_env, _event)
		VC.make_integer self.pos, self.obj
	end
end


class Real < Abstract
	def initialize(pos, obj)
		ASSERT.kind_of obj, ::Float

		super
	end


	def __evaluate__(_env, _event)
		VC.make_real self.pos, self.obj
	end
end

end # Umu::AbstractSyntax::Core::Expression::Unary::Base::Number

end # Umu::AbstractSyntax::Core::Expression::Unary::Base

end # Umu::AbstractSyntax::Core::Expression::Unary


module_function

	def make_integer(pos, obj)
		ASSERT.kind_of pos,	L::Position
		ASSERT.kind_of obj,	::Integer

		Unary::Base::Number::Integer.new(pos, obj).freeze
	end


	def make_real(pos, obj)
		ASSERT.kind_of pos,	L::Position
		ASSERT.kind_of obj,	::Float

		Unary::Base::Number::Real.new(pos, obj).freeze
	end

end	# Umu::AbstractSyntax::Core::Expression

end	# Umu::AbstractSyntax::Core

end	# Umu::AbstractSyntax

end	# Umu
