# coding: utf-8
# frozen_string_literal: true



module Umu

module Environment

module Context

module Type

module Signature

module Method

class Abstract
    attr_reader :meth_sym
    attr_reader :mess_sym

    alias to_sym mess_sym


    def initialize(meth_sym, mess_sym)
        ASSERT.kind_of meth_sym,    ::Symbol
        ASSERT.kind_of mess_sym,    ::Symbol

        @meth_sym = meth_sym
        @mess_sym = mess_sym
    end


    def ==(other)
        other.kind_of?(Abstract) && self.mess_sym == other.mess_sym
    end
    alias eql? ==


    def <=>(other)
        ASSERT.kind_of other, Abstract

        self.mess_sym <=> other.mess_sym
    end


    def hash
        self.mess_sym.hash
    end


    def to_s
        if __keyword_method__?
            format("(%s) -> %s",
                __extract_keywords__.map { |lab, typ|
                    format "%s:%s", lab, typ.type_sym.to_s
                }.join(' '),

                self.ret_class.type_sym.to_s
            )
        else
            format("%s : %s",
                self.mess_sym.to_s,

                (
                    self.param_classes + [self.ret_class]
                ).map { |typ|
                    typ.type_sym.to_s
                }.join(' -> ')
            )
        end
    end


    def param_classes
        raise X::InternalSubclassResponsibility
    end


    def ret_class
        raise X::InternalSubclassResponsibility
    end


private

    def __keyword_method__?
        /:/ =~ self.mess_sym
    end


    def __extract_keywords__
        labels = self.mess_sym.to_s.split(':')
        ASSERT.assert labels.size == self.param_classes.size

        labels.zip self.param_classes
    end
end



class Entry < Abstract
    attr_reader :param_class_signats
    attr_reader :ret_class_signat


    def initialize(
        meth_sym, mess_sym, param_class_signats, ret_class_signat
    )
        ASSERT.kind_of meth_sym,            ::Symbol
        ASSERT.kind_of mess_sym,            ::Symbol
        ASSERT.kind_of param_class_signats, ::Array
        ASSERT.kind_of ret_class_signat,    Class::Abstract

        super(meth_sym, mess_sym)

        @param_class_signats    = param_class_signats
        @ret_class_signat       = ret_class_signat
    end


    def param_classes
        self.param_class_signats
    end


    def ret_class
        self.ret_class_signat
    end
end



class Info < Abstract
    attr_reader :param_class_types
    attr_reader :ret_class_type


    def initialize(
        meth_sym, mess_sym, param_class_types, ret_class_type
    )
        ASSERT.kind_of     meth_sym,          ::Symbol
        ASSERT.kind_of     mess_sym,          ::Symbol
        ASSERT.kind_of     param_class_types, ::Array
        ASSERT.subclass_of ret_class_type,    VC::Top

        super(meth_sym, mess_sym)

        @param_class_types    = param_class_types
        @ret_class_type       = ret_class_type
    end


    def param_classes
        self.param_class_types
    end


    def ret_class
        self.ret_class_type
    end


=begin
    def to_a
        [meth_sym, ret_class_type, mess_sym, param_class_types].freeze
    end
=end


    def to_signat(env)
        ret_signat    = env.ty_signat_of_class self.ret_class_type
        param_signats = self.param_class_types.map { |klass|
            ASSERT.subclass_of klass, VC::Top

            env.ty_signat_of_class klass
        }

        ECTS.make_method_signat(
             self.meth_sym, self.mess_sym, param_signats, ret_signat
        )
    end
end

end # Umu::Environment::Context::Type::Signature::Method


module_function

    def make_method_signat(
        meth_sym, mess_sym, param_class_signats, ret_class_signat
    )
        ASSERT.kind_of meth_sym,            ::Symbol
        ASSERT.kind_of mess_sym,            ::Symbol
        ASSERT.kind_of param_class_signats, ::Array
        ASSERT.kind_of ret_class_signat,    Class::Abstract

        Method::Entry.new(
            meth_sym, mess_sym, param_class_signats.freeze, ret_class_signat
        ).freeze
    end


    def make_method_info(
        meth_sym, mess_sym, param_class_types, ret_class_type
    )
        ASSERT.kind_of     meth_sym,          ::Symbol
        ASSERT.kind_of     mess_sym,          ::Symbol
        ASSERT.kind_of     param_class_types, ::Array
        ASSERT.subclass_of ret_class_type,    VC::Top

        Method::Info.new(
            meth_sym, mess_sym, param_class_types.freeze, ret_class_type
        ).freeze
    end

end # Umu::Environment::Context::Type::Signature

end # Umu::Environment::Context::Type

end # Umu::Environment::Context

end # Umu::Environment

end # Umu
