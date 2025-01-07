# coding: utf-8
# frozen_string_literal: true



module Umu

module Value

module Core

class Top < ::Object
    def self.class_method_infos
        infos = @class_method_infos

        (infos ? infos : []).map {
            |
                meth_sym, mess_sym,
                param_class_types, ret_class_type
            |

            ECTS.make_method_info(
                meth_sym, mess_sym,
                param_class_types, ret_class_type
            )
        }
    end


    def self.instance_method_infos
        infos = @instance_method_infos

        (infos ? infos : []).map {
            |
                meth_sym, message_sym,
                param_class_types, ret_class_type
            |

            ECTS.make_method_info(
                meth_sym, message_sym,
                param_class_types, ret_class_type
            )
        }
    end


    def self.define_class_method(
        meth_sym, hd_mess_sym, tl_mess_syms,
        param_class_types, ret_class_type
    )
        # printf "CLASS METHOD OF %s\n", self

        @class_method_infos ||= []

        self.__define_method__(
            @class_method_infos,
            meth_sym, hd_mess_sym, tl_mess_syms,
            param_class_types, ret_class_type
        )
    end


    def self.define_instance_method(
        meth_sym, hd_mess_sym, tl_mess_syms,
        param_class_types, ret_class_type
    )
        # printf "INSTANCE METHOD OF %s\n", self

        @instance_method_infos ||= []

        self.__define_method__(
            @instance_method_infos,
            meth_sym, hd_mess_sym, tl_mess_syms,
            param_class_types, ret_class_type
        )
    end


    def self.__define_method__(
        infos,
        meth_sym, hd_mess_sym, tl_mess_syms,
        param_class_types, ret_class_type
    )
=begin
        pp [
            meth_sym, hd_mess_sym, tl_mess_syms,
            param_class_types, ret_class_type
        ]
=end
        ASSERT.kind_of infos,              ::Array
        ASSERT.kind_of meth_sym,           ::Symbol
        ASSERT.kind_of hd_mess_sym,        ::Symbol
        tl_mess_syms.each do |mess_alias_sym|
            ASSERT.kind_of mess_alias_sym, ::Symbol
        end
        ASSERT.kind_of param_class_types,  ::Array
        param_class_types.each do |param_class_type|
            ASSERT.subclass_of param_class_type, VC::Top
        end
        ASSERT.subclass_of ret_class_type, VC::Top

        ([hd_mess_sym] + tl_mess_syms).each do |message_sym|
            infos << [
                    meth_sym, message_sym,
                    param_class_types, ret_class_type
                ]
        end
    end


    def self.type_sym
        begin
            self.const_get :TYPE_SYM, false
        rescue ::NameError
            class_path  = self.to_s.split(/::/).map(&:to_sym)
            self_sym    = class_path[-1]

            if self_sym == :Abstract
                class_path[-2]
            else
                self_sym
            end
        end
    end


    def type_sym
        self.class.type_sym
    end


    def pretty_print(q)
        q.text self.to_s
    end


    def invoke(method_signat, loc, env, _event, *arg_values)
        ASSERT.kind_of method_signat,   ECTS::Method::Entry
        ASSERT.kind_of loc,             LOC::Entry
        ASSERT.kind_of env,             E::Entry
        ASSERT.kind_of arg_values,      ::Array
        ASSERT.assert arg_values.all? { |v| v.kind_of? VC::Top }

        msg = format("(%s).%s%s -> %s",
                        self.to_s,

                        method_signat.meth_sym,

                        if arg_values.empty?
                            ''
                        else
                            format("(%s)",
                                arg_values.zip(
                                    method_signat.param_class_signats
                                ).map{ |(value, signat)|
                                    format "%s : %s", value, signat.to_sym
                                }.join(', ')
                            )
                        end,

                        method_signat.ret_class_signat.to_sym
                    )

        value = E::Tracer.trace(
                            env.pref,
                            env.trace_stack.count,
                            'Invoke',
                            self.class,
                            loc,
                            msg,
                        ) { |event|
                            __invoke__(
                                method_signat.meth_sym,
                                loc,
                                env,
                                event,
                                arg_values
                            )
                        }
        ASSERT.kind_of value, VC::Top
    end


    def apply(_head_value, _tail_values, loc, env)
        ASSERT.kind_of loc, LOC::Entry
        ASSERT.kind_of env, E::Entry

        raise X::ApplicationError.new(
            loc,
            env,
            "Application error for %s : %s",
                self.to_s,
                self.type_sym.to_s
        )
    end


    define_instance_method(
        :meth_inspect,
        :inspect, [],
        [], VCBA::String
    )
    def meth_inspect(_loc, _env, _event)
        VC.make_string self.to_s
    end


    define_instance_method(
        :meth_to_string,
        :'to-s', [],
        [], VCBA::String
    )
    alias meth_to_string meth_inspect


    define_instance_method(
        :meth_equal,
        :'==', [],
        [self], VCBA::Bool
    )
    def meth_equal(loc, env, _event, _other)
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
        [self], VCBA::Bool
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


private

    def __invoke__(meth_sym, loc, env, event, arg_values)
        ASSERT.kind_of meth_sym,    ::Symbol
        ASSERT.kind_of loc,         LOC::Entry
        ASSERT.kind_of env,         E::Entry
        ASSERT.kind_of event,       E::Tracer::Event
        ASSERT.kind_of arg_values,  ::Array

        self.send meth_sym, loc, env, event, *arg_values
    end

end
Top.freeze

end # Umu::Value::Core

end # Umu::Value

end # Umu
