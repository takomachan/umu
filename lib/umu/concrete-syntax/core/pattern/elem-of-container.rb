# coding: utf-8
# frozen_string_literal: true



module Umu

module ConcreteSyntax

module Core

module Pattern

module ElementOfContainer

class Abstract < Pattern::Abstract
    def var_pat
        raise X::InternalSubclassResponsibility
    end


    def hash
        self.var_pat.var_sym.hash
    end


    def eql?(other)
        self.var_pat.var_sym.eql? other.var_pat.var_sym
    end


    def wildcard?
        self.var_pat.var_sym == WILDCARD
    end


    def exported_vars
        (
            if self.wildcard?
                []
            else
                [self]
            end
        ).freeze
    end
end



class Variable < Abstract
    attr_reader :var_sym, :opt_type_sym


    def initialize(loc, var_sym, opt_type_sym)
        ASSERT.kind_of      var_sym,        ::Symbol
        ASSERT.opt_kind_of  opt_type_sym,   ::Symbol

        super(loc)

        @var_sym        = var_sym
        @opt_type_sym   = opt_type_sym
    end


    def to_s
        format("%s%s",
            self.var_sym.to_s,

            if self.opt_type_sym
                format " : %s", self.opt_type_sym.to_s
            else
                ''
            end
        )
    end


    def var_pat
        self
    end


private

    def __desugar_value__(expr, _env, _event)
        ASSERT.kind_of expr, ASCE::Abstract

        ASCD.make_value self.loc, self.var_sym, expr, self.opt_type_sym
    end


    def __desugar_lambda__(_seq_num, _env, _event)
        CSCP.make_result(
            ASCE.make_identifier(self.loc, self.var_sym),
            [],
            self.opt_type_sym
        )
    end
end



class Field < Abstract
    attr_reader :label, :var_pat


    def initialize(loc, label, var_pat)
        ASSERT.kind_of label,    Container::Product::Named::Label
        ASSERT.kind_of var_pat,  ElementOfContainer::Variable

        super(loc)

        @label   = label
        @var_pat = var_pat
    end


    def opt_type_sym
        self.var_pat.opt_type_sym
    end


    def to_s
        self.label.to_s + self.var_pat.to_s
    end
end

end # Umu::ConcreteSyntax::Core::Pattern::ElementOfContainer


module_function

    def make_variable(loc, var_sym, opt_type_sym = nil)
        ASSERT.kind_of loc,     LOC::Entry
        ASSERT.kind_of      var_sym,        ::Symbol
        ASSERT.opt_kind_of  opt_type_sym,   ::Symbol

        ElementOfContainer::Variable.new(loc, var_sym, opt_type_sym).freeze
    end

    def make_named_tuple_field(loc, label, var_pat)
        ASSERT.kind_of loc,     LOC::Entry
        ASSERT.kind_of label,   Container::Product::Named::Label
        ASSERT.kind_of var_pat, ElementOfContainer::Variable

        ElementOfContainer::Field.new(loc, label, var_pat).freeze
    end


end # Umu::ConcreteSyntax::Core::Pattern

end # Umu::ConcreteSyntax::Core

end # Umu::ConcreteSyntax

end # Umu
