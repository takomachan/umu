# coding: utf-8
# frozen_string_literal: true

require 'umu/common'
require 'umu/lexical/escape'
require 'umu/lexical/location'


module Umu

module ConcreteSyntax

module Core

module Expression

module Unary

module Atom

class String < Atom::Abstract
    def initialize(loc, obj)
        ASSERT.kind_of obj, ::String

        super
    end


    def to_s
        '"' + L::Escape.unescape(self.obj) + '"'
    end


private

    def __desugar__(_env, _event)
        ASCE.make_string self.loc, self.obj
    end
end

end # Umu::ConcreteSyntax::Core::Expression::Unary::Atom

end # Umu::ConcreteSyntax::Core::Expression::Unary



module_function

    def make_string(loc, obj)
        ASSERT.kind_of loc, L::Location
        ASSERT.kind_of obj, ::String

        Unary::Atom::String.new(loc, obj.freeze).freeze
    end

end # Umu::ConcreteSyntax::Core::Expression

end # Umu::ConcreteSyntax::Core

end # Umu::ConcreteSyntax

end # Umu
