# coding: utf-8
# frozen_string_literal: true



module Umu

module ConcreteSyntax

module Core

module Expression

module SExpression

class Abstract < Expression::Abstract
end



class Nil < Abstract
    def to_s
        '()'
    end


private

    def __desugar__(_env, _event)
        ASCE.make_s_expr_nil self.loc
    end
end



class Atom < Abstract
    attr_reader :atom_val

    def initialize(loc, atom_val); super(loc); @atom_val = atom_val; end
=begin
        ASSERT.kind_of atom_val, ::Object

        super(loc)

        @atom_val = atom_val
    emd
=end


    def to_s
        self.atom_val.to_s
    end


private

    def __desugar__(env, event)
        ASCE.make_s_expr_atom self.loc, self.atom_val
    end
end



class Cons < Abstract
    attr_reader :car_expr, :cdr_expr

    def initialize(loc, car_expr, cdr_expr); super(loc); @car_expr = car_expr; @cdr_expr = cdr_expr; end
=begin
        ASSERT.kind_of car_expr, SExpression::Abstract
        ASSERT.kind_of cdr_expr, SExpression::Abstract

        super(loc)

        @car_expr = car_expr
        @cdr_expr = cdr_expr
    emd
=end


    def to_s
        format "(%s . %s)", self.car_expr.to_s, self.cdr_expr.to_s
    end


private

    def __desugar__(env, event)
        ASCE.make_s_expr_cons(
             self.loc,
             self.car_expr.desugar(env),
             self.cdr_expr.desugar(env)
        )
    end
end

end # Umu::ConcreteSyntax::Core::Expression::SExpression


module_function

    def make_s_expr_nil(loc)
        ASSERT.kind_of loc, LOC::Entry

        SExpression::Nil.new(loc).freeze
    end


    def make_s_expr_int(loc, val)
        ASSERT.kind_of loc, LOC::Entry
        ASSERT.kind_of val, ::Integer

        SExpression::Atom.new(
            loc, VC.make_integer(val)
        ).freeze
    end


    def make_s_expr_float(loc, val)
        ASSERT.kind_of loc, LOC::Entry
        ASSERT.kind_of val, ::Float

        SExpression::Atom.new(
            loc, VC.make_float(val)
        ).freeze
    end


    def make_s_expr_string(loc, val)
        ASSERT.kind_of loc, LOC::Entry
        ASSERT.kind_of val, ::String

        SExpression::Atom.new(
            loc, VC.make_symbol(val.to_sym)
        ).freeze
    end


    def make_s_expr_symbol(loc, sym)
        ASSERT.kind_of loc, LOC::Entry
        ASSERT.kind_of sym, ::Symbol

        SExpression::Atom.new(
            loc, VC.make_symbol(sym)
        ).freeze
    end


    def make_s_expr_cons(loc, car_expr, cdr_expr)
        ASSERT.kind_of loc,      LOC::Entry
        ASSERT.kind_of car_expr, SExpression::Abstract
        ASSERT.kind_of cdr_expr, SExpression::Abstract

        SExpression::Cons.new(loc, car_expr, cdr_expr).freeze
    end

end # Umu::ConcreteSyntax::Core::Expression

end # Umu::ConcreteSyntax::Core

end # Umu::ConcreteSyntax

end # Umu
