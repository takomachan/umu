# coding: utf-8
# frozen_string_literal: true



module Umu

module AbstractSyntax

module Core

module Declaration

class Declarations < Abstract
    attr_reader :decls


    def initialize(loc, decls)
        ASSERT.kind_of loc,     LOC::Entry
        ASSERT.kind_of decls,   ::Array

        super(loc)

        @decls = decls
    end


    def to_s
        format "{ %s }", self.decls.map(&:to_s).join(' ')
    end


    def pretty_print(q)
        q.text '{'
        q.group(PP_INDENT_WIDTH, '', '') do
            self.decls.each do |decl|
                q.breakable

                q.pp decl
            end
        end

        q.breakable

        q.text '}'
    end


private

    def __evaluate__(old_env)
        ASSERT.kind_of old_env, E::Entry

        new_env = self.decls.inject(old_env) { |env, decl|
            ASSERT.kind_of env,     E::Entry
            ASSERT.kind_of decl,    ASCD::Abstract

            result = decl.evaluate env
            ASSERT.kind_of result, ASR::Environment

            result.env
        }

        ASSERT.kind_of new_env, E::Entry
    end
end



module_function

    def make_declarations(loc, decls)
        ASSERT.kind_of loc,     LOC::Entry
        ASSERT.kind_of decls,   ::Array

        Declarations.new(loc, decls.freeze).freeze
    end

end # Umu::AbstractSyntax::Core::Declaration

end # Umu::AbstractSyntax::Core

end # Umu::AbstractSyntax

end # Umu
