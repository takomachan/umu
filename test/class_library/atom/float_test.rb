# frozen_string_literal: true

require "test_helper"


module Umu

module Test

module Library

module Class

module Atom

module Number

class FloatTest < Minitest::Test
    def setup
        @interp = Api.setup_interpreter
    end


    # Constructer

    def test_cmess_make_nan
        value = Api.eval_expr @interp, "&Float.nan"
        assert_instance_of VCAN::Float, value
        assert                          value.val.nan?
    end


    def test_cmess_make_infinity
        value = Api.eval_expr @interp, "&Float.infinity"
        assert_instance_of VCAN::Float, value
        assert                          value.val.infinite?
    end


    # Classifier

    def test_imess_is_zero
        value = Api.eval_expr @interp, "0.0.zero?"
        assert_instance_of VCA::Bool,   value
        assert_equal       true,        value.val

        value = Api.eval_expr @interp, "3.0.zero?"
        assert_instance_of VCA::Bool,   value
        assert_equal       false,       value.val
    end


    def test_imess_is_positive
        value = Api.eval_expr @interp, "3.0.positive?"
        assert_instance_of VCA::Bool,   value
        assert_equal       true,        value.val

        value = Api.eval_expr @interp, "0.0.positive?"
        assert_instance_of VCA::Bool,   value
        assert_equal       false,       value.val
    end


    def test_imess_is_negative
        value = Api.eval_expr @interp, "-3.0.negative?"
        assert_instance_of VCA::Bool,   value
        assert_equal       true,        value.val

        value = Api.eval_expr @interp, "0.0.negative?"
        assert_instance_of VCA::Bool,   value
        assert_equal       false,       value.val
    end


    # Formater

    def test_imess_show_finite
        value = Api.eval_expr @interp, "3.0.show"
        assert_instance_of VCA::String, value
        assert_equal       "3.0",       value.val
    end


    def test_imess_finite_to_s
        value = Api.eval_expr @interp, "3.0.to-s"
        assert_instance_of VCA::String, value
        assert_equal       "3.0",       value.val
    end


    def test_imess_show_nan
        value = Api.eval_expr @interp, "NAN.show"
        assert_instance_of VCA::String, value
        assert_equal       "NAN",       value.val
    end


    def test_imess_nan_to_s
        value = Api.eval_expr @interp, "NAN.to-s"
        assert_instance_of VCA::String, value
        assert_equal       "NAN",       value.val
    end


    def test_imess_show_positive_infinite
        value = Api.eval_expr @interp, "INFINITY.show"
        assert_instance_of VCA::String, value
        assert_equal       "INFINITY",  value.val
    end


    def test_imess_positive_infinite_to_s
        value = Api.eval_expr @interp, "INFINITY.to-s"
        assert_instance_of VCA::String, value
        assert_equal       "INFINITY",  value.val
    end


    def test_imess_show_negative_infinite
        value = Api.eval_expr @interp, "INFINITY.negate.show"
        assert_instance_of VCA::String, value
        assert_equal       "-INFINITY", value.val
    end


    def test_imess_negative_infinite_to_s
        value = Api.eval_expr @interp, "INFINITY.negate.to-s"
        assert_instance_of VCA::String, value
        assert_equal       "-INFINITY", value.val
    end


    # Type converter

    def test_imess_to_i
        value = Api.eval_expr @interp, "3.0.to-i"
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
        value = Api.eval_expr @interp, "3.0.negate"
        assert_instance_of VCAN::Float, value
        assert_equal       (-3.0),      value.val

        value = Api.eval_expr @interp, "-3.0.negate"
        assert_instance_of VCAN::Float, value
        assert_equal       3.0,         value.val
    end


    def test_imess_abs
        value = Api.eval_expr @interp, "3.0.abs"
        assert_instance_of VCAN::Float, value
        assert_equal       3.0,         value.val

        value = Api.eval_expr @interp, "-3.0.negate"
        assert_instance_of VCAN::Float, value
        assert_equal       3.0,         value.val
    end


    def test_imess_add
        value = Api.eval_expr @interp, "3.0.+ 4.0"
        assert_instance_of VCAN::Float, value
        assert_equal       7.0,         value.val
    end


    def test_imess_sub
        value = Api.eval_expr @interp, "3.0.- 4.0"
        assert_instance_of VCAN::Float, value
        assert_equal       (-1.0),      value.val
    end


    def test_imess_multiply
        value = Api.eval_expr @interp, "3.0.* 4.0"
        assert_instance_of VCAN::Float, value
        assert_equal       12.0,        value.val
    end


    def test_imess_divide
        value = Api.eval_expr @interp, "7.0./ 2.0"
        assert_instance_of VCAN::Float, value
        assert_equal       3.5,         value.val
    end


    def test_imess_divide_by_zero
        value = Api.eval_expr @interp, "7.0./ 0.0"
        assert_instance_of VCAN::Float, value
        assert                          value.val.infinite?
    end


    def test_imess_mod
        value = Api.eval_expr @interp, "7.0.mod 3.0"
        assert_instance_of VCAN::Float, value
        assert_equal       1.0,         value.val
    end


    def test_imess_pow
        value = Api.eval_expr @interp, "2.0.pow 3.0"
        assert_instance_of VCAN::Float, value
        assert_equal       8.0,         value.val
    end


    def test_imess_random
        assert (
            Api.eval_expr @interp, "10.0.random"
        )
    end


    def test_parameter_value_should_not_be_negative_number
        assert_raises(X::ArgumentError) do
            Api.eval_expr @interp, "-10.0.random"
        end
    end


    # Type Error

    def test_parameter_should_be_a_int
        assert_raises(X::TypeError) do
            Api.eval_expr @interp, "3.0. + ()"
        end

        assert_raises(X::TypeError) do
            Api.eval_expr @interp, "3.0. + @Apple"
        end

        assert_raises(X::TypeError) do
            Api.eval_expr @interp, "3.0. + 4"
        end
    end
end

end # Umu::Test::Library::Class::Atom::Number

end # Umu::Test::Library::Class::Atom

end # Umu::Test::Library::Class

end # Umu::Test::Library

end # Umu::Test

end # Umu
