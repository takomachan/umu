# coding: utf-8
# frozen_string_literal: true



module Umu

module ConcreteSyntax

module Core

module Expression

module Unary

class Force < Abstract
    alias expr obj


    def initialize(loc, expr)
        ASSERT.kind_of expr, CSCE::Abstract

        super
    end


    def to_s
        format "%%FORCE %s", self.expr.to_s
    end


    def pretty_print(q)
        q.text "%%FORCE "
        q.pp self.expr
    end


private

    def __desugar__(env, event)
        expr = self.expr.desugar env.enter(event)

        ASCE.make_force self.loc, expr
    end
end

end # Umu::ConcreteSyntax::Core::Expression::Unary



module_function

    def make_force(loc, expr)
        ASSERT.kind_of loc,  LOC::Entry
        ASSERT.kind_of expr, CSCE::Abstract

        Unary::Force.new(loc, expr).freeze
    end

end # Umu::ConcreteSyntax::Core::Expression

end # Umu::ConcreteSyntax::Core

end # Umu::ConcreteSyntax

end # Umu
