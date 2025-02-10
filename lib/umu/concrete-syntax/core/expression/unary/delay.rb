# coding: utf-8
# frozen_string_literal: true



module Umu

module ConcreteSyntax

module Core

module Expression

module Unary

class Delay < Abstract
    alias expr obj


    def initialize(loc, expr)
        ASSERT.kind_of expr, CSCE::Abstract

        super
    end


    def to_s
        format "%%DELAY %s", self.expr.to_s
    end


    def pretty_print(q)
        q.text '%DELAY '
        q.pp self.expr
    end


private

    def __desugar__(env, event)
        expr = self.expr.desugar env.enter(event)

        ASCE.make_delay self.loc, expr
    end
end

end # Umu::ConcreteSyntax::Core::Expression::Unary



module_function

    def make_delay(loc, expr)
        ASSERT.kind_of loc,  LOC::Entry
        ASSERT.kind_of expr, CSCE::Abstract

        Unary::Delay.new(loc, expr).freeze
    end

end # Umu::ConcreteSyntax::Core::Expression

end # Umu::ConcreteSyntax::Core

end # Umu::ConcreteSyntax

end # Umu
