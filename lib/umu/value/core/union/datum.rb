require 'umu/common'


module Umu

module Value

module Core

module Union

class Datum < Abstract
	CLASS_METHOD_INFOS = [
		[:meth_make,	self,
			:'make',	VCB::Atom, VC::Top]
	]

	INSTANCE_METHOD_INFOS = [
		[:meth_tag,		VCB::Atom,
			:tag]
	]


	attr_reader :tag_sym


	def initialize(pos, tag_sym, content)
		ASSERT.kind_of tag_sym,	::Symbol
		ASSERT.kind_of content,	VC::Top

		super(pos, content)

		@tag_sym = tag_sym
	end


	def self.meth_make(env, _event, tag, content)
		ASSERT.kind_of tag,		VCB::Atom
		ASSERT.kind_of content,	VC::Top

		VC.make_datum tag.pos, tag.val, content
	end


	def to_s
		format "%s %s", self.tag_sym.to_s, self.content.to_s
	end


	def meth_to_string(env, event)
		VC.make_string(
			self.pos,

			format("%s %s",
					self.tag_sym.to_s,
					self.content.meth_to_string(env, event).val
			)
		)
	end


	def meth_equal(env, event, other)
		ASSERT.kind_of other, VC::Top

		VC.make_bool(
			self.pos,
			(
				other.kind_of?(self.class) &&
				self.tag_sym == other.tag_sym &&
				self.content.meth_equal(env, event, other.content).true?
			)
		)
	end


	def meth_tag(_env,_event)
		VC.make_atom self.pos, self.tag_sym
	end
end

end	# Umu::Core::Union


module_function

	def make_datum(pos, tag_sym, content)
		ASSERT.kind_of pos,		L::Position
		ASSERT.kind_of tag_sym,	::Symbol
		ASSERT.kind_of content,	VC::Top

		Union::Datum.new(pos, tag_sym, content).freeze
	end

end	# Umu::Core

end	# Umu::Value

end	# Umu
