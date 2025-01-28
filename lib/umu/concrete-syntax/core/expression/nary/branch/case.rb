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
        ASSERT.kind_of fst_head, Rule::Case::Head::Abstract
        expr = case fst_head
                when Rule::Case::Head::Atom
                    __desugar_atom__ new_env, fst_head
                when Rule::Case::Head::Datum
                    __desugar_datum__ new_env, fst_head
                when Rule::Case::Head::Class
                    __desugar_class__ new_env, fst_head
                else
                end
        ASSERT.kind_of expr, ASCE::Abstract
    end


    def __desugar_atom__(env, fst_head)
        ASSERT.kind_of fst_head, Rule::Case::Head::Atom

        fst_head_value  = fst_head.atom_value

        leafs = self.rules.inject({}) { |leafs, rule|
            ASSERT.kind_of leafs,   ::Hash
            ASSERT.kind_of rule,    Rule::Case::Entry

            head = rule.head
            ASSERT.kind_of head, Rule::Case::Head::Abstract
            unless head.kind_of? Rule::Case::Head::Atom
                raise X::SyntaxError.new(
                    rule.loc,
                    format("Inconsistent rule types in case-expression, " +
                            "1st is %s : %s, but another is %s : %s",
                        fst_head.to_s,
                        fst_head.type_sym.to_s,
                        head.to_s,
                        head.type_sym.to_s
                    )
                )
            end

            head_value  = head.atom_value
            ASSERT.kind_of head_value, VCA::Abstract
            unless head_value.class == fst_head_value.class
                raise X::SyntaxError.new(
                    rule.loc,
                    format("Inconsistent rule types in case-expression, " +
                            "1st is %s : %s, but another is %s : %s",
                        fst_head_value.to_s,
                        fst_head_value.type_sym.to_s,
                        head_value.to_s,
                        head_value.type_sym.to_s
                    )
                )
            end

            body_expr = __desugar_body_expr__ env, rule

            leafs.merge(head_value.val => body_expr) { |val, _, _|
                raise X::SyntaxError.new(
                    rule.loc,
                    format("Duplicated rules in case-expression: %s",
                        val.to_s
                    )
                )
            }
        }

        ASCE.make_switch(
            self.loc,
            self.expr.desugar(env),
            fst_head_value.type_sym,
            leafs,
            __desugar_else_expr__(env)
        )
    end


    def __desugar_datum__(env, fst_head)
        ASSERT.kind_of fst_head, Rule::Case::Head::Datum

        source_expr = self.expr.desugar env

        leafs = self.rules.inject({}) { |leafs, rule|
            ASSERT.kind_of leafs,   ::Hash
            ASSERT.kind_of rule,    Rule::Case::Entry

            head = rule.head
            ASSERT.kind_of head, Rule::Case::Head::Abstract
            unless head.kind_of? Rule::Case::Head::Datum
                raise X::SyntaxError.new(
                    rule.loc,
                    format("Inconsistent rule types in case-expression, " +
                            "1st is %s : %s, but another is %s : %s",
                        fst_head.to_s,
                        fst_head.type_sym.to_s,
                        head.to_s,
                        head.type_sym.to_s
                    )
                )
            end

            body_expr = if head.opt_contents_pat
                    contents_decl = head.opt_contents_pat.desugar_value(
                        ASCE.make_send(
                            self.expr.loc,

                            if source_expr.simple?
                                source_expr
                            else
                                ASCE.make_identifier(source_expr.loc, :'%x')
                            end,

                            ASCE.make_message(self.expr.loc, :contents)
                        ),
                        env
                    )
                    ASSERT.kind_of contents_decl, ASCD::Abstract

                    ASCE.make_let(
                        rule.loc,

                        ASCD.make_seq_of_declaration(
                            rule.loc,
                            [contents_decl] + rule.decls.desugar(env).to_a
                        ),

                        rule.body_expr.desugar(env)
                    )
                else
                    __desugar_body_expr__ env, rule
                end

            leafs.merge(head.tag_sym => body_expr) { |sym, _, _|
                raise X::SyntaxError.new(
                    rule.loc,
                    format("Duplicated rules in case-expression: %s",
                        sym.to_s
                    )
                )
            }
        }

        if source_expr.simple?
            ASCE.make_switch(
                self.loc,
                ASCE.make_send(
                    source_expr.loc,
                    source_expr,
                    ASCE.make_message(source_expr.loc, :tag),
                    [],
                    :Datum
                ),
                :Symbol,
                leafs,
                __desugar_else_expr__(env)
            )
        else
            ASCE.make_let(
                self.loc,

                ASCD.make_seq_of_declaration(
                    source_expr.loc,
                    [ASCD.make_value(source_expr.loc, :'%x', source_expr)]
                ),

                ASCE.make_switch(
                    self.loc,
                    ASCE.make_send(
                        source_expr.loc,
                        ASCE.make_identifier(source_expr.loc, :'%x'),
                        ASCE.make_message(source_expr.loc, :tag)
                    ),
                    :Symbol,
                    leafs,
                    __desugar_else_expr__(env)
                )
            )
        end
    end


    def __desugar_class__(env, fst_head)
        ASSERT.kind_of fst_head, Rule::Case::Head::Class

        source_expr = self.expr.desugar env
        ASSERT.kind_of source_expr, ASCE::Abstract
        if source_expr.simple?
            rules = __desugar_rules__(env, source_expr) { |_| source_expr }

            ASCE.make_if self.loc, rules, __desugar_else_expr__(env)
        else
            ASCE.make_let(
                self.loc,

                ASCD.make_seq_of_declaration(
                    source_expr.loc,
                    [ASCD.make_value(source_expr.loc, :'%x', source_expr)]
                ),

                ASCE.make_if(
                    self.loc,
                    __desugar_rules__(env, source_expr) { |loc|
                        ASCE.make_identifier loc, :'%x'
                    },
                    __desugar_else_expr__(env)
                )
            )
        end
    end


    def __desugar_rules__(env, source_expr, &fn)
        ASSERT.kind_of source_expr, ASCE::Abstract

        self.rules.map { |rule|
            ASSERT.kind_of rule, Rule::Case::Entry

            head = rule.head
            ASSERT.kind_of head, Rule::Case::Head::Abstract
            unless head.kind_of? Rule::Case::Head::Class
                raise X::SyntaxError.new(
                    rule.loc,
                    format("Inconsistent rule types in case-expression, " +
                            "1st is %s : %s, but another is %s : %s",
                        fst_head.to_s,
                        fst_head.type_sym.to_s,
                        head.to_s,
                        head.type_sym.to_s
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
                            self.expr.loc,

                            if source_expr.simple?
                                source_expr
                            else
                                ASCE.make_identifier(source_expr.loc, :'%x')
                            end,

                            ASCE.make_message(self.expr.loc, :contents)
                        ),
                        env
                    )
                    ASSERT.kind_of contents_decl, ASCD::Abstract

                    ASCE.make_let(
                        rule.loc,

                        ASCD.make_seq_of_declaration(
                            rule.loc,
                            [contents_decl] + rule.decls.desugar(env).to_a
                        ),

                        rule.body_expr.desugar(env)
                    )
                else
                    __desugar_body_expr__ env, rule
                end

            ASCE.make_rule rule.loc, head_expr, body_expr
        }
    end
end

end # Umu::ConcreteSyntax::Core::Expression::Nary::Branch

end # Umu::ConcreteSyntax::Core::Expression::Nary


module_function

    def make_case(loc, expr, fst_rule, snd_rules, opt_else_expr, else_decls)
        ASSERT.kind_of      loc,            LOC::Entry
        ASSERT.kind_of      expr,           CSCE::Abstract
        ASSERT.kind_of      fst_rule,       CSCEN::Rule::Case::Entry
        ASSERT.kind_of      snd_rules,      ::Array
        ASSERT.opt_kind_of  opt_else_expr,  CSCE::Abstract
        ASSERT.kind_of      else_decls,     CSCD::SeqOfDeclaration

        Nary::Branch::Case.new(
            loc, expr, fst_rule, snd_rules, opt_else_expr, else_decls
        ).freeze
    end

end # Umu::ConcreteSyntax::Core::Expression

end # Umu::ConcreteSyntax::Core

end # Umu::ConcreteSyntax

end # Umu
