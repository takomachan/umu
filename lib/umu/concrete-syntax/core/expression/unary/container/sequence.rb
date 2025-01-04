# coding: utf-8
# frozen_string_literal: true



module Umu

module ConcreteSyntax

module Core

module Expression

module Unary

module Container

class Sequential < Abstract
    def initialize(loc, exprs)
        ASSERT.kind_of  exprs, ::Array
        ASSERT.assert   exprs.size >= 2

        super
    end


    def to_s
        format "(%s)", self.map(&:to_s).join('; ')
    end


    def pretty_print(q)
        PRT.group_nary q, self, bb: '(', eb: ')', join: '; '
    end


private

    def __desugar__(env, event)
        new_env = env.enter event

        *not_last_exprs, last_expr = self.exprs

        decls = ASCD.make_seq_of_declaration(
            self.loc,

            not_last_exprs.map { |expr|
                ASSERT.kind_of expr, CSCE::Abstract

                ASCD.make_value expr.loc, WILDCARD, expr.desugar(new_env)
            }
        )

        ASCE.make_let self.loc, decls, last_expr.desugar(new_env)
    end
end

end # Umu::ConcreteSyntax::Core::Expression::Unary::Container

end # Umu::ConcreteSyntax::Core::Expression::Unary


module_function

    def make_sequential (loc, exprs)
        ASSERT.kind_of loc,     LOC::Entry
        ASSERT.kind_of exprs,   ::Array

        Unary::Container::Sequential.new(loc, exprs.freeze).freeze
    end


end # Umu::ConcreteSyntax::Core::Expression

end # Umu::ConcreteSyntax::Core

end # Umu::ConcreteSyntax

end # Umu
