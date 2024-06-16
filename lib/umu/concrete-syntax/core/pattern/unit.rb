# coding: utf-8
# frozen_string_literal: true

require 'umu/common'


module Umu

module ConcreteSyntax

module Core

module Pattern

class Unit < Abstract
    def to_s
        '()'
    end


    def exported_vars
        [].freeze
    end


private

    def __desugar_value__(expr, _env, _event)
        ASSERT.kind_of expr, ASCE::Abstract

        ASCD.make_value self.loc, WILDCARD, expr, :Unit
    end


    def __desugar_lambda__(_seq_num, _env, _event)
        CSCP.make_result(
            ASCE.make_identifier(self.loc, WILDCARD),
            [],
            :Unit
        )
    end
end


module_function

    def make_unit(loc)
        ASSERT.kind_of loc, L::Location

        Unit.new(loc).freeze
    end

end # Umu::ConcreteSyntax::Core::Pattern

end # Umu::ConcreteSyntax::Core

end # Umu::ConcreteSyntax

end # Umu
