require 'umu/common'
require 'umu/lexical/position'


module Umu

module ConcreteSyntax

module Core

module Expression

class Unit < Expression::Abstract
	def to_s
		'()'
	end


private

	def __desugar__(_env, _event)
		SACE.make_unit self.pos
	end
end


module_function

	def make_unit(pos)
		ASSERT.kind_of pos,	L::Position

		Unit.new(pos).freeze
	end

end	# Umu::ConcreteSyntax::Core::Expression

end	# Umu::ConcreteSyntax::Core

end	# Umu::ConcreteSyntax

end	# Umu
