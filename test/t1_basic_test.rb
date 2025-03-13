# frozen_string_literal: true

require "test_helper"


module Umu

module Test

class T1BasicTest < Minitest::Test
    def setup
        @interp = Api.setup_interpreter
    end


    def test_that_it_has_a_version_number
        refute_nil VERSION
    end


    def test_constant
        value = Api.eval_expr @interp, "3"

        assert_instance_of  VCAN::Int, value
        assert_equal        3,         value.val
    end


    def test_variable_bool
        value = Api.eval_expr @interp, "TRUE"

        assert_instance_of  VCA::Bool, value
        assert_equal        true,      value.val
    end


    def test_variable_fun
        value = Api.eval_expr @interp, "(+)"

        assert_instance_of  VC::Fun, value
    end


    def test_send_expression
        value = Api.eval_expr @interp, "3.+ 4"

        assert_instance_of  VCAN::Int, value
        assert_equal        7,         value.val
    end


    def test_infix_expression
        value = Api.eval_expr @interp, "3 + 4"

        assert_instance_of  VCAN::Int, value
        assert_equal        7,         value.val
    end


    def test_declare_value
        interp_1 = Api.eval_decls @interp,  "val x=3 val y=4"
        value    = Api.eval_expr  interp_1, "x + y"

        assert_instance_of  VCAN::Int, value
        assert_equal        7,         value.val
    end


    def test_declare_fun_fact
        interp_1 = Api.eval_decls @interp,  <<-EOS
            fun rec fact = x -> (
                if x <= 1 then
                    1   
                else
                    x * fact (x - 1)
            )
            EOS

        value = Api.eval_expr  interp_1, "fact 3"
        assert_instance_of  VCAN::Int, value
        assert_equal        6,         value.val

        value = Api.eval_expr  interp_1, "fact 4"
        assert_instance_of  VCAN::Int, value
        assert_equal        24,        value.val
    end
end

end # Umu::Test

end # Umu
