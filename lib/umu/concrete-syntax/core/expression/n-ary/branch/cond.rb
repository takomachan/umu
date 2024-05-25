require 'umu/common'
require 'umu/lexical/location'

require 'umu/concrete-syntax/core/expression/n-ary/rule'


module Umu

module ConcreteSyntax

module Core

module Expression

module Nary

module Branch

class Cond < Abstract

private

	def __keyword__
		'cond'
	end


	def __desugar__(env, event)
		new_env = env.enter event

		opnd_expr = self.expr.desugar(new_env)
		ASSERT.kind_of opnd_expr, SACE::Abstract
		if opnd_expr.simple? || self.rules.size <= 1
			rules = __desugar_rules__(env) { |_| opnd_expr }

			SACE.make_if self.loc, rules, __desugar_else_expr__(new_env)
		else
			SACE.make_let(
				self.loc,

				[SACD.make_value(opnd_expr.loc, :'%x', opnd_expr)],

				SACE.make_if(
					self.loc,
					__desugar_rules__(env) { |loc|
						SACE.make_identifier loc, :'%x'
					},
					__desugar_else_expr__(new_env)
				)
			)
		end
	end


	def __desugar_rules__(env, &fn)
		self.rules.map { |rule|
			ASSERT.kind_of rule, Rule::Cond

			opr_expr	= rule.head_expr.desugar env
			head_expr	= SACE.make_apply(
								rule.loc, opr_expr, fn.call(rule.loc)
							)
			body_expr	= __desugar_body_expr__ env, rule

			SACE.make_rule rule.loc, head_expr, body_expr
		}
	end
end

end	# Umu::ConcreteSyntax::Core::Expression::Nary::Branch

end	# Umu::ConcreteSyntax::Core::Expression::Nary


module_function

	def make_cond(loc, expr, fst_rule, snd_rules, opt_else_expr, else_decls)
		ASSERT.kind_of		loc,			L::Location
		ASSERT.kind_of		expr,			CSCE::Abstract
		ASSERT.kind_of		fst_rule,		CSCEN::Rule::Cond
		ASSERT.kind_of		snd_rules,		::Array
		ASSERT.opt_kind_of	opt_else_expr,	CSCE::Abstract
		ASSERT.kind_of		else_decls,		::Array

		Nary::Branch::Cond.new(
			loc, expr, fst_rule, snd_rules, opt_else_expr, else_decls
		).freeze
	end

end	# Umu::ConcreteSyntax::Core::Expression

end	# Umu::ConcreteSyntax::Core

end	# Umu::ConcreteSyntax

end	# Umu
