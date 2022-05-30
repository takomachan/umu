require 'umu/common'
require 'umu/lexical/escape'
require 'umu/lexical/location'


module Umu

module ConcreteSyntax

module Core

module Expression

module Unary

module Base

class Abstract < Unary::Abstract
	def desugar(env)
		E::Tracer.trace_single(
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
end

end	# Umu::ConcreteSyntax::Core::Expression::Unary::Base

end	# Umu::ConcreteSyntax::Core::Expression::Unary

end	# Umu::ConcreteSyntax::Core::Expression

end	# Umu::ConcreteSyntax::Core

end	# Umu::ConcreteSyntax

end	# Umu
