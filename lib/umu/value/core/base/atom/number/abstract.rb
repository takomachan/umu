# coding: utf-8
# frozen_string_literal: true



module Umu

module Value

module Core

module Base

module Atom

module Number

class Abstract < Atom::Abstract
    INSTANCE_METHOD_INFOS = [
        # Number
        [:meth_positive?,   VCBA::Bool,
            :positive?],
        [:meth_negative?,   VCBA::Bool,
            :negative?],
        [:meth_zero?,       VCBA::Bool,
            :zero?],
        [:meth_negate,      self,
            :negate],
        [:meth_absolute,    self,
            :abs],
        [:meth_to_int,      VCBAN::Int,
            :'to-i'],
        [:meth_to_real,     VCBAN::Real,
            :'to-r'],
        [:meth_add,         self,
            :'+',           self],
        [:meth_sub,         self,
            :'-',           self],
        [:meth_multiply,    self,
            :'*',           self],
        [:meth_divide,      self,
            :'/',           self],
        [:meth_modulo,      self,
            :mod,           self],
        [:meth_power,       self,
            :pow,           self],

        # I/O
        [:meth_random,      self,
            :'random']
    ]


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


    def meth_positive?(_loc, _env, _event)
        VC.make_bool(self.val > 0)
    end


    def meth_negative?(_loc, _env, _event)
        VC.make_bool(self.val < 0)
    end


    def meth_zero?(_loc, _env, _event)
        VC.make_bool self.val.zero?
    end


    def meth_negate(_loc, _env, _event)
        VC.make_number self.class, - self.val
    end


    def meth_absolute(_loc, _env, _event)
        VC.make_number self.class, self.val.abs
    end


    def meth_to_int(loc, env, _event)
        begin
            VC.make_integer self.val.to_i
        rescue ::FloatDomainError
            raise X::ArgumentError.new(
                loc,
                env,
                "Domain error on real number %s : %s",
                        self.to_s,
                        self.type_sym.to_s
            )
        end
    end


    def meth_to_real(_loc, _env, _event)
        VC.make_real self.val.to_f
    end


    def meth_add(_loc, _env, _event, other)
        ASSERT.kind_of other, Number::Abstract

        VC.make_number self.class, self.val + other.val
    end


    def meth_sub(_loc, _env, _event, other)
        ASSERT.kind_of other, Number::Abstract

        VC.make_number self.class, self.val - other.val
    end


    def meth_multiply(_loc, _env, _event, other)
        ASSERT.kind_of other, Number::Abstract

        VC.make_number self.class, self.val * other.val
    end


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


    def meth_random(loc, env, _event)
        value = if self.val > 0
                begin
                    VC.make_number self.class, ::Random.rand(self.val)
                rescue Errno::EDOM
                    raise X::ArgumentError.new(
                        loc,
                        env,
                        "Domain error on real number %s : %s",
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

end # Umu::Value::Core::Atom::Base::Number

end # Umu::Value::Core::Atom::Base

end # Umu::Value::Core::Atom


module_function

    def make_number(klass, val)
        ASSERT.subclass_of  klass,  VCBAN::Abstract
        ASSERT.kind_of      val,    ::Numeric

        klass.new(val).freeze
    end

end # Umu::Value::Core

end # Umu::Value

end # Umu
