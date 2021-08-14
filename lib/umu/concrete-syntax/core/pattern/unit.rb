require 'umu/common'


module Umu

module ConcreteSyntax

module Core

module Pattern

class Unit < Abstract
	def to_s
		'()'
	end


	def exported_vars
		[].freeze
	end


private

	def __desugar_value__(expr, _env, _event)
		ASSERT.kind_of expr, SACE::Abstract

		SACD.make_value self.pos, WILDCARD, expr
	end


	def __desugar_lambda__(_seq_num, _env, _event)
		SCCP.make_result(
			SACE.make_identifier(self.pos, WILDCARD),
			[]
		)
	end
end


module_function

	def make_unit(pos)
		ASSERT.kind_of pos,	L::Position

		Unit.new(pos).freeze
	end

end	# Umu::ConcreteSyntax::Core::Pattern

end	# Umu::ConcreteSyntax::Core

end	# Umu::ConcreteSyntax

end	# Umu
