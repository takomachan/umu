# coding: utf-8
# frozen_string_literal: true



module Umu

module Value

module Core

module Base

module Atom

module Number

class Int < Abstract
    def initialize(val)
        ASSERT.kind_of val, ::Integer

        super
    end


    define_instance_method(
        :meth_is_odd,
        :odd?, [],
        [], VCBA::Bool
    )
    def meth_is_odd(_loc, _env, _event)
        VC.make_bool self.val.odd?
    end


    define_instance_method(
        :meth_is_even,
        :even?, [],
        [], VCBA::Bool
    )
    def meth_is_even(_loc, _env, _event)
        VC.make_bool self.val.even?
    end


    define_instance_method(
        :meth_negate,
        :negate, [],
        [], self
    )


    define_instance_method(
        :meth_absolute,
        :abs, [],
        [], self
    )


    def meth_to_int(_loc, _env, _event)
        self
    end


    define_instance_method(
        :meth_less_than,
        :'<', [],
        [self], VCBA::Bool
    )


    define_instance_method(
        :meth_add,
        :'+', [],
        [self], self
    )


    define_instance_method(
        :meth_sub,
        :'-', [],
        [self], self
    )


    define_instance_method(
        :meth_multiply,
        :'*', [],
        [self], self
    )


    define_instance_method(
        :meth_divide,
        :'/', [],
        [self], self
    )


    define_instance_method(
        :meth_modulo,
        :mod, [],
        [self], self
    )


    define_instance_method(
        :meth_power,
        :pow, [],
        [self], self
    )


    define_instance_method(
        :meth_to,
        :to, [:'to:'],
        [self], VCBLM::Interval
    )
    def meth_to(_loc, _env, _event, stop_value)
        ASSERT.kind_of stop_value, VCBAN::Int

        VC.make_interval self, stop_value
    end


    define_instance_method(
        :meth_to_by,
        :'to-by', [:'to:by:'],
        [self, self], VCBLM::Interval
    )
    def meth_to_by(loc, env, _event, stop_value, step_value)
        ASSERT.kind_of stop_value, VCBAN::Int
        ASSERT.kind_of step_value, VCBAN::Int

        if self.val <= stop_value.val
            unless step_value.val.positive?
                raise X::ValueError.new(
                    loc,
                    env,
                    "In upto-interval, the step value must be positive," +
                        " but %d : Int",
                    step_value.val
                )
            end
        else
            unless step_value.val.negative?
                raise X::ValueError.new(
                    loc,
                    env,
                    "In downto-interval, the step value must be negative," +
                        " but %d : Int",
                    step_value.val
                )
            end
        end

        VC.make_interval self, stop_value, step_value
    end


    define_instance_method(
        :meth_random,
        :random, [],
        [], self
    )
end
Int.freeze

end # Umu::Value::Core::Atom::Base::Number

end # Umu::Value::Core::Atom::Base

end # Umu::Value::Core::Atom


module_function

    def make_integer(val)
        ASSERT.kind_of val, ::Integer

        Base::Atom::Number::Int.new(val).freeze
    end


    def make_integer_one
        Base::Atom::Number::Int.new(1).freeze
    end

end # Umu::Value::Core

end # Umu::Value

end # Umu
