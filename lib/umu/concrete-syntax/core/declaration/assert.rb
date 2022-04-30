require 'umu/common'
require 'umu/lexical/position'


module Umu

module ConcreteSyntax

module Core

module Declaration

class Assert < Declaration::Abstract
	attr_reader :test_expr, :else_expr


	def initialize(pos, test_expr, else_expr)
		ASSERT.kind_of test_expr,	SCCE::Abstract
		ASSERT.kind_of else_expr,	SCCE::Abstract

		super(pos)

		@test_expr	= test_expr
		@else_expr	= else_expr
	end


	def to_s
		format("%%ASSERT (%s) %s",
				self.test_expr.to_s,
				self.else_expr.to_s
		)
	end


	def exported_vars
		[].freeze
	end


private

	def __desugar__(env, event)
		new_env = env.enter event

		SACD.make_value(
			self.pos,

			WILDCARD,

			SACE.make_if(
				self.pos,

				[
					SACE.make_rule(
						self.test_expr.pos,
						self.test_expr.desugar(new_env),
						SACE.make_unit(self.test_expr.pos)
					)
				],

				SACE.make_send(
					self.else_expr.pos,
					self.else_expr.desugar(new_env),
					[
						SACE.make_method(
							self.else_expr.pos,
							:abort,
							[]
						)
					]
				)

			)
		)
	end
end



module_function

	def make_assert(pos, test_expr, else_expr)
		ASSERT.kind_of pos,			L::Position
		ASSERT.kind_of test_expr,	SCCE::Abstract
		ASSERT.kind_of else_expr,	SCCE::Abstract

		Assert.new(pos, test_expr, else_expr).freeze
	end

end	# Umu::ConcreteSyntax::Core::Declaration

end	# Umu::ConcreteSyntax::Core

end	# Umu::ConcreteSyntax

end	# Umu
