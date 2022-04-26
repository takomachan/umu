require 'umu/common'


module Umu

module Value

module Core

module Base

class Atom < Abstract
	INSTANCE_METHOD_INFOS = [
		[:meth_less_than,	VCB::Bool,
			:'<',			self]
	]


	def initialize(pos, val)
		ASSERT.kind_of val, ::Symbol

		super
	end


	def to_s
		'@' + self.val.to_s
	end


	def meth_to_string(env, _event)
		VC.make_string self.pos, self.val.to_s
	end
end

end # Umu::Value::Core::Base


module_function

	def make_atom(pos, val)
		ASSERT.kind_of pos,	L::Position
		ASSERT.kind_of val,	::Symbol

		Base::Atom.new(pos, val).freeze
	end

end	# Umu::Value::Core

end	# Umu::Value

end	# Umu
