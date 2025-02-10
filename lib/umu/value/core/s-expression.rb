# coding: utf-8
# frozen_string_literal: true


# See; お気楽 Haskell プログラミング入門, 中級編 : 二分木と Lisp のリスト
#   http://www.nct9.ne.jp/m_hiroi/func/haskell19b.html

module Umu

module Value

module Core

module SExpr

class Abstract < Object
    def self.make(xs)
        ASSERT.kind_of xs, ::Array

        VC.make_s_expr xs
    end


    define_class_method(
        :meth_make_nil,
        :nil, [],
        [], self
    )
    def self.meth_make_nil(_loc, _env, _event)
        VC.make_s_expr_nil
    end


    define_class_method(
        :meth_make_value,
        :value, [],
        [VC::Top], self
    )
    def self.meth_make_value(loc, env, event, val)
        ASSERT.kind_of val, VC::Top

        VC.make_s_expr_value val
    end


    define_class_method(
        :meth_make_cons,
        :cons, [],
        [self, self], self
    )
    def self.meth_make_cons(loc, env, event, car, cdr)
        ASSERT.kind_of car, VC::SExpr::Abstract
        ASSERT.kind_of cdr, VC::SExpr::Abstract

        VC.make_s_expr_cons car, cdr
    end


    define_class_method(
        :meth_make,
        :make, [],
        [VCM::Abstract], self
    )
    def self.meth_make(loc, env, event, xs)
        ASSERT.kind_of xs, VCM::Abstract

        result = xs.foldr(
             loc,     env,     event, VC.make_s_expr_nil
        ) { |new_loc, new_env, x,     s_expr|
            value = VC.make_s_expr_value x

            VC.make_s_expr_cons value, s_expr
        }

        ASSERT.kind_of result, VC::SExpr::Abstract
    end


    define_instance_method(
        :meth_cons,
        :cons, [],
        [self], self
    )
    def meth_cons(_loc, _env, _event, car)
        ASSERT.kind_of car, VC::SExpr::Abstract

        VC.make_s_expr_cons car, self
    end


    def to_s
        self.to_string({})
    end


    def pretty_print(q)
        q.text self.to_s
    end


    define_instance_method(
        :meth_is_nil,
        :nil?, [],
        [], VCA::Bool
    )
    def meth_is_nil(_loc, _env, _event)
        VC.make_false
    end


    define_instance_method(
        :meth_is_value,
        :value?, [],
        [], VCA::Bool
    )
    def meth_is_value(_loc, _env, _event)
        VC.make_false
    end


    define_instance_method(
        :meth_is_cons,
        :cons?, [],
        [], VCA::Bool
    )
    def meth_is_cons(_loc, _env, _event)
        VC.make_false
    end


    def meth_to_string(loc, env, event)
        VC.make_string self.to_string
    end


    def meth_to_s_expr(loc, env, event)
        self
    end
end
Abstract.freeze



class Nil < Abstract
    TYPE_SYM = :SExprNil


    def to_string(visiteds = {})
        '%S()'
    end


    def meth_is_nil(_loc, _env, _event)
        VC.make_true
    end


    def meth_is_equal(_loc, _env, _event, other)
        ASSERT.kind_of other, VC::Top

        VC.make_bool other.kind_of?(Nil)
    end
end
Nil.freeze

NIL = Nil.new.freeze



class Value < Abstract
    TYPE_SYM = :SExprValue


    attr_reader :val

    def initialize(val)
        ASSERT.kind_of val, VC::Top

        super()

        @val = val
    end


    def to_string(visiteds = {})
        format "%%V(%s)", self.val
    end


    def pretty_print(q)
        PRT.group q, bb:'%V(', eb:')' do
            q.pp self.val
        end
    end


    def meth_is_value(_loc, _env, _event)
        VC.make_true
    end


    def contents
        self.val
    end


    define_instance_method(
        :meth_contents,
        :contents, [],
        [], VC::Top
    )
    def meth_contents(_loc, _env, _event)
        self.contents
    end


    def meth_is_equal(loc, env, event, other)
        ASSERT.kind_of other, VC::Top

        VC.make_bool(
            other.kind_of?(Value) &&
            self.val.meth_is_equal(loc, env, event, other.val).true?
        )
    end
end
Value.freeze



