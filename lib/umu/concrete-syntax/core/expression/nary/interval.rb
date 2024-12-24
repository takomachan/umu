# coding: utf-8
# frozen_string_literal: true



module Umu

module ConcreteSyntax

module Core

module Expression

module Nary

class Interval < Expression::Abstract
    attr_reader :fst_expr, :opt_snd_expr, :lst_expr


    def initialize(loc, fst_expr, opt_snd_expr, lst_expr)
        ASSERT.kind_of     fst_expr,        CSCE::Abstract
        ASSERT.opt_kind_of opt_snd_expr,    CSCE::Abstract
        ASSERT.kind_of     lst_expr,        CSCE::Abstract

        super(loc)

        @fst_expr     = fst_expr
        @opt_snd_expr = opt_snd_expr
        @lst_expr     = lst_expr
    end


    def to_s
        format("[%s%s .. %s]",
                 self.fst_expr.to_s,

                 if self.opt_snd_expr
                     format ", %s", self.opt_snd_expr.to_s
                 else
                     ''
                 end,

                 self.lst_expr.to_s
        )
    end


private

    def __desugar__(env, event)
        new_env = env.enter event

        ASCE.make_interval(
                 self.loc,

                 self.fst_expr.desugar(new_env),

                 if self.opt_snd_expr
                     self.opt_snd_expr.desugar(new_env)
                 else
                     nil
                 end,

                 self.lst_expr.desugar(new_env)
        )
    end
end

end # Umu::ConcreteSyntax::Core::Expression::Nary


module_function

    def make_interval(loc, fst_expr, opt_snd_expr, lst_expr)
        ASSERT.kind_of     loc,             LOC::Entry
        ASSERT.kind_of     fst_expr,        CSCE::Abstract
        ASSERT.opt_kind_of opt_snd_expr,    CSCE::Abstract
        ASSERT.kind_of     lst_expr,        CSCE::Abstract

        Nary::Interval.new(loc, fst_expr, opt_snd_expr, lst_expr).freeze
    end

end # Umu::ConcreteSyntax::Core::Expression

end # Umu::ConcreteSyntax::Core

end # Umu::ConcreteSyntax

end # Umu
