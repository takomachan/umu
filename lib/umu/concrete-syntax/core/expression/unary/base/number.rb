require 'umu/common'
require 'umu/lexical/position'


module Umu

module ConcreteSyntax

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


private

	def __desugar__(_env, _event)
		SACE.make_integer self.pos, self.obj
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

end	# Umu::ConcreteSyntax::Expression::Core::Unary::Number::Base

end	# Umu::ConcreteSyntax::Expression::Core::Unary::Number

end	# Umu::ConcreteSyntax::Expression::Core::Unary



module_function

	def make_integer(pos, obj)
		ASSERT.kind_of pos,	L::Position
		ASSERT.kind_of obj, ::Integer

		Unary::Base::Number::Integer.new(pos, obj).freeze
	end


	def make_real(pos, obj)
		ASSERT.kind_of pos,	L::Position
		ASSERT.kind_of obj, ::Float

		Unary::Base::Number::Real.new(pos, obj).freeze
	end

end	# Umu::ConcreteSyntax::Expression::Core

end	# Umu::ConcreteSyntax::Core

end	# Umu::ConcreteSyntax

end	# Umu
