# coding: utf-8
# frozen_string_literal: true



module Umu

module Value

module Core

module Atom

class Symbol < Abstract
    def initialize(val)
        ASSERT.kind_of val, ::Symbol

        super
    end


    def to_s
        '@' + self.val.to_s
    end


    def meth_to_string(_loc, _env, _event)
        VC.make_string self.val.to_s
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
end
Symbol.freeze

end # Umu::Value::Core::Atom


module_function

    def make_symbol(val)
        ASSERT.kind_of val, ::Symbol

        Atom::Symbol.new(val).freeze
    end

end # Umu::Value::Core

end # Umu::Value

end # Umu
