require 'umu/common'
require 'umu/lexical/escape'


module Umu

module Value

module Core

module Base

class String < Abstract
	INSTANCE_METHOD_INFOS = [
		[:meth_less_than,	VCB::Bool,
			:'<',			self],

		[:meth_abort,		VC::Unit,
			:abort],
		[:meth_append,		self,
			:'^',			self]
	]


	def initialize(pos, val)
		ASSERT.kind_of val, ::String

		super
	end


	def to_s
		format "\"%s\"", L::Escape.unescape(self.val)
	end


	def meth_inspect(_env, _event)
		VC.make_string self.pos, self.to_s
	end


	def meth_to_string(env, _event)
		self
	end


	def meth_abort(env, event)
		msg = self.val.gsub /%/, '%%'

		raise X::Abort.new(self.pos, env, msg)
	end


	def meth_append(env, _event, other)
		ASSERT.kind_of other, String

		VC.make_string self.pos, self.val + other.val
	end
end


end # Umu::Value::Core::Base


module_function

	def make_string(pos, val)
		ASSERT.kind_of pos,	L::Position
		ASSERT.kind_of val,	::String

		Base::String.new(pos, val.freeze).freeze
	end

end	# Umu::Value::Core

end	# Umu::Value

end	# Umu
