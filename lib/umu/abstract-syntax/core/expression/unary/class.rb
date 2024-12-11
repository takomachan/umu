# coding: utf-8
# frozen_string_literal: true



module Umu

module AbstractSyntax

module Core

module Expression

module Unary

class Class < Abstract
    alias class_sym obj


    def initialize(loc, class_sym)
        ASSERT.kind_of class_sym, ::Symbol

        super
    end


    def to_s
        format "&%s", self.class_sym
    end


    def __evaluate__(env, _event)
        class_signat = env.ty_lookup self.class_sym, self.loc
        ASSERT.kind_of class_signat, ECTSC::Base

        VC.make_class class_signat
    end
end

end # Umu::AbstractSyntax::Core::Expression::Unary


module_function

    def make_class(loc, class_sym)
        ASSERT.kind_of loc,         LOC::Entry
        ASSERT.kind_of class_sym,   ::Symbol

        Unary::Class.new(loc, class_sym).freeze
    end

end # Umu::AbstractSyntax::Core::Expression

end # Umu::AbstractSyntax::Core

end # Umu::AbstractSyntax

end # Umu
