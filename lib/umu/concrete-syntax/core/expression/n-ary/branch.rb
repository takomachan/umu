require 'umu/common'
require 'umu/lexical/location'

require 'umu/concrete-syntax/core/expression/n-ary/rule'


module Umu

module ConcreteSyntax

module Core

module Expression

module Nary

module Branch

class Abstract < Expression::Abstract
	attr_reader :expr, :fst_rule, :snd_rules, :opt_else_expr, :else_decls


	def initialize(
		loc, expr, fst_rule, snd_rules, opt_else_expr, else_decls
	)
		ASSERT.kind_of		expr,			SCCE::Abstract
		ASSERT.kind_of		fst_rule,
							SCCE::Nary::Rule::Abstraction::WithDeclaration
		ASSERT.kind_of		snd_rules,		::Array
		ASSERT.opt_kind_of	opt_else_expr,	SCCE::Abstract
		ASSERT.kind_of		else_decls,		::Array

		super(loc)

		@expr		= expr
		@fst_rule	= fst_rule
		@snd_rules	= snd_rules
		@opt_else_expr	= opt_else_expr
		@else_decls	= else_decls
	end


	def to_s
		format("%%%s %s { %s %s}",
			__keyword__.upcase,

			self.expr.to_s,

			self.rules.map(&:to_s).join(' | '),
			(
				if self.opt_else_expr
					format("%%ELSE -> %s%s",
						self.opt_else_expr.to_s,
						(
							if self.else_decls.empty?
								' '
							else
								format(" %%WHERE %s ",
									self.else_decls.map(&:to_s).join(' ')
								)
							end
						)
					)
				else
					''
				end
			)
		)
	end


	def rules
		[self.fst_rule] + self.snd_rules
	end


private

	def __keyword__
		raise X::SubclassResponsibility
	end


	def __desugar_body_expr__(rule, env)
		ASSERT.kind_of rule, Nary::Rule::Abstraction::WithDeclaration

		body_expr_	= rule.body_expr.desugar(env)
		body_expr	= unless rule.decls.empty?
							SACE.make_let(
								rule.loc,
								rule.decls.map { |decl| decl.desugar env },
								body_expr_
							)
						else
							body_expr_
						end

		ASSERT.kind_of body_expr, SACE::Abstract
	end


	def __desugar_else_expr__(env)
		else_expr = if self.opt_else_expr
						else_expr_ = self.opt_else_expr.desugar(env)

						unless self.else_decls.empty?
							SACE.make_let(
								else_expr_.loc,
								self.else_decls.map { |decl|
									decl.desugar env
								},
								else_expr_
							)
						else
							else_expr_
						end
					else
						SACE.make_raise(
							self.loc,
							X::UnmatchError,
							format("No rules matched in %s-expression",
									__keyword__
							)
						)
					end

		ASSERT.kind_of else_expr, SACE::Abstract
	end
end



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
								rule.loc, opr_expr, [fn.call(rule.loc)]
							)
			body_expr	= __desugar_body_expr__ rule, env

			SACE.make_rule rule.loc, head_expr, body_expr
		}
	end
end



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
					ASSERT.abort "Rule::Case::Head::Datum"
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

			body_expr = __desugar_body_expr__ rule, env

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
end

end	# Umu::ConcreteSyntax::Core::Expression::Nary::Branch

end	# Umu::ConcreteSyntax::Core::Expression::Nary


module_function

	def make_cond(loc, expr, fst_rule, snd_rules, opt_else_expr, else_decls)
		ASSERT.kind_of		loc,			L::Location
		ASSERT.kind_of		expr,			SCCE::Abstract
		ASSERT.kind_of		fst_rule,		SCCE::Nary::Rule::Cond
		ASSERT.kind_of		snd_rules,		::Array
		ASSERT.opt_kind_of	opt_else_expr,	SCCE::Abstract
		ASSERT.kind_of		else_decls,		::Array

		Nary::Branch::Cond.new(
			loc, expr, fst_rule, snd_rules, opt_else_expr, else_decls
		).freeze
	end


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
