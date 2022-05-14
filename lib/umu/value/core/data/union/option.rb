require 'umu/common'


module Umu

module Value

module Core

module Data

module Union

module Option

class Abstract < Union::Abstract
	CLASS_METHOD_INFOS = [
		[:meth_make_some,	self,
			:'make-some',	VC::Top],
		[:meth_make_none,	self,
			:'make-none']
	]

	INSTANCE_METHOD_INFOS = [
		[:meth_some?,		VCB::Bool,
			:some?],
		[:meth_none?,		VCB::Bool,
			:none?]
	]


	def self.meth_make_some(env, _event, contents)
		ASSERT.kind_of contents, VC::Top

		VC.make_some contents.pos, contents
	end


	def self.meth_make_none(env, _event)
		VC.make_none L.make_position(__FILE__, __LINE__)
	end


	def meth_some?(env, event)
		raise X::SubclassResponsibility
	end


	def meth_none?(env, event)
		raise X::SubclassResponsibility
	end
end



class Some < Abstract
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


	def meth_none?(env, event)
		VC.make_false self.pos
	end
end



class None < Abstract
	def initialize(pos)
		super(pos, VC.make_unit(L.make_position(__FILE__, __LINE__)))
	end


	def to_s
		'NONE'
	end


	def meth_to_string(env, event)
		VC.make_string self.pos, self.to_s
	end


	def meth_some?(env, event)
		VC.make_false self.pos
	end


	def meth_none?(env, event)
		VC.make_true self.pos
	end
end

end	# Umu::Core::Data::Union::Option

end	# Umu::Core::Data::Union

end	# Umu::Core::Data


module_function

	def make_some(pos, contents)
		ASSERT.kind_of pos,			L::Position
		ASSERT.kind_of contents,	VC::Top

		Data::Union::Option::Some.new(pos, contents).freeze
	end


	def make_none(pos)
		ASSERT.kind_of pos,	L::Position

		Data::Union::Option::None.new(pos).freeze
	end

end	# Umu::Core

end	# Umu::Value

end	# Umu
