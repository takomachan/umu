# coding: utf-8
# frozen_string_literal: true



module Umu

module Value

module Core

module Base

module Atom

module Number

class Real < Abstract
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
        VC.make_real Math::PI
    end


    define_class_method(
        :meth_make_e,
        :e, [],
        [], self
    )
    def self.meth_make_e(_loc, _env, _event)
        VC.make_real Math::E
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


    def meth_to_real(_loc, _env, _event)
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
        :meth_is_nan,
        :nan?, [],
        [], VCBA::Bool
    )
    def meth_is_nan(_loc, _env, _event)
        VC.make_bool self.val.nan?
    end


    define_instance_method(
        :meth_is_infinite,
        :infinite?, [],
        [], VCBA::Bool
    )
    def meth_is_infinite(_loc, _env, _event)
        VC.make_bool self.val.infinite?.kind_of?(::Integer)
    end


    define_instance_method(
        :meth_is_finite,
        :finite?, [],
        [], VCBA::Bool
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
        VC.make_real Math.sin(self.val)
    end


    define_instance_method(
        :meth_cos,
        :cos, [],
        [], self
    )
    def meth_cos(_loc, _env, _event)
        VC.make_real Math.cos(self.val)
    end


    define_instance_method(
        :meth_tan,
        :tan, [],
        [], self
    )
    def meth_tan(_loc, _env, _event)
        VC.make_real Math.tan(self.val)
    end


    define_instance_method(
        :meth_asin,
        :asin, [],
        [], self
    )
    def meth_asin(_loc, _env, _event)
        VC.make_real Math.asin(self.val)
    end


    define_instance_method(
        :meth_acos,
        :acos, [],
        [], self
    )
    def meth_acos(_loc, _env, _event)
        VC.make_real Math.acos(self.val)
    end


    define_instance_method(
        :meth_atan,
        :atan, [],
        [], self
    )
    def meth_atan(_loc, _env, _event)
        VC.make_real Math.atan(self.val)
    end


    define_instance_method(
        :meth_atan2,
        :atan2, [],
        [self], self
    )
    def meth_atan2(_loc, _env, _event, other)
        ASSERT.kind_of other, Real

        VC.make_real Math.atan2(other.val, self.val)
    end


    define_instance_method(
        :meth_sinh,
        :sinh, [],
        [], self
    )
    def meth_sinh(_loc, _env, _event)
        VC.make_real Math.sinh(self.val)
    end


    define_instance_method(
        :meth_cosh,
        :cosh, [],
        [], self
    )
    def meth_cosh(_loc, _env, _event)
        VC.make_real Math.cosh(self.val)
    end


    define_instance_method(
        :meth_tanh,
        :tanh, [],
        [], self
    )
    def meth_tanh(_loc, _env, _event)
        VC.make_real Math.tanh(self.val)
    end


    define_instance_method(
        :meth_exp,
        :exp, [],
        [], self
    )
    def meth_exp(_loc, _env, _event)
        VC.make_real Math.exp(self.val)
    end


    define_instance_method(
        :meth_log,
        :log, [],
        [], self
    )
    def meth_log(_loc, _env, _event)
        VC.make_real Math.log(self.val)
    end


    define_instance_method(
        :meth_log10,
        :log10, [],
        [], self
    )
    def meth_log10(_loc, _env, _event)
        VC.make_real Math.log10(self.val)
    end


    define_instance_method(
        :meth_sqrt,
        :sqrt, [],
        [], self
    )
    def meth_sqrt(_loc, _env, _event)
        VC.make_real Math.sqrt(self.val)
    end


    define_instance_method(
        :meth_truncate,
        :truncate, [],
        [VCBAN::Int], self
    )
    def meth_truncate(loc, env, _event, ndigits)
        ASSERT.kind_of ndigits, VCBAN::Int

        unless ndigits.val >= 0
            raise X::ArgumentError.new(
                loc,
                env,
                "truncate: expected zero or positive for digits number: %d",
                ndigits.val.to_i
            )
        end

        VC.make_real self.val.truncate(ndigits.val).to_f
    end


    define_instance_method(
        :meth_ceil,
        :ceil, [],
        [VCBAN::Int], self
    )
    def meth_ceil(loc, env, _event, ndigits)
        ASSERT.kind_of ndigits, VCBAN::Int

        unless ndigits.val >= 0
            raise X::ArgumentError.new(
                loc,
                env,
                "ceil: expected zero or positive for digits number: %d",
                ndigits.val.to_i
            )
        end

        VC.make_real self.val.ceil(ndigits.val).to_f
    end


    define_instance_method(
        :meth_floor,
        :floor, [],
        [VCBAN::Int], self
    )
    def meth_floor(loc, env, _event, ndigits)
        ASSERT.kind_of ndigits, VCBAN::Int

        unless ndigits.val >= 0
            raise X::ArgumentError.new(
                loc,
                env,
                "floor: expected zero or positive for digits number: %d",
                ndigits.val.to_i
            )
        end

        VC.make_real self.val.floor(ndigits.val).to_f
    end


    define_instance_method(
        :meth_ldexp,
        :ldexp, [],
        [VCBAN::Int], self
    )
    def meth_ldexp(_loc, _env, _event, other)
        ASSERT.kind_of other, VCBAN::Int

        VC.make_real Math.ldexp(self.val, other.val)
    end


    define_instance_method(
        :meth_frexp,
        :frexp, [],
        [], VCBLP::Tuple
    )
    def meth_frexp(_loc, _env, _event)
        fract, expon = Math.frexp self.val

        VC.make_tuple(
            [
                VC.make_real(fract.to_f),
                VC.make_integer(expon.to_i)
            ]
        )
    end


    define_instance_method(
        :meth_divmod,
        :divmod, [],
        [self], VCBLP::Tuple
    )
    def meth_divmod(_loc, _env, _event, other)
        ASSERT.kind_of other, VCBAN::Real

        fract, integ = self.val.divmod other.val

        VC.make_tuple(
            [
                VC.make_real(fract.to_f),
                VC.make_real(integ.to_f)
            ]
        )
    end


    define_instance_method(
        :meth_random,
        :random, [],
        [], self
    )
end
Real.freeze

NAN         = Atom::Number::Real.new(::Float::NAN).freeze
INFINITY    = Atom::Number::Real.new(::Float::INFINITY).freeze

end # Umu::Value::Core::Atom::Base::Number

end # Umu::Value::Core::Atom::Base

end # Umu::Value::Core::Atom


module_function

    def make_real(val)
        ASSERT.kind_of val, ::Float

        Base::Atom::Number::Real.new(val).freeze
    end


    def make_nan
        Base::Atom::Number::NAN
    end


    def make_infinity
        Base::Atom::Number::INFINITY
    end

end # Umu::Value::Core

end # Umu::Value

end # Umu
