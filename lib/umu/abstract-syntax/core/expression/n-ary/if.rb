require 'umu/common'
require 'umu/environment/tracer/tracer'


module Umu

module AbstractSyntax

module Core

module Expression

module Nary

module If

class Rule < Abstraction::Model
	attr_reader :test_expr, :then_expr


	def initialize(loc, test_expr, then_expr)
		ASSERT.kind_of test_expr,	SACE::Abstract
		ASSERT.kind_of then_expr,	SACE::Abstract

		super(loc)

		@test_expr	= test_expr
		@then_expr	= then_expr
	end


	def to_s
		format "%s %s", self.test_expr, self.then_expr
	end
end



class Entry < Expression::Abstract
	attr_reader :rules, :else_expr


	def initialize(loc, rules, else_expr)
		ASSERT.kind_of rules,		::Array
		ASSERT.kind_of else_expr,	SACE::Abstract

		super(loc)

		@rules		= rules
		@else_expr	= else_expr
	end


	def to_s
		rules_string = case self.rules.size
						when 0
							''
						when 1
							self.rules[0].to_s + ' '
						else
							head_rule, *tail_rules = self.rules

							format("%s %s ",
								head_rule.to_s,

								tail_rules.map { |rule|
									'%ELSIF ' + rule.to_s
								}.join(' ')
							)
						end

		format("(%%IF %s%%ELSE %s)",
			rules_string,
			self.else_expr.to_s
		)
	end


	def __evaluate__(env, event)
		ASSERT.kind_of env,		E::Entry
		ASSERT.kind_of event,	E::Tracer::Event

		new_env = env.enter event

		result = self.rules.inject(self.else_expr) { |expr, rule|
			ASSERT.kind_of expr,	SACE::Abstract
			ASSERT.kind_of rule,	Rule

			test_result = rule.test_expr.evaluate new_env
			ASSERT.kind_of test_result, SAR::Value

			test_value = test_result.value
			unless test_value.kind_of? VCB::Bool
				raise X::TypeError.new(
					rule.loc,
					env,
					"Type error in if-expression, " +
							"expected a Bool, but %s : %s",
						test_value.to_s,
						test_value.type_sym.to_s
				)
			end

			if test_value.true?
				break rule.then_expr
			end

			expr
		}.evaluate new_env
		ASSERT.kind_of result, SAR::Value

		result.value
	end
end

end	# Umu::AbstractSyntax::Core::Expression::Nary::If

end	# Umu::AbstractSyntax::Core::Expression::Nary


module_function

	def make_rule(loc, test_expr, then_expr)
		ASSERT.kind_of loc,			L::Location
		ASSERT.kind_of test_expr,	SACE::Abstract
		ASSERT.kind_of then_expr,	SACE::Abstract

		Nary::If::Rule.new(loc, test_expr, then_expr).freeze
	end


	def make_if(loc, rules, else_expr)
		ASSERT.kind_of loc,			L::Location
		ASSERT.kind_of rules,		::Array
		ASSERT.kind_of else_expr,	SACE::Abstract

		Nary::If::Entry.new(loc, rules, else_expr).freeze
	end

end	# Umu::AbstractSyntax::Core::Expression

end	# Umu::AbstractSyntax::Core

end	# Umu::AbstractSyntax

end	# Umu
