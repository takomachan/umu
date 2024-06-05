# vim: set nu ai sw=4 ts=4 :
# coding: utf-8
# frozen_string_literal: true

require 'umu/common'
require 'umu/lexical/location'


module Umu

module Value

module Core

module Base

module LSM

module Product

class Named < Abstract
	INSTANCE_METHOD_INFOS = [
		[:meth_less_than,	VCBA::Bool,
			:'<',			self]
	]


	alias values objs
    attr_reader :index_by_label


	def initialize(values, index_by_label)
		ASSERT.kind_of values,			::Array
		ASSERT.assert values.size >= 2
		ASSERT.kind_of index_by_label,	::Hash

		@index_by_label = index_by_label.freeze

		super(values)
	end


	def labels
		self.index_by_label.keys
	end


	def to_s
		format("(%s)",
			self.index_by_label.map { |label, index|
				format "%s: %s", label.to_s, self.values[index].to_s
			}.join(', ')
		)
	end


	def select(sel_lab, loc, env)
		ASSERT.kind_of sel_lab,		::Symbol
		ASSERT.kind_of loc,			L::Location

		opt_index = self.index_by_label[sel_lab]
		unless opt_index
			raise X::SelectionError.new(
				loc,
				env,
				"Unknown selector label: '%s'", sel_lab
			)
		end
		index = opt_index

		ASSERT.kind_of self.values[index], VC::Top
	end


	def modify(other, loc, env)
		ASSERT.kind_of other,	Named
		ASSERT.kind_of loc,		L::Location

		mut_self_values = self.value.dup
		other.index_by_label.each_key do |label, other_index|
			self_index = self.index_by_label[label]
			unless self_index
				raise X::SelectionError.new(
					loc,
					env,
					"Unknown modifier label: '%s'", label.to_s
				)
			end

			mut_self_values[self_index] = other.values[other_index]
		end

		VC.make_named_tuple self.loc, mut_self_values, self.index_by_label
	end


	def meth_to_string(loc, env, event)
		VC.make_string(
			format("(%s)",
				self.map { |elem|
					elem.meth_to_string(loc, env, event).val
				}.join(', ')
			)
		)
	end


	def meth_equal(loc, env, event, other)
		ASSERT.kind_of other, VC::Top

		unless other.kind_of?(self.class) && self.arity == other.arity
			return VC.make_false
		end

		VC.make_bool(
			self.values.zip(other.values).all? {
				|self_value, other_value|

				other_value.kind_of?(self_value.class) &&
				self_value.meth_equal(loc, env, event, other_value).true?
			}
		)
	end


	def meth_less_than(loc, env, event, other)
		ASSERT.kind_of other, VCBLP::Tuple

		VC.make_bool(
			self.values.zip(other.values).each_with_index.any? {
				|(self_value, other_value), index|

				unless other_value.kind_of?(self_value.class)
					raise X::TypeError.new(
						loc,
						env,
						"In %d's element of tuple, " +
								"expected a %s, but %s : %s",
							index + 1,
							self_value.type_sym,
							other_value.to_s,
							other_value.type_sym
					)
				end

				self_value.meth_less_than(
					loc, env, event, other_value
				).true?
			}
		)
	end
end

end	# Umu::Value::Core::LSM::Base::Product

end	# Umu::Value::Core::LSM::Base

end	# Umu::Value::Core::LSM


module_function

	def make_named_tuple(values, index_by_label)
		ASSERT.kind_of values,			::Array
		ASSERT.kind_of index_by_label,	::Hash

		Base::LSM::Product::Named.new(
			values.freeze, index_by_label.freeze
		).freeze
	end

end	# Umu::Value::Core

end	# Umu::Value

end	# Umu
