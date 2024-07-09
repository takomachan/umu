# coding: utf-8
# frozen_string_literal: true



module Umu

module ConcreteSyntax

module Core

module Expression

module Binary

module Infix

class Redefinable < Abstraction::Simple

private

    def __desugar__(env, event)
        new_env = env.enter event

        ASCE.make_apply(
            self.loc,
            ASCE.make_identifier(loc, self.opr_sym),
            self.lhs_opnd.desugar(new_env),
            [self.rhs_opnd.desugar(new_env)]
        )
    end
end



class KindOf < Abstraction::Abstract
    alias rhs_ident rhs_opnd

    def initialize(loc, lhs_opnd, opr_sym, rhs_ident)
        ASSERT.kind_of lhs_opnd,    CSCE::Abstract
        ASSERT.kind_of opr_sym,     ::Symbol
        ASSERT.kind_of rhs_ident,   CSCEU::Identifier::Short

        super
    end


private

    def __desugar__(env, event)
        new_env = env.enter event

        ASCE.make_test_kind_of(
            self.loc,
            self.lhs_opnd.desugar(new_env),
            self.rhs_ident.desugar(new_env)
        )
    end
end



class AndAlso < Abstraction::Simple

private

    def __desugar__(env, event)
        new_env = env.enter event

        ASCE.make_if(
            self.loc,
            [
                ASCE.make_rule(
                    self.loc,
                    self.lhs_opnd.desugar(new_env),
                    self.rhs_opnd.desugar(new_env)
                )
            ],
            ASCE.make_bool(self.loc, false)
        )
    end
end



class OrElse < Abstraction::Simple

private

    def __desugar__(env, event)
        new_env = env.enter event

        ASCE.make_if(
            self.loc,
            [
                ASCE.make_rule(
                    self.loc,
                    self.lhs_opnd.desugar(new_env),
                    ASCE.make_bool(loc, true)
                )
            ],
            self.rhs_opnd.desugar(new_env)
        )
    end
end

end # Umu::ConcreteSyntax::Core::Expression::Binary::Infix

end # Umu::ConcreteSyntax::Core::Expression::Binary


module_function

    def make_infix(loc, lhs_opnd, opr_sym, rhs_opnd)
        ASSERT.kind_of loc,         LOC::Entry
        ASSERT.kind_of lhs_opnd,    CSCE::Abstract
        ASSERT.kind_of opr_sym,     ::Symbol
        ASSERT.kind_of rhs_opnd,    CSCE::Abstract

        Binary::Infix::Redefinable.new(
            loc, lhs_opnd, opr_sym, rhs_opnd
        ).freeze
    end


    def make_kindof(loc, lhs_opnd, opr_sym, rhs_ident)
        ASSERT.kind_of loc,         LOC::Entry
        ASSERT.kind_of lhs_opnd,    CSCE::Abstract
        ASSERT.kind_of opr_sym,     ::Symbol
        ASSERT.kind_of rhs_ident,   CSCEU::Identifier::Short

        Binary::Infix::KindOf.new(
            loc, lhs_opnd, opr_sym, rhs_ident
        ).freeze
    end


    def make_andalso(loc, lhs_opnd, opr_sym, rhs_opnd)
        ASSERT.kind_of loc,         LOC::Entry
        ASSERT.kind_of lhs_opnd,    CSCE::Abstract
        ASSERT.kind_of opr_sym,     ::Symbol
        ASSERT.kind_of rhs_opnd,    CSCE::Abstract

        Binary::Infix::AndAlso.new(
            loc, lhs_opnd, opr_sym, rhs_opnd
        ).freeze
    end


    def make_orelse(loc, lhs_opnd, opr_sym, rhs_opnd)
        ASSERT.kind_of loc,         LOC::Entry
        ASSERT.kind_of lhs_opnd,    CSCE::Abstract
        ASSERT.kind_of opr_sym,     ::Symbol
        ASSERT.kind_of rhs_opnd,    CSCE::Abstract

        Binary::Infix::OrElse.new(
            loc, lhs_opnd, opr_sym, rhs_opnd
        ).freeze
    end

end # Umu::ConcreteSyntax::Core::Expression

end # Umu::ConcreteSyntax::Core

end # Umu::ConcreteSyntax

end # Umu
