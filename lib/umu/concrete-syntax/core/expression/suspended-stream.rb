# coding: utf-8
# frozen_string_literal: true



module Umu

module ConcreteSyntax

module Core

module Expression

class SuspendedStream < Expression::Abstract
    attr_reader :expr

    def initialize(loc, expr)
        ASSERT.kind_of expr, CSCE::Abstract

        super(loc)

        @expr = expr
    end


    def to_s
        format "&{ %s }", self.expr.to_s
    end


    def pretty_print(q)
        PRT.group q, bb:'&{', eb:'}', sep:' ' do
            q.pp self.expr
        end
    end


private

    def __desugar__(env, event)
        new_env = env.enter event

        ASCE.make_suspended_stream(
            self.loc,
            self.expr.desugar(new_env)
        )
    end
end


module_function

    def make_suspended_stream(loc, expr)
        ASSERT.kind_of loc,     LOC::Entry
        ASSERT.kind_of expr,    CSCE::Abstract

        SuspendedStream.new(loc, expr).freeze
    end

end # Umu::ConcreteSyntax::Core::Expression

end # Umu::ConcreteSyntax::Core

end # Umu::ConcreteSyntax

end # Umu
