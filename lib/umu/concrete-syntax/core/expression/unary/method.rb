# coding: utf-8
# frozen_string_literal: true

require 'umu/common'
require 'umu/lexical/escape'
require 'umu/lexical/location'


module Umu

module ConcreteSyntax

module Core

module Expression

module Unary

class Method < Abstract
    alias       method_ident obj
    attr_reader :opt_recv_class_ident


    def initialize(loc, method_ident, opt_recv_class_ident)
        ASSERT.kind_of      method_ident,           CSCEU::Identifier::Short
        ASSERT.opt_kind_of  opt_recv_class_ident,   CSCEU::Identifier::Short

        super(loc, method_ident)

        @opt_recv_class_ident = opt_recv_class_ident
    end


    def to_s
        format("&(%s%s)",
                if self.opt_recv_class_ident
                    format "%s : ", self.opt_recv_class_ident
                else
                    ''
                end,

                self.method_ident
        )
    end


private

    def __desugar__(_env, _event)
        ASCE.make_lambda(
            self.loc,

            [
                ASCE.make_parameter(
                    self.loc,
                    ASCE.make_identifier(self.loc, :'%x')
                )
            ],

            ASCE.make_send(
                loc,

                ASCE.make_identifier(self.loc, :'%x'),

                ASCE.make_method(
                    self.method_ident.loc,
                    self.method_ident.sym
                ),

                [],

                if self.opt_recv_class_ident
                    self.opt_recv_class_ident.sym
                else
                    nil
                end
            ),

            self.method_ident.sym
        )
    end
end

end # Umu::ConcreteSyntax::Core::Expression::Unary



module_function

    def make_functionalized_method(
        loc, method_ident, opt_recv_class_ident = nil
    )
        ASSERT.kind_of      loc,                    L::Location
        ASSERT.kind_of      method_ident,           CSCEU::Identifier::Short
        ASSERT.opt_kind_of  opt_recv_class_ident,   CSCEU::Identifier::Short

        Unary::Method.new(loc, method_ident, opt_recv_class_ident).freeze
    end

end # Umu::ConcreteSyntax::Core::Expression

end # Umu::ConcreteSyntax::Core

end # Umu::ConcreteSyntax

end # Umu
