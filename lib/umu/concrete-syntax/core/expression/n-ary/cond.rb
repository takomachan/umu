require 'umu/common'
require 'umu/lexical/position'

require 'umu/concrete-syntax/core/expression/n-ary/rule'


module Umu

module ConcreteSyntax

module Core

module Expression

module Nary

class Cond < Expression::Abstract
	attr_reader :expr, :rules, :opt_else_expr, :else_decls


	def initialize(pos, expr, rules, opt_else_expr, else_decls)
		ASSERT.kind_of		expr,			SCCE::Abstract
		ASSERT.kind_of		rules,			::Array
		ASSERT.assert rules.count >= 1
		ASSERT.opt_kind_of	opt_else_expr,	SCCE::Abstract
		ASSERT.kind_of		else_decls,		::Array

		super(pos)

		@expr			= expr
		@rules			= rules
		@opt_else_expr	= opt_else_expr
		@else_decls		= else_decls
	end


	def to_s
		format("cond %s {%s%s}",
			self.expr.to_s,

			rules.map(&:to_s).join(' | '),

			if self.opt_else_expr
				format(" else %s%s",
					self.opt_else_expr.to_s,

					unless self.else_decls.empty?
						format(" where %s",
							self.else_decls.map(&:to_s).join(' ')
						)
					else
						''
					end
				)
			else
				''
			end
		)
	end


private

	def __desugar__(env, event)
		new_env = env.enter event

		opnd_expr	= self.expr.desugar(new_env)
		rules		= self.rules.map { |rule|
			ASSERT.kind_of rule, Rule::Cond

			opr_expr	= rule.test_expr.desugar(new_env)
			test_expr	= SACE.make_apply rule.pos, opr_expr, [opnd_expr]
			then_expr_	= rule.then_expr.desugar(new_env)
			then_expr	= unless rule.decls.empty?
								SACE.make_let(
									rule.pos,
									rule.decls.map { |decl|
										decl.desugar new_env
									},
									then_expr_
								)
							else
								then_expr_
							end

			SACE.make_rule rule.pos, test_expr, then_expr
		}
		else_expr	= if self.opt_else_expr
							else_expr_ = self.opt_else_expr.desugar(new_env)

							unless self.else_decls.empty?
								SACE.make_let(
									else_expr_.pos,
									self.else_decls.map { |decl|
										decl.desugar new_env
									},
									else_expr_
								)
							else
								else_expr_
							end
						else
							SACE.make_unit(self.pos)
						end

		SACE.make_if self.pos, rules, else_expr
	end
end

end	# Umu::ConcreteSyntax::Core::Expression::Nary


module_function

	def make_cond(pos, expr, rules, opt_else_expr, else_decls)
		ASSERT.kind_of		pos,			L::Position
		ASSERT.kind_of		expr,			SCCE::Abstract
		ASSERT.kind_of		rules,			::Array
		ASSERT.opt_kind_of	opt_else_expr,	SCCE::Abstract
		ASSERT.kind_of		else_decls,		::Array

		Nary::Cond.new(pos, expr, rules, opt_else_expr, else_decls).freeze
	end

end	# Umu::ConcreteSyntax::Core::Expression

end	# Umu::ConcreteSyntax::Core

end	# Umu::ConcreteSyntax

end	# Umu
