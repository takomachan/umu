# coding: utf-8
# frozen_string_literal: true



module Umu

module Value

module Core

module Union

module Result

class Abstract < Union::Abstract
    attr_reader :contents


    def initialize(contents)
        ASSERT.kind_of contents, VC::Top

        super()

        @contents = contents
    end


    define_instance_method(
        :meth_is_ok,
        :ok?, [],
        [], VCA::Bool
    )
    def meth_is_ok(_loc, _env, event)
        VC.make_false
    end


    define_instance_method(
        :meth_is_err,
        :err?, [],
        [], VCA::Bool
    )
    def meth_is_err(_loc, _env, event)
        VC.make_false
    end
end
Abstract.freeze



class Ok < Abstract
    define_class_method(
        :meth_make,
        :make, [],
        [VC::Top], self
    )
    def self.meth_make(_loc, _env, _event, contents)
        ASSERT.kind_of contents, VC::Top

        VC.make_ok contents
    end


    def meth_is_ok(_loc, _env, _event)
        VC.make_true
    end
end
Ok.freeze



class Err < Abstract
    define_class_method(
        :meth_make,
        :make, [],
        [VC::Top], self
    )
    def self.meth_make(_loc, _env, _event, contents)
        ASSERT.kind_of contents, VC::Top

        VC.make_err contents
    end


    def meth_is_err(_loc, _env, event)
        VC.make_true
    end
end
Err.freeze

end # Umu::Value::Core::Union::Result

end # Umu::Value::Core::Union


module_function

    def make_ok(contents)
        ASSERT.kind_of contents, VC::Top

        Union::Result::Ok.new(contents).freeze
    end


    def make_err(contents)
        ASSERT.kind_of contents, VC::Top

        Union::Result::Err.new(contents).freeze
    end

end # Umu::Value::Core

end # Umu::Value

end # Umu
