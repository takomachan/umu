# frozen_string_literal: true

require "test_helper"


module Umu

module Test

module Library

module Class

class ObjectTest < Minitest::Test
    def setup
        @interp = Api.setup_interpreter
    end


    def test_imess_show
        value = Api.eval_expr @interp, "@Apple.show"
        assert_instance_of VCA::String, value
        assert_equal       "@Apple",    value.val
    end


    def test_imess_to_string
        value = Api.eval_expr @interp, "@Apple.to-s"
        assert_instance_of VCA::String, value
        assert_equal       "Apple",     value.val
    end


    def test_imess_contents
        value = Api.eval_expr @interp, "[3].contents"
        assert_instance_of VCP::Tuple,  value

        head_value, tail_value = value.values
        assert_instance_of VCAN::Int,      head_value
        assert_equal       3,              head_value.val
        assert_instance_of VCM::List::Nil, tail_value
    end


    def test_imess_is_equal
        value = Api.eval_expr @interp, "3.== 3"
        assert_instance_of VCA::Bool,   value
        assert_equal       true,        value.val

        value = Api.eval_expr @interp, "3.== 4"
        assert_instance_of VCA::Bool,   value
        assert_equal       false,       value.val
    end


    def test_imess_is_less_than
        value = Api.eval_expr @interp, "3.< 3"
        assert_instance_of VCA::Bool,   value
        assert_equal       false,       value.val

        value = Api.eval_expr @interp, "3.< 4"
        assert_instance_of VCA::Bool,   value
        assert_equal       true,        value.val
    end


    def test_imess_force
        value = Api.eval_expr @interp, "3.force"
        assert_instance_of VCAN::Int,   value
        assert_equal       3,           value.val
    end
end

end # Umu::Test::Library::Class

end # Umu::Test::Library

end # Umu::Test

end # Umu
