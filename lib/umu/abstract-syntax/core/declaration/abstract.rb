# coding: utf-8
# frozen_string_literal: true



module Umu

module AbstractSyntax

module Core

module Declaration

class Abstract < AbstractSyntax::Abstract
    def evaluate(env)
        ASSERT.kind_of env, E::Entry

        new_env = E::Tracer.trace(
                    env.pref,
                    env.trace_stack.count,
                    'Eval(Decl)',
                    self.class,
                    self.loc,
                    self.to_s
        ) { |event|
            before_env = env.enter(event)

            after_env = __evaluate__ before_env

            after_env.leave
        }

        ASR.make_environment new_env
    end


private

    def __evaluate__(_env)
        raise X::InternalSubclassResponsibility
    end
end

end # Umu::AbstractSyntax::Core::Declaration

end # Umu::AbstractSyntax::Core

end # Umu::AbstractSyntax

end # Umu
