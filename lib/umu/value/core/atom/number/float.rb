# coding: utf-8
# frozen_string_literal: true



module Umu

module Value

module Core

module Atom

module Number

class Float < Abstract
# Class property

    define_class_method(
        :meth_make_nan,
        :nan, [],
        [], self
    )
    def self.meth_make_nan(_loc, _env, _event)
        VC.make_nan
    end


    define_class_method(
        :meth_make_infinity,
        :infinity, [],
        [], self
    )
    def self.meth_make_infinity(_loc, _env, _event)
        VC.make_infinity
    end


# Instance property

    def initialize(val)
        ASSERT.kind_of val, ::Float

        super
    end


    def to_s
        if self.val.nan?
            'NAN'
        elsif self.val.infinite?
            format("%sINFINITY",
                    if self.val < 0
                        '-'
                    else
                        ''
                    end
            )
        elsif val.finite?
            super
        else
            ASSERT.abort
        end
    end


    define_instance_method(
        :meth_is_nan,
        :nan?, [],
        [], VCA::Bool
    )
    def meth_is_nan(_loc, _env, _event)
        VC.make_bool self.val.nan?
    end


    define_instance_method(
        :meth_is_infinite,
        :infinite?, [],
        [], VCA::Bool
    )
    def meth_is_infinite(_loc, _env, _event)
        VC.make_bool self.val.infinite?.kind_of?(::Integer)
    end


    define_instance_method(
        :meth_is_finite,
        :finite?, [],
        [], VCA::Bool
    )
    def meth_is_finite(_loc, _env, _event)
        VC.make_bool self.val.finite?
    end


    define_instance_method(
        :meth_is_less_than,
        :'<', [],
        [self], VCA::Bool
    )


    define_instance_method(
        :meth_is_greater_than,
        :'>', [],
        [self], VCA::Bool
    )


    define_instance_method(
        :meth_is_less_equal,
        :'<=', [],
        [self], VCA::Bool
    )


    define_instance_method(
        :meth_is_greater_equal,
        :'>=', [],
        [self], VCA::Bool
    )


    define_instance_method(
        :meth_compare,
        :'<=>', [],
        [self], VCAN::Int
    )




    define_instance_method(
        :meth_to_float,
        :'to-f', [],
        [], VCAN::Float
    )
    def meth_to_float(_loc, _env, _event)
        self
    end


    define_instance_method(
        :meth_truncate,
        :truncate, [],
        [VCAN::Int], self
    )
    def meth_truncate(loc, env, _event, ndigits)
        ASSERT.kind_of ndigits, VCAN::Int

        unless ndigits.val >= 0
            raise X::ArgumentError.new(
                loc,
                env,
                "truncate: Expected zero or positive number, but: %d",
                ndigits.val.to_i
            )
        end

        VC.make_float self.val.truncate(ndigits.val).to_f
    end


    define_instance_method(
        :meth_ceil,
        :ceil, [],
        [VCAN::Int], self
    )
    def meth_ceil(loc, env, _event, ndigits)
        ASSERT.kind_of ndigits, VCAN::Int

        unless ndigits.val >= 0
            raise X::ArgumentError.new(
                loc,
                env,
                "ceil: expected zero or positive for digits number: %d",
                ndigits.val.to_i
            )
        end

        VC.make_float self.val.ceil(ndigits.val).to_f
    end


    define_instance_method(
        :meth_floor,
        :floor, [],
        [VCAN::Int], self
    )
    def meth_floor(loc, env, _event, ndigits)
        ASSERT.kind_of ndigits, VCAN::Int

        unless ndigits.val >= 0
            raise X::ArgumentError.new(
                loc,
                env,
                "floor: expected zero or positive for digits number: %d",
                ndigits.val.to_i
            )
        end

        VC.make_float self.val.floor(ndigits.val).to_f
    end


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
end
Float.freeze

NAN         = Atom::Number::Float.new(::Float::NAN).freeze
INFINITY    = Atom::Number::Float.new(::Float::INFINITY).freeze

end # Umu::Value::Core::Atom::Number

end # Umu::Value::Core::Atom


module_function

    def make_float(val)
        ASSERT.kind_of val, ::Float

        Atom::Number::Float.new(val).freeze
    end


    def make_nan
        Atom::Number::NAN
    end


    def make_infinity
        Atom::Number::INFINITY
    end

end # Umu::Value::Core

end # Umu::Value

end # Umu
