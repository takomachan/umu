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
    attr_reader :symbol
    attr_reader :param_class_signats

    alias to_sym symbol


    def initialize(meth_sym, ret_class_signat, symbol, param_class_signats)
        ASSERT.kind_of meth_sym,            ::Symbol
        ASSERT.kind_of ret_class_signat,    Class::Abstract
        ASSERT.kind_of symbol,              ::Symbol
        ASSERT.kind_of param_class_signats, ::Array

        @meth_sym               = meth_sym
        @ret_class_signat       = ret_class_signat
        @symbol                 = symbol
        @param_class_signats    = param_class_signats
    end


    def ==(other)
        other.kind_of?(Method) && self.symbol == other.symbol
    end
    alias eql? ==


    def <=>(other)
        ASSERT.kind_of other, Method

        self.symbol <=> other.symbol
    end


    def hash
        self.symbol.hash
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
                self.symbol.to_s,

                (
                    self.param_class_signats + [self.ret_class_signat]
                ).map(&:to_sym).map(&:to_s).join(' -> ')
            )
        end
    end


private

    def __keyword_method__?
        /:/ =~ self.symbol
    end


    def __extract_keywords__
        labels = self.symbol.to_s.split(':')
        ASSERT.assert labels.size == self.param_class_signats.size

        labels.zip self.param_class_signats
    end
end


module_function

    def make_method(symbol, ret_class_signat, meth_sym, param_class_signats)
        ASSERT.kind_of symbol,              ::Symbol
        ASSERT.kind_of ret_class_signat,    Class::Abstract
        ASSERT.kind_of meth_sym,            ::Symbol
        ASSERT.kind_of param_class_signats, ::Array

        Method.new(
            symbol, ret_class_signat, meth_sym, param_class_signats.freeze
        ).freeze
    end

end # Umu::Environment::Context::Type::Signature

end # Umu::Environment::Context::Type

end # Umu::Environment::Context

end # Umu::Environment

end # Umu
