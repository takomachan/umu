require 'umu/common'


module Umu

module ConcreteSyntax

module Core

module Expression

module Unary

class Abstract < Expression::Abstract
	attr_reader :obj


	def initialize(pos, obj)
		ASSERT.kind_of obj, ::Object

		super(pos)

		@obj = obj
	end
end

end	# Umu::ConcreteSyntax::Core::Expression::Unary

end	# Umu::ConcreteSyntax::Core::Expression

end	# Umu::ConcreteSyntax::Core

end	# Umu::ConcreteSyntax

end	# Umu
