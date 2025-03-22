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


    def test_imess_less_than
        value = Api.eval_expr @interp, "TRUE.< FALSE"
        assert_instance_of VCA::Bool,   value
        assert_equal       true,        value.val

        value = Api.eval_expr @interp, "FALSE.< TRUE"
        assert_instance_of VCA::Bool,   value
        assert_equal       false,       value.val
    end


    def test_imess_not
        value = Api.eval_expr @interp, "TRUE.not"
        assert_instance_of VCA::Bool,   value
        assert_equal       false,       value.val

        value = Api.eval_expr @interp, "FALSE.not"
        assert_instance_of VCA::Bool,   value
        assert_equal       true,        value.val
    end
end

end # Umu::Test::Library::Class::Atom

end # Umu::Test::Library::Class

end # Umu::Test::Library

end # Umu::Test

end # Umu
