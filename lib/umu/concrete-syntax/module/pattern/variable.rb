# coding: utf-8
# frozen_string_literal: true


module Umu

module ConcreteSyntax

module Module

module Pattern

class Variable < Abstract
    attr_reader :var_sym


    def initialize(loc, var_sym)
        ASSERT.kind_of var_sym, ::Symbol

        super(loc)

        @var_sym = var_sym
    end


    def to_s
        self.var_sym.to_s
    end


    def exported_vars
        [CSCP.make_variable(self.loc, self.var_sym)].freeze
    end


private

    def __desugar_value__(expr, _env, _event)
        ASSERT.kind_of expr, ASCE::Abstract

        ASCD.make_value self.loc, self.var_sym, expr
    end
end


module_function

    def make_variable(loc, var_sym)
        ASSERT.kind_of loc,     L::Location
        ASSERT.kind_of var_sym, ::Symbol

        Variable.new(loc, var_sym).freeze
    end

end # Umu::ConcreteSyntax::Module::Pattern

end # Umu::ConcreteSyntax::Module

end # Umu::ConcreteSyntax

end # Umu
