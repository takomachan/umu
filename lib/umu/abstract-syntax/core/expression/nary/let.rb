# coding: utf-8
# frozen_string_literal: true

require 'umu/common'
require 'umu/environment/tracer/tracer'


module Umu

module AbstractSyntax

module Core

module Expression

module Nary     # N-ary, where N >= 3

class Let < Expression::Abstract
    attr_reader :decls, :expr


    def initialize(loc, decls, expr)
        ASSERT.kind_of decls,   ::Array
        ASSERT.kind_of expr,    ASCE::Abstract

        super(loc)

        @decls  = decls
        @expr   = expr
    end


    def to_s
        format(
            "%%LET { %s %%IN %s }",
            self.decls.map(&:to_s).join(' '),
            self.expr
        )
    end


    def pretty_print(q)
        q.group(PP_INDENT_WIDTH, '%LET {', '') do
            self.decls.each do |decl|
                q.breakable

                q.pp decl
            end
        end
        q.breakable
        q.group(PP_INDENT_WIDTH, '%IN', '') do
            q.breakable

            q.pp self.expr
        end

        q.breakable

        q.text '}'
    end


    def __evaluate__(init_env, event)
        ASSERT.kind_of init_env,    E::Entry
        ASSERT.kind_of event,       E::Tracer::Event

        new_env = self.decls.inject(init_env.enter(event)) { |env, decl|
            ASSERT.kind_of env,     E::Entry
            ASSERT.kind_of decl,    ASCD::Abstract

            result = decl.evaluate env
            ASSERT.kind_of result, ASR::Environment

            result.env
        }

        final_result = self.expr.evaluate new_env
        ASSERT.kind_of final_result, ASR::Value

        final_result.value
    end
end

end # Umu::AbstractSyntax::Core::Expression::Nary


module_function

    def make_let(loc, decls, expr)
        ASSERT.kind_of loc,     L::Location
        ASSERT.kind_of decls,   ::Array
        ASSERT.kind_of expr,    ASCE::Abstract

        Nary::Let.new(loc, decls.freeze, expr).freeze
    end

end # Umu::AbstractSyntax::Core::Expression

end # Umu::AbstractSyntax::Core

end # Umu::AbstractSyntax

end # Umu
