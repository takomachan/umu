# coding: utf-8
# frozen_string_literal: true

require 'umu/common'
require 'umu/value'


module Umu

module Environment

module Context

module Value

module Bindings

module Target

class Abstract
    attr_reader :obj


    def initialize(obj)
        ASSERT.kind_of obj, ::Object    # Polymophism

        @obj = obj
    end


    def pretty_print(q)
        q.pp self.obj
    end


    def get_value(context)
        raise X::SubclassResponsibility
    end
end



class Value < Abstract
    alias value obj


    def initialize(value)
        ASSERT.kind_of value, VC::Top

        super(value)
    end


    def get_value(_context)
        self.value
    end
end



class Recursive < Abstract
    alias lam_expr obj


    def initialize(lam_expr)
        ASSERT.kind_of lam_expr, ASCEN::Lambda::Entry

        super(lam_expr)
    end


    def get_value(context)
        ASSERT.kind_of context, ECV::Abstract

        VC.make_function self.lam_expr, context
    end
end

end # Umu::Environment::Context::Value::Bindings::Target

end # Umu::Environment::Context::Value::Bindings


module_function

    def make_value_target(value)
        ASSERT.kind_of value, VC::Top

        Bindings::Target::Value.new(value).freeze
    end


    def make_recursive_target(lam_expr)
        ASSERT.kind_of lam_expr, ASCEN::Lambda::Entry

        Bindings::Target::Recursive.new(lam_expr).freeze
    end

end # Umu::Environment::Context::Value

end # Umu::Environment::Context

end # Umu::Environment

end # Umu
