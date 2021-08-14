require 'umu/common'
require 'umu/lexical/position'

require 'umu/concrete-syntax/core/expression/n-ary/rule'


module Umu

module ConcreteSyntax

module Core

module Expression

module Nary

class Cond < Expression::Abstract
	attr_reader :expr, :rules


	def initialize(pos, expr, rules)
		ASSERT.kind_of expr,	SCCE::Abstract
		ASSERT.kind_of rules,	::Array
		ASSERT.assert rules.count >= 1

		super(pos)

		@expr	= expr
		@rules	= rules
	end


	def to_s
		format "cond %s {%s}", self.expr.to_s, rules.map(&:to_s).join(' | ')
	end


private

	def __desugar__(env, event)
		new_env = env.enter event

		opnd_expr	= self.expr.desugar(new_env)
		rules		= self.rules.map { |rule|
			ASSERT.kind_of rule, Rule::Cond

			opr_expr = rule.test_expr.desugar(new_env)
			test_expr = SACE.make_apply rule.pos, opr_expr, [opnd_expr]
			then_expr = if rule.decls.empty?
							rule.then_expr.desugar(new_env)
						else
							SACE.make_let(
								rule.pos,
								rule.decls.map { |decl|
									decl.desugar new_env
								},
								rule.then_expr.desugar(new_env)
							)
						end

			SACE.make_rule rule.pos, test_expr, then_expr
		}

		SACE.make_if self.pos, rules, SACE.make_unit(self.pos)
	end
end

end	# Umu::ConcreteSyntax::Core::Expression::Nary


module_function

	def make_cond(pos, expr, rules)
		ASSERT.kind_of pos,		L::Position
		ASSERT.kind_of expr,	SCCE::Abstract
		ASSERT.kind_of rules,	::Array

		Nary::Cond.new(pos, expr, rules).freeze
	end

end	# Umu::ConcreteSyntax::Core::Expression

end	# Umu::ConcreteSyntax::Core

end	# Umu::ConcreteSyntax

end	# Umu
