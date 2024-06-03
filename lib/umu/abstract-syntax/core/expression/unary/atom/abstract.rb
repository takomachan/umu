# vim: set nu ai sw=4 ts=4 :
# coding: utf-8
# frozen_string_literal: true

require 'umu/common'
require 'umu/environment/tracer/tracer'


module Umu

module AbstractSyntax

module Core

module Expression

module Unary

module Atom

class Abstract < Unary::Abstract
	def evaluate(env)
		value = E::Tracer.trace_single(
					env.pref,
					env.trace_stack.count,
					'Eval(Expr)',
					self.class,
					self.loc,
					self.to_s
				) { |event|
					__evaluate__ env, event
				}

		ASR.make_value value
	end
end

end # Umu::AbstractSyntax::Core::Expression::Unary::Atom

end # Umu::AbstractSyntax::Core::Expression::Unary

end # Umu::AbstractSyntax::Core::Expression

end	# Umu::AbstractSyntax::Core

end	# Umu::AbstractSyntax

end	# Umu
