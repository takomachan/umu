require 'umu/common'
require 'umu/environment/tracer/tracer'


module Umu

module AbstractSyntax

module Core

module Expression

module Unary

module Base

class Abstract < Unary::Abstract
	def evaluate(env)
		value = E::Tracer.trace_single(
					env.pref,
					env.trace_stack.count,
					'Eval(Expr)',
					self.class,
					self.pos,
					self.to_s
				) { |event|
					__evaluate__ env, event
				}

		SAR.make_value value
	end
end

end # Umu::AbstractSyntax::Core::Expression::Unary::Base

end # Umu::AbstractSyntax::Core::Expression::Unary

end # Umu::AbstractSyntax::Core::Expression

end	# Umu::AbstractSyntax::Core

end	# Umu::AbstractSyntax

end	# Umu
