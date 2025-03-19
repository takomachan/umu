# coding: utf-8
# frozen_string_literal: true



module Umu

module ConcreteSyntax

module Core

module Expression

module Nary

module Branch

module Rule

module Case

class Abstract < Umu::Abstraction::Model
    attr_reader :obj


    def initialize(loc, obj)
        ASSERT.kind_of obj, ::Object

        super(loc)

        @obj = obj
    end


    def type_sym
        raise X::InternalSubclassResponsibility
    end


private

    def __escape_string_format__(s)
        s.gsub(/%/, '%%')
    end
end

end # Umu::ConcreteSyntax::Core::Expression::Nary::Branch::Rule::Case

end # Umu::ConcreteSyntax::Core::Expression::Nary::Branch::Rule

end # Umu::ConcreteSyntax::Core::Expression::Nary::Branch

end # Umu::ConcreteSyntax::Core::Expression::Nary

end # Umu::ConcreteSyntax::Core::Expression

end # Umu::ConcreteSyntax::Core

end # Umu::ConcreteSyntax

end # Umu
