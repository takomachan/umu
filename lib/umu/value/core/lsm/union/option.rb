# coding: utf-8
# frozen_string_literal: true



module Umu

module Value

module Core

module LSM

module Union

module Option

class Abstract < Union::Abstract
    define_instance_method(
        :meth_is_none,
        :none?, [],
        [], VCA::Bool
    )
    def meth_is_none(_loc, _env, event)
        VC.make_false
    end


    define_instance_method(
        :meth_is_some,
        :some?, [],
        [], VCA::Bool
    )
    def meth_is_some(_loc, _env, event)
        VC.make_false
    end
end
Abstract.freeze



class None < Abstract
    define_class_method(
        :meth_make,
        :make, [],
        [], self
    )
    def self.meth_make(_loc, _env, _event)
        VC.make_none
    end


    def meth_is_none(_loc, _env, _event)
        VC.make_true
    end
end
None.freeze

NONE = None.new.freeze



class Some < Abstract
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


    def meth_is_some(_loc, _env, event)
        VC.make_true
    end
end
Some.freeze

end # Umu::Core::LSM::Union::Option

end # Umu::Core::LSM::Union

end # Umu::Core::LSM


module_function

    def make_none
        LSM::Union::Option::NONE
    end


    def make_some(contents)
        ASSERT.kind_of contents, VC::Top

        LSM::Union::Option::Some.new(contents).freeze
    end

end # Umu::Core

end # Umu::Value

end # Umu
