# coding: utf-8
# frozen_string_literal: true



module Umu

module AbstractSyntax

module Core

module Declaration

class Import < Declaration::Abstract
    attr_reader :id


    def initialize(loc, id)
        ASSERT.kind_of id, ASCEU::Identifier::Abstract

        super(loc)

        @id = id
    end


    def to_s
        '%IMPORT ' + self.id.to_s
    end


private

    def __evaluate__(env)
        ASSERT.kind_of env, E::Entry

        result = self.id.evaluate env
        ASSERT.kind_of result, ASR::Value

        struct_value = result.value
        unless struct_value.kind_of? VC::Struct::Entry
            raise X::TypeError.new(
                self.loc,
                env,
                "Expected a Struct in <import> declaration, but %s : %s",
                struct_value,
                struct_value.type_sym
            )
        end

        bindings = struct_value.inject({}) { |hash, field|
            hash.merge(
                field.label => ECV.make_value_target(field.value)
            ) { |label, old_value, new_value|
                ASSERT.abort format("No case, label: %s", label)
            }
        }

        env.va_extend_bindings bindings
    end
end


module_function

    def make_import(loc, id)
        ASSERT.kind_of loc, L::Location
        ASSERT.kind_of id,  ASCEU::Identifier::Abstract

        Import.new(loc, id).freeze
    end

end # Umu::AbstractSyntax::Core::Declaration

end # Umu::AbstractSyntax::Core

end # Umu::AbstractSyntax

end # Umu
