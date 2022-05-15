require 'umu/common'


module Umu

module Value

module Core

module Base

module Number

class Integer < Abstract
	INSTANCE_METHOD_INFOS = [
		# Number
		[:meth_odd?,			VCB::Bool,
			:odd?],
		[:meth_even?,			VCB::Bool,
			:even?],
		[:meth_negate,			self,
			:'~'],
		[:meth_absolute,		self,
			:abs],
		[:meth_less_than,		VCB::Bool,
			:'<',				self],
		[:meth_add,	self,
			:'+',				self],
		[:meth_sub,	self,
			:'-',				self],
		[:meth_multiply,		self,
			:'*',				self],
		[:meth_divide,			self,
			:'/',				self],
		[:meth_modulo,			self,
			:mod,				self],
		[:meth_power,			self,
			:pow,				self],

		# I/O
		[:meth_random,			self,
			:'random']
	]


	def initialize(val)
		ASSERT.kind_of val, ::Integer

		super
	end


	def meth_odd?(_pos, _env, _event)
		VC.make_bool self.val.odd?
	end


	def meth_even?(_pos, _env, _event)
		VC.make_bool self.val.even?
	end


	def meth_to_int(_pos, _env, _event)
		self
	end
end

end # Umu::Value::Core::Base::Number

end # Umu::Value::Core::Base


module_function

	def make_integer(val)
		ASSERT.kind_of val, ::Integer

		Base::Number::Integer.new(val).freeze
	end

end # Umu::Value::Core

end	# Umu::Value

end	# Umu
