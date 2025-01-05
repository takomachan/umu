# coding: utf-8
# frozen_string_literal: true



module Umu

module Value

module Core

module Base

module LSM

module Morph

class Interval < Abstract
    CLASS_METHOD_INFOS = [
        [:meth_make_empty,      :'empty', [],
            [], self  # --> NotConstractible
        ],
        [:meth_make,            :make, [:'from:to:'],
            [VCBAN::Int, VCBAN::Int], self
        ],
        [:meth_make,            :'make-by', [:'from:to:by:'],
            [VCBAN::Int, VCBAN::Int, VCBAN::Int], self
        ]
    ]

    INSTANCE_METHOD_INFOS = [
        [ :meth_cons,           :cons, [],
            [VC::Top], VCBLM::List::Abstract  # --> NotConstractible
        ],
        [:meth_head,            :head, [],
            [], VCBAN::Int
        ],
        [:meth_tail,            :tail, [],
            [], self
        ],
        [:meth_map,             :map, [],
            [VC::Fun], VCBLM::List::Abstract
        ],
        [:meth_select,          :select, [],
            [VC::Fun], VCBLM::List::Abstract
        ],
        [:meth_append,          :'++', [],
            [VCBLM::Abstract], VCBLM::List::Abstract
        ],
        [:meth_concat,          :concat, [],
            [], VCBLM::List::Abstract
        ],
        [:meth_concat_map,      :'concat-map', [],
            [VC::Fun], VCBLM::List::Abstract
        ],
        [:meth_zip,             :zip, [],
            [VCBLM::Abstract], VCBLM::List::Abstract
        ],
        [:meth_uniq,            :uniq, [],
            [], VCBLM::List::Abstract
        ],
        [:meth_sort,            :sort, [],
            [], VCBLM::List::Abstract
        ],
        [:meth_sort,            :'sort-with', [],
            [VC::Fun], VCBLM::List::Abstract
        ]
    ]


    def self.make(xs)
        ASSERT.kind_of xs, ::Array

        VC.make_list xs
    end


    def self.meth_make_empty(loc, env, _event)
        raise X::NotImplemented.new(
            loc,
            env,
            "Interval object isn't constructible"
        )
    end


    def self.meth_make(
        _loc, _env, _event,
        start_value,
        stop_value,
        step_value = VC.make_integer_one
    )
        ASSERT.kind_of start_value, VCBAN::Int
        ASSERT.kind_of stop_value,  VCBAN::Int
        ASSERT.kind_of step_value,  VCBAN::Int

        VC.make_interval start_value, stop_value, step_value
    end


    attr_reader :current_value, :stop_value, :step_value


    def initialize(current_value, stop_value, step_value)
        ASSERT.kind_of current_value, VCBAN::Int
        ASSERT.kind_of stop_value,    VCBAN::Int
        ASSERT.kind_of step_value,    VCBAN::Int

        @current_value = current_value
        @stop_value    = stop_value
        @step_value    = step_value
    end


    def meth_cons(loc, env, _event, _value)
        raise X::NotImplemented.new(
            loc,
            env,
            "Interval object isn't constructible"
        )
    end


    def meth_is_empty(_loc, _env, _event)
        VC.make_bool __empty__?
    end


    def des!
        raise ::StopIteration if __empty__?

        VC.make_tuple [
            self.current_value,

            VC.make_interval(
                self.current_value + self.step_value,
                self.stop_value,
                self.step_value
            )
        ]
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


private

    def __empty__?
        if self.step_value.val.positive?
            self.current_value.val > self.stop_value.val
        else
            self.current_value.val < self.stop_value.val
        end
    end
end


end # Umu::Value::Core::Base::LSM::Morph

end # Umu::Value::Core::Base::LSM

end # Umu::Value::Core::Base


module_function

    def make_interval(
        start_value,
        stop_value,
        step_value = VC.make_integer_one
    )
        ASSERT.kind_of start_value, VCBAN::Int
        ASSERT.kind_of stop_value,  VCBAN::Int
        ASSERT.kind_of step_value,  VCBAN::Int

        Base::LSM::Morph::Interval.new(
            start_value, stop_value, step_value
        ).freeze
    end

end # Umu::Value::Core

end # Umu::Value

end # Umu
