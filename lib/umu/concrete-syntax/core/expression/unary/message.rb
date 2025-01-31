# coding: utf-8
# frozen_string_literal: true



module Umu

module ConcreteSyntax

module Core

module Expression

module Unary

class Message < Abstract
    alias       message_ident obj
    attr_reader :opt_recv_class_ident


    def initialize(loc, message_ident, opt_recv_class_ident)
        ASSERT.kind_of      message_ident,          CSCEU::Identifier::Short
        ASSERT.opt_kind_of  opt_recv_class_ident,   CSCEU::Identifier::Short

        super(loc, message_ident)

        @opt_recv_class_ident = opt_recv_class_ident
    end


    def to_s
        format("&(%s%s)",
                if self.opt_recv_class_ident
                    format "%s : ", self.opt_recv_class_ident
                else
                    ''
                end,

                self.message_ident
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

                ASCE.make_message(
                    self.message_ident.loc,
                    self.message_ident.sym
                ),

                [],

                if self.opt_recv_class_ident
                    self.opt_recv_class_ident.sym
                else
                    nil
                end
            ),

            self.message_ident.sym
        )
    end
end

end # Umu::ConcreteSyntax::Core::Expression::Unary



module_function

    def make_functionalized_message(
        loc, message_ident, opt_recv_class_ident = nil
    )
        ASSERT.kind_of      loc,                    LOC::Entry
        ASSERT.kind_of      message_ident,          CSCEU::Identifier::Short
        ASSERT.opt_kind_of  opt_recv_class_ident,   CSCEU::Identifier::Short

        Unary::Message.new(loc, message_ident, opt_recv_class_ident).freeze
    end

end # Umu::ConcreteSyntax::Core::Expression

end # Umu::ConcreteSyntax::Core

end # Umu::ConcreteSyntax

end # Umu
