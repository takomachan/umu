# vim: set nu ai sw=4 ts=4 :
# coding: utf-8
# frozen_string_literal: true

require 'umu/common'


module Umu

module AbstractSyntax

module Core

module Expression

class Abstract < Umu::AbstractSyntax::Abstract
	def evaluate(env)
		value = E::Tracer.trace(
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


	def simple?
		false
	end


private

	def __evaluate__(env, event)
		raise X::SubclassResponsibility
	end
end

end	# Umu::AbstractSyntax::Core::Expression

end	# Umu::AbstractSyntax::Core

end	# Umu::AbstractSyntax

end	# Umu
