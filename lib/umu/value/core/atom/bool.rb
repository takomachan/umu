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


	def self.meth_make_true(env, _event)
		VC.make_true L.make_position(__FILE__, __LINE__)
	end


	def self.meth_make_false(env, _event)
		VC.make_false L.make_position(__FILE__, __LINE__)
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


	def meth_less_than(env, _event, other)
		ASSERT.kind_of other, Bool

		VC.make_bool(
			self.pos,

			if self.val
				! other.val
			else
				FALSE
			end
		)
	end


	def meth_not(env, _event)
		VC.make_bool self.pos, ! self.val
	end
end

end # Umu::Value::Core::Atom



module_function

	def make_true(pos)
		ASSERT.kind_of pos,	L::Position

		Atom::Bool.new(pos, true).freeze
	end


	def make_false(pos)
		ASSERT.kind_of pos,	L::Position

		Atom::Bool.new(pos, false).freeze
	end


	def make_bool(pos, val)
		ASSERT.kind_of	pos, L::Position
		ASSERT.bool		val

		if val
			VC.make_true(pos)
		else
			VC.make_false(pos)
		end
	end

end	# Umu::Value::Core

end	# Umu::Value

end	# Umu
