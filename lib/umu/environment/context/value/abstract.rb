# coding: utf-8
# frozen_string_literal: true



module Umu

module Environment

module Context

module Value

class Abstract < Abstraction::Collection
    def each
        context = self
        until context.kind_of?(Initial)

            yield context

            context = context.old_context
        end

        nil
    end


    def get_bindings
        {}.freeze
    end


    def lookup(sym, loc, env)
        ASSERT.kind_of sym, ::Symbol
        ASSERT.kind_of loc, LOC::Entry
        ASSERT.kind_of env, E::Entry

        self.each do |context|
            ASSERT.kind_of context, Entry

            target = context.bindings[sym]
            ASSERT.opt_kind_of target, Target::Abstract

            if target
                got_value = target.get_value(context)
                ASSERT.kind_of got_value, VC::Top

                return got_value
            end
        end

        raise X::NameError.new(
            loc,
            env,
            "Unbound value identifier: '%s'", sym.to_s
        )
    end


    def extend(sym, target)
        ASSERT.kind_of sym,     ::Symbol
        ASSERT.kind_of target,  Target::Abstract

        pair = __extend__ sym, target
        ASSERT.tuple_of pair, [::Hash, Abstract]

        ECV.make_bindings(*pair)
    end


    def extend_bindings(bindings)
        ASSERT.kind_of bindings, ::Hash

        ECV.make_bindings bindings, self
    end


private

    def __extend__(_sym, _target)
        raise X::InternalSubclassResponsibility
    end
end

end # Umu::Environment::Context::Value

end # Umu::Environment::Context

end # Umu::Environment

end # Umu
