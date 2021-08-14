require 'umu/common'


module Umu

module Environment

module Context

module Type

module Specification

class Method < Abstraction::CartesianProduct
	attr_reader	:meth_sym
	attr_reader	:ret_class_spec
	attr_reader	:symbol
	attr_reader	:param_class_specs

	alias to_sym symbol


	def initialize(meth_sym, ret_class_spec, symbol, param_class_specs)
		ASSERT.kind_of meth_sym,			::Symbol
		ASSERT.kind_of ret_class_spec,		Class::Abstract
		ASSERT.kind_of symbol,				::Symbol
		ASSERT.kind_of param_class_specs,	::Array

		@meth_sym			= meth_sym
		@ret_class_spec		= ret_class_spec
		@symbol				= symbol
		@param_class_specs	= param_class_specs
	end


	def ==(other)
		other.kind_of?(Method) && self.symbol == other.symbol
	end
	alias eql? ==


	def <=>(other)
		ASSERT.kind_of other, Method

		self.symbol <=> other.symbol
	end


	def hash
		self.symbol.hash
	end
end


module_function

	def make_method(symbol, ret_class_spec,  meth_sym, param_class_specs)
		ASSERT.kind_of symbol,				::Symbol
		ASSERT.kind_of ret_class_spec,		Class::Abstract
		ASSERT.kind_of meth_sym,			::Symbol
		ASSERT.kind_of param_class_specs,	::Array

		Method.new(
			symbol, ret_class_spec, meth_sym, param_class_specs.freeze
		).freeze
	end

end	# Umu::Environment::Context::Type::Specification

end	# Umu::Environment::Context::Type

end	# Umu::Environment::Context

end	# Umu::Environment

end	# Umu
