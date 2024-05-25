require 'umu/common'
require 'umu/lexical/location'


module Umu

module Value

module Core

module LSM

module Product

class Tuple < Abstract
	INSTANCE_METHOD_INFOS = [
		[:meth_less_than,	VCA::Bool,
			:'<',			self]
	]


	alias values objs


	def initialize(values)
		ASSERT.kind_of values, ::Array
		ASSERT.assert values.size >= 2	# Pair or More

		super
	end


	def to_s
		format "(%s)", self.map(&:to_s).join(', ')
	end


	def select(sel_num, loc, env)
		ASSERT.kind_of sel_num,		::Integer
		ASSERT.kind_of loc,			L::Location

		unless 1 <= sel_num && sel_num <= self.arity
			raise X::SelectionError.new(
				loc,
				env,
				"Selector expected 1..%d, but %d",
					self.arity, sel_num
			)
		end
		value = self.values[sel_num - 1]

		ASSERT.kind_of value, VC::Top
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
		ASSERT.kind_of other, VCLP::Tuple

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

end	# Umu::Value::Core::LSM::Product

end	# Umu::Value::Core::LSM


module_function

	def make_tuple(values)
		ASSERT.kind_of values, ::Array

		LSM::Product::Tuple.new(values.freeze).freeze
	end

end	# Umu::Value::Core

end	# Umu::Value

end	# Umu
