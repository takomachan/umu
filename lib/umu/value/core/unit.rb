# coding: utf-8
# frozen_string_literal: true



module Umu

module Value

module Core

class Unit < Object
    def to_s
        '()'
    end


    define_instance_method(
        :meth_is_equal,
        :'==', [],
        [VC::Top], VCA::Bool
    )
    def meth_is_equal(_loc, _env, _event, other)
        ASSERT.kind_of other, VC::Top

        VC.make_bool other.kind_of?(Unit)
    end


    define_instance_method(
        :meth_is_less_than,
        :'<', [],
        [self], VCA::Bool
    )
    def meth_is_less_than(_loc, _env, _event, _other)
        VC.make_false
    end
end

UNIT = Unit.new.freeze


module_function

    def make_unit
        UNIT
    end

end # Umu::Core

end # Umu::Value

end # Umu
