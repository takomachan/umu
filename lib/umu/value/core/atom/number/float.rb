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


    define_class_method(
        :meth_make_pi,
        :pi, [],
        [], self
    )
    def self.meth_make_pi(_loc, _env, _event)
        VC.make_float ::Math::PI
    end


    define_class_method(
        :meth_make_e,
        :e, [],
        [], self
    )
    def self.meth_make_e(_loc, _env, _event)
        VC.make_float ::Math::E
    end


    define_class_method(
        :meth_sin,
        :sin, [],
        [self], self
    )
    def self.meth_sin(_loc, _env, _event, this)
        ASSERT.kind_of this, Float

        VC.make_float ::Math.sin(this.val)
    end


    define_class_method(
        :meth_cos,
        :cos, [],
        [self], self
    )
    def self.meth_cos(_loc, _env, _event, this)
        ASSERT.kind_of this, Float

        VC.make_float ::Math.cos(this.val)
    end


    define_class_method(
        :meth_tan,
        :tan, [],
        [self], self
    )
    def self.meth_tan(_loc, _env, _event, this)
        ASSERT.kind_of this, Float

        VC.make_float ::Math.tan(this.val)
    end


    define_class_method(
        :meth_asin,
        :asin, [],
        [self], self
    )
    def self.meth_asin(_loc, _env, _event, this)
        ASSERT.kind_of this, Float

        VC.make_float ::Math.asin(this.val)
    end


    define_class_method(
        :meth_acos,
        :acos, [],
        [self], self
    )
    def self.meth_acos(_loc, _env, _event, this)
        ASSERT.kind_of this, Float

        VC.make_float ::Math.acos(this.val)
    end


    define_class_method(
        :meth_atan,
        :atan, [],
        [self], self
    )
    def self.meth_atan(_loc, _env, _event, this)
        ASSERT.kind_of this, Float

        VC.make_float ::Math.atan(this.val)
    end


    define_class_method(
        :meth_atan2,
        :'atan2-y:x:', [],
        [self, self], self
    )
    def self.meth_atan2(_loc, _env, _event, y, x)
        ASSERT.kind_of y,  Float
        ASSERT.kind_of x, Float

        VC.make_float ::Math.atan2(y.val, x.val)
    end


    define_class_method(
        :meth_sinh,
        :sinh, [],
        [self], self
    )
    def self.meth_sinh(_loc, _env, _event, this)
        ASSERT.kind_of this, Float

        VC.make_float ::Math.sinh(this.val)
    end


    define_class_method(
        :meth_cosh,
        :cosh, [],
        [self], self
    )
    def self.meth_cosh(_loc, _env, _event, this)
        ASSERT.kind_of this, Float

        VC.make_float ::Math.cosh(this.val)
    end


    define_class_method(
        :meth_tanh,
        :tanh, [],
        [self], self
    )
    def self.meth_tanh(_loc, _env, _event, this)
        ASSERT.kind_of this, Float

        VC.make_float ::Math.tanh(this.val)
    end


    define_class_method(
        :meth_exp,
        :exp, [],
        [self], self
    )
    def self.meth_exp(_loc, _env, _event, this)
        ASSERT.kind_of this, Float

        VC.make_float ::Math.exp(this.val)
    end


    define_class_method(
        :meth_log,
        :log, [],
        [self], self
    )
    def self.meth_log(_loc, _env, _event, this)
        ASSERT.kind_of this, Float

        VC.make_float ::Math.log(this.val)
    end


    define_class_method(
        :meth_log10,
        :log10, [],
        [self], self
    )
    def self.meth_log10(_loc, _env, _event, this)
        ASSERT.kind_of this, Float

        VC.make_float ::Math.log10(this.val)
    end


    define_class_method(
        :meth_sqrt,
        :sqrt, [],
        [self], self
    )
    def self.meth_sqrt(_loc, _env, _event, this)
        ASSERT.kind_of this, Float

        VC.make_float ::Math.sqrt(this.val)
    end


    define_class_method(
        :meth_ldexp,
        :ldexp, [],
        [self, VCAN::Int], self
    )
    def self.meth_ldexp(_loc, _env, _event, this, other)
        ASSERT.kind_of this,  Float
        ASSERT.kind_of other, VCAN::Int

        VC.make_float ::Math.ldexp(this.val, other.val)
    end


    define_class_method(
        :meth_frexp,
        :frexp, [],
        [self], VCP::Tuple
    )
    def self.meth_frexp(_loc, _env, _event, this)
        ASSERT.kind_of this, Float

        fract, expon = ::Math.frexp this.val

        VC.make_tuple(
            VC.make_float(fract.to_f),
            VC.make_integer(expon.to_i)
        )
    end


    define_class_method(
        :meth_divmod,
        :divmod, [],
        [self, self], VCP::Tuple
    )
    def self.meth_divmod(_loc, _env, _event, this, other)
        ASSERT.kind_of this,  Float
        ASSERT.kind_of other, VCAN::Float

        fract, integ = this.val.divmod other.val

        VC.make_tuple(
            VC.make_float(fract.to_f),
            VC.make_float(integ.to_f)
        )
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
        :meth_to_float,
        :'to-f', [],
        [], VCAN::Float
    )
    def meth_to_float(_loc, _env, _event)
        self
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
