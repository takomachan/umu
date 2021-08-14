require 'umu/common'


module Umu

module ConcreteSyntax

module Module

module Pattern

class Abstract < Abstraction::Model
	def desugar_value(expr, env)
		E::Tracer.trace(
					env.pref,
					env.trace_stack.count,
					'Desu(Val)',
					self.class,
					self.pos,
					self.to_s
				) { |event|
					__desugar_value__ expr, env, event
				}
	end


	def exported_vars
		raise X::SubclassResponsibility
	end


private

	def __desugar_value__(expr, env, event)
		raise X::SubclassResponsibility
	end
end

end	# Umu::ConcreteSyntax::Module::Pattern

end	# Umu::ConcreteSyntax::Module

end	# Umu::ConcreteSyntax

end	# Umu
