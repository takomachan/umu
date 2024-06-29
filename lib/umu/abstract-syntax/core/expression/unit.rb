# coding: utf-8
# frozen_string_literal: true



module Umu

module AbstractSyntax

module Core

module Expression

class Unit < Expression::Abstract
    def to_s
        '()'
    end


    def evaluate(env)
        value = E::Tracer.trace_single(
                    env.pref,
                    env.trace_stack.count,
                    'Eval(Expr)',
                    self.class,
                    self.loc,
                    self.to_s
                ) { |_event|
                    VC.make_unit
                }

        ASR.make_value value
    end
end


module_function

    def make_unit(loc)
        ASSERT.kind_of loc, LOC::Entry

        Unit.new(loc).freeze
    end

end # Umu::AbstractSyntax::Core::Expression

end # Umu::AbstractSyntax::Core

end # Umu::AbstractSyntax

end # Umu
