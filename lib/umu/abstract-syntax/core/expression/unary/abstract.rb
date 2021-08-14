require 'umu/common'
require 'umu/environment/tracer/tracer'


module Umu

module AbstractSyntax

module Core

module Expression

module Unary

class Abstract < Expression::Abstract
	attr_reader	:obj


	def initialize(pos, obj)
		ASSERT.kind_of obj, ::Object

		super(pos)

		@obj = obj
	end
end

end # Umu::AbstractSyntax::Core::Expression::Unary

end	# Umu::AbstractSyntax::Core::Expression

end	# Umu::AbstractSyntax::Core

end	# Umu::AbstractSyntax

end	# Umu
