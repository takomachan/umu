require 'umu/common'
require 'umu/lexical/position'

require 'umu/concrete-syntax/core/expression/n-ary/rule'


module Umu

module ConcreteSyntax

module Core

module Expression

module Nary

class Unless < Expression::Abstract
	attr_reader :rule


	def initialize(pos, rule)
		ASSERT.kind_of rule, Rule::If

		super(pos)

		@rule = rule
	end


	def to_s
		format "%%UNLESS %s", self.rule.to_s
	end


private

	def __desugar__(env, event)
		new_env = env.enter event

		SACE.make_if(
			pos,
			[
				SACE.make_rule(
					pos,
					rule.test_expr.desugar(new_env),
					SACE.make_unit(pos)
				)
			],
			rule.then_expr.desugar(new_env)
		)
	end
end

end	# Umu::ConcreteSyntax::Core::Expression::Nary


module_function

	def make_unless(pos, rule)
		ASSERT.kind_of pos,		L::Position
		ASSERT.kind_of rule,	Nary::Rule::If

		Nary::Unless.new(pos, rule).freeze
	end

end	# Umu::ConcreteSyntax::Core::Expression

end	# Umu::ConcreteSyntax::Core

end	# Umu::ConcreteSyntax

end	# Umu
