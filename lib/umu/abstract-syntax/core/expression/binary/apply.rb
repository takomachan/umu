require 'umu/common'
require 'umu/environment/tracer/tracer'


module Umu

module AbstractSyntax

module Core

module Expression

module Binary

class Apply < Binary::Abstract
	alias opr_expr		lhs_expr
	alias opnd_exprs	rhs


	def initialize(pos, opr_expr, opnd_exprs)
		ASSERT.kind_of opr_expr,	SACE::Abstract
		ASSERT.kind_of opnd_exprs,	::Array
		ASSERT.assert opnd_exprs.size >= 1

		super
	end


	def to_s
		format("(%s %s)",
				self.opr_expr,
				self.opnd_exprs.map(&:to_s).join(' ')
		)
	end


	def __evaluate__(env, event)
		ASSERT.kind_of env,		E::Entry
		ASSERT.kind_of event,	E::Tracer::Event

		new_env = env.enter event

		opr_result = self.opr_expr.evaluate new_env
		ASSERT.kind_of opr_result, SAR::Value

		opnd_values = self.opnd_exprs.map { |expr|
			ASSERT.kind_of expr, SACE::Abstract

			result = expr.evaluate new_env
			ASSERT.kind_of result, SAR::Value

			result.value
		}

		value = opr_result.value.apply opnd_values, self.pos, new_env

		ASSERT.kind_of value, VC::Top
	end
end

end	# Umu::AbstractSyntax::Core::Expression::Binary


module_function

	def make_apply(pos, opr_expr, opnd_exprs)
		ASSERT.kind_of pos,			L::Position
		ASSERT.kind_of opr_expr,	SACE::Abstract
		ASSERT.kind_of opnd_exprs,	::Array

		Binary::Apply.new(pos, opr_expr, opnd_exprs.freeze).freeze
	end

end	# Umu::AbstractSyntax::Core::Expression

end	# Umu::AbstractSyntax::Core

end	# Umu::AbstractSyntax

end	# Umu
