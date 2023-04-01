require 'umu/common'
require 'umu/lexical/location'

require 'umu/concrete-syntax/core/expression/n-ary/rule'


module Umu

module ConcreteSyntax

module Core

module Expression

module Nary

module Branch

class Case < Abstract

private

	def __keyword__
		'case'
	end


	def __desugar__(env, event)
		new_env = env.enter event

		fst_head = self.fst_rule.head
		ASSERT.kind_of fst_head, Rule::Case::Head::Abstract
		expr = case fst_head
				when Rule::Case::Head::Atom
					__desugar_atom__ new_env, fst_head
				when Rule::Case::Head::Datum
					__desugar_datum__ new_env, fst_head
				else
					ASSERT.abort "Rule::Case::Head::???"
				end
		ASSERT.kind_of expr, SACE::Abstract
	end


	def __desugar_atom__(env, fst_head)
		ASSERT.kind_of fst_head, Rule::Case::Head::Atom

		fst_head_expr	= fst_head.atom_expr
		fst_head_value	= fst_head_expr.to_value

		leafs = self.rules.inject({}) { |leafs, rule|
			ASSERT.kind_of leafs,	::Hash
			ASSERT.kind_of rule,	Rule::Case::Entry

			head = rule.head
			ASSERT.kind_of head, Rule::Case::Head::Abstract
			unless head.kind_of? Rule::Case::Head::Atom
				raise X::SyntaxError.new(
					rule.loc,
					format("Inconsistent rule types in case-expression, " +
							"1st is %s : %s, but another is %s : %s",
						fst_head.to_s,
						fst_head.type_sym.to_s,
						head.to_s,
						head.type_sym.to_s
					)
				)
			end

			head_expr	= head.atom_expr
			ASSERT.kind_of head_expr, SCCE::Unary::Atom::Abstract
			head_value	= head_expr.to_value
			ASSERT.kind_of head_value, VCA::Abstract
			unless head_value.class == fst_head_value.class
				raise X::SyntaxError.new(
					rule.loc,
					format("Inconsistent rule types in case-expression, " +
							"1st is %s : %s, but another is %s : %s",
						fst_head_value.to_s,
						fst_head_value.type_sym.to_s,
						head_value.to_s,
						head_value.type_sym.to_s
					)
				)
			end

			body_expr = __desugar_body_expr__ env, rule

			leafs.merge(head_value.val => body_expr) { |val, _, _|
				raise X::SyntaxError.new(
					rule.loc,
					format("Duplicated rules in case-expression: %s",
						val.to_s
					)
				)
			}
		}

		SACE.make_switch(
			self.loc,
			self.expr.desugar(env),
			fst_head_value.type_sym,
			leafs,
			__desugar_else_expr__(env)
		)
	end


	def __desugar_datum__(env, fst_head)
		ASSERT.kind_of fst_head, Rule::Case::Head::Datum

		leafs = self.rules.inject({}) { |leafs, rule|
			ASSERT.kind_of leafs,	::Hash
			ASSERT.kind_of rule,	Rule::Case::Entry

			head = rule.head
			ASSERT.kind_of head, Rule::Case::Head::Abstract
			unless head.kind_of? Rule::Case::Head::Datum
				raise X::SyntaxError.new(
					rule.loc,
					format("Inconsistent rule types in case-expression, " +
							"1st is %s : %s, but another is %s : %s",
						fst_head.to_s,
						fst_head.type_sym.to_s,
						head.to_s,
						head.type_sym.to_s
					)
				)
			end

			body_expr = if head.opt_contents_pat
					contents_decl = head.opt_contents_pat.desugar_value(
						SACE.make_send(
							self.expr.loc,
							self.expr.desugar(env),
							[SACE.make_method(self.expr.loc, :contents, [])]
						),
						env
					)
					ASSERT.kind_of contents_decl, SACD::Abstract

					SACE.make_let(
						rule.loc,
						(
							[contents_decl] +
							rule.decls.map { |decl| decl.desugar env }
						),
						rule.body_expr.desugar(env)
					)
				else
					__desugar_body_expr__ env, rule
				end

			leafs.merge(head.tag_sym => body_expr) { |val, _, _|
				raise X::SyntaxError.new(
					rule.loc,
					format("Duplicated rules in case-expression: %s",
						head.to_s
					)
				)
			}
		}

		SACE.make_switch(
			self.loc,
			SACE.make_send(
				self.expr.loc,
				self.expr.desugar(env),
				[SACE.make_method(self.expr.loc, :tag, [])]
			),
			:Symbol,
			leafs,
			__desugar_else_expr__(env)
		)
	end
end

end	# Umu::ConcreteSyntax::Core::Expression::Nary::Branch

end	# Umu::ConcreteSyntax::Core::Expression::Nary


module_function

	def make_case(loc, expr, fst_rule, snd_rules, opt_else_expr, else_decls)
		ASSERT.kind_of		loc,			L::Location
		ASSERT.kind_of		expr,			SCCE::Abstract
		ASSERT.kind_of		fst_rule,		SCCE::Nary::Rule::Case::Entry
		ASSERT.kind_of		snd_rules,		::Array
		ASSERT.opt_kind_of	opt_else_expr,	SCCE::Abstract
		ASSERT.kind_of		else_decls,		::Array

		Nary::Branch::Case.new(
			loc, expr, fst_rule, snd_rules, opt_else_expr, else_decls
		).freeze
	end

end	# Umu::ConcreteSyntax::Core::Expression

end	# Umu::ConcreteSyntax::Core

end	# Umu::ConcreteSyntax

end	# Umu
