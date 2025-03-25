# coding: utf-8
# frozen_string_literal: true



module Umu

module Value

module Core

module Atom

module Number

class Abstract < Atom::Abstract
    def initialize(val)
        ASSERT.kind_of val, ::Numeric

        super
    end


    def to_s
        val = self.val

        if val < 0
            format "-%s", val.abs.inspect
        else
            val.inspect
        end
    end


    define_instance_method(
        :meth_is_zero,
        :zero?, [],
        [], VCA::Bool
    )
    def meth_is_zero(_loc, _env, _event)
        VC.make_bool self.val.zero?
    end


    define_instance_method(
        :meth_is_positive,
        :positive?, [],
        [], VCA::Bool
    )
    def meth_is_positive(_loc, _env, _event)
        VC.make_bool(self.val > 0)
    end


    define_instance_method(
        :meth_is_negative,
        :negative?, [],
        [], VCA::Bool
    )
    def meth_is_negative(_loc, _env, _event)
        VC.make_bool(self.val < 0)
    end


    define_instance_method(
        :meth_negate,
        :negate, [],
        [], self
    )
    def meth_negate(_loc, _env, _event)
        VC.make_number self.class, - self.val
    end


    define_instance_method(
        :meth_absolute,
        :abs, [],
        [], self
    )
    def meth_absolute(_loc, _env, _event)
        VC.make_number self.class, self.val.abs
    end


    define_instance_method(
        :meth_to_int,
        :'to-i', [],
        [], VCAN::Int
    )
    def meth_to_int(loc, env, _event)
        begin
            VC.make_integer self.val.to_i
        rescue ::FloatDomainError
            raise X::ArgumentError.new(
                loc,
                env,
                "Domain error on float number %s : %s",
                        self.to_s,
                        self.type_sym.to_s
            )
        end
    end


    define_instance_method(
        :meth_to_float,
        :'to-f', [],
        [], VCAN::Float
    )
    def meth_to_float(_loc, _env, _event)
        VC.make_float self.val.to_f
    end


    def +(other)
        ASSERT.kind_of other, Number::Abstract

        VC.make_number self.class, self.val + other.val
    end


    define_instance_method(
        :meth_add,
        :'+', [],
        [self], self
    )
    def meth_add(_loc, _env, _event, other)
        ASSERT.kind_of other, Number::Abstract

        self.+ other
    end


    define_instance_method(
        :meth_sub,
        :'-', [],
        [self], self
    )
    def meth_sub(_loc, _env, _event, other)
        ASSERT.kind_of other, Number::Abstract

        VC.make_number self.class, self.val - other.val
    end


    define_instance_method(
        :meth_multiply,
        :'*', [],
        [self], self
    )
    def meth_multiply(_loc, _env, _event, other)
        ASSERT.kind_of other, Number::Abstract

        VC.make_number self.class, self.val * other.val
    end


    define_instance_method(
        :meth_divide,
        :'/', [],
        [self], self
    )
    def meth_divide(loc, env, _event, other)
        ASSERT.kind_of other, Number::Abstract

        begin
            VC.make_number self.class, self.val / other.val
        rescue ::ZeroDivisionError
            raise X::ZeroDivisionError.new(
                loc,
                env,
                "Zero devision error"
            )
        end
    end


    define_instance_method(
        :meth_modulo,
        :mod, [],
        [self], self
    )
    def meth_modulo(loc, env, _event, other)
        ASSERT.kind_of other, Number::Abstract

        begin
            VC.make_number self.class, self.val % other.val
        rescue ::ZeroDivisionError
            raise X::ZeroDivisionError.new(
                loc,
                env,
                "Zero devision error"
            )
        end
    end


    define_instance_method(
        :meth_power,
        :pow, [],
        [self], self
    )
    def meth_power(loc, env, _event, other)
        ASSERT.kind_of other, Number::Abstract

        begin
            VC.make_number self.class, self.val ** other.val
        rescue ::ZeroDivisionError
            raise X::ZeroDivisionError.new(
                loc,
                env,
                "Zero devision error"
            )
        end
    end


    define_instance_method(
        :meth_random,
        :random, [],
        [], self
    )
    def meth_random(loc, env, _event)
        value = if self.val > 0
                begin
                    VC.make_number self.class, ::Random.rand(self.val)
                rescue Errno::EDOM
                    raise X::ArgumentError.new(
                        loc,
                        env,
                        "Domain error on float number %s : %s",
                                self.to_s,
                                self.type_sym.to_s
                    )
                end
            elsif self.val < 0
                raise X::ArgumentError.new(
                    loc,
                    env,
                    "Invalid argument %s : %s",
                            self.to_s,
                            self.type_sym.to_s
                )
            else
                self
            end

        ASSERT.kind_of value, Number::Abstract
    end
end
Abstract.freeze

end # Umu::Value::Core::Atom::Number

end # Umu::Value::Core::Atom


module_function

    def make_number(klass, val)
        ASSERT.subclass_of  klass,  VCAN::Abstract
        ASSERT.kind_of      val,    ::Numeric

        klass.new(val).freeze
    end

end # Umu::Value::Core

end # Umu::Value

end # Umu
