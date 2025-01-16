# coding: utf-8
# frozen_string_literal: true



module Umu

module Value

module Core

class Unit < Object
    def to_s
        '()'
    end


    def meth_equal(_loc, _env, _event, other)
        ASSERT.kind_of other, VC::Top

        VC.make_bool other.kind_of?(Unit)
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
