# coding: utf-8
# frozen_string_literal: true



module Umu

module AbstractSyntax

module Core

module Expression

module Unary

module Container

class Tuple < Abstraction::Expressions
    def initialize(loc, exprs)
        ASSERT.kind_of exprs, ::Array
        ASSERT.assert exprs.size >= 2   # Pair or More

        super
    end


    def to_s
        format "(%s)", self.map(&:to_s).join(', ')
    end


    def pretty_print(q)
        PRT.seplist q, self, '(', ')', ','
    end


private

    def __evaluate__(env, event)
        ASSERT.kind_of env,     E::Entry
        ASSERT.kind_of event,   E::Tracer::Event


        new_env = env.enter event

        VC.make_tuple(
            self.map { |expr| expr.evaluate(new_env).value }
        )
    end
end

end # Umu::AbstractSyntax::Core::Expression::Unary::Container

end # Umu::AbstractSyntax::Core::Expression::Unary


module_function

    def make_tuple(loc, exprs)
        ASSERT.kind_of loc,     LOC::Entry
        ASSERT.kind_of exprs,   ::Array

        Unary::Container::Tuple.new(loc, exprs.freeze).freeze
    end

end # Umu::AbstractSyntax::Core::Expression

end # Umu::AbstractSyntax::Core

end # Umu::AbstractSyntax

end # Umu
