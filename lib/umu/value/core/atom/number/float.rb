# coding: utf-8
# frozen_string_literal: true



module Umu

module Value

module Core

module Atom

module Number

class Float < Abstract
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


    define_class_method(
        :meth_make_pi,
        :pi, [],
        [], self
    )
    def self.meth_make_pi(_loc, _env, _event)
        VC.make_float Math::PI
    end


    define_class_method(
        :meth_make_e,
        :e, [],
        [], self
    )
    def self.meth_make_e(_loc, _env, _event)
        VC.make_float Math::E
    end


    define_instance_method(
        :meth_zero,
        :zero, [],
        [], self
    )
    def meth_zero(_loc, _env, _event)
        VC.make_float 0.0
    end


    define_instance_method(
        :meth_absolute,
        :abs, [],
        [], self
    )


    define_instance_method(
        :meth_negate,
        :negate, [],
        [], self
    )


    def meth_to_float(_loc, _env, _event)
        self
    end


    define_instance_method(
        :meth_succ,
        :succ, [],
        [], self
    )
    def meth_succ(_loc, _env, _event)
        VC.make_float(self.val + 1.0)
    end


    define_instance_method(
        :meth_pred,
        :pred, [],
        [], self
    )
    def meth_pred(_loc, _env, _event)
        VC.make_float(self.val - 1.0)
    end


    define_instance_method(
        :meth_less_than,
        :'<', [],
        [self], VCA::Bool
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
        :meth_sin,
        :sin, [],
        [], self
    )
    def meth_sin(_loc, _env, _event)
        VC.make_float Math.sin(self.val)
    end


    define_instance_method(
        :meth_cos,
        :cos, [],
        [], self
    )
    def meth_cos(_loc, _env, _event)
        VC.make_float Math.cos(self.val)
    end


    define_instance_method(
        :meth_tan,
        :tan, [],
        [], self
    )
    def meth_tan(_loc, _env, _event)
        VC.make_float Math.tan(self.val)
    end


    define_instance_method(
        :meth_asin,
        :asin, [],
        [], self
    )
    def meth_asin(_loc, _env, _event)
        VC.make_float Math.asin(self.val)
    end


    define_instance_method(
        :meth_acos,
        :acos, [],
        [], self
    )
    def meth_acos(_loc, _env, _event)
        VC.make_float Math.acos(self.val)
    end


    define_instance_method(
        :meth_atan,
        :atan, [],
        [], self
    )
    def meth_atan(_loc, _env, _event)
        VC.make_float Math.atan(self.val)
    end


    define_instance_method(
        :meth_atan2,
        :atan2, [],
        [self], self
    )
    def meth_atan2(_loc, _env, _event, other)
        ASSERT.kind_of other, Float

        VC.make_float Math.atan2(other.val, self.val)
    end


    define_instance_method(
        :meth_sinh,
        :sinh, [],
        [], self
    )
    def meth_sinh(_loc, _env, _event)
        VC.make_float Math.sinh(self.val)
    end


    define_instance_method(
        :meth_cosh,
        :cosh, [],
        [], self
    )
    def meth_cosh(_loc, _env, _event)
        VC.make_float Math.cosh(self.val)
    end


    define_instance_method(
        :meth_tanh,
        :tanh, [],
        [], self
    )
    def meth_tanh(_loc, _env, _event)
        VC.make_float Math.tanh(self.val)
    end


    define_instance_method(
        :meth_exp,
        :exp, [],
        [], self
    )
    def meth_exp(_loc, _env, _event)
        VC.make_float Math.exp(self.val)
    end


    define_instance_method(
        :meth_log,
        :log, [],
        [], self
    )
    def meth_log(_loc, _env, _event)
        VC.make_float Math.log(self.val)
    end


    define_instance_method(
        :meth_log10,
        :log10, [],
        [], self
    )
    def meth_log10(_loc, _env, _event)
        VC.make_float Math.log10(self.val)
    end


    define_instance_method(
        :meth_sqrt,
        :sqrt, [],
        [], self
    )
    def meth_sqrt(_loc, _env, _event)
        VC.make_float Math.sqrt(self.val)
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
                "truncate: expected zero or positive for digits number: %d",
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
        :meth_ldexp,
        :ldexp, [],
        [VCAN::Int], self
    )
    def meth_ldexp(_loc, _env, _event, other)
        ASSERT.kind_of other, VCAN::Int

        VC.make_float Math.ldexp(self.val, other.val)
    end


    define_instance_method(
        :meth_frexp,
        :frexp, [],
        [], VCLP::Tuple
    )
    def meth_frexp(_loc, _env, _event)
        fract, expon = Math.frexp self.val

        VC.make_tuple(
            VC.make_float(fract.to_f),
            VC.make_integer(expon.to_i)
        )
    end


    define_instance_method(
        :meth_divmod,
        :divmod, [],
        [self], VCLP::Tuple
    )
    def meth_divmod(_loc, _env, _event, other)
        ASSERT.kind_of other, VCAN::Float

        fract, integ = self.val.divmod other.val

        VC.make_tuple(
            VC.make_float(fract.to_f),
            VC.make_float(integ.to_f)
        )
    end


    define_instance_method(
        :meth_random,
        :random, [],
        [], self
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
