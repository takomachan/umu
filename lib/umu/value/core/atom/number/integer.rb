require 'umu/common'


module Umu

module Value

module Core

module Atom

module Number

class Integer < Abstract
	INSTANCE_METHOD_INFOS = [
		# Number
		[:meth_odd?,			VCA::Bool,
			:odd?],
		[:meth_even?,			VCA::Bool,
			:even?],
		[:meth_absolute,		self,
			:abs],
		[:meth_negate,			self,
			:negate],
		[:meth_less_than,		VCA::Bool,
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


	def meth_odd?(_loc, _env, _event)
		VC.make_bool self.val.odd?
	end


	def meth_even?(_loc, _env, _event)
		VC.make_bool self.val.even?
	end


	def meth_to_int(_loc, _env, _event)
		self
	end
end

end # Umu::Value::Core::Atom::Number

end # Umu::Value::Core::Atom


module_function

	def make_integer(val)
		ASSERT.kind_of val, ::Integer

		Atom::Number::Integer.new(val).freeze
	end

end # Umu::Value::Core

end	# Umu::Value

end	# Umu
