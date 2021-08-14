require 'umu/common'


module Umu

module Value

module Core

module Atom

module Number

class Int < Abstract
	INSTANCE_METHOD_INFOS = [
		# Number
		[:meth_odd?,			VCA::Bool,
			:odd?],
		[:meth_even?,			VCA::Bool,
			:even?],
		[:meth_negate,			self,
			:'~'],
		[:meth_absolute,		self,
			:abs],
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


	def initialize(pos, val)
		ASSERT.kind_of val, ::Integer

		super
	end


	def meth_odd?(env, _event)
		VC.make_bool self.pos, self.val.odd?
	end


	def meth_even?(env, _event)
		VC.make_bool self.pos, self.val.even?
	end


	def meth_to_int(env, _event)
		self
	end
end

end # Umu::Value::Core::Atom::Number

end # Umu::Value::Core::Atom


module_function

	def make_int(pos, val)
		ASSERT.kind_of pos,	L::Position
		ASSERT.kind_of val,	::Integer

		Atom::Number::Int.new(pos, val).freeze
	end

end # Umu::Value::Core

end	# Umu::Value

end	# Umu
