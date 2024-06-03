# vim: set nu ai sw=4 ts=4 :
# coding: utf-8
# frozen_string_literal: true

require 'umu/common'


module Umu

module AbstractSyntax

module Core

module Expression

module Unary

class Raise < Abstract
	alias exception_class obj
	attr_reader :msg


	def initialize(loc, exception_class, msg)
		ASSERT.subclass_of	exception_class,	X::Abstraction::RuntimeError
		ASSERT.kind_of		msg,				::String

		super(loc, exception_class)

		@msg = msg
	end


	def to_s
		format "%%RAISE %s", self.exception_class.to_s
	end


	def __evaluate__(env, _event)
		raise self.exception_class.new(self.loc, env, self.msg)
	end
end

end # Umu::AbstractSyntax::Core::Expression::Unary


module_function

	def make_raise(loc, exception_class, msg)
		ASSERT.kind_of		loc,				L::Location
		ASSERT.subclass_of	exception_class,	X::Abstraction::RuntimeError
		ASSERT.kind_of		msg,				::String

		Unary::Raise.new(loc, exception_class, msg).freeze
	end

end	# Umu::AbstractSyntax::Core::Expression

end	# Umu::AbstractSyntax::Core

end	# Umu::AbstractSyntax

end	# Umu
