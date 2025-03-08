# coding: utf-8
# frozen_string_literal: true



module Umu

module Value

module Core

module Morph

class Enum < Abstract
    def self.make(xs)
        ASSERT.kind_of xs, ::Array

        VC.make_list xs
    end


    define_class_method(
        :meth_make_empty,
        :empty, [],
        [], VCM::List::Abstract
    )
    def self.meth_make_empty(loc, env, _event)
        VC.make_nil
    end


    attr_reader :source

    def initialize(source, fn_dest)
        ASSERT.kind_of source,  VC::Top
        ASSERT.kind_of fn_dest, ::Proc

        @source     = source
        @fn_dest    = fn_dest
    end


    def fn_dest
        val_opt = @fn_dest.call self.source
        ASSERT.kind_of  val_opt,            VCU::Option::Abstract
        ASSERT.tuple_of val_opt.contents,   [VC::Top, VC::Top]

        val_opt
    end


    def to_s
        format "#Enum<%s>", self.source.to_s
    end


    define_instance_method(
        :meth_cons,
        :cons, [],
        [VC::Top], VCM::List::Abstract
    )
    def meth_cons(loc, env, _event, value)
        ASSERT.kind_of value, VC::Top

        raise X::NotImplemented.new(
                    loc,
                    env,
                    "cons: Emnumerator morph is not be constructible"
                )
    end


    def meth_dest(_loc, _env, _event)
        self.fn_dest
    end
end
Enum.freeze

end # Umu::Value::Core::Morph



module_function

    def make_enumerator(source, fn_dest)
        ASSERT.kind_of source,  VC::Top
        ASSERT.kind_of fn_dest, ::Proc

        Morph::Enum.new(source, fn_dest).freeze
    end

end # Umu::Value::Core

end # Umu::Value

end # Umu
