# coding: utf-8
# frozen_string_literal: true



module Umu

module Value

module Core

module Base

module Atom

class String < Abstract
    INSTANCE_METHOD_INFOS = [
        [:meth_less_than,   VCBA::Bool,
            :'<',           self],

        [:meth_panic,       VC::Unit,
            :'panic!'],
        [:meth_append,      self,
            :'^',           self]
    ]


    def initialize(val)
        ASSERT.kind_of val, ::String

        super
    end


    def to_s
        format "\"%s\"", Escape.unescape(self.val)
    end


    def meth_inspect(_loc, _env, _event)
        VC.make_string self.to_s
    end


    def meth_to_string(_loc, _env, _event)
        self
    end


    def meth_panic(loc, env, _event)
        raise X::Panic.new(loc, env, self.to_s)
    end


    def meth_append(_loc, _env, _event, other)
        ASSERT.kind_of other, String

        VC.make_string self.val + other.val
    end
end


end # Umu::Value::Core::Base::Atom

end # Umu::Value::Core::Base


module_function

    def make_string(val)
        ASSERT.kind_of val, ::String

        Base::Atom::String.new(val.freeze).freeze
    end

end # Umu::Value::Core

end # Umu::Value

end # Umu
