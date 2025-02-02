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
        :meth_make_atom,
        :atom, [],
        [VCA::Abstract], self
    )
    def self.meth_make_atom(loc, env, event, val)
        ASSERT.kind_of val, VCA::Abstract

        VC.make_s_expr_atom val
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


    define_instance_method(
        :meth_cons,
        :cons, [],
        [self], self
    )
    def meth_cons(_loc, _env, _event, car)
        ASSERT.kind_of car, VC::SExpr::Abstract

        VC.make_s_expr_cons car, self
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
        :meth_is_atom,
        :atom?, [],
        [], VCA::Bool
    )
    def meth_is_atom(_loc, _env, _event)
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
        VC.make_string(
            format("[%s]",
                self.map { |elem|
                    elem.meth_to_string(loc, env, event).val
                }.join(', ')
            )
        )
    end


    def meth_to_s_expr(loc, env, event)
        self
    end
end
Abstract.freeze



class Nil < Abstract
    TYPE_SYM = :SExprNil


    def to_s
        '()'
    end


    def meth_is_nil(_loc, _env, _event)
        VC.make_true
    end
end
Nil.freeze

NIL = Nil.new.freeze



class Atom < Abstract
    TYPE_SYM = :SExprAtom


    attr_reader :val

    def initialize(val)
        ASSERT.kind_of val, VCA::Abstract

        super()

        @val = val
    end


    def to_s
        self.val.to_s
    end


    def meth_is_atom(_loc, _env, _event)
        VC.make_true
    end


    def contents
        self.val
    end


    define_instance_method(
        :meth_contents,
        :contents, [],
        [], VCA::Abstract
    )
    def meth_contents(_loc, _env, _event)
        self.contents
    end
end
Atom.freeze



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


    def to_s
        format "(%s)", __to_string__(self)
    end


    INDEX_BY_LABELS = {car: 0, cdr: 1}

    def contents
        VC.make_named_tuple INDEX_BY_LABELS, self.car, self.car
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
        self.car
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


private

    def __to_string__(cons)
        ASSERT.kind_of cons, SExpr::Cons

        cdr = cons.cdr
        ASSERT.kind_of cdr, SExpr::Abstract

        format("%s%s",
            cons.car.to_s,

            case cdr
            when SExpr::Nil
                ''
            when SExpr::Atom
                format " . %s", cdr.val.to_s
            when SExpr::Cons
                format " %s", __to_string__(cdr)
            else
                ASSERT.abort cdr.inspect
            end
        )
    end
end
Cons.freeze

end # Umu::Value::Core


module_function

    def make_s_expr_nil
        SExpr::NIL
    end


    def make_s_expr_atom(val)
        ASSERT.kind_of val, VCA::Abstract

        SExpr::Atom.new(val).freeze
    end


    def make_s_expr_cons(car, cdr)
        ASSERT.kind_of car,    SExpr::Abstract
        ASSERT.kind_of cdr,    SExpr::Abstract

        SExpr::Cons.new(car, cdr)   # Does NOT freeze!!
    end

end # Umu::Value::Core

end # Umu::Value

end # Umu
