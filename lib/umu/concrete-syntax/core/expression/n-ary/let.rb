require 'umu/common'
require 'umu/lexical/position'


module Umu

module ConcreteSyntax

module Core

module Expression

module Nary		# N-ary, where N >= 3

class Let < Expression::Abstract
	attr_reader :decls, :expr


	def initialize(pos, decls, expr)
		ASSERT.kind_of decls,	::Array
		ASSERT.kind_of expr,	SCCE::Abstract

		super(pos)

		@decls	= decls
		@expr	= expr
	end


	def to_s
		format("let { %s in %s }",
			self.decls.map(&:to_s).join(' '),
			self.expr.to_s
		)
	end


private

	def __desugar__(env, event)
		new_env = env.enter event

		if self.decls.empty?
			self.expr.desugar(new_env)
		else
			SACE.make_let(
				self.pos,
				self.decls.map { |decl|
					ASSERT.kind_of decl, SCCD::Abstract

					decl.desugar(new_env)
				},
				self.expr.desugar(new_env)
			)
		end
	end
end

end	# Umu::ConcreteSyntax::Core::Expression::Nary


module_function

	def make_let(pos, decls, expr)
		ASSERT.kind_of pos,		L::Position
		ASSERT.kind_of decls,	::Array
		ASSERT.kind_of expr,	SCCE::Abstract

		Nary::Let.new(pos, decls.freeze, expr).freeze
	end

end	# Umu::ConcreteSyntax::Core::Expression

end	# Umu::ConcreteSyntax::Core

end	# Umu::ConcreteSyntax

end	# Umu
