# frozen_string_literal: true

require "test_helper"


module Umu

module Test

module Library

module Class

module Atom

module Number

class IntTest < Minitest::Test
    def setup
        @interp = Api.setup_interpreter
    end


    # Constructer

    def test_imess_make_zero
        value = Api.eval_expr @interp, "3.zero"
        assert_instance_of VCAN::Int,   value
        assert_equal       0,           value.val
    end


    # Classifier

    def test_imess_is_zero
        value = Api.eval_expr @interp, "0.zero?"
        assert_instance_of VCA::Bool,   value
        assert_equal       true,        value.val

        value = Api.eval_expr @interp, "3.zero?"
        assert_instance_of VCA::Bool,   value
        assert_equal       false,       value.val
    end


    def test_imess_is_even
        value = Api.eval_expr @interp, "2.even?"
        assert_instance_of VCA::Bool,   value
        assert_equal       true,        value.val

        value = Api.eval_expr @interp, "3.even?"
        assert_instance_of VCA::Bool,   value
        assert_equal       false,       value.val
    end


    def test_imess_is_odd
        value = Api.eval_expr @interp, "3.odd?"
        assert_instance_of VCA::Bool,   value
        assert_equal       true,        value.val

        value = Api.eval_expr @interp, "4.odd?"
        assert_instance_of VCA::Bool,   value
        assert_equal       false,       value.val
    end


    def test_imess_is_positive
        value = Api.eval_expr @interp, "3.positive?"
        assert_instance_of VCA::Bool,   value
        assert_equal       true,        value.val

        value = Api.eval_expr @interp, "0.positive?"
        assert_instance_of VCA::Bool,   value
        assert_equal       false,       value.val
    end


    def test_imess_is_negative
        value = Api.eval_expr @interp, "-3.negative?"
        assert_instance_of VCA::Bool,   value
        assert_equal       true,        value.val

        value = Api.eval_expr @interp, "0.negative?"
        assert_instance_of VCA::Bool,   value
        assert_equal       false,       value.val
    end


    # Type converter

    def test_imess_to_i
        value = Api.eval_expr @interp, "3.to-i"
        assert_instance_of VCAN::Int,   value
        assert_equal       3,           value.val
    end


    def test_imess_to_f
        value = Api.eval_expr @interp, "3.to-f"
        assert_instance_of VCAN::Float, value
        assert_equal       3.0,         value.val
    end


    # Computer

    def test_imess_negate
        value = Api.eval_expr @interp, "3.negate"
        assert_instance_of VCAN::Int,   value
        assert_equal       (-3),        value.val

        value = Api.eval_expr @interp, "-3.negate"
        assert_instance_of VCAN::Int,   value
        assert_equal       3,          value.val
    end


    def test_imess_abs
        value = Api.eval_expr @interp, "3.abs"
        assert_instance_of VCAN::Int,   value
        assert_equal       3,           value.val

        value = Api.eval_expr @interp, "-3.negate"
        assert_instance_of VCAN::Int,   value
        assert_equal       3,          value.val
    end


    def test_imess_succ
        value = Api.eval_expr @interp, "3.succ"
        assert_instance_of VCAN::Int,   value
        assert_equal       4,           value.val
    end


    def test_imess_pred
        value = Api.eval_expr @interp, "3.pred"
        assert_instance_of VCAN::Int,   value
        assert_equal       2,           value.val
    end


    def test_imess_add
        value = Api.eval_expr @interp, "3.+ 4"
        assert_instance_of VCAN::Int,   value
        assert_equal       7,           value.val
    end


    def test_imess_sub
        value = Api.eval_expr @interp, "3.- 4"
        assert_instance_of VCAN::Int,   value
        assert_equal       (-1),        value.val
    end


    def test_imess_multiply
        value = Api.eval_expr @interp, "3.* 4"
        assert_instance_of VCAN::Int,   value
        assert_equal       12,          value.val
    end


    def test_imess_divide
        value = Api.eval_expr @interp, "7./ 3"
        assert_instance_of VCAN::Int,   value
        assert_equal       2,           value.val
    end


    def test_integer_should_be_not_devide_by_zero
        assert_raises(X::ZeroDivisionError) do
            Api.eval_expr @interp, "7./ 0"
        end
    end


    def test_imess_mod
        value = Api.eval_expr @interp, "7.mod 3"
        assert_instance_of VCAN::Int,   value
        assert_equal       1,           value.val
    end


    def test_imess_pow
        value = Api.eval_expr @interp, "2.pow 3"
        assert_instance_of VCAN::Int,   value
        assert_equal       8,           value.val
    end


    def test_imess_random
        assert (
            Api.eval_expr @interp, "10.random"
        )
    end


    def test_parameter_value_should_not_be_negative_number
        assert_raises(X::ArgumentError) do
            Api.eval_expr @interp, "-10.random"
        end
    end


    def test_imess_to
        value = Api.eval_expr @interp, "3.to 10"
        assert_instance_of  VCM::Interval, value
        assert_instance_of  VCAN::Int,     value.current_value
        assert_equal        3,             value.current_value.val
        assert_instance_of  VCAN::Int,     value.step_value
        assert_equal        1,             value.step_value.val
        assert_instance_of  VCAN::Int,     value.stop_value
        assert_equal        10,            value.stop_value.val
    end


    def test_kw_imess_to
        value = Api.eval_expr @interp, "3.(to:10)"
        assert_instance_of  VCM::Interval, value
        assert_instance_of  VCAN::Int,     value.current_value
        assert_equal        3,             value.current_value.val
        assert_instance_of  VCAN::Int,     value.step_value
        assert_equal        1,             value.step_value.val
        assert_instance_of  VCAN::Int,     value.stop_value
        assert_equal        10,            value.stop_value.val
    end


    def test_imess_to_by
        value = Api.eval_expr @interp, "3.to-by 10 2"
        assert_instance_of  VCM::Interval, value
        assert_instance_of  VCAN::Int,     value.current_value
        assert_equal        3,             value.current_value.val
        assert_instance_of  VCAN::Int,     value.step_value
        assert_equal        2,             value.step_value.val
        assert_instance_of  VCAN::Int,     value.stop_value
        assert_equal        10,            value.stop_value.val
    end


    def test_kw_imess_to_by
        value = Api.eval_expr @interp, "3.(to:10 by:2)"
        assert_instance_of  VCM::Interval, value
        assert_instance_of  VCAN::Int,     value.current_value
        assert_equal        3,             value.current_value.val
        assert_instance_of  VCAN::Int,     value.step_value
        assert_equal        2,             value.step_value.val
        assert_instance_of  VCAN::Int,     value.stop_value
        assert_equal        10,            value.stop_value.val
    end


    def test_step_value_should_be_positive_if_upto_interval
        assert_raises(X::ValueError) do
            Api.eval_expr @interp, "3.to-by 10 -2"
        end
    end


    def test_step_value_should_be_negative_if_downto_interval
        assert_raises(X::ValueError) do
            Api.eval_expr @interp, "10.to-by 3 2"
        end
    end


    # Type Error

    def test_parameter_of_computer_should_be_a_int
        assert_raises(X::TypeError) do
            Api.eval_expr @interp, "3.+ ()"
        end

        assert_raises(X::TypeError) do
            Api.eval_expr @interp, "3.+ @Apple"
        end

        assert_raises(X::TypeError) do
            Api.eval_expr @interp, "3.+ 4.0"
        end
    end


    def test_parameter_of_relation_operator_should_be_a_int
        assert_raises(X::TypeError) do
            Api.eval_expr @interp, "3.< ()"
        end

        assert_raises(X::TypeError) do
            Api.eval_expr @interp, "3.< @Apple"
        end

        assert_raises(X::TypeError) do
            Api.eval_expr @interp, "3.< 4.0"
        end

        assert_raises(X::TypeError) do
            Api.eval_expr @interp, "3.<= ()"
        end

        assert_raises(X::TypeError) do
            Api.eval_expr @interp, "3.<= @Apple"
        end

        assert_raises(X::TypeError) do
            Api.eval_expr @interp, "3.<= 4.0"
        end
    end
end

end # Umu::Test::Library::Class::Atom::Number

end # Umu::Test::Library::Class::Atom

end # Umu::Test::Library::Class

end # Umu::Test::Library

end # Umu::Test

end # Umu
