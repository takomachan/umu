# frozen_string_literal: true

require "test_helper"


module Umu

module Test

module Grammar

module CoreLanguage

module Expression

module Atomic

class LambdaExpressionTest < Minitest::Test
=begin
<lambda-expression> ::=
    "{" <pattern> { <pattern> } "->"
        <expression> 
        [ WHERE { declaration> } ]
    "}"
    ;
=end


    def setup
        @interp = Api.setup_interpreter
    end


    def test_with_single_argument
        value = Api.eval_expr @interp, "{ x -> x }"
        assert_instance_of  VC::Fun, value

        value = Api.eval_expr @interp, "{ x -> x } 1"
        assert_instance_of  VCAN::Int, value
        assert_equal        1,         value.val
    end


    def test_with_some_argument
        value = Api.eval_expr @interp, "{ x y -> x + y }"
        assert_instance_of  VC::Fun, value

        value = Api.eval_expr @interp, "{ x y -> x + y } 3 4"
        assert_instance_of  VCAN::Int, value
        assert_equal        7,         value.val
    end


    def test_with_emptye_declaration
        value = Api.eval_expr @interp, "{ x -> x + 4 where }"
        assert_instance_of  VC::Fun, value

        value = Api.eval_expr @interp, "{ x -> x + 4 where } 3"
        assert_instance_of  VCAN::Int, value
        assert_equal        7,         value.val
    end


    def test_with_single_declaration
        value = Api.eval_expr @interp, "{ x -> x + y where val y=4 }"
        assert_instance_of  VC::Fun, value

        value = Api.eval_expr @interp, "{ x -> x + y where val y=4 } 3"
        assert_instance_of  VCAN::Int, value
        assert_equal        7,         value.val
    end


    def test_with_some_declarations
        value = Api.eval_expr @interp, <<-EOS
            { x -> x + y + z where val y=4 val z=5 }
            EOS
        assert_instance_of  VC::Fun, value

        value = Api.eval_expr @interp, <<-EOS
            { x -> x + y + z where val y=4 val z=5 } 3
            EOS
        assert_instance_of  VCAN::Int, value
        assert_equal        12,        value.val
    end
end

end # Umu::Test::Grammar::CoreLanguage::Expression::Atomic

end # Umu::Test::Grammar::CoreLanguage::Expression

end # Umu::Test::Grammar::CoreLanguage

end # Umu::Test::Grammar

end # Umu::Test

end # Umu
