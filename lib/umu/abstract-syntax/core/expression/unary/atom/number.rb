# coding: utf-8
# frozen_string_literal: true



module Umu

module AbstractSyntax

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


    def __evaluate__(_env, _event)
        VC.make_integer self.obj
    end
end


class Real < Abstract
    def initialize(loc, obj)
        ASSERT.kind_of obj, ::Float

        super
    end


    def __evaluate__(_env, _event)
        VC.make_real self.obj
    end
end

end # Umu::AbstractSyntax::Core::Expression::Unary::Atom::Number

end # Umu::AbstractSyntax::Core::Expression::Unary::Atom

end # Umu::AbstractSyntax::Core::Expression::Unary


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

end # Umu::AbstractSyntax::Core::Expression

end # Umu::AbstractSyntax::Core

end # Umu::AbstractSyntax

end # Umu
