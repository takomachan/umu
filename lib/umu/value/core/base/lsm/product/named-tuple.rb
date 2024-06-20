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
        [:meth_less_than,   VCBA::Bool,
            :'<',           self]
    ]


    alias values objs
    attr_reader :index_by_label


    def initialize(values, index_by_label)
        ASSERT.kind_of values,          ::Array
        ASSERT.assert values.size >= 2
        ASSERT.kind_of index_by_label,  ::Hash

        @index_by_label = index_by_label.freeze

        super(values)
    end


    def labels
        self.index_by_label.keys
    end


    def each
        self.index_by_label.each do |label, index|
            ASSERT.kind_of label, ::Symbol
            ASSERT.kind_of index, ::Integer

            yield label, self.values[index]
        end
    end


    def to_s
        format("(%s)",
            self.map { |label, value|
                format "%s: %s", label.to_s, value.to_s
            }.join(', ')
        )
    end


    def pretty_print(q)
        P.seplist(q, self, '(', ')', ', ') do |label, value|
            q.text label.to_s
            q.text ': '
            q.pp value
        end
    end


    def select_by_label(sel_lab, loc, env)
        ASSERT.kind_of sel_lab,     ::Symbol
        ASSERT.kind_of loc,         L::Location

        opt_index = self.index_by_label[sel_lab]
        unless opt_index
            raise X::SelectionError.new(
                loc,
                env,
                "Unknown selector label: '%s'", sel_lab.to_s
            )
        end
        index = opt_index

        ASSERT.kind_of self.values[index], VC::Top
    end


    def modify(value_by_label, loc, env)
        ASSERT.kind_of value_by_label,  ::Hash
        ASSERT.kind_of loc,             L::Location

        mut_values = self.values.dup
        value_by_label.each_key do |label, expr|
            index = self.index_by_label[label]
            unless index
                raise X::SelectionError.new(
                    loc,
                    env,
                    "Unknown modifier label: '%s'", label.to_s
                )
            end

            mut_values[index] = value_by_label[label]
        end

        VC.make_named_tuple mut_values, self.index_by_label
    end


    def meth_to_string(loc, env, event)
        VC.make_string self.to_s
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
        ASSERT.kind_of other, VCBLP::Named

        unless other.kind_of?(self.class) && self.arity == other.arity
            raise X::TypeError.new(
                loc,
                env,
                "Expected a named tuple of %d element, but %d: %s",
                    self.arity, other.arity, other.to_s
            )
        end

        result, _index = self.index_by_label.map { |label, index|
            [label, self.values[index]]
        }.zip(
            other.index_by_label.map { |label, index|
                [label, other.values[index]]
            }
        ).inject([VC.make_false, 0]) {
            |
                (res, index),
                ((self_label, self_value), (other_label, other_value))
            |
            ASSERT.kind_of res,         VCBA::Bool
            ASSERT.kind_of index,       ::Integer
            ASSERT.kind_of self_label,  ::Symbol
            ASSERT.kind_of self_value,  VC::Top
            ASSERT.kind_of other_value, VC::Top
            ASSERT.kind_of other_label, ::Symbol

=begin
            pp({index: index,
                self_label: self_label, self_value: self_value,
                other_label: other_label, other_value: other_value
            })
=end

            unless self_label == other_label
                raise X::TypeError.new(
                    loc,
                    env,
                    "Expected '%s:' " +
                            "as label for #%d named tuple element, " +
                            "but '%s:'",
                        self_label.to_s, index + 1, other_label
                )
            end

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

    def make_named_tuple(values, index_by_label)
        ASSERT.kind_of values,          ::Array
        ASSERT.kind_of index_by_label,  ::Hash

        Base::LSM::Product::Named.new(
            values.freeze, index_by_label.freeze
        ).freeze
    end

end # Umu::Value::Core

end # Umu::Value

end # Umu
