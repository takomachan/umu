# coding: utf-8
# frozen_string_literal: true



module Umu

module Value

module Core

module Morph

class Interval < Abstract
    def self.make(xs)
        ASSERT.kind_of xs, ::Array

        VC.make_list xs
    end


    define_class_method(
        :meth_make_empty,
        :empty, [],
        [], VCM::List::Abstract
    )
    def self.meth_make_empty(loc, env, _event)
        VC.make_nil
    end


    define_class_method(
        :meth_make,
        :make, [:'from:to:'],
        [VCAN::Int, VCAN::Int], self
    )
    define_class_method(
        :meth_make,
        :'make-by', [:'from:to:by:'],
        [VCAN::Int, VCAN::Int, VCAN::Int], self
    )
    def self.meth_make(
        _loc, _env, _event,
        start_value,
        stop_value,
        step_value = VC.make_integer_one
    )
        ASSERT.kind_of start_value, VCAN::Int
        ASSERT.kind_of stop_value,  VCAN::Int
        ASSERT.kind_of step_value,  VCAN::Int

        VC.make_interval start_value, stop_value, step_value
    end


    attr_reader :current_value, :stop_value, :step_value


    def initialize(current_value, stop_value, step_value)
        ASSERT.kind_of current_value, VCAN::Int
        ASSERT.kind_of stop_value,    VCAN::Int
        ASSERT.kind_of step_value,    VCAN::Int

        @current_value = current_value
        @stop_value    = stop_value
        @step_value    = step_value
    end


    def to_s
        step = self.step_value.val

        format("[%s .. %s (%s%s)]",
            self.current_value.to_s,
            self.stop_value.to_s,
            step.positive? ? '+' : '',
            step.to_s
        )
    end


    INDEX_BY_LABELS = {current: 0, stop: 1, step: 2}

    define_instance_method(
        :meth_contents,
        :contents, [],
        [], VCP::Named
    )
    def meth_contents(_loc, _env, _event)
        VC.make_named_tuple(
            INDEX_BY_LABELS, 
            self.current_value,
            self.stop_value,
            self.step_value
        )
    end


    define_instance_method(
        :meth_susp,
        :susp, [],
        [], VCM::Stream::Entry::Interval
    )
    def meth_susp(_loc, env, _event)
        VC.make_interval_stream(
            self.current_value,
            self.stop_value,
            self.step_value,
            env.va_context
        )
    end


    define_instance_method(
        :meth_cons,
        :cons, [],
        [VC::Top], VCM::List::Abstract
    )
    def meth_cons(loc, env, event, value)
        ASSERT.kind_of value, VC::Top

        self.meth_to_list(loc, env, event)
            .meth_cons(loc, env, event, value)
    end


    def meth_dest(_loc, _env, _event)
        if (
            if self.step_value.val.positive?
                self.current_value.val > self.stop_value.val
            else
                self.current_value.val < self.stop_value.val
            end
        )
            VC.make_none
        else
            VC.make_some(
                VC.make_tuple(
                    self.current_value,

                    VC.make_interval(
                        self.current_value + self.step_value,
                        self.stop_value,
                        self.step_value
                    )
                )
            )
        end
    end
end
Interval.freeze


end # Umu::Value::Core::Morph


module_function

    def make_interval(
        start_value,
        stop_value,
        step_value = VC.make_integer_one
    )
        ASSERT.kind_of start_value, VCAN::Int
        ASSERT.kind_of stop_value,  VCAN::Int
        ASSERT.kind_of step_value,  VCAN::Int

        Morph::Interval.new(
            start_value, stop_value, step_value
        ).freeze
    end

end # Umu::Value::Core

end # Umu::Value

end # Umu
