# coding: utf-8
# frozen_string_literal: true



module Umu

module AbstractSyntax

module Core

module Expression

module Binary

class Pipe < Binary::Abstract
    alias       opnd_expr      lhs_expr
    alias       opr_head_expr  rhs
    attr_reader :opr_tail_exprs


    def initialize(loc, opnd_expr, opr_head_expr, opr_tail_exprs)
        ASSERT.kind_of opnd_expr,       ASCE::Abstract
        ASSERT.kind_of opr_head_expr,   ASCE::Abstract
        ASSERT.kind_of opr_tail_exprs,  ::Array

        super(loc, opnd_expr, opr_head_expr)

        @opr_tail_exprs = opr_tail_exprs
    end


    def opr_exprs
        [self.opr_head_expr] + self.opr_tail_exprs
    end


    def to_s
        format("(%s |> %s)",
                self.opnd_expr,
                self.opr_exprs.map(&:to_s).join(' |> ')
        )
    end


    def pretty_print(q)
        q.text '('
        q.pp self.opnd_expr

        self.opr_exprs.each do |expr|
            q.breakable

            q.text '|> '
            q.pp expr
        end

        q.text ')'
    end


private

    def __evaluate__(env, event)
        ASSERT.kind_of env,     E::Entry
        ASSERT.kind_of event,   E::Tracer::Event

        new_env = env.enter event

        init_opnd_value = self.opnd_expr.evaluate(new_env).value
        ASSERT.kind_of init_opnd_value, VC::Top

        opr_values = self.opr_exprs.map { |expr|
            ASSERT.kind_of expr, ASCE::Abstract

            result = expr.evaluate new_env
            ASSERT.kind_of result, ASR::Value

            result.value
        }

        value = opr_values.inject(init_opnd_value) { |opnd_value, opr_value|
            ASSERT.kind_of opnd_value, VC::Top
            ASSERT.kind_of opr_value,  VC::Top

            opr_value.apply(
                opnd_value, [], self.loc, new_env
            )
        }

        ASSERT.kind_of value, VC::Top
    end
end

end # Umu::AbstractSyntax::Core::Expression::Binary


module_function

    def make_pipe(loc, opnd_expr, opr_head_expr, opr_tail_exprs = [])
        ASSERT.kind_of loc,             LOC::Entry
        ASSERT.kind_of opnd_expr,       ASCE::Abstract
        ASSERT.kind_of opr_head_expr,   ASCE::Abstract
        ASSERT.kind_of opr_tail_exprs,  ::Array

        Binary::Pipe.new(
            loc, opnd_expr, opr_head_expr, opr_tail_exprs.freeze
        ).freeze
    end

end # Umu::AbstractSyntax::Core::Expression

end # Umu::AbstractSyntax::Core

end # Umu::AbstractSyntax

end # Umu
