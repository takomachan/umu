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
		[:meth_none?,		VCB::Bool,
			:none?],
		[:meth_some?,		VCB::Bool,
			:some?]
	]


	def self.meth_make_none(env, _event)
		VC.make_none L.make_position(__FILE__, __LINE__)
	end


	def self.meth_make_some(env, _event, contents)
		ASSERT.kind_of contents, VC::Top

		VC.make_some contents.pos, contents
	end


	def meth_none?(env, event)
		VC.make_false self.pos
	end


	def meth_some?(env, event)
		VC.make_false self.pos
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


	def meth_to_string(env, event)
		VC.make_string self.pos, self.to_s
	end


	def meth_none?(env, event)
		VC.make_true self.pos
	end
end



class Some < Abstract
	attr_reader :contents


	def initialize(pos, contents)
		ASSERT.kind_of contents, VC::Top

		super(pos)

		@contents = contents
	end


	def to_s
		format "Some %s", self.contents.to_s
	end


	def meth_to_string(env, event)
		VC.make_string(
			self.pos,
			format("Some %s", self.contents.meth_to_string(env, event).val)
		)
	end


	def meth_some?(env, event)
		VC.make_true self.pos
	end


	def meth_contents(_env, _event)
		self.contents
	end
end

end	# Umu::Core::Data::Union::Option

end	# Umu::Core::Data::Union

end	# Umu::Core::Data


module_function

	def make_none(pos)
		ASSERT.kind_of pos,	L::Position

		Data::Union::Option::None.new(pos).freeze
	end


	def make_some(pos, contents)
		ASSERT.kind_of pos,			L::Position
		ASSERT.kind_of contents,	VC::Top

		Data::Union::Option::Some.new(pos, contents).freeze
	end

end	# Umu::Core

end	# Umu::Value

end	# Umu
