require 'umu/common'


module Umu

module Value

module Core

module Union

module Option

class Abstract < Union::Abstract
	INSTANCE_METHOD_INFOS = [
		[:meth_none?,		VCA::Bool,
			:none?],
		[:meth_some?,		VCA::Bool,
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
		[:meth_contents,	VC::Unit,
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

end	# Umu::Core::Union::Option

end	# Umu::Core::Union


module_function

	def make_none
		Union::Option::NONE
	end


	def make_some(contents)
		ASSERT.kind_of contents, VC::Top

		Union::Option::Some.new(contents).freeze
	end

end	# Umu::Core

end	# Umu::Value

end	# Umu
