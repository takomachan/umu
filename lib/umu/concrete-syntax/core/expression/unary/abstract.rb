# vim: set nu ai sw=4 ts=4 :
# coding: utf-8
# frozen_string_literal: true

require 'umu/common'


module Umu

module ConcreteSyntax

module Core

module Expression

module Unary

class Abstract < Expression::Abstract
	attr_reader :obj


	def initialize(loc, obj)
		ASSERT.kind_of obj, ::Object

		super(loc)

		@obj = obj
	end
end

end	# Umu::ConcreteSyntax::Core::Expression::Unary

end	# Umu::ConcreteSyntax::Core::Expression

end	# Umu::ConcreteSyntax::Core

end	# Umu::ConcreteSyntax

end	# Umu
