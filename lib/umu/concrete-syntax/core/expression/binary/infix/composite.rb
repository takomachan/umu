# coding: utf-8
# frozen_string_literal: true



module Umu

module ConcreteSyntax

module Core

module Expression

module Binary

module Infix

module Composite

class Abstract < Abstraction::WithRepetition

private

=begin
    f1 >> f2 >> f3 = { x -> x |> f1 |> f2 |> f3 }
=end

    def __desugar_composite__(env, event, &_block)
        new_env = env.enter event
        ident_x = ASCE.make_identifier self.loc, :'%x'

        hd_opnd,
        *tl_opnds = self.then { |exprs|
                        yield exprs
                    }.map { |opnd|
                         opnd.desugar new_env
                    }

        ASCE.make_lambda(
            self.loc,
            [ASCE.make_parameter(self.loc, ident_x)],
            ASCE.make_pipe(self.loc, ident_x, hd_opnd, tl_opnds)
        )
    end
end



class Left < Abstract

private

=begin
    f1 >> f2 >> f3 = { x -> x |> f1 |> f2 |> f3 }
=end

    def __desugar__(env, event)
        __desugar_composite__ env, event, &:each
    end
end



class Right < Abstract

private

=begin
    f1 << f2 << f3 = { x -> x |> f3 |> f2 |> f1 }
=end

    def __desugar__(env, event)
        __desugar_composite__ env, event, &:reverse_each
    end
end

end # Umu::ConcreteSyntax::Core::Expression::Binary::Infix::Composite

end # Umu::ConcreteSyntax::Core::Expression::Binary::Infix

end # Umu::ConcreteSyntax::Core::Expression::Binary


module_function

    def make_comp_left(loc, lhs_opnd, opr_sym, hd_rhs_opnd, tl_rhs_opnds)
        ASSERT.kind_of loc,             LOC::Entry
        ASSERT.kind_of lhs_opnd,        CSCE::Abstract
        ASSERT.kind_of opr_sym,         ::Symbol
        ASSERT.kind_of hd_rhs_opnd,     CSCE::Abstract
        ASSERT.kind_of tl_rhs_opnds,    ::Array

        Binary::Infix::Composite::Left.new(
            loc, lhs_opnd, opr_sym, hd_rhs_opnd, tl_rhs_opnds.freeze
        ).freeze
    end


    def make_comp_right(loc, lhs_opnd, opr_sym, hd_rhs_opnd, tl_rhs_opnds)
        ASSERT.kind_of loc,             LOC::Entry
        ASSERT.kind_of lhs_opnd,        CSCE::Abstract
        ASSERT.kind_of opr_sym,         ::Symbol
        ASSERT.kind_of hd_rhs_opnd,     CSCE::Abstract
        ASSERT.kind_of tl_rhs_opnds,    ::Array

        Binary::Infix::Composite::Right.new(
            loc, lhs_opnd, opr_sym, hd_rhs_opnd, tl_rhs_opnds.freeze
        ).freeze
    end

end # Umu::ConcreteSyntax::Core::Expression

end # Umu::ConcreteSyntax::Core

end # Umu::ConcreteSyntax

end # Umu
