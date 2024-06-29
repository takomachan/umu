# coding: utf-8
# frozen_string_literal: true



module Umu

module AbstractSyntax

module Core

module Declaration

class MutualRecursive < Abstract
    attr_reader :bindings


    def initialize(loc, bindings)
        ASSERT.kind_of loc,         L::Location
        ASSERT.kind_of bindings,    ::Hash
        ASSERT.assert (bindings.size >= 2), bindings.inspect

        super(loc)

        @bindings = bindings
    end


    def to_s
        format(
            "%%VAL %%REC %s",
            self.bindings.map { |sym, target|
                format "%s = %s", sym.to_s, target.lam_expr.to_s
            }.join(" %%AND ")
        )
    end


    def pretty_print(q)
        q.text '%VAL %REC '

        fst_sym, fst_target = self.bindings.first
        __pretty_print_binding__ q, fst_sym, fst_target

        not_fst_bindings = self.bindings.reject { |sym, _| sym == fst_sym }
        not_fst_bindings.each do |sym, target|
            q.breakable ''

            q.text ' %AND '
            __pretty_print_binding__ q, sym, target
        end
    end


private

    def __pretty_print_binding__(q, sym, target)
            q.text format("%s = ", sym.to_s)
            q.group(PP_INDENT_WIDTH, '', '') do
                q.pp target
            end
    end


    def __evaluate__(env)
        ASSERT.kind_of env, E::Entry

        env.va_extend_bindings self.bindings
    end
end



module_function

    def make_mutual_recursive(loc, bindings)
        ASSERT.kind_of loc,         L::Location
        ASSERT.kind_of bindings,    ::Hash

        MutualRecursive.new(loc, bindings.freeze).freeze
    end

end # Umu::AbstractSyntax::Core::Declaration

end # Umu::AbstractSyntax::Core

end # Umu::AbstractSyntax

end # Umu
