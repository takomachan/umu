# coding: utf-8
# frozen_string_literal: true



module Umu

module ConcreteSyntax

module Core

module Pattern

module Container

class Abstract < Pattern::Abstract
    include Enumerable

    attr_reader :array


    def initialize(loc, array)
        ASSERT.kind_of array, ::Array

        super(loc)

        @array = array
    end


    def each
        self.array.each do |x|
            yield x
        end
    end


private

    def __gen_sym__(num)
        ASSERT.kind_of num, ::Integer

        format("%%a%d", num).to_sym
    end
end

end # Umu::ConcreteSyntax::Core::Pattern::Container

end # Umu::ConcreteSyntax::Core::Pattern

end # Umu::ConcreteSyntax::Core

end # Umu::ConcreteSyntax

end # Umu
