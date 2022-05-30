require 'umu/common'
require 'umu/lexical/location'

require 'umu/concrete-syntax/core/expression/n-ary/rule'


module Umu

module ConcreteSyntax

module Core

module Expression

module Nary

class Cond < Expression::Abstract
	attr_reader :expr, :rules, :else_expr, :else_decls


	def initialize(loc, expr, rules, else_expr, else_decls)
		ASSERT.kind_of expr,		SCCE::Abstract
		ASSERT.kind_of rules,		::Array
		ASSERT.kind_of else_expr,	SCCE::Abstract
		ASSERT.kind_of else_decls,	::Array
		ASSERT.assert rules.size >= 1

		super(loc)

		@expr		= expr
		@rules		= rules
		@else_expr	= else_expr
		@else_decls	= else_decls
	end


	def to_s
		decls_string = if self.else_decls.empty?
							' '
						else
							format(" %%WHERE %s ",
								self.else_decls.map(&:to_s).join(' ')
							)
						end

		format("%%COND %s { %s %%ELSE %s%s}",
			self.expr.to_s,
			self.rules.map(&:to_s).join(' | '),
			self.else_expr.to_s,
			decls_string
		)
	end


private

	def __desugar__(env, event)
		new_env = env.enter event

		opnd_expr = self.expr.desugar(new_env)

		rules = self.rules.map { |rule|
			ASSERT.kind_of rule, Rule::Cond

			opr_expr	= rule.test_expr.desugar(new_env)
			test_expr	= SACE.make_apply rule.loc, opr_expr, [opnd_expr]
			then_expr_	= rule.then_expr.desugar(new_env)
			then_expr	= unless rule.decls.empty?
								SACE.make_let(
									rule.loc,
									rule.decls.map { |decl|
										decl.desugar new_env
									},
									then_expr_
								)
							else
								then_expr_
							end

			SACE.make_rule rule.loc, test_expr, then_expr
		}

		else_expr_ = self.else_expr.desugar(new_env)
		else_expr	= unless self.else_decls.empty?
							SACE.make_let(
								else_expr_.loc,
								self.else_decls.map { |decl|
									decl.desugar new_env
								},
								else_expr_
							)
						else
							else_expr_
						end

		SACE.make_if self.loc, rules, else_expr
	end
end

end	# Umu::ConcreteSyntax::Core::Expression::Nary


module_function

	def make_cond(loc, expr, rules, else_expr, else_decls)
		ASSERT.kind_of loc,			L::Location
		ASSERT.kind_of expr,		SCCE::Abstract
		ASSERT.kind_of rules,		::Array
		ASSERT.kind_of else_expr,	SCCE::Abstract
		ASSERT.kind_of else_decls,	::Array

		Nary::Cond.new(loc, expr, rules, else_expr, else_decls).freeze
	end

end	# Umu::ConcreteSyntax::Core::Expression

end	# Umu::ConcreteSyntax::Core

end	# Umu::ConcreteSyntax

end	# Umu
