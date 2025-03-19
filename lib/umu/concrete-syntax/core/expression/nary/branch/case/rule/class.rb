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

class Class < Abstract
    alias       class_ident obj

    attr_reader :opt_contents_pat
    attr_reader :opt_superclass_ident

    def initialize(
        loc, class_ident, opt_contents_pat, opt_superclass_ident
    )
        ASSERT.kind_of      class_ident,          CSCEU::Identifier::Short
        ASSERT.opt_kind_of  opt_contents_pat,     CSCP::Abstract
        ASSERT.opt_kind_of  opt_superclass_ident, CSCEU::Identifier::Short

        super(loc, class_ident)

        @opt_contents_pat     = opt_contents_pat
        @opt_superclass_ident = opt_superclass_ident
    end


    def type_sym
        :Class
    end


    def to_s
        format("&%s%s",
                if self.opt_superclass_ident
                    format("(%s < %s)",
                             self.class_ident.to_s,
                             self.opt_superclass_ident.to_s
                    )
                else
                    self.class_ident.to_s
                end,

                if self.opt_contents_pat
                    ' ' + self.opt_contents_pat.to_s
                else
                    ''
                end
        )
    end


    def pretty_print(q)
        q.text '&'
        if self.opt_superclass_ident
            q.text format("(%s < %s)",
                         self.class_ident.to_s,
                         self.opt_superclass_ident.to_s
                    )
        else
            q.text self.class_ident.to_s
        end

        if self.opt_contents_pat
            q.text ' '
            q.pp self.opt_contents_pat
        end
    end


    def desugar_for_rule(env, case_expr)
        ASSERT.kind_of case_expr, Branch::Case

        source_expr = case_expr.expr.desugar env
        ASSERT.kind_of source_expr, ASCE::Abstract
        if source_expr.simple?
            rules = __desugar_rules__(env, case_expr) {
                            |_| source_expr
                        }

            ASCE.make_if(
                case_expr.loc, rules, case_expr.desugar_else_expr(env)
            )
        else
            ASCE.make_let(
                case_expr.loc,

                ASCD.make_seq_of_declaration(
                    source_expr.loc,
                    [ASCD.make_value(source_expr.loc, :'%x', source_expr)]
                ),

                ASCE.make_if(
                    case_expr.loc,
                    __desugar_rules__(env, case_expr) {
                        |loc|

                        ASCE.make_identifier loc, :'%x'
                    },
                    case_expr.desugar_else_expr(env)
                )
            )
        end
    end


private

    def __desugar_rules__(env, case_expr, &fn)
        ASSERT.kind_of case_expr, Branch::Case

        source_expr = case_expr.expr.desugar env

        case_expr.rules.map { |rule|
            ASSERT.kind_of rule, Rule::Abstraction::Abstract

            head = rule.head
            ASSERT.kind_of head, Rule::Case::Abstract
            unless head.kind_of? Rule::Case::Class
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

            head_expr = ASCE.make_test_kind_of(
                                head.loc,

                                fn.call(head.loc),

                                head.class_ident.desugar(env),

                                if head.opt_superclass_ident
                                    head.opt_superclass_ident.sym
                                else
                                    nil
                                end
                            )
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

            ASCE.make_rule rule.loc, head_expr, body_expr
        }
    end
end


end # Umu::ConcreteSyntax::Core::Expression::Nary::Branch::Rule::Case

end # Umu::ConcreteSyntax::Core::Expression::Nary::Branch::Rule

end # Umu::ConcreteSyntax::Core::Expression::Nary::Branch

end # Umu::ConcreteSyntax::Core::Expression::Nary


module_function

    def make_case_rule_class(
        loc, class_ident, opt_contents_pat, opt_superclass_ident = nil
    )
        ASSERT.kind_of      loc,                  LOC::Entry
        ASSERT.kind_of      class_ident,          CSCEU::Identifier::Short
        ASSERT.opt_kind_of  opt_contents_pat,     CSCP::Abstract
        ASSERT.opt_kind_of  opt_superclass_ident, CSCEU::Identifier::Short

        Nary::Branch::Rule::Case::Class.new(
            loc, class_ident, opt_contents_pat, opt_superclass_ident
        ).freeze
    end

end # Umu::ConcreteSyntax::Core::Expression

end # Umu::ConcreteSyntax::Core

end # Umu::ConcreteSyntax

end # Umu
