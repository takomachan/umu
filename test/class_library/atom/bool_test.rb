# frozen_string_literal: true

require "test_helper"


module Umu

module Test

module Library

module Class

module Atom

class BoolTest < Minitest::Test
    def setup
        @interp = Api.setup_interpreter
    end


    def test_cmess_make_true
        value = Api.eval_expr @interp, "&Bool.true"
        assert_instance_of VCA::Bool,   value
        assert_equal       true,        value.val
    end


    def test_cmess_make_false
        value = Api.eval_expr @interp, "&Bool.false"
        assert_instance_of VCA::Bool,   value
        assert_equal       false,       value.val
    end


    def test_imess_show
        value = Api.eval_expr @interp, "TRUE.show"
        assert_instance_of VCA::String, value
        assert_equal       "TRUE",      value.val

        value = Api.eval_expr @interp, "FALSE.show"
        assert_instance_of VCA::String, value
        assert_equal       "FALSE",     value.val
    end


    def test_imess_to_s
        value = Api.eval_expr @interp, "TRUE.to-s"
        assert_instance_of VCA::String, value
        assert_equal       "TRUE",      value.val

        value = Api.eval_expr @interp, "FALSE.to-s"
        assert_instance_of VCA::String, value
        assert_equal       "FALSE",     value.val
    end


    def test_imess_equal
        value = Api.eval_expr @interp, "TRUE.== TRUE"
        assert_instance_of VCA::Bool,   value
        assert_equal       true,        value.val

        value = Api.eval_expr @interp, "FALSE.== FALSE"
        assert_instance_of VCA::Bool,   value
        assert_equal       true,        value.val

        value = Api.eval_expr @interp, "TRUE.== FALSE"
        assert_instance_of VCA::Bool,   value
        assert_equal       false,       value.val

        value = Api.eval_expr @interp, "FALSE.== TRUE"
        assert_instance_of VCA::Bool,   value
        assert_equal       false,       value.val
    end


    def test_imess_not_equal
        value = Api.eval_expr @interp, "TRUE.<> TRUE"
        assert_instance_of VCA::Bool,   value
        assert_equal       false,       value.val

        value = Api.eval_expr @interp, "FALSE.<> FALSE"
        assert_instance_of VCA::Bool,   value
        assert_equal       false,       value.val

        value = Api.eval_expr @interp, "TRUE.<> FALSE"
        assert_instance_of VCA::Bool,   value
        assert_equal       true,        value.val

        value = Api.eval_expr @interp, "FALSE.<> TRUE"
        assert_instance_of VCA::Bool,   value
        assert_equal       true,        value.val
    end


    def test_imess_less_than
        value = Api.eval_expr @interp, "TRUE.< TRUE"
        assert_instance_of VCA::Bool,   value
        assert_equal       false,       value.val

        value = Api.eval_expr @interp, "FALSE.< FALSE"
        assert_instance_of VCA::Bool,   value
        assert_equal       false,       value.val

        value = Api.eval_expr @interp, "TRUE.< FALSE"
        assert_instance_of VCA::Bool,   value
        assert_equal       true,        value.val

        value = Api.eval_expr @interp, "FALSE.< TRUE"
        assert_instance_of VCA::Bool,   value
        assert_equal       false,       value.val
    end


    def test_imess_less_equal
        value = Api.eval_expr @interp, "TRUE.<= TRUE"
        assert_instance_of VCA::Bool,   value
        assert_equal       true,        value.val

        value = Api.eval_expr @interp, "FALSE.<= FALSE"
        assert_instance_of VCA::Bool,   value
        assert_equal       true,        value.val

        value = Api.eval_expr @interp, "TRUE.<= FALSE"
        assert_instance_of VCA::Bool,   value
        assert_equal       true,        value.val

        value = Api.eval_expr @interp, "FALSE.<= TRUE"
        assert_instance_of VCA::Bool,   value
        assert_equal       false,       value.val
    end


    def test_imess_greater_than
        value = Api.eval_expr @interp, "TRUE.> TRUE"
        assert_instance_of VCA::Bool,   value
        assert_equal       false,       value.val

        value = Api.eval_expr @interp, "FALSE.> FALSE"
        assert_instance_of VCA::Bool,   value
        assert_equal       false,       value.val

        value = Api.eval_expr @interp, "TRUE.> FALSE"
        assert_instance_of VCA::Bool,   value
        assert_equal       false,       value.val

        value = Api.eval_expr @interp, "FALSE.> TRUE"
        assert_instance_of VCA::Bool,   value
        assert_equal       true,        value.val
    end


    def test_imess_greater_equal
        value = Api.eval_expr @interp, "TRUE.>= TRUE"
        assert_instance_of VCA::Bool,   value
        assert_equal       true,        value.val

        value = Api.eval_expr @interp, "FALSE.>= FALSE"
        assert_instance_of VCA::Bool,   value
        assert_equal       true,        value.val

        value = Api.eval_expr @interp, "TRUE.>= FALSE"
        assert_instance_of VCA::Bool,   value
        assert_equal       false,       value.val

        value = Api.eval_expr @interp, "FALSE.>= TRUE"
        assert_instance_of VCA::Bool,   value
        assert_equal       true,        value.val
    end


    def test_imess_compare
        value = Api.eval_expr @interp, "TRUE.<=> TRUE"
        assert_instance_of VCAN::Int,   value
        assert_equal       0,           value.val

        value = Api.eval_expr @interp, "FALSE.<=> FALSE"
        assert_instance_of VCAN::Int,   value
        assert_equal       0,           value.val

        value = Api.eval_expr @interp, "TRUE.<=> FALSE"
        assert_instance_of VCAN::Int,   value
        assert_equal       (-1),        value.val

        value = Api.eval_expr @interp, "FALSE.<=> TRUE"
        assert_instance_of VCAN::Int,   value
        assert_equal       1,           value.val
    end


    def test_imess_not
        value = Api.eval_expr @interp, "TRUE.not"
        assert_instance_of VCA::Bool,   value
        assert_equal       false,       value.val

        value = Api.eval_expr @interp, "FALSE.not"
        assert_instance_of VCA::Bool,   value
        assert_equal       true,        value.val
    end


    # Type Error

    def test_parameter_of_relation_operator_should_be_a_bool
        assert_raises(X::TypeError) do
            Api.eval_expr @interp, "TRUE.< ()"
        end

        assert_raises(X::TypeError) do
            Api.eval_expr @interp, "TRUE.< @Apple"
        end

        assert_raises(X::TypeError) do
            Api.eval_expr @interp, "TRUE.< 4"
        end

        assert_raises(X::TypeError) do
            Api.eval_expr @interp, "TRUE.<= ()"
        end

        assert_raises(X::TypeError) do
            Api.eval_expr @interp, "TRUE.<= @Apple"
        end

        assert_raises(X::TypeError) do
            Api.eval_expr @interp, "TRUE.<= 4"
        end
    end
end

end # Umu::Test::Library::Class::Atom

end # Umu::Test::Library::Class

end # Umu::Test::Library

end # Umu::Test

end # Umu
