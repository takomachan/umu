require 'umu/common'


module Umu

module AbstractSyntax

module Core

module Expression

module Unary

module Atom

module Number

class Abstract < Atom::Abstract
	def initialize(pos, obj)
		ASSERT.kind_of obj, ::Numeric

		super
	end


	def to_s
		self.obj.to_s
	end
end


class Int < Abstract
	def initialize(pos, obj)
		ASSERT.kind_of obj, ::Integer

		super
	end


	def __evaluate__(_env, _event)
		VC.make_int self.pos, self.obj
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

end # Umu::AbstractSyntax::Core::Expression::Unary::Atom::Number

end # Umu::AbstractSyntax::Core::Expression::Unary::Atom

end # Umu::AbstractSyntax::Core::Expression::Unary


module_function

	def make_int(pos, obj)
		ASSERT.kind_of pos,	L::Position
		ASSERT.kind_of obj,	::Integer

		Unary::Atom::Number::Int.new(pos, obj).freeze
	end


	def make_real(pos, obj)
		ASSERT.kind_of pos,	L::Position
		ASSERT.kind_of obj,	::Float

		Unary::Atom::Number::Real.new(pos, obj).freeze
	end

end	# Umu::AbstractSyntax::Core::Expression

end	# Umu::AbstractSyntax::Core

end	# Umu::AbstractSyntax

end	# Umu
