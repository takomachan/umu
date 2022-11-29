require 'umu/common'


module Umu

module Value

module Core

module Data

module Union

module Option

class Abstract < Union::Abstract
	CLASS_METHOD_INFOS = [
		[:meth_make_none,	self,
			:'make-none'],
		[:meth_make_some,	self,
			:'make-some',	VC::Top]
	]

	INSTANCE_METHOD_INFOS = [
		[:meth_none?,		VCA::Bool,
			:none?],
		[:meth_some?,		VCA::Bool,
			:some?]
	]


	def self.meth_make_none(_loc, _env, _event)
		VC.make_none
	end


	def self.meth_make_some(_loc, _env, _event, contents)
		ASSERT.kind_of contents, VC::Top

		VC.make_some contents
	end


	def meth_none?(_loc, _env, event)
		VC.make_false
	end


	def meth_some?(_loc, _env, event)
		VC.make_false
	end
end



class None < Abstract
	INSTANCE_METHOD_INFOS = [
		[:meth_contents,	VC::Unit,
			:contents]
	]


	def to_s
		'NONE'
	end


	def meth_to_string(_loc, _env, _event)
		VC.make_string self.to_s
	end


	def meth_none?(_loc, _env, _event)
		VC.make_true
	end
end

NONE = None.new.freeze



class Some < Abstract
	attr_reader :contents


	def initialize(contents)
		ASSERT.kind_of contents, VC::Top

		super()

		@contents = contents
	end


	def to_s
		format "Some %s", self.contents.to_s
	end


	def meth_to_string(loc, env, event)
		VC.make_string(
			format("Some %s",
					self.contents.meth_to_string(loc, env, event).val
			)
		)
	end


	def meth_some?(_loc, _env, event)
		VC.make_true
	end


	def meth_contents(_loc, _env, _event)
		self.contents
	end
end

end	# Umu::Core::Data::Union::Option

end	# Umu::Core::Data::Union

end	# Umu::Core::Data


module_function

	def make_none
		Data::Union::Option::NONE
	end


	def make_some(contents)
		ASSERT.kind_of contents, VC::Top

		Data::Union::Option::Some.new(contents).freeze
	end

end	# Umu::Core

end	# Umu::Value

end	# Umu
