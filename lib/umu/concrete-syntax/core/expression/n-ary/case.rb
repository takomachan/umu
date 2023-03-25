require 'umu/common'
require 'umu/lexical/location'

require 'umu/concrete-syntax/core/expression/n-ary/rule'


module Umu

module ConcreteSyntax

module Core

module Expression

module Nary

class Case < Expression::Abstract
	attr_reader :expr, :fst_rule, :snd_rules, :else_expr, :else_decls


	def initialize(loc, expr, fst_rule, snd_rules, else_expr, else_decls)
		ASSERT.kind_of expr,		SCCE::Abstract
		ASSERT.kind_of fst_rule,	SCCE::Nary::Rule::Case
		ASSERT.kind_of snd_rules,	::Array
		ASSERT.kind_of else_expr,	SCCE::Abstract
		ASSERT.kind_of else_decls,	::Array

		super(loc)

		@expr		= expr
		@fst_rule	= fst_rule
		@snd_rules	= snd_rules
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
			([self.fst_rule] + self.snd_rules).map(&:to_s).join(' | '),
			self.else_expr.to_s,
			decls_string
		)
	end


private

	def __desugar__(env, event)
		new_env = env.enter event

		source_expr		= self.expr.desugar(new_env)
		fst_head_expr	= self.fst_rule.head_expr
		fst_head_value	=
				fst_head_expr.desugar(new_env).evaluate(new_env).value

		leafs = ([self.fst_rule] + self.snd_rules).inject({}) {
			|leafs, rule|
			ASSERT.kind_of leafs,	::Hash
			ASSERT.kind_of rule,	Rule::Case

			head_expr	= rule.head_expr
			ASSERT.kind_of head_expr, SCCE::Unary::Atom::Abstract
			head_value	= head_expr.desugar(new_env).evaluate(new_env).value
			ASSERT.kind_of head_value, VCA::Abstract

			unless head_expr.class == fst_head_expr.class
				raise X::SyntaxError.new(
					rule.loc,
					format("Inconsistent rule types in case-expression, " +
							"1st is %s : %s, another is %s : %s",
						fst_head_expr.to_s,
						fst_head_value.type_sym.to_s,
						head_expr.to_s,
						head_value.type_sym.to_s
					)
				)
			end


			body_expr_	= rule.body_expr.desugar(new_env)
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

		SACE.make_switch(
			self.loc,
			source_expr,
			fst_head_value.type_sym,
			leafs,
			else_expr
		)
	end
end

end	# Umu::ConcreteSyntax::Core::Expression::Nary


module_function

	def make_case(loc, expr, fst_rule, snd_rules, else_expr, else_decls)
		ASSERT.kind_of loc,			L::Location
		ASSERT.kind_of expr,		SCCE::Abstract
		ASSERT.kind_of fst_rule,	SCCE::Nary::Rule::Case
		ASSERT.kind_of snd_rules,	::Array
		ASSERT.kind_of else_expr,	SCCE::Abstract
		ASSERT.kind_of else_decls,	::Array

		Nary::Case.new(
			loc, expr, fst_rule, snd_rules, else_expr, else_decls
		).freeze
	end

end	# Umu::ConcreteSyntax::Core::Expression

end	# Umu::ConcreteSyntax::Core

end	# Umu::ConcreteSyntax

end	# Umu
