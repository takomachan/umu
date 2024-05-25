require 'umu/common'
require 'umu/lexical/location'


module Umu

module ConcreteSyntax

module Core

module Expression

module Unary

class Prefix < Unary::Abstract
	alias		sym obj
	attr_reader	:rhs_expr


	def initialize(loc, sym, rhs_expr)
		ASSERT.kind_of sym,			::Symbol
		ASSERT.kind_of rhs_expr,	CSCE::Abstract

		super(loc, sym)

		@rhs_expr = rhs_expr
	end


	def to_s
		format "(%s %s)", self.sym, self.rhs_expr.to_s
	end


private

	def __desugar__(env, event)
		ASCE.make_lambda(
			self.loc,

			[
				ASCE.make_parameter(
					self.loc,
					ASCE.make_identifier(self.loc, :'%x')
				)
			],

			ASCE.make_apply(
				self.loc,
				ASCE.make_identifier(self.loc, self.sym),
				ASCE.make_identifier(self.loc, :'%x'),
				[self.rhs_expr.desugar(env.enter(event))]
			),

			self.sym
		)
	end
end

end	# Umu::ConcreteSyntax::Core::Expression::Unary



module_function

	def make_prefix(loc, sym, rhs_expr)
		ASSERT.kind_of loc,			L::Location
		ASSERT.kind_of sym, 		::Symbol
		ASSERT.kind_of rhs_expr,	CSCE::Abstract

		Unary::Prefix.new(loc, sym, rhs_expr).freeze
	end

end	# Umu::ConcreteSyntax::Core::Expression

end	# Umu::ConcreteSyntax::Core

end	# Umu::ConcreteSyntax

end	# Umu
