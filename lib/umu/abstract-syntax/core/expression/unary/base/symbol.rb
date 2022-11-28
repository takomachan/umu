require 'umu/common'


module Umu

module AbstractSyntax

module Core

module Expression

module Unary

module Base

class Symbol < Abstract
	def initialize(loc, obj)
		ASSERT.kind_of obj, ::Symbol

		super
	end


	def to_s
		'@' + self.obj.to_s
	end


	def __evaluate__(_env, _event)
		VC.make_symbol self.obj
	end
end

end # Umu::AbstractSyntax::Core::Expression::Unary::Base

end # Umu::AbstractSyntax::Core::Expression::Unary


module_function

	def make_symbol(loc, obj)
		ASSERT.kind_of loc,	L::Location
		ASSERT.kind_of obj,	::Symbol

		Unary::Base::Symbol.new(loc, obj).freeze
	end

end	# Umu::AbstractSyntax::Core::Expression

end	# Umu::AbstractSyntax::Core

end	# Umu::AbstractSyntax

end	# Umu
