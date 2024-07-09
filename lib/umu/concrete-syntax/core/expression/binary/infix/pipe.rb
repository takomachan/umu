# coding: utf-8
# frozen_string_literal: true



module Umu

module ConcreteSyntax

module Core

module Expression

module Binary

module Infix

module Pipe

class Abstract < Abstraction::WithRepetition

private

    def __desugar_pipe__(env, event, &_block)
        new_env = env.enter event

        opnd_expr,
        hd_opr_exprs,
        *tl_opr_exprs = self.then { |exprs|
                            yield exprs
                        }.map { |expr|
                            expr.desugar new_env
                        }

        ASCE.make_pipe self.loc, opnd_expr, hd_opr_exprs, tl_opr_exprs
    end
end



class Left < Abstract

private

    def __desugar__(env, event)
        __desugar_pipe__ env, event, &:each
    end
end



class Right < Abstract

private

    def __desugar__(env, event)
        __desugar_pipe__ env, event, &:reverse_each
    end
end

end # Umu::ConcreteSyntax::Core::Expression::Binary::Infix::Pipe

end # Umu::ConcreteSyntax::Core::Expression::Binary::Infix

end # Umu::ConcreteSyntax::Core::Expression::Binary


module_function

    def make_pipe_left(loc, lhs_opnd, opr_sym, hd_rhs_opnd, tl_rhs_opnds)
        ASSERT.kind_of loc,             LOC::Entry
        ASSERT.kind_of lhs_opnd,        CSCE::Abstract
        ASSERT.kind_of opr_sym,         ::Symbol
        ASSERT.kind_of hd_rhs_opnd,     CSCE::Abstract
        ASSERT.kind_of tl_rhs_opnds,    ::Array

        Binary::Infix::Pipe::Left.new(
            loc, lhs_opnd, opr_sym, hd_rhs_opnd, tl_rhs_opnds.freeze
        ).freeze
    end


    def make_pipe_right(loc, lhs_opnd, opr_sym, hd_rhs_opnd, tl_rhs_opnds)
        ASSERT.kind_of loc,             LOC::Entry
        ASSERT.kind_of lhs_opnd,        CSCE::Abstract
        ASSERT.kind_of opr_sym,         ::Symbol
        ASSERT.kind_of hd_rhs_opnd,     CSCE::Abstract
        ASSERT.kind_of tl_rhs_opnds,    ::Array

        Binary::Infix::Pipe::Right.new(
            loc, lhs_opnd, opr_sym, hd_rhs_opnd, tl_rhs_opnds.freeze
        ).freeze
    end

end # Umu::ConcreteSyntax::Core::Expression

end # Umu::ConcreteSyntax::Core

end # Umu::ConcreteSyntax

end # Umu
