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


    def meth_is_equal(loc, env, _event, _other)
        raise X::EqualityError.new(
            loc,
            env,
            "Equality error for %s : %s",
                self.to_s,
                self.type_sym.to_s
        )
    end


    def meth_is_not_equal(loc, env, event, other)
        ASSERT.kind_of other, VC::Top

        value = if other.kind_of? VC::Object
                    bool_value = self.meth_is_equal(loc, env, event, other)
                    ASSERT.kind_of bool_value, VCA::Bool
                else
                    VC.make_true
                end

        VC.make_bool value.val.!
    end


    def meth_is_less_than(loc, env, _event, _other)
        raise X::OrderError.new(
            loc,
            env,
            "Order error for %s : %s",
                self.to_s,
                self.type_sym.to_s
        )
    end


    def meth_is_greater_than(loc, env, event, other)
        ASSERT.kind_of other, VC::Top

        unless other.kind_of? VC::Object
            raise X::TypeError.new(
                loc,
                env,
                "Expected a Object, but %s : %s",
                    other.to_s,
                    other.type_sym.to_s
            )
        end

        bool_value = other.meth_is_less_than(loc, env, event, self)
        ASSERT.kind_of bool_value, VCA::Bool

        VC.make_bool bool_value.val
    end


    def meth_is_less_equal(loc, env, event, other)
        ASSERT.kind_of other, VC::Top

        unless other.kind_of? VC::Object
            raise X::TypeError.new(
                loc,
                env,
                "Expected a Object, but %s : %s",
                    other.to_s,
                    other.type_sym.to_s
            )
        end

        bool_value = other.meth_is_less_than(loc, env, event, self)
        ASSERT.kind_of bool_value, VCA::Bool

        VC.make_bool bool_value.val.!
    end


    def meth_is_greater_equal(loc, env, event, other)
        ASSERT.kind_of other, VC::Top

        unless other.kind_of? VC::Object
            raise X::TypeError.new(
                loc,
                env,
                "Expected a Object, but %s : %s",
                    other.to_s,
                    other.type_sym.to_s
            )
        end

        bool_value = self.meth_is_less_than(loc, env, event, other)
        ASSERT.kind_of bool_value, VCA::Bool

        VC.make_bool bool_value.val.!
    end


    def meth_compare(loc, env, event, other)
        ASSERT.kind_of other, VC::Top

        unless other.kind_of? VC::Object
            raise X::TypeError.new(
                loc,
                env,
                "Expected a Object, but %s : %s",
                    other.to_s,
                    other.type_sym.to_s
            )
        end

        bool_value_1 = self.meth_is_less_than(loc, env, event, other)
        ASSERT.kind_of bool_value_1, VCA::Bool

        result = (
            if bool_value_1.val
                VC.make_integer(-1)
            else
                value = other.meth_is_less_than(loc, env, event, self)
                ASSERT.kind_of value, VCA::Bool

                if value.val
                    VC.make_integer 1
                else
                    VC.make_integer 0
                end
            end
        )

        ASSERT.kind_of result, VCAN::Int
    end


    define_instance_method(
        :meth_force,
        :force, [],
        [], VC::Top
    )
    def meth_force(_loc, _env, _event)
        self
    end
end
Object.freeze

end # Umu::Value::Core

end # Umu::Value

end # Umu
