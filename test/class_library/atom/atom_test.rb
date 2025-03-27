# frozen_string_literal: true

require "test_helper"


module Umu

module Test

module Library

module Class

module Atom

class AtomTest < Minitest::Test
    def setup
        @interp = Api.setup_interpreter
    end


    def test_imess_equal
        value = Api.eval_expr @interp, "3.== 3"
        assert_instance_of VCA::Bool,   value
        assert_equal       true,        value.val

        value = Api.eval_expr @interp, "3.== 4"
        assert_instance_of VCA::Bool,   value
        assert_equal       false,       value.val
    end


    def test_imess_not_equal
        value = Api.eval_expr @interp, "3.<> 3"
        assert_instance_of VCA::Bool,   value
        assert_equal       false,       value.val

        value = Api.eval_expr @interp, "3.<> 4"
        assert_instance_of VCA::Bool,   value
        assert_equal       true,        value.val
    end


    def test_imess_less_than
        value = Api.eval_expr @interp, "3.< 3"
        assert_instance_of VCA::Bool,   value
        assert_equal       false,       value.val

        value = Api.eval_expr @interp, "3.< 4"
        assert_instance_of VCA::Bool,   value
        assert_equal       true,        value.val

        value = Api.eval_expr @interp, "4.< 3"
        assert_instance_of VCA::Bool,   value
        assert_equal       false,       value.val
    end


    def test_imess_less_equal
        value = Api.eval_expr @interp, "3.<= 3"
        assert_instance_of VCA::Bool,   value
        assert_equal       true,        value.val

        value = Api.eval_expr @interp, "3.<= 4"
        assert_instance_of VCA::Bool,   value
        assert_equal       true,        value.val

        value = Api.eval_expr @interp, "4.<= 3"
        assert_instance_of VCA::Bool,   value
        assert_equal       false,       value.val
    end


    def test_imess_greater_than
        value = Api.eval_expr @interp, "3.> 3"
        assert_instance_of VCA::Bool,   value
        assert_equal       false,       value.val

        value = Api.eval_expr @interp, "3.> 4"
        assert_instance_of VCA::Bool,   value
        assert_equal       false,       value.val

        value = Api.eval_expr @interp, "4.> 3"
        assert_instance_of VCA::Bool,   value
        assert_equal       true,        value.val
    end


    def test_imess_greater_equal
        value = Api.eval_expr @interp, "3.>= 3"
        assert_instance_of VCA::Bool,   value
        assert_equal       true,        value.val

        value = Api.eval_expr @interp, "3.>= 4"
        assert_instance_of VCA::Bool,   value
        assert_equal       false,       value.val

        value = Api.eval_expr @interp, "4.>= 3"
        assert_instance_of VCA::Bool,   value
        assert_equal       true,        value.val
    end


    def test_imess_compare
        value = Api.eval_expr @interp, "3.<=> 3"
        assert_instance_of VCAN::Int,   value
        assert_equal       0,           value.val

        value = Api.eval_expr @interp, "3.<=> 4"
        assert_instance_of VCAN::Int,   value
        assert_equal       (-1),        value.val

        value = Api.eval_expr @interp, "4.<=> 3"
        assert_instance_of VCAN::Int,   value
        assert_equal       1,           value.val
    end
end

end # Umu::Test::Library::Class::Atom

end # Umu::Test::Library::Class

end # Umu::Test::Library

end # Umu::Test

end # Umu
