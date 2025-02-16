# coding: utf-8
# frozen_string_literal: true



module Umu

module AbstractSyntax

module Core

module Expression

class SuspendedStream < Expression::Abstract
    attr_reader :expr


    def initialize(loc, expr)
        ASSERT.kind_of expr, ASCE::Abstract

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

    def __evaluate__(env, event)
        VC.make_suspended_stream self.expr, env.va_context
    end
end


module_function

    def make_suspended_stream(loc, expr)
        ASSERT.kind_of loc,     LOC::Entry
        ASSERT.kind_of expr,    ASCE::Abstract

        SuspendedStream.new(loc, expr).freeze
    end

end # Umu::AbstractSyntax::Core::Expression

end # Umu::AbstractSyntax::Core

end # Umu::AbstractSyntax

end # Umu
