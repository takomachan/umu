require 'umu/common'


module Umu

module AbstractSyntax

module Core

module Expression

module Unary

module Base

module Number

class Abstract < Base::Abstract
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


	def __evaluate__(_env, _event)
		VC.make_integer self.obj
	end
end


class Float < Abstract
	def initialize(loc, obj)
		ASSERT.kind_of obj, ::Float

		super
	end


	def __evaluate__(_env, _event)
		VC.make_float self.obj
	end
end

end # Umu::AbstractSyntax::Core::Expression::Unary::Base::Number

end # Umu::AbstractSyntax::Core::Expression::Unary::Base

end # Umu::AbstractSyntax::Core::Expression::Unary


module_function

	def make_integer(loc, obj)
		ASSERT.kind_of loc,	L::Location
		ASSERT.kind_of obj,	::Integer

		Unary::Base::Number::Integer.new(loc, obj).freeze
	end


	def make_float(loc, obj)
		ASSERT.kind_of loc,	L::Location
		ASSERT.kind_of obj,	::Float

		Unary::Base::Number::Float.new(loc, obj).freeze
	end

end	# Umu::AbstractSyntax::Core::Expression

end	# Umu::AbstractSyntax::Core

end	# Umu::AbstractSyntax

end	# Umu
