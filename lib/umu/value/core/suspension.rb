# coding: utf-8
# frozen_string_literal: true



module Umu

module Value

module Core

class Susp < Object
    attr_reader :expr, :va_context
    attr_reader :memorized_value

    def initialize(expr, va_context)
        ASSERT.kind_of expr,       ASCE::Abstract
        ASSERT.kind_of va_context, ECV::Abstract

        super()

        @expr       = expr
        @va_context = va_context

        @memorized_value = nil
    end


    def to_s
        format "#Susp<%s>", self.expr.to_s
    end


    def pretty_print(q)
        PRT.group q, bb:'#Susp<', eb:'>' do
            q.pp self.expr
        end
    end


    def force(loc, env, event)
        ASSERT.kind_of loc,     LOC::Entry
        ASSERT.kind_of env,     E::Entry
        ASSERT.kind_of event,   E::Tracer::Event

        unless @memorized_value
            new_env = env.update_va_context(self.va_context)
                         .enter(event)

            result  = self.expr.evaluate new_env
            ASSERT.kind_of result, ASR::Value

            @memorized_value = result.value
        end

        ASSERT.kind_of @memorized_value, VC::Top
    end
end
Susp.freeze


module_function

    def make_suspension(expr, va_context)
        ASSERT.kind_of expr,       ASCE::Abstract
        ASSERT.kind_of va_context, ECV::Abstract

        Susp.new(expr, va_context)   # Does NOT freeze!!
    end

end # Umu::Value::Core

end # Umu::Value

end # Umu
