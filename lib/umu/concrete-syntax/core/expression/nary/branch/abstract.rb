# coding: utf-8
# frozen_string_literal: true



module Umu

module ConcreteSyntax

module Core

module Expression

module Nary

module Branch

class Abstract < Expression::Abstract
    attr_reader :expr, :fst_rule, :snd_rules, :opt_else_expr


    def initialize(loc, expr, fst_rule, snd_rules, opt_else_expr)
        ASSERT.kind_of      expr,           CSCE::Abstract
        ASSERT.kind_of      fst_rule,
                                CSCEN::Rule::Abstraction::Abstract
        ASSERT.kind_of      snd_rules,      ::Array
        ASSERT.opt_kind_of  opt_else_expr,  CSCE::Abstract

        super(loc)

        @expr       = expr
        @fst_rule   = fst_rule
        @snd_rules  = snd_rules
        @opt_else_expr  = opt_else_expr
    end


    def to_s
        format("%%%s %s %%OF { %s %s}",
            __keyword__.upcase,

            self.expr.to_s,

            self.rules.map(&:to_s).join(' | '),
            (
                if self.opt_else_expr
                    format("%%ELSE -> %s", self.opt_else_expr.to_s)
                else
                    ''
                end
            )
        )
    end


    def pretty_print(q)
        q.text format("%%%s ", __keyword__.upcase)
        q.pp self.expr
        q.text ' %OF {'

        q.breakable

        self.rules.each do |rule|
            q.breakable

            PRT.group q, bb:'| ' do
                q.pp rule
            end
        end

        if self.opt_else_expr
            else_expr = self.opt_else_expr

            q.breakable ' '

            PRT.group q, bb:'%ELSE -> ' do
                q.pp else_expr
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
        ASSERT.kind_of rule, Nary::Rule::Abstraction::WithHead

        body_expr = rule.body_expr.desugar(env)

        ASSERT.kind_of body_expr, ASCE::Abstract
    end


    def __desugar_else_expr__(env)
        else_expr = if self.opt_else_expr
            self.opt_else_expr.desugar(env)
        else
            ASCE.make_raise(
                self.loc,
                X::UnmatchError,
                ASCE.make_string(self.loc, "No rules matched")
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
