# coding: utf-8
# frozen_string_literal: true



module Umu

module Value

module Core

class Ref < Object
    define_class_method(
        :meth_make_ref,
        :make, [],
        [VC::Top], self
    )
    def self.meth_make_ref(loc, env, _event, val)
        VC.make_reference val
    end


    attr_reader :mutable_val

    def initialize(val)
        ASSERT.kind_of val, VC::Top

        super()

        @mutable_val = val
    end


    def to_s
        format "#Ref<%s>", self.mutable_val.to_s
    end


    def pretty_print(q)
        PRT.group q, bb:'#Ref<', eb:'>' do
            q.pp self.mutable_val
        end
    end


    define_instance_method(
        :meth_peek,
        :'peek!', [],
        [], VC::Top
    )
    def meth_peek(loc, env, _event)
        self.mutable_val
    end


    define_instance_method(
        :meth_poke,
        :'poke!', [],
        [VC::Top], VC::Unit
    )
    def meth_poke(_loc, _env, _event, val)
        ASSERT.kind_of val, VC::Top

        @mutable_val = val

        VC.make_unit
    end
end
Ref.freeze


module_function

    def make_reference(val)
        ASSERT.kind_of val, VC::Top

        Ref.new(val)   # Does NOT freeze!!
    end

end # Umu::Value::Core

end # Umu::Value

end # Umu
