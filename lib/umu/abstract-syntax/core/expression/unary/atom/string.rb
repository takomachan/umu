# coding: utf-8
# frozen_string_literal: true



module Umu

module AbstractSyntax

module Core

module Expression

module Unary

module Atom

class String < Abstract
    def initialize(loc, obj)
        ASSERT.kind_of obj, ::String

        super
    end


    def to_s
        '"' + Escape.unescape(self.obj) + '"'
    end


    def __evaluate__(_env, _event)
        VC.make_string self.obj
    end
end

end # Umu::AbstractSyntax::Core::Expression::Unary::Atom

end # Umu::AbstractSyntax::Core::Expression::Unary


module_function

    def make_string(loc, obj)
        ASSERT.kind_of loc, Umu::Location
        ASSERT.kind_of obj, ::String

        Unary::Atom::String.new(loc, obj.freeze).freeze
    end

end # Umu::AbstractSyntax::Core::Expression

end # Umu::AbstractSyntax::Core

end # Umu::AbstractSyntax

end # Umu
