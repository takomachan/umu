require 'umu/common'


module Umu

module AbstractSyntax

module Core

module Expression

module Unary

module Base

class Atom < Abstract
	def initialize(pos, obj)
		ASSERT.kind_of obj, ::Symbol

		super
	end


	def to_s
		'@' + self.obj.to_s
	end


	def __evaluate__(_env, _event)
		VC.make_atom self.obj
	end
end

end # Umu::AbstractSyntax::Core::Expression::Unary::Base

end # Umu::AbstractSyntax::Core::Expression::Unary


module_function

	def make_atom(pos, obj)
		ASSERT.kind_of pos,	L::Position
		ASSERT.kind_of obj,	::Symbol

		Unary::Base::Atom.new(pos, obj).freeze
	end

end	# Umu::AbstractSyntax::Core::Expression

end	# Umu::AbstractSyntax::Core

end	# Umu::AbstractSyntax

end	# Umu
