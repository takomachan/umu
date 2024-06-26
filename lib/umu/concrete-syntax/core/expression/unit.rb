# coding: utf-8
# frozen_string_literal: true



module Umu

module ConcreteSyntax

module Core

module Expression

class Unit < Expression::Abstract
    def to_s
        '()'
    end


private

    def __desugar__(_env, _event)
        ASCE.make_unit self.loc
    end
end


module_function

    def make_unit(loc)
        ASSERT.kind_of loc, LOC::Entry

        Unit.new(loc).freeze
    end

end # Umu::ConcreteSyntax::Core::Expression

end # Umu::ConcreteSyntax::Core

end # Umu::ConcreteSyntax

end # Umu
