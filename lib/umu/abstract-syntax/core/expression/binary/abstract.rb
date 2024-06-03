# vim: set nu ai sw=4 ts=4 :
# coding: utf-8
# frozen_string_literal: true

require 'umu/common'
require 'umu/environment/tracer/tracer'


module Umu

module AbstractSyntax

module Core

module Expression

module Binary

class Abstract < Expression::Abstract
	attr_reader	:lhs_expr, :rhs


	def initialize(loc, lhs_expr, rhs)
		ASSERT.kind_of lhs_expr,	ASCE::Abstract
		ASSERT.kind_of rhs,			::Object

		super(loc)

		@lhs_expr	= lhs_expr
		@rhs		= rhs
	end
end

end	# Umu::AbstractSyntax::Core::Expression::Binary

end	# Umu::AbstractSyntax::Core::Expression

end	# Umu::AbstractSyntax::Core

end	# Umu::AbstractSyntax

end	# Umu
