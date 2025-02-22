# coding: utf-8
# frozen_string_literal: true



module Umu

module ConcreteSyntax

module Core

module Expression

module Nary

module Branch

class Case < Abstract

private

    def __keyword__
        'case'
    end


    def __desugar__(env, event)
        new_env = env.enter event

        fst_head = self.fst_rule.head
        ASSERT.kind_of fst_head, Rule::Case::Abstract
        expr = case fst_head
                when Rule::Case::Atom
                    fst_head.desugar_for_rule new_env, self
                when Rule::Case::Datum
                    fst_head.desugar_for_rule new_env, self
                when Rule::Case::Class
                    fst_head.desugar_for_rule new_env, self
                when Rule::Case::Polymorph::Abstract
                    fst_head.desugar_for_rule new_env, self
                when Rule::Case::Monomorph::Abstraction::Abstract
                    fst_head.desugar_for_rule new_env, self
                else
                    ASSERT.abort "Np case: %s", fst_head.inspect
                end

        ASSERT.kind_of expr, ASCE::Abstract
    end
end

end # Umu::ConcreteSyntax::Core::Expression::Nary::Branch

end # Umu::ConcreteSyntax::Core::Expression::Nary


module_function

    def make_case(loc, expr, fst_rule, snd_rules, opt_else_expr)
        ASSERT.kind_of      loc,            LOC::Entry
        ASSERT.kind_of      expr,           CSCE::Abstract
        ASSERT.kind_of      fst_rule,
                                CSCEN::Branch::Rule::Abstraction::Abstract
        ASSERT.kind_of      snd_rules,      ::Array
        ASSERT.opt_kind_of  opt_else_expr,  CSCE::Abstract

        Nary::Branch::Case.new(
            loc, expr, fst_rule, snd_rules, opt_else_expr
        ).freeze
    end


end # Umu::ConcreteSyntax::Core::Expression

end # Umu::ConcreteSyntax::Core

end # Umu::ConcreteSyntax

end # Umu
