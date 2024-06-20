# coding: utf-8
# frozen_string_literal: true

require 'umu/common'
require 'umu/environment/tracer/tracer'


module Umu

module AbstractSyntax

module Core

module Expression

module Nary

class Switch < Expression::Abstract
    attr_reader :source_expr, :souce_type_sym, :leafs, :else_expr


    def initialize(loc, source_expr, souce_type_sym, leafs, else_expr)
        ASSERT.kind_of source_expr,     ASCE::Abstract
        ASSERT.kind_of souce_type_sym,  ::Symbol
        ASSERT.kind_of leafs,           ::Hash
        ASSERT.kind_of else_expr,       ASCE::Abstract

        super(loc)

        @source_expr    = source_expr
        @souce_type_sym = souce_type_sym
        @leafs          = leafs
        @else_expr      = else_expr
    end


    def to_s
        format("%%SWITCH %s : %s { %s %%ELSE -> %s}",
            self.source_expr.to_s,

            self.souce_type_sym.to_s,

            self.leafs.map { |(head, body)|
                format "%s -> %s", head.to_s, body.to_s
            }.join(' | '),

            self.else_expr.to_s
        )
    end


    def pretty_print(q)
        q.text '%SWITCH '
        q.pp self.source_expr
        q.text ' : '
        q.text self.souce_type_sym.to_s
        q.text ' {'

        case self.leafs.size
        when 0
            # Nothing to do
        when 1
            q.breakable ''

            head, body = self.leafs.first
            __pretty_print_leaf__ q, head, body
        else
            q.breakable ''

            fst_head, fst_body = self.leafs.first
            __pretty_print_leaf__ q, fst_head, fst_body

            not_fst_leafs = self.leafs.reject { |hd, _| hd.eql? fst_head }
            not_fst_leafs.each do |(head, body)|
                q.breakable ''

                q.text '| '
                q.group(PP_INDENT_WIDTH, '', '') do
                    __pretty_print_leaf__ q, head, body
                end
            end
        end

        q.breakable ''

        q.text '%ELSE -> '
        q.group(PP_INDENT_WIDTH, '', '') do
            q.breakable ''

            q.pp self.else_expr
        end

        q.breakable ''

        q.text '}'
    end


private

    def __pretty_print_leaf__(q, head, body)
        q.pp head
        q.text ' -> '
        q.group(PP_INDENT_WIDTH, '', '') do
            q.pp body
        end
    end


    def __evaluate__(env, event)
        ASSERT.kind_of env,     E::Entry
        ASSERT.kind_of event,   E::Tracer::Event

        new_env = env.enter event

        source_result = self.source_expr.evaluate new_env
        ASSERT.kind_of source_result, ASR::Value
        source_value = source_result.value

        source_signat = new_env.ty_lookup self.souce_type_sym, self.loc
        ASSERT.kind_of source_signat, ECTSC::Base
        unless env.ty_kind_of?(source_value, source_signat)
            raise X::TypeError.new(
                self.loc,
                env,
                "Type error in case-expression, " +
                    "expected a %s, but %s : %s",
                self.souce_type_sym,
                source_value,
                source_value.type_sym
            )
        end

        opt_leaf_expr = self.leafs[source_value.val]
        ASSERT.opt_kind_of opt_leaf_expr, ASCE::Abstract

        result = (
            if opt_leaf_expr
                opt_leaf_expr
            else
                self.else_expr
            end
        ).evaluate new_env
        ASSERT.kind_of result, ASR::Value

        result.value
    end
end

end # Umu::AbstractSyntax::Core::Expression::Nary


module_function

    def make_switch(loc, source_expr, souce_type_sym, leafs, else_expr)
        ASSERT.kind_of loc,             L::Location
        ASSERT.kind_of source_expr,     ASCE::Abstract
        ASSERT.kind_of souce_type_sym,  ::Symbol
        ASSERT.kind_of leafs,           ::Hash
        ASSERT.kind_of else_expr,       ASCE::Abstract

        Nary::Switch.new(
            loc, source_expr, souce_type_sym, leafs, else_expr
        ).freeze
    end

end # Umu::AbstractSyntax::Core::Expression

end # Umu::AbstractSyntax::Core

end # Umu::AbstractSyntax

end # Umu
