# frozen_string_literal: true

require "test_helper"


module Umu

module Test

module Library

module Class

module Product

class TupleTest < Minitest::Test
    def setup
        @interp = Api.setup_interpreter
    end


    def test_imeth_show
        value = Api.eval_expr @interp, '(@Apple, "Aomori").show'
        assert_instance_of VCA::String,             value
        assert_equal       '(@Apple, "Aomori")',    value.val
    end


    def test_imeth_to_s
        value = Api.eval_expr @interp, '(@Apple, "Aomori").to-s'
        assert_instance_of VCA::String,         value
        assert_equal       '(Apple, Aomori)',   value.val
    end


    def test_imess_equal
        value = Api.eval_expr @interp, "(@Apple, 300).== (@Apple,  300)"
        assert_instance_of VCA::Bool,   value
        assert_equal       true,        value.val

        value = Api.eval_expr @interp, "(@Apple, 300).== 4"
        assert_instance_of VCA::Bool,   value
        assert_equal       false,       value.val

        value = Api.eval_expr @interp, "(@Apple, 300).== (@Banana, 300)"
        assert_instance_of VCA::Bool,   value
        assert_equal       false,       value.val

        value = Api.eval_expr @interp, "(@Apple, 300).== (@Apple,  500)"
        assert_instance_of VCA::Bool,   value
        assert_equal       false,       value.val
    end


    def test_imess_less_than
        value = Api.eval_expr @interp, "(@Apple, 300).< (@Banana, 300)"
        assert_instance_of VCA::Bool,   value
        assert_equal       true,        value.val

        value = Api.eval_expr @interp, "(@Apple, 300).< (@Apple,  500)"
        assert_instance_of VCA::Bool,   value
        assert_equal       true,        value.val

        assert_raises(X::TypeError) do
            Api.eval_expr @interp,      "(@Apple, 300).< 4"
        end

        value = Api.eval_expr @interp, "(@Apple,  300).< (@Apple,  300)"
        assert_instance_of VCA::Bool,   value
        assert_equal       false,       value.val
    end
end

end # Umu::Test::Library::Class::Product

end # Umu::Test::Library::Class

end # Umu::Test::Library

end # Umu::Test

end # Umu
