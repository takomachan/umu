# vim: set nu ai sw=4 ts=4 :
# coding: utf-8
# frozen_string_literal: true

require 'umu/common'


module Umu

module AbstractSyntax

module Core

module Expression

module Unary

module Atom

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

end # Umu::AbstractSyntax::Core::Expression::Unary::Atom

end # Umu::AbstractSyntax::Core::Expression::Unary


module_function

	def make_symbol(loc, obj)
		ASSERT.kind_of loc,	L::Location
		ASSERT.kind_of obj,	::Symbol

		Unary::Atom::Symbol.new(loc, obj).freeze
	end

end	# Umu::AbstractSyntax::Core::Expression

end	# Umu::AbstractSyntax::Core

end	# Umu::AbstractSyntax

end	# Umu
