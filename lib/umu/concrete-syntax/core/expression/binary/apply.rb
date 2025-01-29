# coding: utf-8
# frozen_string_literal: true



module Umu

module ConcreteSyntax

module Core

module Expression

module Binary

class Apply < Binary::Abstract
    alias       opr_expr            lhs
    alias       opnd_head_expr      rhs
    attr_reader :opnd_tail_exprs


    def initialize(loc, opr_expr, opnd_head_expr, opnd_tail_exprs)
        ASSERT.kind_of opr_expr,        CSCE::Abstract
        ASSERT.kind_of opnd_head_expr,  CSCE::Abstract
        ASSERT.kind_of opnd_tail_exprs, ::Array

        super(loc, opr_expr, opnd_head_expr)

        @opnd_tail_exprs = opnd_tail_exprs
    end


    def to_s
        format("(%s %s)",
                self.opr_expr.to_s,
                self.opnd_exprs.map(&:to_s).join(' ')
        )
    end


    def pretty_print(q)
        PRT.group q, bb:'(', eb:')' do
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

    def __desugar__(env, event)
        new_env = env.enter event

        ASCE.make_apply(
            self.loc,
            self.opr_expr.desugar(new_env),
            self.opnd_head_expr.desugar(new_env),
            self.opnd_tail_exprs.map { |expr|
                ASSERT.kind_of expr, CSCE::Abstract

                expr.desugar new_env
            }
        )
    end
end

end # Umu::ConcreteSyntax::Core::Expression::Binary


module_function

    def make_apply(loc, opr_expr, opnd_head_expr, opnd_tail_exprs = [])
        ASSERT.kind_of loc,             LOC::Entry
        ASSERT.kind_of opr_expr,        CSCE::Abstract
        ASSERT.kind_of opnd_head_expr,  CSCE::Abstract
        ASSERT.kind_of opnd_tail_exprs, ::Array

        Binary::Apply.new(
            loc, opr_expr, opnd_head_expr, opnd_tail_exprs.freeze
        ).freeze
    end

end # Umu::ConcreteSyntax::Core::Expression

end # Umu::ConcreteSyntax::Core

end # Umu::ConcreteSyntax

end # Umu
