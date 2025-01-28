# coding: utf-8
# frozen_string_literal: true



module Umu

module AbstractSyntax

module Core

module Expression

module Unary

class Raise < Abstract
    alias exception_class obj
    attr_reader :msg_expr


    def initialize(loc, exception_class, msg_expr)
        ASSERT.subclass_of  exception_class,    X::Abstraction::RuntimeError
        ASSERT.kind_of      msg_expr,           ASCE::Abstract

        super(loc, exception_class)

        @msg_expr = msg_expr
    end


    def to_s
        format("%%RAISE %s %s",
                self.exception_class.to_s.split(/::/)[2],
                self.msg_expr.to_s
        )
    end


    def pretty_print(q)
        q.text format("%%RAISE %s ",
                        self.exception_class.to_s.split(/::/)[2]
                )
        PRT.group q do
            q.pp self.msg_expr
        end
    end


    def __evaluate__(env, event)
        new_env = env.enter event

        msg_result = self.msg_expr.evaluate new_env
        ASSERT.kind_of msg_result, ASR::Value

        msg_value = msg_result.value
        unless msg_value.kind_of? VCA::String
            raise X::TypeError.new(
                self.msg_expr.loc,
                new_env,
                "Expected a String, but %s : %s",
                    msg_value.to_s,
                    msg_value.type_sym.to_s
            )
        end

        raise self.exception_class.new(self.loc, env, msg_value.val)
    end
end

end # Umu::AbstractSyntax::Core::Expression::Unary


module_function

    def make_raise(loc, exception_class, msg_expr)
        ASSERT.kind_of      loc,                LOC::Entry
        ASSERT.subclass_of  exception_class,    X::Abstraction::RuntimeError
        ASSERT.kind_of      msg_expr,           ASCE::Abstract

        Unary::Raise.new(loc, exception_class, msg_expr).freeze
    end

end # Umu::AbstractSyntax::Core::Expression

end # Umu::AbstractSyntax::Core

end # Umu::AbstractSyntax

end # Umu
