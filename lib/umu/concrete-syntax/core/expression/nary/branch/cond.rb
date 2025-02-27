# coding: utf-8
# frozen_string_literal: true



module Umu

module ConcreteSyntax

module Core

module Expression

module Nary

module Branch

module Rule

class Cond < Abstraction::HasHead
    alias head_expr head
end

end # Umu::ConcreteSyntax::Core::Expression::Nary::Branch::Rule



class Cond < Abstract

private

    def __keyword__
        'cond'
    end


    def __desugar__(env, event)
        new_env = env.enter event

        opnd_expr = self.expr.desugar(new_env)
        ASSERT.kind_of opnd_expr, ASCE::Abstract
        if opnd_expr.simple? || self.rules.size <= 1
            rules = __desugar_rules__(env) { |_| opnd_expr }

            ASCE.make_if self.loc, rules, self.desugar_else_expr(new_env)
        else
            ASCE.make_let(
                self.loc,

                ASCD.make_seq_of_declaration(
                    opnd_expr.loc,
                    [ASCD.make_value(opnd_expr.loc, :'%x', opnd_expr)]
                ),

                ASCE.make_if(
                    self.loc,
                    __desugar_rules__(env) { |loc|
                        ASCE.make_identifier loc, :'%x'
                    },
                    self.desugar_else_expr(new_env)
                )
            )
        end
    end


    def __desugar_rules__(env, &fn)
        self.rules.map { |rule|
            ASSERT.kind_of rule, Rule::Cond

            opr_expr    = rule.head_expr.desugar env
            head_expr   = ASCE.make_apply(
                                rule.loc, opr_expr, fn.call(rule.loc)
                            )
            body_expr   = self.desugar_body_expr env, rule

            ASCE.make_rule rule.loc, head_expr, body_expr
        }
    end
end

end # Umu::ConcreteSyntax::Core::Expression::Nary::Branch

end # Umu::ConcreteSyntax::Core::Expression::Nary


module_function

    def make_cond_rule(loc, head_expr, body_expr)
        ASSERT.kind_of loc,         LOC::Entry
        ASSERT.kind_of head_expr,   CSCE::Abstract
        ASSERT.kind_of body_expr,   CSCE::Abstract

        Nary::Branch::Rule::Cond.new(loc, head_expr, body_expr).freeze
    end


    def make_cond(loc, expr, fst_rule, snd_rules, opt_else_expr)
        ASSERT.kind_of      loc,            LOC::Entry
        ASSERT.kind_of      expr,           CSCE::Abstract
        ASSERT.kind_of      fst_rule,       CSCEN::Branch::Rule::Cond
        ASSERT.kind_of      snd_rules,      ::Array
        ASSERT.opt_kind_of  opt_else_expr,  CSCE::Abstract

        Nary::Branch::Cond.new(
            loc, expr, fst_rule, snd_rules, opt_else_expr
        ).freeze
    end

end # Umu::ConcreteSyntax::Core::Expression

end # Umu::ConcreteSyntax::Core

end # Umu::ConcreteSyntax

end # Umu
