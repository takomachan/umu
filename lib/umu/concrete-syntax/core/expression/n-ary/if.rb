require 'umu/common'
require 'umu/lexical/position'

require 'umu/concrete-syntax/core/expression/n-ary/rule'


module Umu

module ConcreteSyntax

module Core

module Expression

module Nary

class If < Expression::Abstract
	attr_reader :if_rule, :elsif_rules, :else_expr


	def initialize(pos, if_rule, elsif_rules, else_expr)
		ASSERT.kind_of if_rule,		Nary::Rule::If
		ASSERT.kind_of elsif_rules,	::Array
		ASSERT.kind_of else_expr,	SCCE::Abstract

		super(pos)

		@if_rule		= if_rule
		@elsif_rules	= elsif_rules
		@else_expr		= else_expr
	end


	def to_s
		rules_string = if self.elsif_rules.empty?
							' '
						else
							format(" %s ",
								self.elsif_rules.map { |rule|
									'%ELSIF ' + rule.to_s
								}.join(' ')
							)
						end

		format("%%IF %s%s%%ELSE %s",
			self.if_rule.to_s, 
			rules_string,
			self.else_expr.to_s
		)
	end


private

	def __desugar__(env, event)
		new_env = env.enter event

		SACE.make_if(
			self.pos,

			([self.if_rule] + self.elsif_rules).map { |rule|
				ASSERT.kind_of rule, Nary::Rule::If

				SACE.make_rule(
					rule.pos,
					rule.test_expr.desugar(new_env),
					rule.then_expr.desugar(new_env)
				)
			},

			self.else_expr.desugar(new_env)
		)
	end
end

end	# Umu::ConcreteSyntax::Core::Expression::Nary


module_function

	def make_if(pos, if_rule, elsif_rules, else_expr)
		ASSERT.kind_of pos,			L::Position
		ASSERT.kind_of if_rule,		Nary::Rule::If
		ASSERT.kind_of elsif_rules,	::Array
		ASSERT.kind_of else_expr,	SCCE::Abstract

		Nary::If.new(pos, if_rule, elsif_rules, else_expr).freeze
	end

end	# Umu::ConcreteSyntax::Core::Expression

end	# Umu::ConcreteSyntax::Core

end	# Umu::ConcreteSyntax

end	# Umu
