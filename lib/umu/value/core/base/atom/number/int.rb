# coding: utf-8
# frozen_string_literal: true



module Umu

module Value

module Core

module Base

module Atom

module Number

class Int < Abstract
    INSTANCE_METHOD_INFOS = [
        # Number
        [:meth_is_odd,          :odd?, [],
            [], VCBA::Bool
        ],
        [:meth_is_even,         :even?, [],
            [], VCBA::Bool
        ],
        [:meth_absolute,        :abs, [],
            [], self
        ],
        [:meth_negate,          :negate, [],
            [], self
        ],
        [:meth_less_than,       :'<', [],
            [self], VCBA::Bool
        ],
        [:meth_add,             :'+', [],
            [self], self
        ],
        [:meth_sub,             :'-', [],
            [self], self
        ],
        [:meth_multiply,        :'*', [],
            [self], self
        ],
        [:meth_divide,          :'/', [],
            [self], self
        ],
        [:meth_modulo,          :mod, [],
            [self], self
        ],
        [:meth_power,           :pow, [],
            [self], self
        ],
        [:meth_to,              :to, [:'to:'],
            [self], VCBLM::Interval
        ],
        [:meth_to_by,           :'to-by', [:'to:by:'],
            [self], VCBLM::Interval
         ],

        # I/O
        [:meth_random,          :'random', [],
            [], self
        ]
    ]


    def initialize(val)
        ASSERT.kind_of val, ::Integer

        super
    end


    def meth_is_odd(_loc, _env, _event)
        VC.make_bool self.val.odd?
    end


    def meth_is_even(_loc, _env, _event)
        VC.make_bool self.val.even?
    end


    def meth_to_int(_loc, _env, _event)
        self
    end


    def meth_to(_loc, _env, _event, stop_value)
        ASSERT.kind_of stop_value, VCBAN::Int

        VC.make_interval self, stop_value
    end


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
end

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
