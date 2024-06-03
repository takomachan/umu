# vim: set nu ai sw=4 ts=4 :
# coding: utf-8
# frozen_string_literal: true

require 'umu/common'
require 'umu/lexical/location'


module Umu

module ConcreteSyntax

module Core

module Expression

module Unary

module Container

class Tuple < Abstract
	def initialize(loc, exprs)
		ASSERT.kind_of	exprs, ::Array
		ASSERT.assert	exprs.size >= 2

		super
	end


	def to_s
		format "(%s)", self.map(&:to_s).join(', ')
	end


private

	def __desugar__(env, event)
		new_env = env.enter event

		ASCE.make_tuple(self.loc, self.map { |elem| elem.desugar(new_env) })
	end
end

end	# Umu::ConcreteSyntax::Core::Expression::Unary::Container

end	# Umu::ConcreteSyntax::Core::Expression::Unary


module_function

	def make_tuple(loc, exprs)
		ASSERT.kind_of loc,		L::Location
		ASSERT.kind_of exprs,	::Array

		Unary::Container::Tuple.new(loc, exprs.freeze).freeze
	end

end	# Umu::ConcreteSyntax::Core::Expression

end	# Umu::ConcreteSyntax::Core

end	# Umu::ConcreteSyntax

end	# Umu
