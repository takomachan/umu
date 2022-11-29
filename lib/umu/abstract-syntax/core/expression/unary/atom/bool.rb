require 'umu/common'


module Umu

module AbstractSyntax

module Core

module Expression

module Unary

module Atom

class Bool < Abstract
	def initialize(loc, obj)
		ASSERT.bool obj

		super
	end


	def to_s
		if self.obj
			'TRUE'
		else
			'FALSE'
		end
	end


	def __evaluate__(_env, _event)
		VC.make_bool self.obj
	end
end

end # Umu::AbstractSyntax::Core::Expression::Unary::Atom

end # Umu::AbstractSyntax::Core::Expression::Unary


module_function

	def make_bool(loc, obj)
		ASSERT.kind_of	loc, L::Location
		ASSERT.bool		obj

		Unary::Atom::Bool.new(loc, obj).freeze
	end

end	# Umu::AbstractSyntax::Core::Expression

end	# Umu::AbstractSyntax::Core

end	# Umu::AbstractSyntax

end	# Umu
