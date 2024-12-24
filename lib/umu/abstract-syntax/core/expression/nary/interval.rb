# coding: utf-8
# frozen_string_literal: true



module Umu

module AbstractSyntax

module Core

module Expression

module Nary

class Interval < Expression::Abstract
    attr_reader :fst_expr, :opt_snd_expr, :lst_expr


    def initialize(loc, fst_expr, opt_snd_expr, lst_expr)
        ASSERT.kind_of     fst_expr,        ASCE::Abstract
        ASSERT.opt_kind_of opt_snd_expr,    ASCE::Abstract
        ASSERT.kind_of     lst_expr,        ASCE::Abstract

        super(loc)

        @fst_expr     = fst_expr
        @opt_snd_expr = opt_snd_expr
        @lst_expr     = lst_expr
    end


    def to_s
        format("[%s%s .. %s]",
                 self.fst_expr.to_s,

                 if self.opt_snd_expr
                     format ", %s", self.opt_snd_expr.to_s
                 else
                     ''
                 end,

                 self.lst_expr.to_s
        )
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
                self.loc,
                env,
                "Type error in interval-expression, " +
                        "expected a Int as first value, but %s : %s",
                    fst_value.to_s,
                    fst_value.type_sym.to_s
            )
        end

        opt_snd_value =
            if self.opt_snd_expr
                snd_result = self.opt_snd_expr.evaluate new_env
                ASSERT.kind_of snd_result, ASR::Value
                snd_value = snd_result.value
                ASSERT.kind_of snd_value, VC::Top
                unless snd_value.kind_of? VCBAN::Int
                    raise X::TypeError.new(
                        self.loc,
                        env,
                        "Type error in interval-expression, " +
                            "expected a Int as second value, but %s : %s",
                            snd_value.to_s,
                            snd_value.type_sym.to_s
                    )
                end

                snd_value
            else
                nil
            end

        lst_result = self.lst_expr.evaluate new_env
        ASSERT.kind_of lst_result, ASR::Value
        lst_value = lst_result.value
        ASSERT.kind_of lst_value, VC::Top
        unless lst_value.kind_of? VCBAN::Int
            raise X::TypeError.new(
                self.loc,
                env,
                "Type error in interval-expression, " +
                        "expected a Int as last value, but %s : %s",
                    lst_value.to_s,
                    lst_value.type_sym.to_s
            )
        end

        step_value = VC.make_integer(
            if fst_value.val <= lst_value.val
                if opt_snd_value
                    snd_value = opt_snd_value
                    unless (fst_value.val <= snd_value.val &&
                            snd_value.val <= lst_value.val)
                        raise X::ValueError.new(
                            self.loc,
                            env,
                            "The second value must be between " +
                                "the first and last value, but %s : %s",
                                snd_value.to_s,
                                snd_value.type_sym.to_s
                        )
                    end

                    snd_value.val - fst_value.val
                else
                    1
                end
            else
                if opt_snd_value
                    snd_value = opt_snd_value
                    unless (fst_value.val > snd_value.val &&
                            snd_value.val > lst_value.val)
                        raise X::ValueError.new(
                            self.loc,
                            env,
                            "The second value must be between " +
                                "the first and last value, but %s : %s",
                                snd_value.to_s,
                                snd_value.type_sym.to_s
                        )
                    end

                    snd_value.val - fst_value.val
                else
                    -1
                end
            end
        )

        VC.make_interval fst_value, lst_value, step_value
    end
end

end # Umu::AbstractSyntax::Core::Expression::Nary


module_function

    def make_interval(loc, fst_expr, opt_snd_expr, lst_expr)
        ASSERT.kind_of     loc,             LOC::Entry
        ASSERT.kind_of     fst_expr,        ASCE::Abstract
        ASSERT.opt_kind_of opt_snd_expr,    ASCE::Abstract
        ASSERT.kind_of     lst_expr,        ASCE::Abstract

        Nary::Interval.new(loc, fst_expr, opt_snd_expr, lst_expr).freeze
    end

end # Umu::AbstractSyntax::Core::Expression

end # Umu::AbstractSyntax::Core

end # Umu::AbstractSyntax

end # Umu
