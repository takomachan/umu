require 'umu/common'
require 'umu/lexical/escape'
require 'umu/lexical/position'


module Umu

module ConcreteSyntax

module Core

module Expression

module Unary

class Class < Abstract
	alias		class_sym obj


	def initialize(pos, class_sym)
		ASSERT.kind_of class_sym,	::Symbol

		super
	end


	def to_s
		format "@(%s)", self.class_sym
	end


private

	def __desugar__(_env, _event)
		SACE.make_class self.pos, self.class_sym
	end
end

end	# Umu::ConcreteSyntax::Core::Expression::Unary



module_function

	def make_class(pos, class_sym)
		ASSERT.kind_of pos,			L::Position
		ASSERT.kind_of class_sym,	::Symbol

		Unary::Class.new(pos, class_sym).freeze
	end

end	# Umu::ConcreteSyntax::Core::Expression

end	# Umu::ConcreteSyntax::Core

end	# Umu::ConcreteSyntax

end	# Umu
