# coding: utf-8
# frozen_string_literal: true



module Umu

module ConcreteSyntax

module Core

module Expression

module Unary

module Container

class Abstract < Unary::Abstract
    include Enumerable

    alias exprs obj


    def initialize(loc, exprs)
        ASSERT.kind_of exprs, ::Array

        super
    end


    def each
        self.exprs.each do |x|
            yield x
        end
    end


    def empty?
        self.count == 0
    end
end

end # Umu::ConcreteSyntax::Core::Expression::Unary::Container

end # Umu::ConcreteSyntax::Core::Expression::Unary

end # Umu::ConcreteSyntax::Core::Expression

end # Umu::ConcreteSyntax::Core

end # Umu::ConcreteSyntax

end # Umu
