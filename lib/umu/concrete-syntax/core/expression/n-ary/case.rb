require 'umu/common'
require 'umu/lexical/location'

require 'umu/concrete-syntax/core/expression/n-ary/rule'


module Umu

module ConcreteSyntax

module Core

module Expression

module Nary

class Case < Expression::Abstract
	attr_reader :expr, :head_rule, :tail_rules, :else_expr, :else_decls


	def initialize(loc, expr, head_rule, tail_rules, else_expr, else_decls)
		ASSERT.kind_of expr,		SCCE::Abstract
		ASSERT.kind_of head_rule,	SCCE::Nary::Rule::Case
		ASSERT.kind_of tail_rules,	::Array
		ASSERT.kind_of else_expr,	SCCE::Abstract
		ASSERT.kind_of else_decls,	::Array

		super(loc)

		@expr		= expr
		@head_rule	= head_rule
		@tail_rules	= tail_rules
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

		format("%%CASE %s { %s %%ELSE -> %s%s}",
			self.expr.to_s,
			([self.head_rule] + self.tail_rules).map(&:to_s).join(' | '),
			self.else_expr.to_s,
			decls_string
		)
	end


private

	def __desugar__(env, event)
		new_env = env.enter event

		source_expr = self.expr.desugar(new_env)

		leafs = ([self.head_rule] + self.tail_rules).inject({}) {
			|leafs, rule|
			ASSERT.kind_of leafs,	::Hash
			ASSERT.kind_of rule,	Rule::Case

			head_expr	= rule.test_expr
			ASSERT.kind_of head_expr, SCCE::Unary::Atom::Abstract
			head_value	= head_expr.desugar(new_env).evaluate(new_env).value
			ASSERT.kind_of head_value, VCA::Abstract

			body_expr_	= rule.then_expr.desugar(new_env)
			body_expr	= unless rule.decls.empty?
								SACE.make_let(
									rule.loc,
									rule.decls.map { |decl|
										decl.desugar new_env
									},
									body_expr_
								)
							else
								body_expr_
							end

			leafs.merge(head_value.val => body_expr) { |val, _, _|
				raise X::SyntaxError.new(
					rule.loc,
					format("Duplicated rules in case-expression: %s",
						val.to_s
					)
				)
			}
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

		SACE.make_switch self.loc, source_expr, leafs, else_expr
	end
end

end	# Umu::ConcreteSyntax::Core::Expression::Nary


module_function

	def make_case(loc, expr, head_rule, tail_rules, else_expr, else_decls)
		ASSERT.kind_of loc,			L::Location
		ASSERT.kind_of expr,		SCCE::Abstract
		ASSERT.kind_of head_rule,	SCCE::Nary::Rule::Case
		ASSERT.kind_of tail_rules,	::Array
		ASSERT.kind_of else_expr,	SCCE::Abstract
		ASSERT.kind_of else_decls,	::Array

		Nary::Case.new(
			loc, expr, head_rule, tail_rules, else_expr, else_decls
		).freeze
	end

end	# Umu::ConcreteSyntax::Core::Expression

end	# Umu::ConcreteSyntax::Core

end	# Umu::ConcreteSyntax

end	# Umu
