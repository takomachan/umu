require 'umu/common'
require 'umu/lexical/escape'
require 'umu/lexical/location'


module Umu

module ConcreteSyntax

module Core

module Expression

module Unary

module Method

class Abstract < Unary::Abstract
	alias		class_sym obj
	attr_reader	:method_sym


	def initialize(loc, class_sym, method_sym)
		ASSERT.kind_of class_sym,	::Symbol
		ASSERT.kind_of method_sym,	::Symbol

		super(loc, class_sym)

		@method_sym = method_sym
	end
end



class Class < Abstract
	def to_s
		format "&(%s.%s)", self.class_sym, self.method_sym
	end


private

	def __desugar__(_env, _event)
		SACE.make_class_method self.loc, self.class_sym, self.method_sym
	end
end



class Instance < Abstract
	def to_s
		format "&(%s$%s)", self.class_sym, self.method_sym
	end


private

	def __desugar__(_env, _event)
		SACE.make_instance_method self.loc, self.class_sym, self.method_sym
	end
end

end	# Umu::ConcreteSyntax::Core::Expression::Unary::Method

end	# Umu::ConcreteSyntax::Core::Expression::Unary



module_function

	def make_class_method(loc, class_sym, method_sym)
		ASSERT.kind_of loc,			L::Location
		ASSERT.kind_of class_sym,	::Symbol
		ASSERT.kind_of method_sym,	::Symbol

		Unary::Method::Class.new(loc, class_sym, method_sym).freeze
	end


	def make_instance_method(loc, class_sym, method_sym)
		ASSERT.kind_of loc,			L::Location
		ASSERT.kind_of class_sym,	::Symbol
		ASSERT.kind_of method_sym,	::Symbol

		Unary::Method::Instance.new(loc, class_sym, method_sym).freeze
	end

end	# Umu::ConcreteSyntax::Core::Expression

end	# Umu::ConcreteSyntax::Core

end	# Umu::ConcreteSyntax

end	# Umu
