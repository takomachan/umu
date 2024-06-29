# coding: utf-8
# frozen_string_literal: true



module Umu

module AbstractSyntax

module Core

module Expression

module Unary

module Container

module Abstraction

class Abstract < Unary::Abstract
    include ::Enumerable

    alias enum obj


    def each
        raise X::SubclassResponsibility
    end


    def simple?
        false
    end
end



class Expressions < Abstract
    alias exprs enum


    def initialize(loc, exprs)
        ASSERT.kind_of exprs, ::Array

        super
    end


    def each
        self.exprs.each do |expr|
            ASSERT.kind_of expr, ASCE::Abstract

            yield expr
        end
    end
end

end # Umu::AbstractSyntax::Core::Expression::Unary::Container::Abstraction

end # Umu::AbstractSyntax::Core::Expression::Unary::Container

end # Umu::AbstractSyntax::Core::Expression::Unary

end # Umu::AbstractSyntax::Core::Expression

end # Umu::AbstractSyntax::Core

end # Umu::AbstractSyntax

end # Umu
