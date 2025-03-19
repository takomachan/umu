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

        fst_head_value          = self.atom_value
        fst_head_type_sym       = self.type_sym
        fst_head_line_num       = self.loc.line_num
        fst_head_value_type_sym = self.atom_value.type_sym

        leafs = case_expr.rules.inject({}) { |leafs, rule|
            ASSERT.kind_of leafs,   ::Hash
            ASSERT.kind_of rule,    Rule::Abstraction::Abstract

            head = rule.head
            ASSERT.kind_of head, Rule::Case::Abstract

            head_type_sym       = head.type_sym
            head_line_num       = head.loc.line_num
            unless head.kind_of? Rule::Case::Atom
                raise X::SyntaxError.new(
                    rule.loc,
                    format("Inconsistent rule categories " +
                                "in case-expression, " +
                            "1st is %s : %s(#%d), " +
                            "but another is %s : %s(#%d)",
                        __escape_string_format__(fst_head_value.to_s),
                        fst_head_type_sym.to_s,
                        fst_head_line_num + 1,
                        __escape_string_format__(head.to_s),
                        head_type_sym.to_s,
                        head_line_num + 1
                    )
                )
            end

            head_value          = head.atom_value
            head_value_type_sym = head.atom_value.type_sym
            ASSERT.kind_of head_value, VCA::Abstract
            unless head_value.class == fst_head_value.class
                raise X::SyntaxError.new(
                    rule.loc,
                    format("Inconsistent rule types in case-expression, " +
                            "1st is %s : %s(#%d), " +
                            "but another is %s : %s(#%d)",
                        __escape_string_format__(fst_head_value.to_s),
                        fst_head_value_type_sym.to_s,
                        fst_head_line_num + 1,
                        __escape_string_format__(head_value.to_s),
                        head_value_type_sym.to_s,
                        head_line_num + 1
                    )
                )
            end

            body_expr = case_expr.desugar_body_expr env, rule

            leafs.merge(head_value.val => body_expr) { |val, _, _|
                raise X::SyntaxError.new(
                    rule.loc,
                    format("Duplicated rules in case-expression: %s : %s",
                        head_value.to_s,
                        head_value_type_sym.to_s
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
