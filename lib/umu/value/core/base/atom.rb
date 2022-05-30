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


	def initialize(val)
		ASSERT.kind_of val, ::Symbol

		super
	end


	def to_s
		'@' + self.val.to_s
	end


	def meth_to_string(_loc, _env, _event)
		VC.make_string self.val.to_s
	end
end

end # Umu::Value::Core::Base


module_function

	def make_atom(val)
		ASSERT.kind_of val, ::Symbol

		Base::Atom.new(val).freeze
	end

end	# Umu::Value::Core

end	# Umu::Value

end	# Umu
