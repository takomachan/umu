require 'umu/common'
require 'umu/environment/tracer/tracer'


module Umu

module AbstractSyntax

module Core

module Expression

class Unit < Expression::Abstract
	def to_s
		'()'
	end


	def evaluate(env)
		value = E::Tracer.trace_single(
					env.pref,
					env.trace_stack.count,
					'Eval(Expr)',
					self.class,
					self.pos,
					self.to_s
				) { |_event|
					VC.make_unit
				}

		SAR.make_value value
	end
end


module_function

	def make_unit(pos)
		ASSERT.kind_of pos, L::Position

		Unit.new(pos).freeze
	end

end	# Umu::AbstractSyntax::Core::Expression

end	# Umu::AbstractSyntax::Core

end	# Umu::AbstractSyntax

end	# Umu
