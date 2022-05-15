require 'umu/common'
require 'umu/value'


module Umu

module Environment

module Context

module Value

module Bindings

module Target

class Abstract
	attr_reader :val


	def initialize(val)
		ASSERT.kind_of val, ::Object	# Polymophism

		@val = val
	end


	def get_value(context)
		raise X::SubclassResponsibility
	end
end



class Value < Abstract
	alias value val


	def initialize(value)
		ASSERT.kind_of value, VC::Top

		super(value)
	end


	def get_value(_context)
		self.value
	end
end



class Recursive < Abstract
	alias lam_expr val


	def initialize(lam_expr)
		ASSERT.kind_of lam_expr, SACE::Nary::Lambda

		super(lam_expr)
	end


	def get_value(context)
		ASSERT.kind_of context, ECV::Abstract

		VC.make_closure self.lam_expr, context
	end
end

end # Umu::Environment::Context::Value::Bindings::Target


module_function

	def make_value(value)
		ASSERT.kind_of value, VC::Top

		Target::Value.new(value).freeze
	end


	def make_recursive(lam_expr)
		ASSERT.kind_of lam_expr, SACE::Nary::Lambda

		Target::Recursive.new(lam_expr).freeze
	end

end # Umu::Environment::Context::Value::Bindings

end	# Umu::Environment::Context::Value

end	# Umu::Environment::Context

end	# Umu::Environment

end	# Umu
