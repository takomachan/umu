# coding: utf-8
# frozen_string_literal: true



module Umu

module Value

module Core

class Math < Top
    define_class_method(
        :meth_make_pi,
        :pi, [],
        [], VCAN::Float
    )
    def self.meth_make_pi(_loc, _env, _event)
        VC.make_float ::Math::PI
    end


    define_class_method(
        :meth_make_e,
        :e, [],
        [], VCAN::Float
    )
    def self.meth_make_e(_loc, _env, _event)
        VC.make_float ::Math::E
    end


    define_class_method(
        :meth_sin,
        :sin, [],
        [VCAN::Float], VCAN::Float
    )
    def self.meth_sin(_loc, _env, _event, this)
        ASSERT.kind_of this, VCAN::Float

        VC.make_float ::Math.sin(this.val)
    end


    define_class_method(
        :meth_cos,
        :cos, [],
        [VCAN::Float], VCAN::Float
    )
    def self.meth_cos(_loc, _env, _event, this)
        ASSERT.kind_of this, VCAN::Float

        VC.make_float ::Math.cos(this.val)
    end


    define_class_method(
        :meth_tan,
        :tan, [],
        [VCAN::Float], VCAN::Float
    )
    def self.meth_tan(_loc, _env, _event, this)
        ASSERT.kind_of this, VCAN::Float

        VC.make_float ::Math.tan(this.val)
    end


    define_class_method(
        :meth_asin,
        :asin, [],
        [VCAN::Float], VCAN::Float
    )
    def self.meth_asin(_loc, _env, _event, this)
        ASSERT.kind_of this, VCAN::Float

        VC.make_float ::Math.asin(this.val)
    end


    define_class_method(
        :meth_acos,
        :acos, [],
        [VCAN::Float], VCAN::Float
    )
    def self.meth_acos(_loc, _env, _event, this)
        ASSERT.kind_of this, VCAN::Float

        VC.make_float ::Math.acos(this.val)
    end


    define_class_method(
        :meth_atan,
        :atan, [],
        [VCAN::Float], VCAN::Float
    )
    def self.meth_atan(_loc, _env, _event, this)
        ASSERT.kind_of this, VCAN::Float

        VC.make_float ::Math.atan(this.val)
    end


    define_class_method(
        :meth_atan2,
        :'atan2-y:x:', [],
        [VCAN::Float, VCAN::Float], VCAN::Float
    )
    def self.meth_atan2(_loc, _env, _event, y, x)
        ASSERT.kind_of y,   VCAN::Float
        ASSERT.kind_of x,   VCAN::Float

        VC.make_float ::Math.atan2(y.val, x.val)
    end


    define_class_method(
        :meth_sinh,
        :sinh, [],
        [VCAN::Float], VCAN::Float
    )
    def self.meth_sinh(_loc, _env, _event, this)
        ASSERT.kind_of this, VCAN::Float

        VC.make_float ::Math.sinh(this.val)
    end


    define_class_method(
        :meth_cosh,
        :cosh, [],
        [VCAN::Float], VCAN::Float
    )
    def self.meth_cosh(_loc, _env, _event, this)
        ASSERT.kind_of this, VCAN::Float

        VC.make_float ::Math.cosh(this.val)
    end


    define_class_method(
        :meth_tanh,
        :tanh, [],
        [VCAN::Float], VCAN::Float
    )
    def self.meth_tanh(_loc, _env, _event, this)
        ASSERT.kind_of this, VCAN::Float

        VC.make_float ::Math.tanh(this.val)
    end


    define_class_method(
        :meth_exp,
        :exp, [],
        [VCAN::Float], VCAN::Float
    )
    def self.meth_exp(_loc, _env, _event, this)
        ASSERT.kind_of this, VCAN::Float

        VC.make_float ::Math.exp(this.val)
    end


    define_class_method(
        :meth_log,
        :log, [],
        [VCAN::Float], VCAN::Float
    )
    def self.meth_log(_loc, _env, _event, this)
        ASSERT.kind_of this, VCAN::Float

        VC.make_float ::Math.log(this.val)
    end


    define_class_method(
        :meth_log10,
        :log10, [],
        [VCAN::Float], VCAN::Float
    )
    def self.meth_log10(_loc, _env, _event, this)
        ASSERT.kind_of this, VCAN::Float

        VC.make_float ::Math.log10(this.val)
    end


    define_class_method(
        :meth_sqrt,
        :sqrt, [],
        [VCAN::Float], VCAN::Float
    )
    def self.meth_sqrt(_loc, _env, _event, this)
        ASSERT.kind_of this, VCAN::Float

        VC.make_float ::Math.sqrt(this.val)
    end


    define_class_method(
        :meth_ldexp,
        :ldexp, [],
        [VCAN::Float, VCAN::Int], VCAN::Float
    )
    def self.meth_ldexp(_loc, _env, _event, this, other)
        ASSERT.kind_of this,  VCAN::Float
        ASSERT.kind_of other, VCAN::Int

        VC.make_float ::Math.ldexp(this.val, other.val)
    end


    define_class_method(
        :meth_frexp,
        :frexp, [],
        [VCAN::Float], VCP::Tuple
    )
    def self.meth_frexp(_loc, _env, _event, this)
        ASSERT.kind_of this, VCAN::Float

        fract, expon = ::Math.frexp this.val

        VC.make_tuple(
            VC.make_float(fract.to_f),
            VC.make_integer(expon.to_i)
        )
    end


    define_class_method(
        :meth_divmod,
        :divmod, [],
        [VCAN::Float, VCAN::Float], VCP::Tuple
    )
    def self.meth_divmod(_loc, _env, _event, this, other)
        ASSERT.kind_of this,  VCAN::Float
        ASSERT.kind_of other, VCAN::Float

        fract, integ = this.val.divmod other.val

        VC.make_tuple(
            VC.make_float(fract.to_f),
            VC.make_float(integ.to_f)
        )
    end


end
Math.freeze


module_function

    def make_pi
        PI
    end


    def make_e
        E
    end

end # Umu::Value::Core

end # Umu::Value

end # Umu
