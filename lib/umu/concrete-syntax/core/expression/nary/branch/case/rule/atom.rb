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

class Atom < Abstract
    alias atom_value obj

    def initialize(loc, atom_value)
        ASSERT.kind_of atom_value, VCA::Abstract

        super
    end


    def to_s
        self.obj.to_s
    end


    def pretty_print(q)
        self.obj.pretty_print(q)
    end


    def type_sym
        :Atom
    end


    def desugar_for_rule(env, case_expr)
        ASSERT.kind_of case_expr, Branch::Case

        fst_head_value  = self.atom_value

        leafs = case_expr.rules.inject({}) { |leafs, rule|
            ASSERT.kind_of leafs,   ::Hash
            ASSERT.kind_of rule,    Rule::Abstraction::Abstract

            head = rule.head
            ASSERT.kind_of head, Rule::Case::Abstract
            unless head.kind_of? Rule::Case::Atom
                raise X::SyntaxError.new(
                    rule.loc,
                    format("Inconsistent rule types in case-expression, " +
                            "1st is %s(#%d), but another is %s(#%d)",
                        self.type_sym.to_s,
                        self.line_num,
                        head.type_sym.to_s,
                        head.line_num
                    )
                )
            end

            head_value  = head.atom_value
            ASSERT.kind_of head_value, VCA::Abstract
            unless head_value.class == fst_head_value.class
                raise X::SyntaxError.new(
                    rule.loc,
                    format("Inconsistent rule types in case-expression, " +
                            "1st is %s(%d), but another is %s(%d)",
                        fst_head_value.line_num,
                        fst_head_value.type_sym.to_s,
                        head_value.type_sym.to_s,
                        head_value.line_num
                    )
                )
            end

            body_expr = case_expr.desugar_body_expr env, rule

            leafs.merge(head_value.val => body_expr) { |val, _, _|
                raise X::SyntaxError.new(
                    rule.loc,
                    format("Duplicated rules in case-expression: @%s",
                        val.to_s
                    )
                )
            }
        }

        ASCE.make_switch(
            case_expr.loc,
            case_expr.expr.desugar(env),
            fst_head_value.type_sym,
            leafs,
            case_expr.desugar_else_expr(env)
        )
    end
end

end # Umu::ConcreteSyntax::Core::Expression::Nary::Branch::Rule::Case

end # Umu::ConcreteSyntax::Core::Expression::Nary::Branch::Rule

end # Umu::ConcreteSyntax::Core::Expression::Nary::Branch

end # Umu::ConcreteSyntax::Core::Expression::Nary


module_function

    def make_case_rule_atom(loc, atom_value)
        ASSERT.kind_of loc,         LOC::Entry
        ASSERT.kind_of atom_value,  VCA::Abstract

        Nary::Branch::Rule::Case::Atom.new(
            loc, atom_value
        ).freeze
    end

end # Umu::ConcreteSyntax::Core::Expression

end # Umu::ConcreteSyntax::Core

end # Umu::ConcreteSyntax

end # Umu
