# coding: utf-8
# frozen_string_literal: true



module Umu

module AbstractSyntax

module Core

module Expression

module Unary

class Force < Abstract
    alias expr obj


    def initialize(loc, expr)
        ASSERT.kind_of expr, ASCE::Abstract

        super
    end


    def to_s
        format "(%%FORCE %s)", self.expr.to_s
    end


    def pretty_print(q)
        PRT.group q, bb:'(%FORCE ', eb:')' do
            q.pp self.expr
        end
    end


private

    def __evaluate__(env, event)
        result = self.expr.evaluate env.enter(event)
        ASSERT.kind_of result, ASR::Value

        value = result.value.force self.loc, env, event
        ASSERT.kind_of value, VC::Top
    end
end

end # Umu::AbstractSyntax::Core::Expression::Unary


module_function

    def make_force(loc, expr)
        ASSERT.kind_of loc,  LOC::Entry
        ASSERT.kind_of expr, ASCE::Abstract

        Unary::Force.new(loc, expr).freeze
    end

end # Umu::AbstractSyntax::Core::Expression

end # Umu::AbstractSyntax::Core

end # Umu::AbstractSyntax

end # Umu
