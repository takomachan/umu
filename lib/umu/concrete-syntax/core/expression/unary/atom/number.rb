require 'umu/common'
require 'umu/lexical/position'


module Umu

module ConcreteSyntax

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


private

	def __desugar__(_env, _event)
		SACE.make_int self.pos, self.obj
	end
end


class Real < Abstract
	def initialize(pos, obj)
		ASSERT.kind_of obj, ::Float

		super
	end


private

	def __desugar__(_env, _event)
		SACE.make_real self.pos, self.obj
	end
end

end	# Umu::ConcreteSyntax::Expression::Core::Unary::Number::Atom

end	# Umu::ConcreteSyntax::Expression::Core::Unary::Number

end	# Umu::ConcreteSyntax::Expression::Core::Unary



module_function

	def make_int(pos, obj)
		ASSERT.kind_of pos,	L::Position
		ASSERT.kind_of obj, ::Integer

		Unary::Atom::Number::Int.new(pos, obj).freeze
	end


	def make_real(pos, obj)
		ASSERT.kind_of pos,	L::Position
		ASSERT.kind_of obj, ::Float

		Unary::Atom::Number::Real.new(pos, obj).freeze
	end

end	# Umu::ConcreteSyntax::Expression::Core

end	# Umu::ConcreteSyntax::Core

end	# Umu::ConcreteSyntax

end	# Umu
