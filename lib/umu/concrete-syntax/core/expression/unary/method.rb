require 'umu/common'
require 'umu/lexical/escape'
require 'umu/lexical/position'


module Umu

module ConcreteSyntax

module Core

module Expression

module Unary

module Method

class Abstract < Unary::Abstract
	alias		class_sym obj
	attr_reader	:method_sym


	def initialize(pos, class_sym, method_sym)
		ASSERT.kind_of class_sym,	::Symbol
		ASSERT.kind_of method_sym,	::Symbol

		super(pos, class_sym)

		@method_sym = method_sym
	end
end



class Class < Abstract
	def to_s
		format "&(%s.%s)", self.class_sym, self.method_sym
	end


private

	def __desugar__(_env, _event)
		SACE.make_class_method self.pos, self.class_sym, self.method_sym
	end
end



class Instance < Abstract
	def to_s
		format "&(%s$%s)", self.class_sym, self.method_sym
	end


private

	def __desugar__(_env, _event)
		SACE.make_instance_method self.pos, self.class_sym, self.method_sym
	end
end

end	# Umu::ConcreteSyntax::Core::Expression::Unary::Method

end	# Umu::ConcreteSyntax::Core::Expression::Unary



module_function

	def make_class_method(pos, class_sym, method_sym)
		ASSERT.kind_of pos,			L::Position
		ASSERT.kind_of class_sym,	::Symbol
		ASSERT.kind_of method_sym,	::Symbol

		Unary::Method::Class.new(pos, class_sym, method_sym).freeze
	end


	def make_instance_method(pos, class_sym, method_sym)
		ASSERT.kind_of pos,			L::Position
		ASSERT.kind_of class_sym,	::Symbol
		ASSERT.kind_of method_sym,	::Symbol

		Unary::Method::Instance.new(pos, class_sym, method_sym).freeze
	end

end	# Umu::ConcreteSyntax::Core::Expression

end	# Umu::ConcreteSyntax::Core

end	# Umu::ConcreteSyntax

end	# Umu
