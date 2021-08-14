require 'umu/common'
require 'umu/lexical/position'


module Umu

module ConcreteSyntax

module Core

module Expression

module Unary

class Prefix < Unary::Abstract
	alias		sym obj
	attr_reader	:rhs_expr


	def initialize(pos, sym, rhs_expr)
		ASSERT.kind_of sym,			::Symbol
		ASSERT.kind_of rhs_expr,	SCCE::Abstract

		super(pos, sym)

		@rhs_expr = rhs_expr
	end


	def to_s
		format "(%s %s)", self.sym, self.rhs_expr.to_s
	end


private

	def __desugar__(env, event)
		SACE.make_lambda(
			self.pos,

			[SACE.make_identifier(self.pos, :'%x')],

			SACE.make_apply(
				self.pos,
				SACE.make_identifier(self.pos, self.sym),
				[
					SACE.make_identifier(self.pos, :'%x'),
					self.rhs_expr.desugar(env.enter(event))
				]
			),

			self.sym
		)
	end
end

end	# Umu::ConcreteSyntax::Core::Expression::Unary



module_function

	def make_prefix(pos, sym, rhs_expr)
		ASSERT.kind_of pos,			L::Position
		ASSERT.kind_of sym, 		::Symbol
		ASSERT.kind_of rhs_expr,	SCCE::Abstract

		Unary::Prefix.new(pos, sym, rhs_expr).freeze
	end

end	# Umu::ConcreteSyntax::Core::Expression

end	# Umu::ConcreteSyntax::Core

end	# Umu::ConcreteSyntax

end	# Umu
