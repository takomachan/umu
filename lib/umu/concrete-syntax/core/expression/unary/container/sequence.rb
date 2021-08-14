require 'umu/common'
require 'umu/lexical/position'


module Umu

module ConcreteSyntax

module Core

module Expression

module Unary

module Container

class Sequence < Abstraction::Abstract
	alias exprs array


	def initialize(pos, exprs)
		ASSERT.kind_of	exprs, ::Array
		ASSERT.assert	exprs.size >= 2

		super
	end


	def to_s
		format "(%s)", self.map(&:to_s).join(' ; ')
	end


private

	def __desugar__(env, event)
		new_env = env.enter event

		*not_last_exprs, last_expr = self.exprs

		SACE.make_let(
			self.pos,

			not_last_exprs.map { |expr|
				ASSERT.kind_of expr, SCCE::Abstract

				SACD.make_value expr.pos, WILDCARD, expr.desugar(new_env)
			},

			last_expr.desugar(new_env)
		)
	end
end

end	# Umu::ConcreteSyntax::Core::Expression::Unary::Container

end	# Umu::ConcreteSyntax::Core::Expression::Unary


module_function

	def make_sequence(pos, exprs)
		ASSERT.kind_of pos,		L::Position
		ASSERT.kind_of exprs,	::Array

		Unary::Container::Sequence.new(pos, exprs.freeze).freeze
	end


end	# Umu::ConcreteSyntax::Core::Expression

end	# Umu::ConcreteSyntax::Core

end	# Umu::ConcreteSyntax

end	# Umu
