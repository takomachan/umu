# coding: utf-8
# frozen_string_literal: true



module Umu

module Value

module Core

module Union

class Abstract < Object
    def self.base_type_sym
        raise X::InternalSubclassResponsibility
    end


    def self.order_num
        raise X::InternalSubclassResponsibility
    end


    def base_type_sym
        self.class.base_type_sym
    end


    def order_num
        self.class.order_num
    end


    def to_s
        format("&%s %s", self.type_sym, self.contents.to_s)
    end


    def pretty_print(q)
        q.text format("&%s ", self.type_sym.to_s)
        q.pp self.contents
    end


    define_instance_method(
        :meth_to_string,
        :'to-s', [],
        [], VCA::String
    )
    def meth_to_string(loc, env, event)
        VC.make_string(
            format("&%s %s",
                    self.type_sym,
                    self.meth_contents(
                        loc, env, event
                    ).meth_to_string(
                        loc, env, event
                    ).val
            )
        )
    end


    define_instance_method(
        :meth_is_equal,
        :'==', [],
        [VC::Top], VCA::Bool
    )
    def meth_is_equal(loc, env, event, other)
        ASSERT.kind_of other, VC::Top

        VC.make_bool(
            (
                other.kind_of?(self.class) &&
                self.contents.meth_is_equal(
                    loc, env, event, other.contents
                ).true?
            )
        )
    end


    define_instance_method(
        :meth_is_less_than,
        :'<', [],
        [self], VCA::Bool
    )
    def meth_is_less_than(loc, env, event, other)
        ASSERT.kind_of other, VCU::Abstract

        unless other.base_type_sym == self.base_type_sym
            raise X::TypeError.new(
                loc,
                env,
                "Expected a %s, but %s : %s",
                    self.base_type_sym,
                    other.to_s,
                    other.base_type_sym
            )
        end

        VC.make_bool(
            if self.order_num == other.order_num
                unless other.contents.kind_of?(self.contents.class)
                    raise X::TypeError.new(
                        loc,
                        env,
                        "Expected a %s, but %s : %s",
                            self.contents.type_sym,
                            other.contents.to_s,
                            other.contents.type_sym
                    )
                end

                self.contents.meth_is_less_than(
                    loc, env, event, other.contents
                ).true?
            else
                self.order_num < other.order_num
            end
        )
    end
end
Abstract.freeze

end # Umu::Value::Core::Union

end # Umu::Value::Core

end # Umu::Value

end # Umu
