# coding: utf-8
# frozen_string_literal: true



module Umu

module Value

module Core

module Union

module Option

class Abstract < Union::Abstract
    def self.base_type_sym
        :Option
    end


    def none?
        false
    end


    def some?
        false
    end


    define_instance_method(
        :meth_is_none,
        :None?, [],
        [], VCA::Bool
    )
    def meth_is_none(_loc, _env, event)
        VC.make_false
    end


    define_instance_method(
        :meth_is_some,
        :Some?, [],
        [], VCA::Bool
    )
    def meth_is_some(_loc, _env, event)
        VC.make_false
    end


    define_instance_method(
        :meth_is_less_than,
        :'<', [],
        [self], VCA::Bool
    )
end
Abstract.freeze



class None < Abstract
    def self.order_num
        __LINE__
    end


    define_class_method(
        :meth_make,
        :make, [],
        [], self
    )
    def self.meth_make(_loc, _env, _event)
        VC.make_none
    end


    def none?
        true
    end


    define_instance_method(
        :meth_is_none,
        :None?, [],
        [], VCA::Bool
    )
    def meth_is_none(_loc, _env, _event)
        VC.make_true
    end
end
None.freeze

NONE = None.new.freeze



class Some < Abstract
    def self.order_num
        __LINE__
    end


    define_class_method(
        :meth_make,
        :make, [],
        [VC::Top], self
    )
    def self.meth_make(_loc, _env, _event, contents)
        ASSERT.kind_of contents, VC::Top

        VC.make_some contents
    end


    attr_reader :contents


    def initialize(contents)
        ASSERT.kind_of contents, VC::Top

        super()

        @contents = contents
    end


    def some?
        true
    end


    define_instance_method(
        :meth_is_some,
        :Some?, [],
        [], VCA::Bool
    )
    def meth_is_some(_loc, _env, event)
        VC.make_true
    end
end
Some.freeze

end # Umu::Value::Core::Union::Option

end # Umu::Value::Core::Union


module_function

    def make_none
        Union::Option::NONE
    end


    def make_some(contents)
        ASSERT.kind_of contents, VC::Top

        Union::Option::Some.new(contents).freeze
    end

end # Umu::Value::Core

end # Umu::Value

end # Umu
