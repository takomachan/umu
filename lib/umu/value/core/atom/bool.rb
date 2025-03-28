# coding: utf-8
# frozen_string_literal: true



module Umu

module Value

module Core

module Atom

class Bool < Abstract
    define_class_method(
        :meth_make_true,
        :true, [],
        [], VCA::Bool
    )
    def self.meth_make_true(_loc, _env, _event)
        VC.make_true
    end


    define_class_method(
        :meth_make_false,
        :false, [],
        [], VCA::Bool
    )
    def self.meth_make_false(_loc, _env, _event)
        VC.make_false
    end


    alias true? val


    def false?
        ! self.val
    end


    def to_s
        if self.val
            'TRUE'
        else
            'FALSE'
        end
    end


    define_instance_method(
        :meth_is_less_than,
        :'<', [],
        [self], self
    )
    def meth_is_less_than(_loc, _env, _event, other)
        ASSERT.kind_of other, Bool

        VC.make_bool(
            if self.val
                ! other.val
            else
                false
            end
        )
    end


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
        :meth_not,
        :not, [],
        [], self
    )
    def meth_not(_loc, _env, _event)
        VC.make_bool(! self.val)
    end
end
Bool.freeze

TRUE    = Bool.new(true).freeze
FALSE   = Bool.new(false).freeze

end # Umu::Value::Core::Atom



module_function

    def make_true
        Atom::TRUE
    end


    def make_false
        Atom::FALSE
    end


    def make_bool(val)
        ASSERT.bool val

        if val
            VC.make_true
        else
            VC.make_false
        end
    end

end # Umu::Value::Core

end # Umu::Value

end # Umu
