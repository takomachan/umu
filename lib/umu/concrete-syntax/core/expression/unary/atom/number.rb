# coding: utf-8
# frozen_string_literal: true



module Umu

module ConcreteSyntax

module Core

module Expression

module Unary

module Atom

module Number

class Abstract < Atom::Abstract
    def initialize(loc, obj)
        ASSERT.kind_of obj, ::Numeric

        super
    end


    def to_s
        self.obj.to_s
    end
end


class Int < Abstract
    def initialize(loc, obj)
        ASSERT.kind_of obj, ::Integer

        super
    end


private

    def __desugar__(_env, _event)
        ASCE.make_integer self.loc, self.obj
    end
end


class Real < Abstract
    def initialize(loc, obj)
        ASSERT.kind_of obj, ::Float

        super
    end


private

    def __desugar__(_env, _event)
        ASCE.make_real self.loc, self.obj
    end
end

end # Umu::ConcreteSyntax::Expression::Core::Unary::Number::Atom

end # Umu::ConcreteSyntax::Expression::Core::Unary::Number

end # Umu::ConcreteSyntax::Expression::Core::Unary



module_function

    def make_integer(loc, obj)
        ASSERT.kind_of loc, LOC::Entry
        ASSERT.kind_of obj, ::Integer

        Unary::Atom::Number::Int.new(loc, obj).freeze
    end


    def make_real(loc, obj)
        ASSERT.kind_of loc, LOC::Entry
        ASSERT.kind_of obj, ::Float

        Unary::Atom::Number::Real.new(loc, obj).freeze
    end

end # Umu::ConcreteSyntax::Expression::Core

end # Umu::ConcreteSyntax::Core

end # Umu::ConcreteSyntax

end # Umu
