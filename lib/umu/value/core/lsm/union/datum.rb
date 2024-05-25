require 'umu/common'


module Umu

module Value

module Core

module LSM

module Union

class Datum < Abstract
	CLASS_METHOD_INFOS = [
		[:meth_make,	self,
			:'make',	VCA::Symbol, VC::Top]
	]

	INSTANCE_METHOD_INFOS = [
		[:meth_tag,		VCA::Symbol,
			:tag]
	]


	attr_reader :tag_sym, :contents


	def initialize(tag_sym, contents)
		ASSERT.kind_of tag_sym,		::Symbol
		ASSERT.kind_of contents,	VC::Top

		super()

		@tag_sym	= tag_sym
		@contents	= contents
	end


	def self.meth_make(_loc, _env, _event, tag, contents)
		ASSERT.kind_of tag,			VCA::Symbol
		ASSERT.kind_of contents,	VC::Top

		VC.make_datum tag.val, contents
	end


	def to_s
		format "%s %s", self.tag_sym.to_s, self.contents.to_s
	end


	def meth_to_string(loc, env, event)
		VC.make_string(
			format("%s %s",
					self.tag_sym.to_s,
					self.contents.meth_to_string(loc, env, event).val
			)
		)
	end


	def meth_equal(loc, env, event, other)
		ASSERT.kind_of other, VC::Top

		VC.make_bool(
			(
				other.kind_of?(self.class) &&
				self.tag_sym == other.tag_sym &&
				self.contents.meth_equal(
					loc, env, event, other.contents
				).true?
			)
		)
	end


	def meth_tag(_loc, _env, _event)
		VC.make_symbol self.tag_sym
	end


	def meth_contents(_loc, _env, _event)
		self.contents
	end
end

end	# Umu::Core::LSM::Union

end	# Umu::Core::LSM


module_function

	def make_datum(tag_sym, contents)
		ASSERT.kind_of tag_sym,		::Symbol
		ASSERT.kind_of contents,	VC::Top

		LSM::Union::Datum.new(tag_sym, contents).freeze
	end

end	# Umu::Core

end	# Umu::Value

end	# Umu
