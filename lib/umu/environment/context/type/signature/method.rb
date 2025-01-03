# coding: utf-8
# frozen_string_literal: true



module Umu

module Environment

module Context

module Type

module Signature

class Method
    attr_reader :meth_sym
    attr_reader :ret_class_signat
    attr_reader :mess_sym
    attr_reader :param_class_signats

    alias to_sym mess_sym


    def initialize(
        meth_sym, ret_class_signat, mess_sym, param_class_signats
    )
        ASSERT.kind_of meth_sym,            ::Symbol
        ASSERT.kind_of ret_class_signat,    Class::Abstract
        ASSERT.kind_of mess_sym,            ::Symbol
        ASSERT.kind_of param_class_signats, ::Array

        @meth_sym               = meth_sym
        @ret_class_signat       = ret_class_signat
        @mess_sym               = mess_sym
        @param_class_signats    = param_class_signats
    end


    def ==(other)
        other.kind_of?(Method) && self.mess_sym == other.mess_sym
    end
    alias eql? ==


    def <=>(other)
        ASSERT.kind_of other, Method

        self.mess_sym <=> other.mess_sym
    end


    def hash
        self.mess_sym.hash
    end


    def to_s
        if __keyword_method__?
            format("(%s) -> %s",
                __extract_keywords__.map { |lab, typ|
                    format "%s:%s", lab, typ.to_sym.to_s
                }.join(' '),

                self.ret_class_signat.to_sym.to_s
            )
        else
            format("%s : %s",
                self.mess_sym.to_s,

                (
                    self.param_class_signats + [self.ret_class_signat]
                ).map(&:to_sym).map(&:to_s).join(' -> ')
            )
        end
    end


private

    def __keyword_method__?
        /:/ =~ self.mess_sym
    end


    def __extract_keywords__
        labels = self.mess_sym.to_s.split(':')
        ASSERT.assert labels.size == self.param_class_signats.size

        labels.zip self.param_class_signats
    end
end


module_function

    def make_method(meth_sym, ret_class_signat, mess_sym, param_class_signats)
        ASSERT.kind_of meth_sym,            ::Symbol
        ASSERT.kind_of ret_class_signat,    Class::Abstract
        ASSERT.kind_of mess_sym,            ::Symbol
        ASSERT.kind_of param_class_signats, ::Array

        Method.new(
            meth_sym, ret_class_signat, mess_sym, param_class_signats.freeze
        ).freeze
    end

end # Umu::Environment::Context::Type::Signature

end # Umu::Environment::Context::Type

end # Umu::Environment::Context

end # Umu::Environment

end # Umu
