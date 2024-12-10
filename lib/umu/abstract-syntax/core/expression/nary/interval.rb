# coding: utf-8
# frozen_string_literal: true



module Umu

module AbstractSyntax

module Core

module Expression

module Nary

class Interval < Expression::Abstract
    attr_reader :fst_expr, :lst_expr


    def initialize(loc, fst_expr, lst_expr)
        ASSERT.kind_of fst_expr, ASCE::Abstract
        ASSERT.kind_of lst_expr, ASCE::Abstract

        super(loc)

        @fst_expr = fst_expr
        @lst_expr = lst_expr
    end


    def to_s
        format "[%s .. %s]", self.fst_expr, self.lst_expr
    end

    def __evaluate__(env, event)
        ASSERT.kind_of env,     E::Entry
        ASSERT.kind_of event,   E::Tracer::Event

        new_env = env.enter event

        fst_result = self.fst_expr.evaluate new_env
        ASSERT.kind_of fst_result, ASR::Value
        fst_value = fst_result.value
        ASSERT.kind_of fst_value, VC::Top
        unless fst_value.kind_of? VCBAN::Int
            raise X::TypeError.new(
                rule.loc,
                env,
                "Type error in interval-expression, " +
                        "expected a Int as first value, but %s : %s",
                    fst_value.to_s,
                    fst_value.type_sym.to_s
            )
        end

        lst_result = self.lst_expr.evaluate new_env
        ASSERT.kind_of lst_result, ASR::Value
        lst_value = lst_result.value
        ASSERT.kind_of lst_value, VC::Top
        unless lst_value.kind_of? VCBAN::Int
            raise X::TypeError.new(
                rule.loc,
                env,
                "Type error in interval-expression, " +
                        "expected a Int as last value, but %s : %s",
                    lst_value.to_s,
                    lst_value.type_sym.to_s
            )
        end

        step_value = VC.make_integer(
                            fst_value.val <= lst_value.val ? 1 : -1
                        )

        VC.make_interval fst_value, lst_value, step_value
    end
end

end # Umu::AbstractSyntax::Core::Expression::Nary


module_function

    def make_interval(loc, fst_expr, lst_expr)
        ASSERT.kind_of loc,      LOC::Entry
        ASSERT.kind_of fst_expr, ASCE::Abstract
        ASSERT.kind_of lst_expr, ASCE::Abstract

        Nary::Interval.new(loc, fst_expr, lst_expr)
    end

end # Umu::AbstractSyntax::Core::Expression

end # Umu::AbstractSyntax::Core

end # Umu::AbstractSyntax

end # Umu
