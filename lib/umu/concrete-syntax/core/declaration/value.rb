require 'umu/common'
require 'umu/lexical/position'


module Umu

module ConcreteSyntax

module Core

module Declaration

class Value < Declaration::Abstract
	attr_reader :pat, :expr, :decls


	def initialize(pos, pat, expr, decls)
		ASSERT.kind_of pat,		SCCP::Abstract
		ASSERT.kind_of expr,	SCCE::Abstract
		ASSERT.kind_of decls,	::Array

		super(pos)

		@pat	= pat
		@expr	= expr
		@decls	= decls
	end


	def to_s
		format("val %s = %s%s",
				self.pat.to_s,

				self.expr.to_s,

				if self.decls.empty?
					''
				else
					format(" where {%s}", self.decls.map(&:to_s).join(' '))
				end
		)
	end


	def exported_vars
		self.pat.exported_vars
	end


private

	def __desugar__(env, event)
		new_env = env.enter event

		self.pat.desugar_value(
			(
				if self.decls.empty?
					self.expr
				else
					SCCE.make_let(self.pos, self.decls, self.expr)
				end
			).desugar(new_env),

			new_env
		)
	end
end



module_function

	def make_value(pos, pat, expr, decls)
		ASSERT.kind_of pos,		L::Position
		ASSERT.kind_of pat,		SCCP::Abstract
		ASSERT.kind_of expr,	SCCE::Abstract
		ASSERT.kind_of decls,	::Array

		Value.new(pos, pat, expr, decls).freeze
	end

end	# Umu::ConcreteSyntax::Core::Declaration

end	# Umu::ConcreteSyntax::Core

end	# Umu::ConcreteSyntax

end	# Umu
