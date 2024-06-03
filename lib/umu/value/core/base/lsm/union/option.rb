# vim: set nu ai sw=4 ts=4 :
# coding: utf-8
# frozen_string_literal: true

require 'umu/common'


module Umu

module Value

module Core

module Base

module LSM

module Union

module Option

class Abstract < Union::Abstract
	INSTANCE_METHOD_INFOS = [
		[:meth_none?,		VCBA::Bool,
			:none?],
		[:meth_some?,		VCBA::Bool,
			:some?]
	]



	def meth_none?(_loc, _env, event)
		VC.make_false
	end


	def meth_some?(_loc, _env, event)
		VC.make_false
	end
end



class None < Abstract
	CLASS_METHOD_INFOS = [
		[:meth_make,		self,
			:'make']
	]

	INSTANCE_METHOD_INFOS = [
		[:meth_contents,	VCBA::Unit,
			:contents]
	]


	def self.meth_make(_loc, _env, _event)
		VC.make_none
	end


	def meth_none?(_loc, _env, _event)
		VC.make_true
	end
end

NONE = None.new.freeze



class Some < Abstract
	CLASS_METHOD_INFOS = [
		[:meth_make,		self,
			:'make',		VC::Top]
	]


	def self.meth_make(_loc, _env, _event, contents)
		ASSERT.kind_of contents, VC::Top

		VC.make_some contents
	end


	attr_reader :contents


	def initialize(contents)
		ASSERT.kind_of contents, VC::Top

		super()

		@contents = contents
	end


	def meth_some?(_loc, _env, event)
		VC.make_true
	end
end

end	# Umu::Core::Base::LSM::Union::Option

end	# Umu::Core::Base::LSM::Union

end	# Umu::Core::Base::LSM

end	# Umu::Core::Base


module_function

	def make_none
		Base::LSM::Union::Option::NONE
	end


	def make_some(contents)
		ASSERT.kind_of contents, VC::Top

		Base::LSM::Union::Option::Some.new(contents).freeze
	end

end	# Umu::Core

end	# Umu::Value

end	# Umu
