# coding: utf-8
# frozen_string_literal: true



module Umu

module AbstractSyntax

module Core

module Expression

module Unary

module Container

class Struct < Abstraction::Abstract
    alias expr_by_sym enum


    def initialize(loc, expr_by_sym)
        ASSERT.kind_of expr_by_sym, ::Hash

        super
    end


    def each
        self.expr_by_sym.each do |sym, expr|
            ASSERT.kind_of sym,   ::Symbol
            ASSERT.kind_of expr,  ASCE::Abstract

            yield sym, expr
        end
    end


    def to_s
        format "%%STRUCT {%s}", self.map { |sym, _| sym.to_s }.join(', ')
    end


    def pretty_print(q)
        P.seplist(q, self, '%STRUCT {', '}', ',') do |sym, _expr|
            q.text sym.to_s
        end
    end


private

    def __evaluate__(env, event)
        ASSERT.kind_of env,     E::Entry
        ASSERT.kind_of event,   E::Tracer::Event

        new_env = env.enter event

        VC.make_struct(
            self.inject({}) { |hash, (sym, expr)|
                hash.merge(sym => expr.evaluate(new_env).value) {
                    |lab, _, _|

                    ASSERT.abort(lab.to_s)
                }
            }
        )
    end
end

end # Umu::AbstractSyntax::Core::Expression::Unary::Container

end # Umu::AbstractSyntax::Core::Expression::Unary


module_function

    def make_struct(loc, expr_by_sym)
        ASSERT.kind_of loc,           L::Location
        ASSERT.kind_of expr_by_sym,   ::Hash

        Unary::Container::Struct.new(loc, expr_by_sym.freeze).freeze
    end

end # Umu::AbstractSyntax::Core::Expression

end # Umu::AbstractSyntax::Core

end # Umu::AbstractSyntax

end # Umu
