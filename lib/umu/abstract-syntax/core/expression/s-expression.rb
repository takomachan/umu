# coding: utf-8
# frozen_string_literal: true



module Umu

module AbstractSyntax

module Core

module Expression

module SExpression

class Abstract < Expression::Abstract; end



class Nil < Abstract
    def to_s
        '()'
    end


    def __evaluate__(_env, _event)
        VC.make_s_expr_nil
    end
end



class Atom < Abstract
    attr_reader :val

    def initialize(loc, val)
        ASSERT.kind_of val, VCA::Abstract

        super(loc)

        @val = val
    end


    def to_s
        self.val.to_s
    end


    def __evaluate__(_env, _event)
        VC.make_s_expr_atom self.val
    end
end



class Cons < Abstract
    attr_reader :car_expr, :cdr_expr

    def initialize(loc, car_expr, cdr_expr)
        ASSERT.kind_of car_expr, ASCE::SExpression::Abstract
        ASSERT.kind_of cdr_expr, ASCE::SExpression::Abstract

        super(loc)

        @car_expr = car_expr
        @cdr_expr = cdr_expr
    end


    def to_s
        format "(%s . %s)", self.car_expr.to_s, self.cdr_expr.to_s
    end


    def __evaluate__(env, event)
        new_env = env.enter event

        VC.make_s_expr_cons(
             self.car_expr.evaluate(new_env).value,
             self.cdr_expr.evaluate(new_env).value
        )
    end
end

end # Umu::AbstractSyntax::Core::Expression::SExpression


module_function

    def make_s_expr_nil(loc)
        ASSERT.kind_of loc, LOC::Entry

        SExpression::Nil.new(loc).freeze
    end


    def make_s_expr_atom(loc, val)
        ASSERT.kind_of loc, LOC::Entry
        ASSERT.kind_of val, VCA::Abstract

        SExpression::Atom.new(loc, val).freeze
    end


    def make_s_expr_cons(loc, car_expr, cdr_expr)
        ASSERT.kind_of loc,      LOC::Entry
        ASSERT.kind_of car_expr, ASCE::SExpression::Abstract
        ASSERT.kind_of cdr_expr, ASCE::SExpression::Abstract

        SExpression::Cons.new(loc, car_expr, cdr_expr).freeze
    end

end # Umu::AbstractSyntax::Core::Expression

end # Umu::AbstractSyntax::Core

end # Umu::AbstractSyntax

end # Umu
