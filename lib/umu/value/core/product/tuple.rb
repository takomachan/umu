require 'umu/common'
require 'umu/lexical/position'


module Umu

module Value

module Core

module Product

class Tuple < Abstract
	INSTANCE_METHOD_INFOS = [
		[:meth_less_than,	VCA::Bool,
			:'<',			self]
	]


	alias values objs


	def initialize(pos, values)
		ASSERT.kind_of values, ::Array
		ASSERT.assert values.size >= 2	# Pair or More

		super
	end


	def to_s
		format "(%s)", self.map(&:to_s).join(', ')
	end


	def select(sel_num, pos, env)
		ASSERT.kind_of sel_num,		::Integer
		ASSERT.kind_of pos,			L::Position

		unless 1 <= sel_num && sel_num <= self.arity
			raise X::SelectionError.new(
				pos,
				env,
				"Selector expected 1..%d, but %d",
					self.arity, sel_num
			)
		end
		value = self.values[sel_num - 1]

		ASSERT.kind_of value, VC::Top
	end


	def meth_to_string(env, event)
		VC.make_string(
			self.pos,

			format("(%s)",
				self.map { |elem|
					elem.meth_to_string(env, event).val
				}.join(', ')
			)
		)
	end


	def meth_equal(env, event, other)
		ASSERT.kind_of other, VC::Top

		unless other.kind_of?(self.class) && self.arity == other.arity
			return VC.make_false self.pos
		end

		VC.make_bool(
			self.pos,

			self.values.zip(other.values).all? {
				|self_value, other_value|

				other_value.kind_of?(self_value.class) &&
				self_value.meth_equal(env, event, other_value).true?
			}
		)
	end


	def meth_less_than(env, event, other)
		ASSERT.kind_of other, VCP::Tuple

		VC.make_bool(
			self.pos,

			self.values.zip(other.values).each_with_index.any? {
				|(self_value, other_value), index|

				unless other_value.kind_of?(self_value.class)
					raise X::TypeError.new(
						pos,
						env,
						"In %d's element of tuple, " +
								"expected a %s, but %s : %s",
							index + 1,
							self_value.type_sym,
							other_value.to_s,
							other_value.type_sym
					)
				end

				self_value.meth_less_than(env, event, other_value).true?
			}
		)
	end
end

end	# Umu::Value::Core::Product


module_function

	def make_tuple(pos, values)
		ASSERT.kind_of pos,		L::Position
		ASSERT.kind_of values,	::Array

		Product::Tuple.new(pos, values.freeze).freeze
	end

end	# Umu::Value::Core

end	# Umu::Value

end	# Umu
