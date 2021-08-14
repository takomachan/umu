require 'umu/common'


module Umu

module ConcreteSyntax

module Core

module Pattern

class Variable < Abstract
	attr_reader :var_sym


	def initialize(pos, var_sym)
		ASSERT.kind_of var_sym, ::Symbol

		super(pos)

		@var_sym = var_sym
	end


	def to_s
		self.var_sym.to_s
	end


	def wildcard?
		self.var_sym == WILDCARD
	end


	def exported_vars
		(
			if self.wildcard?
				[]
			else
				[self]
			end
		).freeze
	end


private

	def __desugar_value__(expr, _env, _event)
		ASSERT.kind_of expr, SACE::Abstract

		SACD.make_value self.pos, self.var_sym, expr
	end


	def __desugar_lambda__(_seq_num, _env, _event)
		SCCP.make_result(
			SACE.make_identifier(self.pos, self.var_sym),
			[]
		)
	end
end


module_function

	def make_variable(pos, var_sym)
		ASSERT.kind_of pos,		L::Position
		ASSERT.kind_of var_sym,	::Symbol

		Variable.new(pos, var_sym).freeze
	end

end	# Umu::ConcreteSyntax::Core::Pattern

end	# Umu::ConcreteSyntax::Core

end	# Umu::ConcreteSyntax

end	# Umu