class Cons < Abstract
    TYPE_SYM = :SExprCons


    def initialize(car, cdr)
        ASSERT.kind_of car, SExpr::Abstract
        ASSERT.kind_of cdr, SExpr::Abstract

        super()

        @mutable_car = car
        @mutable_cdr = cdr
    end


    def car
        @mutable_car
    end


    def cdr
        @mutable_cdr
    end


    def to_string(visiteds = {})
        format("%%S(%s)",
                if visiteds.has_key? self.object_id
                    '....'
                else
                     __to_string__(
                        self,
                        visiteds.merge(self.object_id => true)
                    )
                end
        )
    end


    def pretty_print(q)
        PRT.group q, bb:'%S(', eb:')' do
            __pretty_print__ q, self
        end
    end


    def pretty_print_cycle(q)
        '(....)'
    end


    INDEX_BY_LABELS = {car: 0, cdr: 1}

    def contents
        VC.make_named_tuple INDEX_BY_LABELS, self.car, self.cdr
    end


    define_instance_method(
        :meth_car,
        :car, [],
        [], VC::SExpr::Abstract
    )
    def meth_car(_loc, _env, _event)
        self.car
    end


    define_instance_method(
        :meth_cdr,
        :cdr, [],
        [], VC::SExpr::Abstract
    )
    def meth_cdr(_loc, _env, _event)
        self.cdr
    end


    def meth_is_cons(_loc, _env, _event)
        VC.make_true
    end


    define_instance_method(
        :meth_contents,
        :contents, [],
        [], VCP::Named
    )
    def meth_contents(_loc, _env, _event)
        self.contents
    end


    define_instance_method(
        :meth_set_car!,
        :'set-car!', [],
        [SExpr::Abstract], VC::Unit
    )
    def meth_set_car!(_loc, _env, _event, car)
        ASSERT.kind_of car, SExpr::Abstract

        @mutable_car = car

        VC.make_unit
    end


    define_instance_method(
        :meth_set_cdr!,
        :'set-cdr!', [],
        [SExpr::Abstract], VC::Unit
    )
    def meth_set_cdr!(_loc, _env, _event, cdr)
        ASSERT.kind_of cdr, SExpr::Abstract

        @mutable_cdr = cdr

        VC.make_unit
    end


    def meth_is_equal(loc, env, event, other)
        ASSERT.kind_of other, VC::Top

        VC.make_bool(
            other.kind_of?(Cons) &&
            self.car.meth_is_equal(loc, env, event, other.car).true? &&
            self.cdr.meth_is_equal(loc, env, event, other.cdr).true?
        )
    end


private

    def __to_string__(cons, visiteds = {})
        ASSERT.kind_of cons,     SExpr::Cons
        ASSERT.kind_of visiteds, ::Hash

        car = cons.car
        car_str = if visiteds.has_key? car.object_id
                        '....'
                    else
                        cons.car.to_string(
                            visiteds.merge(self.object_id => true)
                        )
                    end


        cdr = cons.cdr
        cdr_str = case cdr
            when SExpr::Nil
                ''
            when SExpr::Value
                format " . %s", cdr.to_s
            when SExpr::Cons
                cddr_str = if visiteds.has_key? cdr.object_id
                                '....'
                            else
                                __to_string__(
                                    cdr,
                                    visiteds.merge(self.object_id => true)
                                )
                            end

                ' ' + cddr_str
            else
                ASSERT.abort cdr.inspect
            end

        format "%s%s", car_str, cdr_str
    end


    def __pretty_print__(q, cons)
        ASSERT.kind_of cons, SExpr::Cons

        q.pp cons.car

        cdr = cons.cdr
        ASSERT.kind_of cdr, SExpr::Abstract

        case cdr
        when SExpr::Nil
            # Nothing to do
        when SExpr::Value
            q.breakable

            q.text '.'

            q.breakable

            q.pp cdr
        when SExpr::Cons
            q.breakable

            __pretty_print__ q, cdr
        else
            ASSERT.abort cdr.inspect
        end
    end
end
Cons.freeze

end # Umu::Value::Core


module_function

    def make_s_expr_nil
        SExpr::NIL
    end


    def make_s_expr_value(val)
        ASSERT.kind_of val, VC::Top

        SExpr::Value.new(val).freeze
    end


    def make_s_expr_cons(car, cdr)
        ASSERT.kind_of car,    SExpr::Abstract
        ASSERT.kind_of cdr,    SExpr::Abstract

        SExpr::Cons.new(car, cdr)   # Does NOT freeze!!
    end

end # Umu::Value::Core

end # Umu::Value

end # Umu
