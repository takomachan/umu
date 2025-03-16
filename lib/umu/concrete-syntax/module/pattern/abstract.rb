# coding: utf-8
# frozen_string_literal: true


module Umu

module ConcreteSyntax

module Module

module Pattern

class Abstract < Abstraction::Model
    def desugar_value(expr, env)
        E::Tracer.trace(
                    env.pref,
                    env.trace_stack.count,
                    'Desu(Val)',
                    self.class,
                    self.loc,
                    self.to_s
                ) { |event|
                    __desugar_value__ expr, env, event
                }
    end


    def exported_vars
        raise X::InternalSubclassResponsibility
    end


private

    def __desugar_value__(_expr, _env, _event)
        raise X::InternalSubclassResponsibility
    end
end

end # Umu::ConcreteSyntax::Module::Pattern

end # Umu::ConcreteSyntax::Module

end # Umu::ConcreteSyntax

end # Umu
