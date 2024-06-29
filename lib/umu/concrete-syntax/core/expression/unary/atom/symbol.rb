# coding: utf-8
# frozen_string_literal: true



module Umu

module ConcreteSyntax

module Core

module Expression

module Unary

module Atom

class Symbol < Atom::Abstract
    def initialize(loc, obj)
        ASSERT.kind_of obj, ::Symbol

        super
    end


    def to_s
        '@' + self.obj.to_s
    end


private

    def __desugar__(_env, _event)
        ASCE.make_symbol self.loc, self.obj
    end
end

end # Umu::ConcreteSyntax::Core::Expression::Unary::Atom

end # Umu::ConcreteSyntax::Core::Expression::Unary



module_function

    def make_symbol(loc, obj)
        ASSERT.kind_of loc, Umu::Location
        ASSERT.kind_of obj, ::Symbol

        Unary::Atom::Symbol.new(loc, obj).freeze
    end

end # Umu::ConcreteSyntax::Core::Expression

end # Umu::ConcreteSyntax::Core

end # Umu::ConcreteSyntax

end # Umu
