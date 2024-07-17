# coding: utf-8
# frozen_string_literal: true



module Umu

module ConcreteSyntax

module Core

module Pattern

class Abstract < Abstraction::Model
    def pretty_print(q)
        q.text self.to_s
    end


    def exported_vars
        raise X::InternalSubclassResponsibility
    end


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


    def desugar_lambda(seq_num, env)
        E::Tracer.trace(
                    env.pref,
                    env.trace_stack.count,
                    'Desu(Lam)',
                    self.class,
                    self.loc,
                    self.to_s
                ) { |event|
                    __desugar_lambda__ seq_num, env, event
                }
    end


private

    def __desugar_value__(expr, env, event)
        raise X::InternalSubclassResponsibility
    end


    def __desugar_lambda__(seq_num, env, event)
        raise X::InternalSubclassResponsibility
    end
end

end # Umu::ConcreteSyntax::Core::Pattern

end # Umu::ConcreteSyntax::Core

end # Umu::ConcreteSyntax

end # Umu
