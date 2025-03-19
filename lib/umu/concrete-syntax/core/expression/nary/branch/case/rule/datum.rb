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

class Datum < Abstract
    alias       tag_sym obj
    attr_reader :opt_contents_pat

    def initialize(loc, tag_sym, opt_contents_pat)
        ASSERT.kind_of      tag_sym,            ::Symbol
        ASSERT.opt_kind_of  opt_contents_pat,   CSCP::Abstract

        super(loc, tag_sym)

        @opt_contents_pat = opt_contents_pat
    end


    def type_sym
        :Datum
    end


    def to_s
        format("%s%s",
                self.tag_sym.to_s,

                if self.opt_contents_pat
                    ' ' + self.opt_contents_pat.to_s
                else
                    ''
                end
        )
    end


    def pretty_print(q)
        q.text self.tag_sym.to_s

        if self.opt_contents_pat
            q.text ' '
            q.pp self.opt_contents_pat
        end
    end


    def desugar_for_rule(env, case_expr)
        ASSERT.kind_of case_expr, Branch::Case

        source_expr = case_expr.expr.desugar env

        leafs = case_expr.rules.inject({}) { |leafs, rule|
            ASSERT.kind_of leafs,   ::Hash
            ASSERT.kind_of rule,    Rule::Abstraction::Abstract

            head = rule.head
            ASSERT.kind_of head, Rule::Case::Abstract
            unless head.kind_of? Rule::Case::Datum
                raise X::SyntaxError.new(
                    rule.loc,
                    format("Inconsistent rule categories " +
                                "in case-expression, " +
                            "1st is %s : %s(#%d), " +
                            "but another is %s : %s(#%d)",
                        self.to_s,
                        self.type_sym.to_s,
                        self.loc.line_num + 1,
                        __escape_string_format__(head.to_s),
                        head.type_sym.to_s,
                        head.loc.line_num + 1
                    )
                )
            end

            body_expr = if head.opt_contents_pat
                    contents_decl = head.opt_contents_pat.desugar_value(
                        ASCE.make_send(
                            case_expr.expr.loc,

                            if source_expr.simple?
                                source_expr
                            else
                                ASCE.make_identifier(
                                    source_expr.loc, :'%x'
                                )
                            end,

                            ASCE.make_message(
                                case_expr.expr.loc, :contents
                            )
                        ),

                        env
                    )
                    ASSERT.kind_of contents_decl, ASCD::Abstract

                    ASCE.make_let(
                        rule.loc,

                        ASCD.make_seq_of_declaration(
                            rule.loc,
                            [contents_decl]
                        ),

                        rule.body_expr.desugar(env)
                    )
                else
                    case_expr.desugar_body_expr env, rule
                end

            leafs.merge(head.tag_sym => body_expr) {
                raise X::SyntaxError.new(
                    rule.loc,
                    format("Duplicated rules in case-expression: %s",
                        head.to_s
                    )
                )
            }
        }

        if source_expr.simple?
            ASCE.make_switch(
                case_expr.loc,
                ASCE.make_send(
                    source_expr.loc,
                    source_expr,
                    ASCE.make_message(source_expr.loc, :tag),
                    [],
                    :Datum
                ),
                :Symbol,
                leafs,
                case_expr.desugar_else_expr(env)
            )
        else
            ASCE.make_let(
                case_expr.loc,

                ASCD.make_seq_of_declaration(
                    source_expr.loc,
                    [ASCD.make_value(source_expr.loc, :'%x', source_expr)]
                ),

                ASCE.make_switch(
                    case_expr.loc,
                    ASCE.make_send(
                        source_expr.loc,
                        ASCE.make_identifier(source_expr.loc, :'%x'),
                        ASCE.make_message(source_expr.loc, :tag)
                    ),
                    :Symbol,
                    leafs,
                    case_expr.desugar_else_expr(env)
                )
            )
        end
    end
end

end # Umu::ConcreteSyntax::Core::Expression::Nary::Branch::Rule::Case

end # Umu::ConcreteSyntax::Core::Expression::Nary::Branch::Rule

end # Umu::ConcreteSyntax::Core::Expression::Nary::Branch

end # Umu::ConcreteSyntax::Core::Expression::Nary


module_function

    def make_case_rule_datum(loc, tag_sym, opt_contents_pat)
        ASSERT.kind_of      loc,                LOC::Entry
        ASSERT.kind_of      tag_sym,            ::Symbol
        ASSERT.opt_kind_of  opt_contents_pat,   CSCP::Abstract

        Nary::Branch::Rule::Case::Datum.new(
            loc, tag_sym, opt_contents_pat
        ).freeze
    end

end # Umu::ConcreteSyntax::Core::Expression

end # Umu::ConcreteSyntax::Core

end # Umu::ConcreteSyntax

end # Umu
