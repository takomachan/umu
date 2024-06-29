# coding: utf-8
# frozen_string_literal: true



module Umu

module ConcreteSyntax

module Core

module Expression

module Binary

class Abstract < Expression::Abstract
    attr_reader :lhs, :rhs


    def initialize(loc, lhs, rhs)
        ASSERT.kind_of lhs, ::Object
        ASSERT.kind_of rhs, ::Object

        super(loc)

        @lhs = lhs
        @rhs = rhs
    end
end

end # Umu::ConcreteSyntax::Core::Expression::Binary

end # Umu::ConcreteSyntax::Core::Expression

end # Umu::ConcreteSyntax::Core

end # Umu::ConcreteSyntax

end # Umu
