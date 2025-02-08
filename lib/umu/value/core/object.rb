# coding: utf-8
# frozen_string_literal: true



module Umu

module Value

module Core

class Object < Top
    define_instance_method(
        :meth_show,
        :show, [],
        [], VCA::String
    )
    def meth_show(_loc, _env, _event)
        VC.make_string self.to_s
    end


    define_instance_method(
        :meth_to_string,
        :'to-s', [],
        [], VCA::String
    )
    alias meth_to_string meth_show


    def contents
        VC.make_unit
    end


    define_instance_method(
        :meth_contents,
        :contents, [],
        [], VC::Top
    )
    def meth_contents(_loc, _env, _event)
        self.contents
    end


    define_instance_method(
        :meth_is_equal,
        :'==', [],
        [self], VCA::Bool
    )
    def meth_is_equal(loc, env, _event, _other)
        raise X::EqualityError.new(
            loc,
            env,
            "Equality error for %s : %s",
                self.to_s,
                self.type_sym.to_s
        )
    end


    define_instance_method(
        :meth_less_than,
        :'<', [],
        [self], VCA::Bool
    )
    def meth_less_than(loc, env, _event, _other)
        raise X::OrderError.new(
            loc,
            env,
            "Order error for %s : %s",
                self.to_s,
                self.type_sym.to_s
        )
    end
end
Object.freeze

end # Umu::Value::Core

end # Umu::Value

end # Umu
