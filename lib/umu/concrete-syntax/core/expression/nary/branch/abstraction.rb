# coding: utf-8
# frozen_string_literal: true



module Umu

module ConcreteSyntax

module Core

module Expression

module Nary

module Branch

module Rule

module Abstraction

class Abstract < Umu::Abstraction::Model
    def line_num
        self.loc.line_num
    end


    def desugar_poly_rule(_env)
        raise X::InternalSubclassResponsibility
    end
end



class HasHead < Abstract
    attr_reader :head, :body_expr


    def initialize(loc, head, body_expr)
        ASSERT.kind_of head,        Umu::Abstraction::Model
        ASSERT.kind_of body_expr,   CSCE::Abstract

        super(loc)

        @head       = head
        @body_expr  = body_expr
    end


    def to_s
        format "%s -> %s", self.head.to_s, self.body_expr.to_s
    end


    def pretty_print(q)
        q.pp self.head
        q.text ' -> '
        q.pp self.body_expr
    end
end

end # Umu::ConcreteSyntax::Core::Expression::Nary::Branch::Rule::Abstraction

end # Umu::ConcreteSyntax::Core::Expression::Nary::Branch::Rule



class Abstract < Expression::Abstract
    attr_reader :expr, :fst_rule, :snd_rules, :opt_else_expr


    def initialize(loc, expr, fst_rule, snd_rules, opt_else_expr)
        ASSERT.kind_of      expr,           CSCE::Abstract
        ASSERT.kind_of      fst_rule,
                                CSCEN::Branch::Rule::Abstraction::Abstract
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


    def desugar_body_expr(env, rule)
        ASSERT.kind_of rule, Nary::Branch::Rule::Abstraction::HasHead

        body_expr = rule.body_expr.desugar(env)

        ASSERT.kind_of body_expr, ASCE::Abstract
    end


    def desugar_else_expr(env)
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


private

    def __keyword__
        raise X::InternalSubclassResponsibility
    end
end

end # Umu::ConcreteSyntax::Core::Expression::Nary::Branch

end # Umu::ConcreteSyntax::Core::Expression::Nary

end # Umu::ConcreteSyntax::Core::Expression

end # Umu::ConcreteSyntax::Core

end # Umu::ConcreteSyntax

end # Umu
