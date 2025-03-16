# coding: utf-8
# frozen_string_literal: true



module Umu

module ConcreteSyntax

module Core

module Expression

module Nary

module Interval

class Abstract < Expression::Abstract
    attr_reader :fst_expr, :opt_snd_expr, :opt_lst_expr


    def initialize(loc, fst_expr, opt_snd_expr, opt_lst_expr)
        ASSERT.kind_of     fst_expr,        CSCE::Abstract
        ASSERT.opt_kind_of opt_snd_expr,    CSCE::Abstract
        ASSERT.opt_kind_of opt_lst_expr,    CSCE::Abstract

        super(loc)

        @fst_expr     = fst_expr
        @opt_snd_expr = opt_snd_expr
        @opt_lst_expr = opt_lst_expr
    end


    def to_s
        format("%s%s%s .. %s]",
                 __bb__,

                 self.fst_expr.to_s,

                 if self.opt_snd_expr
                     format ", %s", self.opt_snd_expr.to_s
                 else
                     ''
                 end,

                 if self.opt_lst_expr
                     format " %s", self.opt_lst_expr.to_s
                 else
                     ''
                 end
        )
    end


private

    def __bb__
        raise X::InternalSubclassResponsibility
    end


    def __desugar__(env, event)
        new_env = env.enter event

        __make__(
            self.loc,

            self.fst_expr.desugar(new_env),

            if self.opt_snd_expr
                self.opt_snd_expr.desugar(new_env)
            else
                nil
            end,

            if self.opt_lst_expr
                self.opt_lst_expr.desugar(new_env)
            else
                nil
            end
        )
    end


    def __make__(_loc, _fst_expr, _opt_snd_expr, _lst_expr)
        raise X::InternalSubclassResponsibility
    end
end



class Basic < Abstract
    def initialize(loc, fst_expr, opt_snd_expr, lst_expr)
        ASSERT.kind_of     fst_expr,        CSCE::Abstract
        ASSERT.opt_kind_of opt_snd_expr,    CSCE::Abstract
        ASSERT.kind_of     lst_expr,        CSCE::Abstract

        super
    end


private

    def __bb__
        '['
    end


    def __make__(loc, fst_expr, opt_snd_expr, lst_expr)
        ASCE.make_interval loc, fst_expr, opt_snd_expr, lst_expr
    end
end



class Stream < Abstract

private

    def __bb__
        '&['
    end


    def __make__(loc, fst_expr, opt_snd_expr, lst_expr)
        ASCE.make_interval_stream loc, fst_expr, opt_snd_expr, lst_expr
    end
end

end # Umu::ConcreteSyntax::Core::Expression::Nary::Interval

end # Umu::ConcreteSyntax::Core::Expression::Nary


module_function

    def make_interval(loc, fst_expr, opt_snd_expr, lst_expr)
        ASSERT.kind_of     loc,             LOC::Entry
        ASSERT.kind_of     fst_expr,        CSCE::Abstract
        ASSERT.opt_kind_of opt_snd_expr,    CSCE::Abstract
        ASSERT.kind_of     lst_expr,        CSCE::Abstract

        Nary::Interval::Basic.new(
            loc, fst_expr, opt_snd_expr, lst_expr
        ).freeze
    end


    def make_interval_stream(loc, fst_expr, opt_snd_expr, opt_lst_expr)
        ASSERT.kind_of     loc,             LOC::Entry
        ASSERT.kind_of     fst_expr,        CSCE::Abstract
        ASSERT.opt_kind_of opt_snd_expr,    CSCE::Abstract
        ASSERT.opt_kind_of opt_lst_expr,    CSCE::Abstract

        Nary::Interval::Stream.new(
            loc, fst_expr, opt_snd_expr, opt_lst_expr
        ).freeze
    end

end # Umu::ConcreteSyntax::Core::Expression

end # Umu::ConcreteSyntax::Core

end # Umu::ConcreteSyntax

end # Umu
