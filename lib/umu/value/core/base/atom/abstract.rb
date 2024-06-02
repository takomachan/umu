require 'umu/common'


module Umu

module Value

module Core

module Base

module Atom

class Abstract < Base::Abstract
	INSTANCE_METHOD_INFOS = [
		[:meth_less_than,	VCBA::Bool,
			:'<',			self]
	]


	attr_reader	:val


	def initialize(val)
		ASSERT.kind_of val, ::Object	# Polymophic

		super()

		@val = val
	end


	def meth_equal(_loc, _env, _event, other)
		ASSERT.kind_of other, VC::Top

		VC.make_bool(
			other.kind_of?(self.class) && self.val == other.val
		)
	end


	def meth_less_than(_loc, _env, _event, other)
		ASSERT.kind_of other, Atom::Abstract

		VC.make_bool self.val < other.val
	end
end

end # Umu::Value::Core::Base::Atom

end # Umu::Value::Core::Base

end # Umu::Value::Core

end	# Umu::Value

end	# Umu
