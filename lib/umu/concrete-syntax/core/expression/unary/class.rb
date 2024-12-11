# coding: utf-8
# frozen_string_literal: true



module Umu

module ConcreteSyntax

module Core

module Expression

module Unary

class Class < Abstract
    alias       class_sym obj


    def initialize(loc, class_sym)
        ASSERT.kind_of class_sym,   ::Symbol

        super
    end


    def to_s
        format "&%s", self.class_sym
    end


private

    def __desugar__(_env, _event)
        ASCE.make_class self.loc, self.class_sym
    end
end

end # Umu::ConcreteSyntax::Core::Expression::Unary



module_function

    def make_class(loc, class_sym)
        ASSERT.kind_of loc,         LOC::Entry
        ASSERT.kind_of class_sym,   ::Symbol

        Unary::Class.new(loc, class_sym).freeze
    end

end # Umu::ConcreteSyntax::Core::Expression

end # Umu::ConcreteSyntax::Core

end # Umu::ConcreteSyntax

end # Umu
