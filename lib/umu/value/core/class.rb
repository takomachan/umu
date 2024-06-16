# coding: utf-8
# frozen_string_literal: true

require 'umu/common'


module Umu

module Value

module Core

class Class < Top
    attr_reader :class_signat


    def initialize(class_signat)
        ASSERT.kind_of class_signat, ECTSC::Base

        super()

        @class_signat = class_signat
    end


    def to_s
        format "&{%s}", self.class_signat.to_sym
    end


private

    def __invoke__(meth_sym, loc, env, event, arg_values)
        ASSERT.kind_of meth_sym,    ::Symbol
        ASSERT.kind_of loc,         L::Location
        ASSERT.kind_of env,         E::Entry
        ASSERT.kind_of event,       E::Tracer::Event
        ASSERT.kind_of arg_values,  ::Array

        self.class_signat.klass.send meth_sym, loc, env, event, *arg_values
    end
end


module_function

    def make_class(class_signat)
        ASSERT.kind_of class_signat, ECTSC::Base

        Class.new(class_signat).freeze
    end

end # Umu::Core

end # Umu::Value

end # Umu
