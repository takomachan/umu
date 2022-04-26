require 'umu/common'
require 'umu/lexical/escape'
require 'umu/lexical/position'


module Umu

module ConcreteSyntax

module Core

module Expression

module Unary

module Base

class Symbol < Base::Abstract
	def initialize(pos, obj)
		ASSERT.kind_of obj, ::Symbol

		super
	end


	def to_s
		'@' + self.obj.to_s
	end


private

	def __desugar__(_env, _event)
		SACE.make_symbol self.pos, self.obj
	end
end

end	# Umu::ConcreteSyntax::Core::Expression::Unary::Base

end	# Umu::ConcreteSyntax::Core::Expression::Unary



module_function

	def make_symbol(pos, obj)
		ASSERT.kind_of pos,	L::Position
		ASSERT.kind_of obj, ::Symbol

		Unary::Base::Symbol.new(pos, obj).freeze
	end

end	# Umu::ConcreteSyntax::Core::Expression

end	# Umu::ConcreteSyntax::Core

end	# Umu::ConcreteSyntax

end	# Umu
