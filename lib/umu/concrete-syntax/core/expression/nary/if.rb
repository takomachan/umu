# coding: utf-8
# frozen_string_literal: true



module Umu

module ConcreteSyntax

module Core

module Expression

module Nary

class If < Expression::Abstract
    attr_reader :if_rule, :elsif_rules, :else_expr


    def initialize(loc, if_rule, elsif_rules, else_expr)
        ASSERT.kind_of if_rule,     Nary::Rule::If
        ASSERT.kind_of elsif_rules, ::Array
        ASSERT.kind_of else_expr,   CSCE::Abstract

        super(loc)

        @if_rule        = if_rule
        @elsif_rules    = elsif_rules
        @else_expr      = else_expr
    end


    def to_s
        rules_string = if self.elsif_rules.empty?
                            ' '
                        else
                            format(" %s ",
                                self.elsif_rules.map { |rule|
                                    '%ELSIF ' + rule.to_s
                                }.join(' ')
                            )
                        end

        format("%%IF %s%s%%ELSE %s",
            self.if_rule.to_s, 
            rules_string,
            self.else_expr.to_s
        )
    end


    def pretty_print(q)
        PRT.group q, bb:'(', eb:')' do
            PRT.group q, bb:'%IF ' do
                q.pp self.if_rule
            end

            self.elsif_rules.each do |rule|
                q.breakable

                PRT.group q, bb:'%ELSIF ' do
                    q.pp rule
                end
            end

            q.breakable

            PRT.group q, bb:'%ELSE ' do
                q.pp self.else_expr
            end
        end
    end


private

    def __desugar__(env, event)
        new_env = env.enter event

        ASCE.make_if(
            self.loc,

            ([self.if_rule] + self.elsif_rules).map { |rule|
                ASSERT.kind_of rule, Nary::Rule::If

                ASCE.make_rule(
                    rule.loc,
                    rule.head_expr.desugar(new_env),
                    rule.body_expr.desugar(new_env)
                )
            },

            self.else_expr.desugar(new_env)
        )
    end
end

end # Umu::ConcreteSyntax::Core::Expression::Nary


module_function

    def make_if(loc, if_rule, elsif_rules, else_expr)
        ASSERT.kind_of loc,         LOC::Entry
        ASSERT.kind_of if_rule,     Nary::Rule::If
        ASSERT.kind_of elsif_rules, ::Array
        ASSERT.kind_of else_expr,   CSCE::Abstract

        Nary::If.new(loc, if_rule, elsif_rules, else_expr).freeze
    end

end # Umu::ConcreteSyntax::Core::Expression

end # Umu::ConcreteSyntax::Core

end # Umu::ConcreteSyntax

end # Umu
