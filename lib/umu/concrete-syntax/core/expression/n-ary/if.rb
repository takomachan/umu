require 'umu/common'
require 'umu/lexical/position'

require 'umu/concrete-syntax/core/expression/n-ary/rule'


module Umu

module ConcreteSyntax

module Core

module Expression

module Nary

class If < Expression::Abstract
	attr_reader :rules, :else_expr


	def initialize(pos, rules, else_expr)
		ASSERT.kind_of rules,		::Array
		ASSERT.kind_of else_expr,	SCCE::Abstract
		ASSERT.assert rules.count >= 1

		super(pos)

		@rules		= rules
		@else_expr	= else_expr
	end


	def to_s
		head_rule, *tail_rules = self.rules

		format("if %s%s else %s",
			head_rule.to_s,

			if tail_rules.empty?
				''
			else
				' ' + tail_rules.map { |rule|
					format "elsif %s", rule.to_s
				}.join(' ')
			end,

			self.else_expr.to_s
		)
	end


private

	def __desugar__(env, event)
		new_env = env.enter event

		SACE.make_if(
			self.pos,

			self.rules.map { |rule|
				ASSERT.kind_of rule, Rule::If

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

	def make_if(pos, rules, else_expr)
		ASSERT.kind_of pos,			L::Position
		ASSERT.kind_of rules,		::Array
		ASSERT.kind_of else_expr,	SCCE::Abstract

		Nary::If.new(pos, rules, else_expr).freeze
	end

end	# Umu::ConcreteSyntax::Core::Expression

end	# Umu::ConcreteSyntax::Core

end	# Umu::ConcreteSyntax

end	# Umu
