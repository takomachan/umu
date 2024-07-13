# coding: utf-8
# frozen_string_literal: true



module Umu

module Value

module Core

module Base

module LSM

module Product

class Tuple < Abstract
    INSTANCE_METHOD_INFOS = [
        [:meth_less_than,   VCBA::Bool,
            :'<',           self]
    ]


    alias values objs


    def initialize(values)
        ASSERT.kind_of values, ::Array
        ASSERT.assert values.size >= 2  # Pair or More

        super
    end


    def to_s
        format "(%s)", self.map(&:to_s).join(', ')
    end


    def pretty_print(q)
        PRT.seplist q, self, '(', ')', ','
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

        unless other.kind_of?(self.class) && self.arity == other.arity
            raise X::TypeError.new(
                loc,
                env,
                "Expected a tuple of %d element, but %d: %s",
                    self.arity, other.arity, other.to_s
            )
        end

        result, _index = self.values
            .zip(other.values)
            .inject([VC.make_false, 0]) {
            |(res, index), (self_value, other_value)|
            ASSERT.kind_of res,         VCBA::Bool
            ASSERT.kind_of index,       ::Integer
            ASSERT.kind_of self_value,  VC::Top
            ASSERT.kind_of other_value, VC::Top

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

            if self_value.meth_less_than(       # self < other
                loc, env, event, other_value
            ).true?
                break VC.make_true
            elsif self_value.meth_equal(        # self = other
                loc, env, event, other_value
            ).true?
                [res, index + 1]
            elsif other_value.meth_less_than(   # self > other
                loc, env, event, self_value
            ).true?
                break VC.make_false
            else
                ASSERT.abort 'No case'
            end
        }

        ASSERT.kind_of result, VCBA::Bool
    end
end

end # Umu::Value::Core::LSM::Base::Product

end # Umu::Value::Core::LSM::Base

end # Umu::Value::Core::LSM


module_function

    def make_tuple(values)
        ASSERT.kind_of values, ::Array

        Base::LSM::Product::Tuple.new(values.freeze).freeze
    end

end # Umu::Value::Core

end # Umu::Value

end # Umu
