# coding: utf-8
# frozen_string_literal: true



module Umu

module AbstractSyntax

module Core

module Expression

module Binary

class Apply < Binary::Abstract
    alias       opr_expr        lhs_expr
    alias       opnd_head_expr  rhs
    attr_reader :opnd_tail_exprs


    def initialize(loc, opr_expr, opnd_head_expr, opnd_tail_exprs)
        ASSERT.kind_of opr_expr,        ASCE::Abstract
        ASSERT.kind_of opnd_head_expr,  ASCE::Abstract
        ASSERT.kind_of opnd_tail_exprs, ::Array

        super(loc, opr_expr, opnd_head_expr)

        @opnd_tail_exprs = opnd_tail_exprs
    end


    def to_s
        format("(%s %s)",
                self.opr_expr,
                self.opnd_exprs.map(&:to_s).join(' ')
        )
    end


    def pretty_print(q)
        q.group(PP_INDENT_WIDTH, '(', ')') do
            q.pp self.opr_expr

            self.opnd_exprs.each do |expr|
                q.breakable

                q.pp expr
            end
        end
    end


    def opnd_exprs
        [self.opnd_head_expr] + self.opnd_tail_exprs
    end


private

    def __evaluate__(env, event)
        ASSERT.kind_of env,     E::Entry
        ASSERT.kind_of event,   E::Tracer::Event

        new_env = env.enter event

        opr_result = self.opr_expr.evaluate new_env
        ASSERT.kind_of opr_result, ASR::Value

        opnd_head_result = self.opnd_head_expr.evaluate new_env
        ASSERT.kind_of opnd_head_result, ASR::Value

        opnd_tail_values = self.opnd_tail_exprs.map { |expr|
            ASSERT.kind_of expr, ASCE::Abstract

            result = expr.evaluate new_env
            ASSERT.kind_of result, ASR::Value

            result.value
        }

        value = opr_result.value.apply(
                opnd_head_result.value, opnd_tail_values, self.loc, new_env
            )

        ASSERT.kind_of value, VC::Top
    end
end

end # Umu::AbstractSyntax::Core::Expression::Binary


module_function

    def make_apply(loc, opr_expr, opnd_head_expr, opnd_tail_exprs = [])
        ASSERT.kind_of loc,             LOC::Entry
        ASSERT.kind_of opr_expr,        ASCE::Abstract
        ASSERT.kind_of opnd_head_expr,  ASCE::Abstract
        ASSERT.kind_of opnd_tail_exprs, ::Array

        Binary::Apply.new(
            loc, opr_expr, opnd_head_expr, opnd_tail_exprs.freeze
        ).freeze
    end

end # Umu::AbstractSyntax::Core::Expression

end # Umu::AbstractSyntax::Core

end # Umu::AbstractSyntax

end # Umu
