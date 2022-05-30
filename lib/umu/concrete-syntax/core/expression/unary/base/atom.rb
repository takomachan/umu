require 'umu/common'
require 'umu/lexical/escape'
require 'umu/lexical/location'


module Umu

module ConcreteSyntax

module Core

module Expression

module Unary

module Base

class Atom < Base::Abstract
	def initialize(loc, obj)
		ASSERT.kind_of obj, ::Symbol

		super
	end


	def to_s
		'@' + self.obj.to_s
	end


private

	def __desugar__(_env, _event)
		SACE.make_atom self.loc, self.obj
	end
end

end	# Umu::ConcreteSyntax::Core::Expression::Unary::Base

end	# Umu::ConcreteSyntax::Core::Expression::Unary



module_function

	def make_atom(loc, obj)
		ASSERT.kind_of loc,	L::Location
		ASSERT.kind_of obj, ::Symbol

		Unary::Base::Atom.new(loc, obj).freeze
	end

end	# Umu::ConcreteSyntax::Core::Expression

end	# Umu::ConcreteSyntax::Core

end	# Umu::ConcreteSyntax

end	# Umu
