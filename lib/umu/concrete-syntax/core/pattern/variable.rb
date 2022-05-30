require 'umu/common'


module Umu

module ConcreteSyntax

module Core

module Pattern

class Variable < Abstract
	attr_reader :var_sym


	def initialize(loc, var_sym)
		ASSERT.kind_of var_sym, ::Symbol

		super(loc)

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

		SACD.make_value self.loc, self.var_sym, expr
	end


	def __desugar_lambda__(_seq_num, _env, _event)
		SCCP.make_result(
			SACE.make_identifier(self.loc, self.var_sym),
			[]
		)
	end
end


module_function

	def make_variable(loc, var_sym)
		ASSERT.kind_of loc,		L::Location
		ASSERT.kind_of var_sym,	::Symbol

		Variable.new(loc, var_sym).freeze
	end

end	# Umu::ConcreteSyntax::Core::Pattern

end	# Umu::ConcreteSyntax::Core

end	# Umu::ConcreteSyntax

end	# Umu
