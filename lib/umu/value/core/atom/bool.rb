require 'umu/common'


module Umu

module Value

module Core

module Atom

class Bool < Abstract
	CLASS_METHOD_INFOS = [
		[:meth_make_true,		self,
			:'make-true'],
		[:meth_make_false,		self,
			:'make-false']
	]


	INSTANCE_METHOD_INFOS = [
		[:meth_less_than,	self,
			:'<',			self],

		[:meth_not,			self,
			:not],
	]


	def self.meth_make_true(_loc, _env, _event)
		VC.make_true
	end


	def self.meth_make_false(_loc, _env, _event)
		VC.make_false
	end


	alias true? val


	def false?
		! self.val
	end


	def to_s
		if self.val
			'TRUE'
		else
			'FALSE'
		end
	end


	def meth_less_than(_loc, _env, _event, other)
		ASSERT.kind_of other, Bool

		VC.make_bool(
			if self.val
				! other.val
			else
				FALSE
			end
		)
	end


	def meth_not(_loc, _env, _event)
		VC.make_bool(! self.val)
	end
end

TRUE	= Bool.new(true).freeze
FALSE	= Bool.new(false).freeze

end # Umu::Value::Core::Atom



module_function

	def make_true
		Atom::TRUE
	end


	def make_false
		Atom::FALSE
	end


	def make_bool(val)
		ASSERT.bool val

		if val
			VC.make_true
		else
			VC.make_false
		end
	end

end	# Umu::Value::Core

end	# Umu::Value

end	# Umu
