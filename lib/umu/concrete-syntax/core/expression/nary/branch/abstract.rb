# coding: utf-8
# frozen_string_literal: true



module Umu

module ConcreteSyntax

module Core

module Expression

module Nary

module Branch

class Abstract < Expression::Abstract
    attr_reader :expr, :fst_rule, :snd_rules, :opt_else_expr, :else_decls


    def initialize(
        loc, expr, fst_rule, snd_rules, opt_else_expr, else_decls
    )
        ASSERT.kind_of      expr,           CSCE::Abstract
        ASSERT.kind_of      fst_rule,
                            CSCEN::Rule::Abstraction::WithDeclaration
        ASSERT.kind_of      snd_rules,      ::Array
        ASSERT.opt_kind_of  opt_else_expr,  CSCE::Abstract
        ASSERT.kind_of      else_decls,     ::Array

        super(loc)

        @expr       = expr
        @fst_rule   = fst_rule
        @snd_rules  = snd_rules
        @opt_else_expr  = opt_else_expr
        @else_decls = else_decls
    end


    def to_s
        format("%%%s %s { %s %s}",
            __keyword__.upcase,

            self.expr.to_s,

            self.rules.map(&:to_s).join(' | '),
            (
                if self.opt_else_expr
                    format("%%ELSE -> %s%s",
                        self.opt_else_expr.to_s,
                        (
                            if self.else_decls.empty?
                                ' '
                            else
                                format(" %%WHERE %s ",
                                    self.else_decls.map(&:to_s).join(' ')
                                )
                            end
                        )
                    )
                else
                    ''
                end
            )
        )
    end


    def pretty_print(q)
        q.text format("%%%s ", __keyword__.upcase)
        q.pp self.expr
        q.text ' {'

        q.breakable

        fst_rule, *not_fst_rules = self.rules

        q.pp fst_rule
        unless not_fst_rules.empty?
            not_fst_rules.each do |rule|
                q.breakable

                q.text '| '
                q.group(PP_INDENT_WIDTH, '', '') do
                    q.pp rule
                end
            end
        end

        if self.opt_else_expr
            else_expr = self.opt_else_expr

            q.breakable

            q.text '%ELSE -> '
            q.group(PP_INDENT_WIDTH, '', '') do
                q.breakable ''

                q.pp else_expr

                unless self.else_decls.empty?
                    q.text ' %WHERE '

                    fst_decl, *not_fst_decls = self.else_decls

                    q.pp fst_decl

                    q.breakable

                    not_fst_decls.each do |decl|
                        q.pp decl

                        q.breakable
                    end
                end
            end
        end

        q.breakable

        q.text '}'
    end


    def rules
        [self.fst_rule] + self.snd_rules
    end


private

    def __keyword__
        raise X::InternalSubclassResponsibility
    end


    def __desugar_body_expr__(env, rule)
        ASSERT.kind_of rule, Nary::Rule::Abstraction::WithDeclaration

        body_expr_  = rule.body_expr.desugar(env)
        body_expr   = unless rule.decls.empty?
            ASCE.make_let(
                rule.loc,

                ASCD.make_seq_of_declaration(
                    rule.loc,
                    rule.decls.map { |decl| decl.desugar env }
                ),

                body_expr_
            )
        else
            body_expr_
        end

        ASSERT.kind_of body_expr, ASCE::Abstract
    end


    def __desugar_else_expr__(env)
        else_expr = if self.opt_else_expr
            else_expr_ = self.opt_else_expr.desugar(env)

            unless self.else_decls.empty?
                ASCE.make_let(
                    else_expr_.loc,

                    ASCD.make_seq_of_declaration(
                        else_expr_.loc,
                        self.else_decls.map { |decl|
                            decl.desugar env
                        }
                    ),

                    else_expr_
                )
            else
                else_expr_
            end
        else
            ASCE.make_raise(
                self.loc,
                X::UnmatchError,
                format("No rules matched in %s-expression",
                        __keyword__
                )
            )
        end

        ASSERT.kind_of else_expr, ASCE::Abstract
    end
end

end # Umu::ConcreteSyntax::Core::Expression::Nary::Branch

end # Umu::ConcreteSyntax::Core::Expression::Nary

end # Umu::ConcreteSyntax::Core::Expression

end # Umu::ConcreteSyntax::Core

end # Umu::ConcreteSyntax

end # Umu
