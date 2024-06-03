# vim: set nu ai sw=4 ts=4 :
# coding: utf-8
# frozen_string_literal: true

require 'umu/common'
require 'umu/abstraction'


module Umu

module ConcreteSyntax

class Abstract < Abstraction::Model
	def desugar(env)
		E::Tracer.trace(
					env.pref,
					env.trace_stack.count,
					'Desu',
					self.class,
					self.loc,
					self.to_s
				) { |event|
					__desugar__ env, event
				}
	end


private

	def __desugar__(env, event)
		raise X::SubclassResponsibility
	end
end

end	# Umu::ConcreteSyntax

end	# Umu
