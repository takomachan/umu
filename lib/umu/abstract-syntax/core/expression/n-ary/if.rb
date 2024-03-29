require 'umu/common'
require 'umu/environment/tracer/tracer'


module Umu

module AbstractSyntax

module Core

module Expression

module Nary

module If

class Rule < Abstraction::Model
	attr_reader :head_expr, :body_expr


	def initialize(loc, head_expr, body_expr)
		ASSERT.kind_of head_expr,	SACE::Abstract
		ASSERT.kind_of body_expr,	SACE::Abstract

		super(loc)

		@head_expr	= head_expr
		@body_expr	= body_expr
	end


	def to_s
		format "%s %s", self.head_expr, self.body_expr
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

			head_result = rule.head_expr.evaluate new_env
			ASSERT.kind_of head_result, SAR::Value

			head_value = head_result.value
			unless head_value.kind_of? VCA::Bool
				raise X::TypeError.new(
					rule.loc,
					env,
					"Type error in if-expression, " +
							"expected a Bool, but %s : %s",
						head_value.to_s,
						head_value.type_sym.to_s
				)
			end

			if head_value.true?
				break rule.body_expr
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

	def make_rule(loc, head_expr, body_expr)
		ASSERT.kind_of loc,			L::Location
		ASSERT.kind_of head_expr,	SACE::Abstract
		ASSERT.kind_of body_expr,	SACE::Abstract

		Nary::If::Rule.new(loc, head_expr, body_expr).freeze
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
