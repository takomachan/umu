require 'umu/common'
require 'umu/lexical/position'


module Umu

module Value

module Core

module Product

module Struct

class Field < Umu::Abstraction::LabelValuePair
	def initialize(pos, label, value)
		ASSERT.kind_of value, VC::Top

		super
	end


private

	def __infix_string__
		' = '
	end
end



class Entry < Product::Abstract
	TYPE_SYM = :Struct

	alias value_by_label objs


	def initialize(pos, value_by_label)
		ASSERT.kind_of value_by_label, ::Hash

		super
	end


	def each
		self.value_by_label.each do |label, value|
			ASSERT.kind_of label,	::Symbol
			ASSERT.kind_of value,	VC::Top

			yield VC.make_struct_field self.pos, label, value
		end
	end


	def to_s
		__to_s__ &:to_s
	end


	def select(sel_lab, pos, env)
		ASSERT.kind_of sel_lab,		::Symbol
		ASSERT.kind_of pos,			L::Position

		value = self.value_by_label[sel_lab]
		unless value
			raise X::SelectionError.new(
				pos,
				env,
				"Unknown selector label: '%s'", sel_lab
			)
		end

		ASSERT.kind_of value, VC::Top
	end


	def modify(other, pos, env)
		ASSERT.kind_of other,	Struct::Entry
		ASSERT.kind_of pos,		L::Position

		other.value_by_label.each_key do |label|
			unless self.value_by_label.key? label
				raise X::SelectionError.new(
					pos,
					env,
					"Unknown modifier label: '%s'", label.to_s
				)
			end
		end

		VC.make_struct(
			self.pos,

			self.value_by_label.merge(other.value_by_label)
		)
	end


	def meth_equal(env, event, other)
		ASSERT.kind_of other, VC::Top

		VC.make_bool(
			self.pos,

			other.kind_of?(self.class) &&
			self.arity == other.arity &&
			self.value_by_label.keys.sort ==
					other.value_by_label.keys.sort &&
			self.value_by_label.all? { |label, value|
				ASSERT.kind_of label,	::Symbol
				ASSERT.kind_of value,	VC::Top

				value.meth_equal(
						env, event, other.value_by_label[label]
				).true?
			}
		)
	end


private

	def __to_s__
		ASSERT.assert block_given?

		format "{%s}", self.map { |obj| yield obj }.join(', ')
	end
end

end	# Umu::Value::Core::Product::Struct

end	# Umu::Value::Core::Product


module_function

	def make_struct_field(pos, label, value)
		ASSERT.kind_of pos,		L::Position
		ASSERT.kind_of label,	::Symbol
		ASSERT.kind_of value,	VC::Top

		Product::Struct::Field.new(pos, label, value).freeze
	end


	def make_struct(pos, value_by_label)
		ASSERT.kind_of pos,				L::Position
		ASSERT.kind_of value_by_label,	::Hash

		Product::Struct::Entry.new(pos, value_by_label.freeze).freeze
	end

end	# Umu::Value::Core

end	# Umu::Value

end	# Umu
