# coding: utf-8
# frozen_string_literal: true



module Umu

module AbstractSyntax

module Core

module Expression

module Nary

module Interval

class Abstract < Expression::Abstract
    attr_reader :fst_expr, :opt_snd_expr, :opt_lst_expr


    def initialize(loc, fst_expr, opt_snd_expr, opt_lst_expr)
        ASSERT.kind_of     fst_expr,        ASCE::Abstract
        ASSERT.opt_kind_of opt_snd_expr,    ASCE::Abstract
        ASSERT.opt_kind_of opt_lst_expr,    ASCE::Abstract

        super(loc)

        @fst_expr     = fst_expr
        @opt_snd_expr = opt_snd_expr
        @opt_lst_expr = opt_lst_expr
    end


    def to_s
        format("%s%s%s ..%s]",
            __bb__,

            self.fst_expr.to_s,

            if self.opt_snd_expr
                format ", %s", self.opt_snd_expr.to_s
            else
                ''
            end,

            if self.opt_lst_expr
                format " %s", self.opt_lst_expr.to_s
            else
                ''
            end
        )
    end


private

    def __bb__
        raise X::InternalSubclassResponsibility
    end


    def __evaluate__(env, event)
        ASSERT.kind_of env,     E::Entry
        ASSERT.kind_of event,   E::Tracer::Event

        new_env = env.enter event

        fst_result = self.fst_expr.evaluate new_env
        ASSERT.kind_of fst_result, ASR::Value
        fst_value = fst_result.value
        ASSERT.kind_of fst_value, VC::Top
        unless fst_value.kind_of? VCAN::Int
            raise X::TypeError.new(
                self.loc,
                env,
                "Type error in interval-expression, " +
                        "expected a Int as first value, but %s : %s",
                    fst_value.to_s,
                    fst_value.type_sym.to_s
            )
        end

        opt_snd_value = (
            if self.opt_snd_expr
                snd_result = self.opt_snd_expr.evaluate new_env
                ASSERT.kind_of snd_result, ASR::Value
                snd_value = snd_result.value
                ASSERT.kind_of snd_value, VC::Top
                unless snd_value.kind_of? VCAN::Int
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
        )

        opt_lst_value = (
            if self.opt_lst_expr
                lst_result = self.opt_lst_expr.evaluate new_env
                ASSERT.kind_of lst_result, ASR::Value

                lst_val = lst_result.value
                ASSERT.kind_of lst_val, VC::Top
                unless lst_val.kind_of? VCAN::Int
                    raise X::TypeError.new(
                        self.loc,
                        env,
                        "Type error in interval-expression, " +
                                "expected a Int as last value, but %s : %s",
                            lst_val.to_s,
                            lst_val.type_sym.to_s
                    )
                end

                lst_val
            else
                nil
            end
        )

        step_value = VC.make_integer(
            if opt_lst_value
                lst_value = opt_lst_value

                if fst_value.val <= lst_value.val
                    if opt_snd_value
                        snd_value = opt_snd_value
                        unless (fst_value.val < snd_value.val &&
                                snd_value.val < lst_value.val)
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
            else
                if opt_snd_value
                    snd_value = opt_snd_value

                    if fst_value.val == snd_value.val
                        raise X::ValueError.new(
                            self.loc,
                            env,
                            "The first value and second value " +
                                "must be not equal, but %s : %s",
                                snd_value.to_s,
                                snd_value.type_sym.to_s
                        )
                    else
                        snd_value.val - fst_value.val
                    end
                else
                    1
                end
            end
        )

        __make__ fst_value, lst_value, step_value, env.va_context
    end


private

    def __make__(_fst_value, _lst_value, _step_value, _va_context)
        raise X::InternalSubclassResponsibility
    end


    def __validate_second_value__(loc, env, fst_value, snd_value)
    end
end



class Basic < Abstract
    def initialize(loc, fst_expr, opt_snd_expr, lst_expr)
        ASSERT.kind_of     fst_expr,        ASCE::Abstract
        ASSERT.opt_kind_of opt_snd_expr,    ASCE::Abstract
        ASSERT.kind_of     lst_expr,        ASCE::Abstract

        super
    end


private

    def __bb__
        '['
    end


    def __make__(fst_value, lst_value, step_value, _va_context)
        VC.make_interval fst_value, lst_value, step_value
    end
end



class Stream < Abstract

private

    def __bb__
        '&['
    end


    def __make__(fst_value, lst_value, step_value, va_context)
        VC.make_interval_stream fst_value, lst_value, step_value, va_context
    end
end

end # Umu::AbstractSyntax::Core::Expression::Nary::Interval

end # Umu::AbstractSyntax::Core::Expression::Nary


module_function

    def make_interval(loc, fst_expr, opt_snd_expr, lst_expr)
        ASSERT.kind_of     loc,             LOC::Entry
        ASSERT.kind_of     fst_expr,        ASCE::Abstract
        ASSERT.opt_kind_of opt_snd_expr,    ASCE::Abstract
        ASSERT.kind_of     lst_expr,        ASCE::Abstract

        Nary::Interval::Basic.new(
            loc, fst_expr, opt_snd_expr, lst_expr
        ).freeze
    end


    def make_interval_stream(loc, fst_expr, opt_snd_expr, opt_lst_expr)
        ASSERT.kind_of     loc,             LOC::Entry
        ASSERT.kind_of     fst_expr,        ASCE::Abstract
        ASSERT.opt_kind_of opt_snd_expr,    ASCE::Abstract
        ASSERT.opt_kind_of opt_lst_expr,    ASCE::Abstract

        Nary::Interval::Stream.new(
            loc, fst_expr, opt_snd_expr, opt_lst_expr
        ).freeze
    end

end # Umu::AbstractSyntax::Core::Expression

end # Umu::AbstractSyntax::Core

end # Umu::AbstractSyntax

end # Umu
