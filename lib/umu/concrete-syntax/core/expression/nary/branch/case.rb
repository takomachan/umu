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
                    __desugar_atom__  new_env, fst_head
                when Rule::Case::Head::Datum
                    __desugar_datum__ new_env, fst_head
                when Rule::Case::Head::Class
                    __desugar_class__ new_env, fst_head
                when Rule::Case::Head::Poly::Abstract
                    __desugar_poly__  new_env, fst_head
                else
                    ASSERT.abort "Np case: %s", fst_head.inspect
                end
        ASSERT.kind_of expr, ASCE::Abstract
    end


    def __desugar_atom__(env, fst_head)
        ASSERT.kind_of fst_head, Rule::Case::Head::Atom

        fst_head_value  = fst_head.atom_value

        leafs = self.rules.inject({}) { |leafs, rule|
            ASSERT.kind_of leafs,   ::Hash
            ASSERT.kind_of rule,    Rule::Abstraction::Abstract

            head = rule.head
            ASSERT.kind_of head, Rule::Case::Head::Abstract
            unless head.kind_of? Rule::Case::Head::Atom
                raise X::SyntaxError.new(
                    rule.loc,
                    format("Inconsistent rule types in case-expression, " +
                            "1st is %s(#%d), but another is %s(#%d)",
                        fst_head.type_sym.to_s,
                        fst_head.line_num,
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

            body_expr = __desugar_body_expr__ env, rule

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
            ASSERT.kind_of rule,    Rule::Abstraction::Abstract

            head = rule.head
            ASSERT.kind_of head, Rule::Case::Head::Abstract
            unless head.kind_of? Rule::Case::Head::Datum
                raise X::SyntaxError.new(
                    rule.loc,
                    format("Inconsistent rule types in case-expression, " +
                            "1st is %s(#%d), but another is %s(#%d)",
                        fst_head.type_sym.to_s,
                        fst_head.line_num,
                        head.type_sym.to_s,
                        head.line_num
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
            rules = __desugar_class_rules__(env, fst_head, source_expr) {
                            |_| source_expr
                        }

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
                    __desugar_class_rules__(env, fst_head, source_expr) {
                        |loc|

                        ASCE.make_identifier loc, :'%x'
                    },
                    __desugar_else_expr__(env)
                )
            )
        end
    end


    def __desugar_class_rules__(env, fst_head, source_expr, &fn)
        ASSERT.kind_of source_expr, ASCE::Abstract

        self.rules.map { |rule|
            ASSERT.kind_of rule, Rule::Abstraction::Abstract

            head = rule.head
            ASSERT.kind_of head, Rule::Case::Head::Abstract
            unless head.kind_of? Rule::Case::Head::Class
                raise X::SyntaxError.new(
                    rule.loc,
                    format("Inconsistent rule types in case-expression, " +
                            "1st is %s(#%d), but another is %s(#%d)",
                        fst_head.type_sym.to_s,
                        fst_head.line_num,
                        head.type_sym.to_s,
                        head.line_num,
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


    def __desugar_poly__(env, fst_head)
        ASSERT.kind_of fst_head, Rule::Case::Head::Poly::Abstract

        opt_nil_rule, opt_cons_rule = self.rules.inject(
             [nil,          nil]
        ) { |(opt_nil_rule, opt_cons_rule), rule|
            ASSERT.opt_kind_of opt_nil_rule,    Rule::Abstraction::Abstract
            ASSERT.opt_kind_of opt_cons_rule,   Rule::Abstraction::Abstract
            ASSERT.kind_of     rule,            Rule::Abstraction::Abstract

            head = rule.head
            ASSERT.kind_of head, Rule::Case::Head::Abstract
            unless head.kind_of? Rule::Case::Head::Poly::Abstract
                raise X::SyntaxError.new(
                    rule.loc,
                    format("case: Inconsistent rule types, " +
                            "1st is %s(#%d), but another is %s(#%d)",
                        fst_head.type_sym.to_s,
                        fst_head.line_num,
                        head.type_sym.to_s,
                        head.line_num
                    )
                )
            end

            case head
            when Rule::Case::Head::Poly::Nil
                if opt_nil_rule
                    raise X::SyntaxError.new(
                        rule.loc,
                        format("case: Duplicated polymorphic " +
                                    "empty morph pattern: %s ",
                            head.type_sym.to_s
                        )
                    )
                end

                [rule,         opt_cons_rule]
            when Rule::Case::Head::Poly::Cons
                if opt_cons_rule
                    raise X::SyntaxError.new(
                        rule.loc,
                        format("case: Duplicated polymorphic " +
                                    "not empty morph pattern: %s ",
                            head.type_sym.to_s
                        )
                    )
                end

                [opt_nil_rule, rule]
            else
                ASSERT.abort "No case: %s", head.inspect
            end
        }

        ASSERT.opt_kind_of opt_nil_rule,    Rule::Abstraction::Abstract
        ASSERT.opt_kind_of opt_cons_rule,   Rule::Abstraction::Abstract

        opt_otherwise_rule = (
            if self.opt_else_expr
                CSCE.make_case_rule_otherwise self.loc, opt_else_expr
            else
                nil
            end
        )

        unmatch_rule = CSCE.make_case_rule_unmatch self.loc

        # N: Nil,       !N: not Nil
        # C: Cons,      !C: not Cons
        # O: Otherwise, !O: not Otherwise
        # *: Don't care
        then_rule, else_rule, has_cons = (
            if opt_nil_rule
                nil_rule = opt_nil_rule

                if opt_cons_rule
                    cons_rule = opt_cons_rule

                    if opt_otherwise_rule   # 1. (N,  C,  O)
                        raise X::SyntaxError.new(
                            rule.loc,
                            "case: Never reached 'else' expression"
                        )
                    else                    # 2. (N,  C,  !O)
                        [nil_rule,       cons_rule,      true]
                    end
                else
                    if opt_otherwise_rule   # 3. (N,  !C, O)
                        otherwise_rule = opt_otherwise_rule

                        [nil_rule,       otherwise_rule, false]
                    else                    # 4. (N,  !C, !O)
                        [nil_rule,       unmatch_rule,   false]
                    end
                end
            else
                if opt_cons_rule
                    cons_rule = opt_cons_rule

                    if opt_otherwise_rule   # 5. (!N, C,  O)
                        otherwise_rule = opt_otherwise_rule

                        [otherwise_rule, cons_rule,      true]
                    else                    # 6. (!N, C,  !O)
                        [unmatch_rule,   cons_rule,      true]
                    end
                else                        # 7. (!N, !C, *)
                    ASSERT.abort "No case -- empty rule set"
                end
            end
        )
        ASSERT.kind_of then_rule, Nary::Rule::Abstraction::Abstract
        ASSERT.kind_of else_rule, Nary::Rule::Abstraction::Abstract
        ASSERT.bool    has_cons

        then_expr = then_rule.desugar_poly_rule env
        else_expr = else_rule.desugar_poly_rule env
        body_expr = self.expr.desugar env

        if has_cons
            # Concrete Syntax
            #
            #     %CASE <xs> %OF {
            #     | %[]                    -> <then-expr>
            #     | %[ <x> | <xs'> : <T> ] -> <else-expr>
            #     }
            #
            # Abstract Syntax
            #
            #     %LET {
            #         %VAL %o : Option = <xs>.dest
            #     %IN
            #         %IF %o kind-of? None %THEN
            #             <then-expr>
            #         %ELSE %LET {
            #             %VAL %t    : Tuple = %o.contents
            #             %VAL <x>           = %t$1
            #             %VAL <xs'> : <T>   = %t$2
            #         %IN
            #             <else-expr>
            #         }
            #     }
            cons_head = else_rule.head
            ASSERT.kind_of cons_head, Nary::Rule::Case::Head::Poly::Cons

            test_expr = ASCE.make_test_kind_of(
                body_expr.loc,

                ASCE.make_identifier(body_expr.loc, :'%o'),

                ASCE.make_identifier(body_expr.loc, :None),

                :Option
            )

            let_expr = ASCE.make_let(
                cons_head.loc,

                ASCD.make_seq_of_declaration(
                    cons_head.loc,
                    [
                        ASCD.make_value(
                            cons_head.loc,

                            :'%p',

                            ASCE.make_send(
                                cons_head.loc,
                                ASCE.make_identifier(cons_head.loc, :'%o'),
                                ASCE.make_message(cons_head.loc, :contents)
                            ),

                            :Product
                        ),

                        __make_value_poly__(
                            loc,
                            cons_head.head_pat.var_sym,
                            1
                        ),

                        __make_value_poly__(
                            loc,
                            cons_head.tail_pat.var_sym,
                            2
                        )
                    ]
                ),

                else_expr
            )

            ASCE.make_let(
                self.loc,

                ASCD.make_seq_of_declaration(
                    self.loc,
                    [
                        ASCD.make_value(
                            body_expr.loc,

                            :'%o',

                            ASCE.make_send(
                                body_expr.loc,
                                body_expr,
                                ASCE.make_message(body_expr.loc, :dest)
                            )
                        )
                    ]
                ),

                ASCE.make_if(
                    self.loc,
                    [
                        ASCE.make_rule(self.loc, test_expr, then_expr)
                    ],
                    let_expr
                )
            )
        else
            # Concrete Syntax
            #
            #     %CASE <xs> %OF {
            #       %[]   -> <then-expr>
            #       %ELSE -> <else-expr>
            #     }
            #
            # Abstract Syntax
            #
            #     %IF <xs>.dest kind-of? None
            #         %THEN <then-expr>
            #         %ELSE <else-expr>

            test_expr = ASCE.make_test_kind_of(
                body_expr.loc,

                ASCE.make_send(
                    body_expr.loc,
                    body_expr,
                    ASCE.make_message(body_expr.loc, :dest)
                ),

                ASCE.make_identifier(body_expr.loc, :None),

                :Option
            )

            ASCE.make_if(
                self.loc,
                [
                    ASCE.make_rule(
                        self.loc,
                        test_expr,
                        then_expr,
                    )
                ],
                else_expr
            )
        end
    end


    def __make_value_poly__(loc, var_sym, num)
        ASSERT.kind_of loc,         LOC::Entry
        ASSERT.kind_of var_sym,     ::Symbol
        ASSERT.kind_of num,         ::Integer

        ASCD.make_value(
            loc,

            var_sym,

            ASCE.make_product(
                loc,
                ASCE.make_identifier(loc, :'%p'),
                ASCE.make_number_selector(loc, num)
            )
        )
    end
end

end # Umu::ConcreteSyntax::Core::Expression::Nary::Branch

end # Umu::ConcreteSyntax::Core::Expression::Nary


module_function

    def make_case(loc, expr, fst_rule, snd_rules, opt_else_expr, else_decls)
        ASSERT.kind_of      loc,            LOC::Entry
        ASSERT.kind_of      expr,           CSCE::Abstract
        ASSERT.kind_of      fst_rule,
                                CSCEN::Rule::Abstraction::Abstract
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
