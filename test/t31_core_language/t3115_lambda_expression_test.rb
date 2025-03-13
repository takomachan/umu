# frozen_string_literal: true

require "test_helper"


module Umu

module Test

module T3Language

module T31Core

module T311AtomicExpression

class T3115LambdaExpressionTest < Minitest::Test
=begin
<lambda-expression> ::=
    "{" <pattern> { <pattern> } "->"
        <expression> 
        [ WHERE <declaration> { declaration> } ]
    "}"
    ;
=end


    def setup
        @interp = Api.setup_interpreter
    end


    def test_lambda_expression_with_single_argument
        value = Api.eval_expr @interp, "{ x -> x }"
        assert_instance_of  VC::Fun, value

        value = Api.eval_expr @interp, "{ x -> x } 1"
        assert_instance_of  VCAN::Int, value
        assert_equal        1,         value.val
    end


    def test_lambda_expression_with_some_argument
        value = Api.eval_expr @interp, "{ x y -> x.+ y }"
        assert_instance_of  VC::Fun, value

        value = Api.eval_expr @interp, "{ x y -> x.+ y } 3 4"
        assert_instance_of  VCAN::Int, value
        assert_equal        7,         value.val
    end


    def test_lambda_expression_with_declaration
        value = Api.eval_expr @interp, "{ x -> x.+ y where val y=4 }"
        assert_instance_of  VC::Fun, value

        value = Api.eval_expr @interp, "{ x -> x.+ y where val y=4 } 3"
        assert_instance_of  VCAN::Int, value
        assert_equal        7,         value.val
    end
end

end # Umu::Test::T3Language::T31Core::T311AtomicExpression

end # Umu::Test::T3Language::T31Core

end # Umu::Test::T3Language

end # Umu::Test

end # Umu
