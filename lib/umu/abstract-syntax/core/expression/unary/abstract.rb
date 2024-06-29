# coding: utf-8
# frozen_string_literal: true



module Umu

module AbstractSyntax

module Core

module Expression

module Unary

class Abstract < Expression::Abstract
    attr_reader :obj


    def initialize(loc, obj)
        ASSERT.kind_of obj, ::Object

        super(loc)

        @obj = obj
    end


    def simple?
        true
    end
end

end # Umu::AbstractSyntax::Core::Expression::Unary

end # Umu::AbstractSyntax::Core::Expression

end # Umu::AbstractSyntax::Core

end # Umu::AbstractSyntax

end # Umu
