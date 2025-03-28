# coding: utf-8
# frozen_string_literal: true



module Umu

module Value

module Core

module Atom

class String < Abstract
    def initialize(val)
        ASSERT.kind_of val, ::String

        super
    end


    def to_s
        format "\"%s\"", Escape.unescape(self.val)
    end


    def meth_show(_loc, _env, _event)
        VC.make_string self.to_s
    end


    def meth_to_string(_loc, _env, _event)
        self
    end


    define_instance_method(
        :meth_is_less_than,
        :'<', [],
        [self], VCA::Bool
    )


    define_instance_method(
        :meth_is_greater_than,
        :'>', [],
        [self], VCA::Bool
    )


    define_instance_method(
        :meth_is_less_equal,
        :'<=', [],
        [self], VCA::Bool
    )


    define_instance_method(
        :meth_is_greater_equal,
        :'>=', [],
        [self], VCA::Bool
    )


    define_instance_method(
        :meth_compare,
        :'<=>', [],
        [self], VCAN::Int
    )


    define_instance_method(
        :meth_append,
        :'^', [],
        [self], self
    )
    def meth_append(_loc, _env, _event, other)
        ASSERT.kind_of other, String

        VC.make_string self.val + other.val
    end


    define_instance_method(
        :meth_panic,
        :panic!, [],
        [], VC::Unit
    )
    def meth_panic(loc, env, _event)
        raise X::Panic.new(loc, env, self.to_s)
    end
end
String.freeze


end # Umu::Value::Core::Atom


module_function

    def make_string(val)
        ASSERT.kind_of val, ::String

        Atom::String.new(val.freeze).freeze
    end

end # Umu::Value::Core

end # Umu::Value

end # Umu
