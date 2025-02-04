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



class List < Abstract
    attr_reader :fst_expr, :snd_exprs, :opt_expr

    def initialize(loc, fst_expr, snd_exprs, opt_expr)
        ASSERT.kind_of     fst_expr,  SExpression::Abstract
        ASSERT.kind_of     snd_exprs, ::Array
        ASSERT.opt_kind_of opt_expr,  SExpression::Abstract
        snd_exprs.each do |expr|
            ASSERT.kind_of expr, SExpression::Abstract
        end

        super(loc)

        @fst_expr  = fst_expr
        @snd_exprs = snd_exprs
        @opt_expr  = opt_expr
    end


    def to_s
        format("(%s%s)",
            ([self.fst_expr] + self.snd_exprs).map(&:to_s).join(' '),

            if self.opt_expr
                format " . %s", self.opt_expr.to_s
            else
                ''
            end
        )
    end


private

    def __desugar__(env, event)
        ASCE.make_s_expr_list(
            self.loc,

            self.fst_expr.desugar(env),

            self.snd_exprs.map { |expr| expr.desugar(env) },

            if self.opt_expr
                self.opt_expr.desugar(env)
            else
                nil
            end
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


    def make_s_expr_list(loc, fst_expr, snd_exprs, opt_expr = nil)
        ASSERT.kind_of     loc,       LOC::Entry
        ASSERT.kind_of     fst_expr,  SExpression::Abstract
        ASSERT.kind_of     snd_exprs, ::Array
        ASSERT.opt_kind_of opt_expr,  SExpression::Abstract

        SExpression::List.new(
            loc, fst_expr, snd_exprs.freeze, opt_expr
        ).freeze
    end

end # Umu::ConcreteSyntax::Core::Expression

end # Umu::ConcreteSyntax::Core

end # Umu::ConcreteSyntax

end # Umu
