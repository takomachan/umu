require 'umu/common'
require 'umu/lexical/location'


module Umu

module ConcreteSyntax

module Core

module Expression

module Binary

class Apply < Binary::Abstract
	alias opr_expr		lhs_expr
	alias opnd_exprs	rhs


	def initialize(loc, opr_expr, opnd_exprs)
		ASSERT.kind_of opr_expr,	SCCE::Abstract
		ASSERT.kind_of opnd_exprs,	::Array
		ASSERT.assert opnd_exprs.size >= 1

		super
	end


	def to_s
		format("(%s %s)",
				self.opr_expr.to_s,
				self.opnd_exprs.map(&:to_s).join(' ')
		)
	end


private

	def __desugar__(env, event)
		new_env = env.enter event

		SACE.make_apply(
			self.loc,
			self.opr_expr.desugar(new_env),
			self.opnd_exprs.map { |expr| expr.desugar(new_env) }
		)
	end
end

end	# Umu::ConcreteSyntax::Core::Expression::Binary


module_function

	def make_apply(loc, opr_expr, opnd_exprs)
		ASSERT.kind_of loc,			L::Location
		ASSERT.kind_of opr_expr,	SCCE::Abstract
		ASSERT.kind_of opnd_exprs,	::Array

		Binary::Apply.new(loc, opr_expr, opnd_exprs.freeze).freeze
	end

end	# Umu::ConcreteSyntax::Core::Expression

end	# Umu::ConcreteSyntax::Core

end	# Umu::ConcreteSyntax

end	# Umu
