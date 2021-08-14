require 'umu/common'
require 'umu/lexical/escape'
require 'umu/lexical/position'


module Umu

module ConcreteSyntax

module Core

module Expression

module Unary

module Atom

class String < Atom::Abstract
	def initialize(pos, obj)
		ASSERT.kind_of obj, ::String

		super
	end


	def to_s
		'"' + L::Escape.unescape(self.obj) + '"'
	end


private

	def __desugar__(_env, _event)
		SACE.make_string self.pos, self.obj
	end
end

end	# Umu::ConcreteSyntax::Core::Expression::Unary::Atom

end	# Umu::ConcreteSyntax::Core::Expression::Unary



module_function

	def make_string(pos, obj)
		ASSERT.kind_of pos,	L::Position
		ASSERT.kind_of obj, ::String

		Unary::Atom::String.new(pos, obj.freeze).freeze
	end

end	# Umu::ConcreteSyntax::Core::Expression

end	# Umu::ConcreteSyntax::Core

end	# Umu::ConcreteSyntax

end	# Umu
