# vim: set nu ai sw=4 ts=4 :
# coding: utf-8
# frozen_string_literal: true

require 'umu/common'


module Umu

module Value

module Core

module Base

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

end # Umu::Value::Core::Base::Atom

end # Umu::Value::Core::Base



module_function

	def make_true
		Base::Atom::TRUE
	end


	def make_false
		Base::Atom::FALSE
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
