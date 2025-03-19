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

module Polymorph

class Abstract < Case::Abstract
    alias opt_body_type_sym obj

    def initialize(loc, opt_body_type_sym)
        ASSERT.opt_kind_of opt_body_type_sym, ::Symbol

        super
    end


    def desugar_for_rule(env, case_expr)
        ASSERT.kind_of case_expr, Branch::Case

        opt_nil_rule,
        opt_cons_rule,
        opt_body_type_sym,
        opt_head_type_sym = __fold_rules__ case_expr.rules



        then_rule,
        else_rule,
        has_cons = __classify_pattern__(
                self.loc,
                opt_nil_rule,       opt_cons_rule,
                opt_body_type_sym,  opt_head_type_sym ,

                if case_expr.opt_else_expr
                    Rule::Case.make_poly_otherwise(
                        case_expr.opt_else_expr.loc,
                        case_expr.opt_else_expr
                    )
                else
                    nil
                end,

                Rule::Case.make_poly_unmatch(case_expr.loc)
            )

        result = __make_expression__(
                env, case_expr, then_rule, else_rule,
                has_cons,       opt_body_type_sym,
                opt_cons_rule,  opt_head_type_sym
            )

        ASSERT.kind_of result, ASCE::Abstract
    end


private

    def __fold_rules__(rules)
        ASSERT.kind_of rules, ::Array

        rules.inject(
             [nil, nil, nil, nil]
        ) { |(
                 opt_nil_rule,
                 opt_cons_rule,
                 opt_body_type_sym,
                 opt_head_type_sym
              ),
                 rule
            |
            ASSERT.opt_kind_of opt_nil_rule,    Rule::Abstraction::Abstract
            ASSERT.opt_kind_of opt_cons_rule,   Rule::Abstraction::Abstract
            ASSERT.opt_kind_of opt_body_type_sym,   ::Symbol
            ASSERT.opt_kind_of opt_head_type_sym,   ::Symbol
            ASSERT.kind_of     rule,            Rule::Abstraction::Abstract

            head = rule.head
            ASSERT.kind_of head, Rule::Case::Abstract
            unless head.kind_of? Rule::Case::Polymorph::Abstract
                raise X::SyntaxError.new(
                    rule.loc,
                    format("Inconsistent rule categories " +
                                "in case-expression, " +
                            "1st is %s : %s(#%d), " +
                            "but another is %s : %s(#%d)",
                        __escape_string_format__(self.to_s),
                        self.type_sym.to_s,
                        self.loc.line_num + 1,
                        __escape_string_format__(head.to_s),
                        head.type_sym.to_s,
                        head.loc.line_num + 1
                    )
                )
            end

            case head
            when Rule::Case::Polymorph::Nil
                if opt_nil_rule
                    raise X::SyntaxError.new(
                        rule.loc,
                        format("Duplicated empty morph patterns " +
                                "in case-expression: %s : %s",
                            __escape_string_format__(head.to_s),
                            head.type_sym.to_s
                        )
                    )
                end

                [
                    rule,
                    opt_cons_rule,
                    head.opt_body_type_sym,
                    opt_head_type_sym
                ]
            when Rule::Case::Polymorph::Cons
                if opt_cons_rule
                    raise X::SyntaxError.new(
                        rule.loc,
                        format("Duplicated not empty morph patterns " +
                                "in case-expression: %s : %s",
                            __escape_string_format__(head.to_s),
                            head.type_sym.to_s
                        )
                    )
                end

                [
                    opt_nil_rule,
                    rule,
                    head.opt_body_type_sym,
                    head.head_pat.opt_type_sym
                ]
            else
                ASSERT.abort "No case: %s", head.inspect
            end
        }
    end


    def __classify_pattern__(
        loc,
        opt_nil_rule,       opt_cons_rule,
        opt_head_type_sym , opt_body_type_sym,
        opt_otherwise_rule,
        unmatch_rule
    )
        ASSERT.opt_kind_of opt_nil_rule,        Rule::Abstraction::Abstract
        ASSERT.opt_kind_of opt_cons_rule,       Rule::Abstraction::Abstract
        ASSERT.opt_kind_of opt_head_type_sym,   ::Symbol
        ASSERT.opt_kind_of opt_body_type_sym,   ::Symbol
        ASSERT.opt_kind_of opt_otherwise_rule,  Rule::Abstraction::Abstract
        ASSERT.kind_of     unmatch_rule,        Rule::Abstraction::Abstract

        # N: Nil,       !N: not Nil
        # C: Cons,      !C: not Cons
        # O: Otherwise, !O: not Otherwise
        # *: Don't care
        result = (
            if opt_nil_rule
                nil_rule = opt_nil_rule

                if opt_cons_rule
                    cons_rule = opt_cons_rule

                    if opt_otherwise_rule   # 1. (N,  C,  O)
                        raise X::SyntaxError.new(
                            opt_otherwise_rule.loc,
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

        ASSERT.tuple_of result, [
            Branch::Rule::Abstraction::Abstract,
            Branch::Rule::Abstraction::Abstract,
            ::Object
        ]
        ASSERT.bool result[2]

        result
    end


    def __make_expression__(
            env, case_expr, then_rule, else_rule,
            has_cons,       opt_body_type_sym,
            opt_cons_rule,  opt_head_type_sym
        )
        ASSERT.kind_of     case_expr,   Branch::Case
        ASSERT.kind_of     then_rule,   Branch::Rule::Abstraction::Abstract
        ASSERT.kind_of     else_rule,   Branch::Rule::Abstraction::Abstract
        ASSERT.bool        has_cons
        ASSERT.opt_kind_of opt_body_type_sym,   ::Symbol
        ASSERT.opt_kind_of opt_cons_rule,
                                Branch::Rule::Abstraction::Abstract
        ASSERT.opt_kind_of opt_head_type_sym,   ::Symbol

        then_expr = then_rule.desugar_poly_rule env
        else_expr = else_rule.desugar_poly_rule env
        body_expr = case_expr.expr.desugar env

        if has_cons
            cons_head = opt_cons_rule.head

            __make_expression_has_cons__(
                case_expr, then_expr, else_expr, body_expr,
                cons_head.head_pat.var_sym, opt_head_type_sym,
                cons_head.tail_pat.var_sym, opt_body_type_sym
            )
        else
            __make_expression_has_not_cons__(
                case_expr, then_expr, else_expr, body_expr,
                opt_body_type_sym
            )
        end
    end


    def __make_expression_has_cons__(
            case_expr, then_expr, else_expr, body_expr,
            head_var_sym, opt_head_type_sym,
            tail_var_sym, opt_body_type_sym
        )
        ASSERT.kind_of     case_expr,           Branch::Case
        ASSERT.kind_of     then_expr,           ASCE::Abstract
        ASSERT.kind_of     else_expr,           ASCE::Abstract
        ASSERT.kind_of     body_expr,           ASCE::Abstract
        ASSERT.kind_of     head_var_sym,        ::Symbol
        ASSERT.opt_kind_of opt_head_type_sym,   ::Symbol
        ASSERT.kind_of     tail_var_sym,        ::Symbol
        ASSERT.opt_kind_of opt_body_type_sym,   ::Symbol

        # <S> : Source type
        # <H> : Head type
        # <B> : Body type
        #
        # Concrete Syntax
        #
        #     %CASE <xs> %OF {
        #       | %[]                    -> <then-expr>
        #       | %[ <x> | <xs'> : <B> ] -> <else-expr>
        #     }
        #
        # Abstract Syntax
        #
        #     %LET {
        #         %VAL %o : Option = <xs : <S>>.dest
        #     %IN
        #         %IF %o kind-of? None %THEN
        #             <then-expr>
        #         %ELSE %LET {
        #             %VAL %t    : Tuple = %o.contents
        #             %VAL <x>   : <H>   = %t$1
        #             %VAL <xs'> : <xs'> = %t$2
        #         %IN
        #             <else-expr>
        #         }
        #     }
        #
        #    where type <xs'> = case <B> of { NONE -> <S> | Some _ -> <B> }
        #

        test_expr = ASCE.make_test_kind_of(
            body_expr.loc,

            ASCE.make_identifier(body_expr.loc, :'%o'),

            ASCE.make_identifier(body_expr.loc, :None),

            :Option
        )

        let_expr = ASCE.make_let(
            case_expr.loc,

            ASCD.make_seq_of_declaration(
                case_expr.loc,
                [
                    ASCD.make_value(
                        case_expr.loc,

                        :'%p',

                        ASCE.make_send(
                            case_expr.loc,
                            ASCE.make_identifier(case_expr.loc, :'%o'),
                            ASCE.make_message(case_expr.loc, :contents)
                        ),

                        :Product
                    ),

                    __make_value_morph__(
                        loc,
                        head_var_sym,
                        1,
                        opt_head_type_sym
                    ),

                    __make_value_morph__(
                        loc,
                        tail_var_sym,
                        2,
                        opt_body_type_sym
                    )
                ]
            ),

            else_expr
        )

        ASCE.make_let(
            case_expr.loc,

            ASCD.make_seq_of_declaration(
                case_expr.loc,
                [
                    ASCD.make_value(
                        body_expr.loc,

                        :'%o',

                        ASCE.make_send(
                            body_expr.loc,
                            body_expr,
                            ASCE.make_message(body_expr.loc, :dest),
                            [],
                            opt_body_type_sym
                        )
                    )
                ]
            ),

            ASCE.make_if(
                case_expr.loc,
                [
                    ASCE.make_rule(case_expr.loc, test_expr, then_expr)
                ],
                let_expr
            )
        )
    end


    def __make_expression_has_not_cons__(
            case_expr, then_expr, else_expr, body_expr,
            opt_body_type_sym
        )
        ASSERT.kind_of     case_expr,           Branch::Case
        ASSERT.kind_of     then_expr,           ASCE::Abstract
        ASSERT.kind_of     else_expr,           ASCE::Abstract
        ASSERT.kind_of     body_expr,           ASCE::Abstract
        ASSERT.opt_kind_of opt_body_type_sym,   ::Symbol

        # <S> : Source type
        # <B> : Body type
        #
        # Concrete Syntax
        #
        #     %CASE <xs> %OF {
        #       | %[] : <B> -> <then-expr>
        #       | %ELSE -> <else-expr>
        #     }
        #
        # Abstract Syntax
        #
        #     %IF <xs : <S>>.dest kind-of? None
        #         %THEN <then-expr>
        #         %ELSE <else-expr>

        test_expr = ASCE.make_test_kind_of(
            body_expr.loc,

            ASCE.make_send(
                body_expr.loc,
                body_expr,
                ASCE.make_message(body_expr.loc, :dest),
                [],
                opt_body_type_sym
            ),

            ASCE.make_identifier(body_expr.loc, :None),

            :Option
        )

        ASCE.make_if(
            case_expr.loc,
            [
                ASCE.make_rule(
                    case_expr.loc,
                    test_expr,
                    then_expr,
                )
            ],
            else_expr
        )
    end


private

    def __make_value_morph__(loc, var_sym, num, opt_body_type_sym = nil)
        ASSERT.kind_of     loc,                 LOC::Entry
        ASSERT.kind_of     var_sym,             ::Symbol
        ASSERT.kind_of     num,                 ::Integer
        ASSERT.opt_kind_of opt_body_type_sym,   ::Symbol

        ASCD.make_value(
            loc,

            var_sym,

            ASCE.make_product(
                loc,
                ASCE.make_identifier(loc, :'%p'),
                ASCE.make_number_selector(loc, num)
            ),

            opt_body_type_sym
        )
    end
end



class Nil < Abstract
    def type_sym
        :PolyNil
    end


    def to_s
        format("%%[]%s",
            if self.opt_body_type_sym
                format " : %s", self.opt_body_type_sym
            else
                ''
            end
        )
    end


    def pretty_print(q)
        q.text self.to_s
    end
end



class Cons < Abstract
    attr_reader :head_pat, :tail_pat

    def initialize(loc, head_pat, tail_pat, opt_body_type_sym)
        ASSERT.kind_of     head_pat,            CSCP::Abstract
        ASSERT.kind_of     tail_pat,            CSCP::Abstract
        ASSERT.opt_kind_of opt_body_type_sym,   ::Symbol

        super(loc, opt_body_type_sym)
        @head_pat = head_pat
        @tail_pat = tail_pat
    end


    def type_sym
        :PolyCons
    end


    def to_s
        format("%%[%s%s]",
                self.head_pat.to_s,

                format(" | %s", self.tail_pat.to_s)
        )
    end


    def pretty_print(q)
        PRT.group q, bb:'%[', eb:']' do
            q.pp self.head_pat

            if self.tail_pat
                q.breakable

                q.text '|'

                q.breakable

                q.pp self.tail_pat
            end
        end
    end
end



class Otherwise < Abstraction::Abstract
    attr_reader :expr

    def initialize(loc, expr)
        ASSERT.kind_of expr, CSCE::Abstract

        super(loc)

        @expr = expr
    end


    def desugar_poly_rule(env)
        self.expr.desugar env
    end
end



class Unmatch < Abstraction::Abstract
    def desugar_poly_rule(_env)
        ASCE.make_raise(
            self.loc,
            X::UnmatchError,
            ASCE.make_string(self.loc, "No rules matched")
        )
    end
end

end # Umu::ConcreteSyntax::Core::Expression::Nary::Branch::Rule::Case::Polymorph


module_function

    def make_poly_otherwise(loc, expr)
        ASSERT.kind_of loc,     LOC::Entry
        ASSERT.kind_of expr,    CSCE::Abstract

        Nary::Branch::Rule::Case::Polymorph::Otherwise.new(
            loc, expr
        ).freeze
    end


    def make_poly_unmatch(loc)
        ASSERT.kind_of loc, LOC::Entry

        Nary::Branch::Rule::Case::Polymorph::Unmatch.new(
            loc
        ).freeze
    end

end # Umu::ConcreteSyntax::Core::Expression::Nary::Branch::Rule::Case

end # Umu::ConcreteSyntax::Core::Expression::Nary::Branch::Rule

end # Umu::ConcreteSyntax::Core::Expression::Nary::Branch

end # Umu::ConcreteSyntax::Core::Expression::Nary


module_function

    def make_case_rule_poly_nil(loc, opt_body_type_sym = nil)
        ASSERT.kind_of     loc,                 LOC::Entry
        ASSERT.opt_kind_of opt_body_type_sym,   ::Symbol

        Nary::Branch::Rule::Case::Polymorph::Nil.new(
            loc, opt_body_type_sym, 
        ).freeze
    end


    def make_case_rule_poly_cons(
        loc, head_pat, tail_pat, opt_body_type_sym = nil
    )
        ASSERT.kind_of loc,                     LOC::Entry
        ASSERT.kind_of head_pat,                CSCP::Abstract
        ASSERT.kind_of tail_pat,                CSCP::Abstract
        ASSERT.opt_kind_of opt_body_type_sym,   ::Symbol

        Nary::Branch::Rule::Case::Polymorph::Cons.new(
            loc, head_pat, tail_pat, opt_body_type_sym
        ).freeze
    end

end # Umu::ConcreteSyntax::Core::Expression

end # Umu::ConcreteSyntax::Core

end # Umu::ConcreteSyntax

end # Umu
