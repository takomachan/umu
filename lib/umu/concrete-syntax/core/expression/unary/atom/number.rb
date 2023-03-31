require 'umu/common'
require 'umu/lexical/location'


module Umu

module ConcreteSyntax

module Core

module Expression

module Unary

module Atom

module Number

class Abstract < Atom::Abstract
	def initialize(loc, obj)
		ASSERT.kind_of obj, ::Numeric

		super
	end


	def to_s
		self.obj.to_s
	end
end


class Integer < Abstract
	def initialize(loc, obj)
		ASSERT.kind_of obj, ::Integer

		super
	end


	def to_value
		VC.make_integer self.obj
	end


private

	def __desugar__(_env, _event)
		SACE.make_integer self.loc, self.obj
	end
end


class Float < Abstract
	def initialize(loc, obj)
		ASSERT.kind_of obj, ::Float

		super
	end


	def to_value
		VC.make_float self.obj
	end


private

	def __desugar__(_env, _event)
		SACE.make_float self.loc, self.obj
	end
end

end	# Umu::ConcreteSyntax::Expression::Core::Unary::Number::Atom

end	# Umu::ConcreteSyntax::Expression::Core::Unary::Number

end	# Umu::ConcreteSyntax::Expression::Core::Unary



module_function

	def make_integer(loc, obj)
		ASSERT.kind_of loc,	L::Location
		ASSERT.kind_of obj, ::Integer

		Unary::Atom::Number::Integer.new(loc, obj).freeze
	end


	def make_float(loc, obj)
		ASSERT.kind_of loc,	L::Location
		ASSERT.kind_of obj, ::Float

		Unary::Atom::Number::Float.new(loc, obj).freeze
	end

end	# Umu::ConcreteSyntax::Expression::Core

end	# Umu::ConcreteSyntax::Core

end	# Umu::ConcreteSyntax

end	# Umu
