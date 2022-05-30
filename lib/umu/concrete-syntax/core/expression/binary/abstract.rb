require 'umu/common'
require 'umu/lexical/location'


module Umu

module ConcreteSyntax

module Core

module Expression

module Binary

class Abstract < Expression::Abstract
	attr_reader :lhs_expr, :rhs


	def initialize(loc, lhs_expr, rhs)
		ASSERT.kind_of lhs_expr,	SCCE::Abstract
		ASSERT.kind_of rhs,			::Object

		super(loc)

		@lhs_expr	= lhs_expr
		@rhs		= rhs
	end
end

end	# Umu::ConcreteSyntax::Core::Expression::Binary

end	# Umu::ConcreteSyntax::Core::Expression

end	# Umu::ConcreteSyntax::Core

end	# Umu::ConcreteSyntax

end	# Umu
