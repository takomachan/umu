require 'umu/common'
require 'umu/lexical/location'


module Umu

module Value

module Core

module Product

module Struct

class Field < ::Object
	attr_reader :label, :value


	def initialize(label, value)
		ASSERT.kind_of label,	::Symbol
		ASSERT.kind_of value,	VC::Top

		super()

		@label	= label
		@value	= value
	end


	def to_s
		format "%%VAL %s = %s", self.label, self.value
	end
end



class Entry < Product::Abstract
	TYPE_SYM = :Struct

	alias value_by_label objs


	def initialize(value_by_label)
		ASSERT.kind_of value_by_label, ::Hash

		super
	end


	def each
		self.value_by_label.each do |label, value|
			ASSERT.kind_of label,	::Symbol
			ASSERT.kind_of value,	VC::Top

			yield VC.make_struct_field label, value
		end
	end


	def to_s
		format("%%STRUCT {%s}",
				self.map { |field|
					case field.value
					when Entry
						format "%%STRUCTURE %s", field.label
					else
						field.to_s
					end
				}.join(' ')
		)
	end


	def select(sel_lab, loc, env)
		ASSERT.kind_of sel_lab,		::Symbol
		ASSERT.kind_of loc,			L::Location

		value = self.value_by_label[sel_lab]
		unless value
			raise X::SelectionError.new(
				loc,
				env,
				"Unknown selector label: '%s'", sel_lab
			)
		end

		ASSERT.kind_of value, VC::Top
	end


	def modify(other, loc, env)
		ASSERT.kind_of other,	Struct::Entry
		ASSERT.kind_of loc,		L::Location

		other.value_by_label.each_key do |label|
			unless self.value_by_label.key? label
				raise X::SelectionError.new(
					loc,
					env,
					"Unknown modifier label: '%s'", label.to_s
				)
			end
		end

		VC.make_struct(
			self.loc,

			self.value_by_label.merge(other.value_by_label)
		)
	end


	def meth_equal(loc, env, event, other)
		ASSERT.kind_of other, VC::Top

		VC.make_bool(
			other.kind_of?(self.class) &&
			self.arity == other.arity &&
			self.value_by_label.keys.sort ==
					other.value_by_label.keys.sort &&
			self.value_by_label.all? { |label, value|
				ASSERT.kind_of label,	::Symbol
				ASSERT.kind_of value,	VC::Top

				value.meth_equal(
						loc, env, event, other.value_by_label[label]
				).true?
			}
		)
	end
end

end	# Umu::Value::Core::Product::Struct

end	# Umu::Value::Core::Product


module_function

	def make_struct_field(label, value)
		ASSERT.kind_of label,	::Symbol
		ASSERT.kind_of value,	VC::Top

		Product::Struct::Field.new(label, value).freeze
	end


	def make_struct(value_by_label)
		ASSERT.kind_of value_by_label, ::Hash

		Product::Struct::Entry.new(value_by_label.freeze).freeze
	end

end	# Umu::Value::Core

end	# Umu::Value

end	# Umu
