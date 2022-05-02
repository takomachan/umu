require 'umu/common'


module Umu

module AbstractSyntax

module Core

module Expression

module Unary

class Class < Abstract
	alias class_sym obj


	def initialize(pos, class_sym)
		ASSERT.kind_of class_sym, ::Symbol

		super
	end


	def to_s
		format "&%s", self.class_sym
	end


	def __evaluate__(env, _event)
		class_spec = env.ty_lookup self.class_sym, self.pos
		ASSERT.kind_of class_spec, ECTSC::Base

		VC.make_class self.pos, class_spec
	end
end

end # Umu::AbstractSyntax::Core::Expression::Unary


module_function

	def make_class(pos, class_sym)
		ASSERT.kind_of pos,			L::Position
		ASSERT.kind_of class_sym,	::Symbol

		Unary::Class.new(pos, class_sym).freeze
	end

end	# Umu::AbstractSyntax::Core::Expression

end	# Umu::AbstractSyntax::Core

end	# Umu::AbstractSyntax

end	# Umu
