# coding: utf-8
# frozen_string_literal: true



module Umu

module Environment

module Context

module Value

class Entry < Abstract
    attr_reader :bindings
    attr_reader :old_context


    def initialize(bindings, old_context)
        ASSERT.kind_of bindings,    ::Hash
        ASSERT.kind_of old_context, ECV::Abstract

        @bindings       = bindings
        @old_context    = old_context
    end


    def get_bindings
        self.bindings.inject({}) { |hash, (sym, target)|
            hash.merge(sym => target.get_value(self))
        }.freeze
    end


    def get_bindings_difference_with(prev_ctx)
        ASSERT.kind_of prev_ctx, ECV::Abstract

        prev_bindings = prev_ctx.get_bindings

        diff_bindings = self.get_bindings.select {
            |sym, value|

            opt_prev_value = prev_bindings[sym]

            if opt_prev_value
                if opt_prev_value == value
                    false
                else
                    true
                end
            else
                true
            end
        }

        ASSERT.kind_of diff_bindings, ::Hash
    end


private

    def __extend__(sym, target)
        ASSERT.kind_of sym,     ::Symbol
        ASSERT.kind_of target,  Target::Abstract

        if self.bindings.has_key? sym
            [{sym => target},                       self]
        else
            [self.bindings.merge(sym => target),    self.old_context]
        end
    end
end



module_function

    def make_bindings(bindings, old_context)
        ASSERT.kind_of bindings,    ::Hash
        ASSERT.kind_of old_context, ECV::Abstract

        Entry.new(bindings.freeze, old_context).freeze
    end

end # Umu::Environment::Context::Value

end # Umu::Environment::Context

end # Umu::Environment

end # Umu
