# coding: utf-8
# frozen_string_literal: true



module Umu

module Value

module Core

class Opaque < Top
    attr_reader :obj


    def initialize(obj)
        ASSERT.kind_of obj, ::Object

        super()

        @obj = obj
    end


    def to_s
        format "#Opaque<%s>", self.obj.inspect
    end


    def pretty_print(q)
        PRT.group q, bb:'#Opaque<', eb:'>' do
            q.pp self.obj
        end
    end
end
Opaque.freeze



module_function

    def make_opaque(obj)
        ASSERT.kind_of obj, ::Object

        Opaque.new(obj).freeze
    end

end # Umu::Value::Core

end # Umu::Value

end # Umu
