# coding: utf-8
# frozen_string_literal: true



module Umu

module ConcreteSyntax

module Core

module Pattern

module Container

module Morph

class Polymorph < Abstract

private

    def __bb__
        '%['
    end


    def __eb__
        ']'
    end


    def __desugar_value_nil__(loc, expr)
        ASSERT.kind_of expr, ASCE::Abstract

        bool_expr = ASCE.make_send(
                loc,

                if expr.simple?
                    expr
                else
                    ASCE.make_identifier(loc, :'%x')
                end,

                ASCE.make_message(loc, :'empty?')
            )

        decl = ASCD.make_value(
                loc,

                WILDCARD,

                ASCE.make_if(
                    loc,

                    [
                        ASCE.make_rule(
                            loc,
                            bool_expr,
                            ASCE.make_unit(loc)
                        )
                    ],

                    ASCE.make_raise(
                        loc,
                        X::EmptyError,
                        ASCE.make_string(
                            loc,
                            "Empty morph cannot be destructible"
                        )
                    )
                )
            )

        let_expr = ASCE.make_let(
                loc,

                ASCD.make_seq_of_declaration(
                    loc,

                    (
                        if expr.simple?
                            []
                        else
                            [ASCD.make_value(loc, :'%x', expr)]
                        end
                    ) + [
                        decl
                    ]
                ),

                if expr.simple?
                    expr
                else
                    ASCE.make_identifier(loc, :'%x')
                end
            )

        ASCD.make_value(
            loc, WILDCARD, let_expr, __opt_type_sym_of_nil__
        )
    end


    def __desugar_lambda_nil__(loc)
        nil
    end


    def __opt_type_sym_of_morph__
        nil
    end


    def __opt_type_sym_of_nil__
        nil
    end


    def __opt_type_sym_of_cons__
        nil
    end
end

end # Umu::ConcreteSyntax::Core::Pattern::Container::Morph

end # Umu::ConcreteSyntax::Core::Pattern::Container


module_function

    def make_poly(loc, pats = [], opt_last_pat = nil)
        ASSERT.kind_of      loc,            LOC::Entry
        ASSERT.kind_of      pats,           ::Array
        ASSERT.opt_kind_of  opt_last_pat,   ElementOfContainer::Variable

        Container::Morph::Polymorph.new(
            loc, pats.freeze, opt_last_pat
        ).freeze
    end

end # Umu::ConcreteSyntax::Core::Pattern

end # Umu::ConcreteSyntax::Core

end # Umu::ConcreteSyntax

end # Umu
