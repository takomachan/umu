# coding: utf-8
# frozen_string_literal: true



module Umu

module AbstractSyntax

module Core

module Expression

module Unary

class Delay < Abstract
    alias expr obj


    def initialize(loc, expr)
        ASSERT.kind_of expr, ASCE::Abstract

        super
    end


    def to_s
        format "%%DELAY %s", self.expr.to_s
    end


    def pretty_print(q)
        q.text "%%DELAY "
        q.pp self.expr
    end


private

    def __evaluate__(env, event)
        VC.make_suspension self.expr, env.va_context
    end
end

end # Umu::AbstractSyntax::Core::Expression::Unary


module_function

    def make_delay(loc, expr)
        ASSERT.kind_of loc,  LOC::Entry
        ASSERT.kind_of expr, ASCE::Abstract

        Unary::Delay.new(loc, expr).freeze
    end

end # Umu::AbstractSyntax::Core::Expression

end # Umu::AbstractSyntax::Core

end # Umu::AbstractSyntax

end # Umu
