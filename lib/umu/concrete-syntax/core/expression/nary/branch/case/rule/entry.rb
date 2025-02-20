# coding: utf-8
# frozen_string_literal: true



module Umu

module ConcreteSyntax

module Core

module Expression

module Nary

module Branch

module Rule

module Case

class Entry < Abstraction::HasHead
    def desugar_poly_rule(env)
        self.body_expr.desugar env
    end
end

end # Umu::ConcreteSyntax::Core::Expression::Nary::Branch::Rule::Case

end # Umu::ConcreteSyntax::Core::Expression::Nary::Branch::Rule

end # Umu::ConcreteSyntax::Core::Expression::Nary::Branch

end # Umu::ConcreteSyntax::Core::Expression::Nary


module_function

    def make_case_rule(loc, head, body_expr)
        ASSERT.kind_of loc,         LOC::Entry
        ASSERT.kind_of head,        CSCEN::Branch::Rule::Case::Abstract
        ASSERT.kind_of body_expr,   CSCE::Abstract

        Nary::Branch::Rule::Case::Entry.new(loc, head, body_expr).freeze
    end

end # Umu::ConcreteSyntax::Core::Expression

end # Umu::ConcreteSyntax::Core

end # Umu::ConcreteSyntax

end # Umu
