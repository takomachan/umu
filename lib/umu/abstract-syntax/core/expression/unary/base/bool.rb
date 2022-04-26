require 'umu/common'


module Umu

module AbstractSyntax

module Core

module Expression

module Unary

module Base

class Bool < Abstract
	def initialize(pos, obj)
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
		VC.make_bool self.pos, self.obj
	end
end

end # Umu::AbstractSyntax::Core::Expression::Unary::Base

end # Umu::AbstractSyntax::Core::Expression::Unary


module_function

	def make_bool(pos, obj)
		ASSERT.kind_of	pos, L::Position
		ASSERT.bool		obj

		Unary::Base::Bool.new(pos, obj).freeze
	end

end	# Umu::AbstractSyntax::Core::Expression

end	# Umu::AbstractSyntax::Core

end	# Umu::AbstractSyntax

end	# Umu
