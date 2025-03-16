# frozen_string_literal: true

require "test_helper"


module Umu

module Test

module Grammar

module CoreLanguage

module Pattern

module Variable
=begin
<variable-pattern> ::=
    <basic-variable-pattern>
  | <wildcard-pattern>
  | <braket-variable-pattern>
  | <infix-operator-pattern>
  ;
=end

class BasicTest < Minitest::Test
=begin
<basic-variable-pattern> ::= ID [ ":" ID ] ; ;
=end
    def setup
        @interp = Api.setup_interpreter
    end


    def test_value
        interp = Api.eval_decls @interp, "val x = 3"

        value = Api.eval_expr interp, "x"
        assert_instance_of VCAN::Int, value
        assert_equal       3,         value.val
    end


    def test_value_with_type
        interp = Api.eval_decls @interp, "val x : Int = 3"

        value = Api.eval_expr interp, "x"
        assert_instance_of VCAN::Int, value
        assert_equal       3,         value.val
    end


    def test_value_with_type_error
        assert_raises(X::TypeError) do
            Api.eval_decls @interp, "val x : String = 3"
        end
    end


    def test_lambda
        value = Api.eval_expr @interp, "{ x -> x + 4 } 3"
        assert_instance_of VCAN::Int, value
        assert_equal       7,         value.val
    end


    def test_lambda_with_type
        value = Api.eval_expr @interp, "{ x : Int -> x + 4 } 3"
        assert_instance_of VCAN::Int, value
        assert_equal       7,         value.val
    end


    def test_lambda_with_type_error
        assert_raises(X::TypeError) do
            Api.eval_expr @interp, "{ x : String -> x + 4 } 3"
        end
    end
end



class WildcardTest < Minitest::Test
=begin
<wildcard-pattern> ::= "_" [ ":" ID ] ;
=end
    def setup
        @interp = Api.setup_interpreter
    end


    def test_value
        assert (
            Api.eval_decls @interp, "val _ = 3"
        )
    end


    def test_value_with_type
        assert (
            Api.eval_decls @interp, "val _ : Int = 3"
        )
    end


    def test_value_with_type_error
        assert_raises(X::TypeError) do
            Api.eval_decls @interp, "val _ : String = 3"
        end
    end


    def test_lambda
        value = Api.eval_expr @interp, "{ _ -> 4 } 3"
        assert_instance_of VCAN::Int, value
        assert_equal       4,         value.val
    end


    def test_lambda_with_type
        value = Api.eval_expr @interp, "{ _ : Int -> 4 } 3"
        assert_instance_of VCAN::Int, value
        assert_equal       4,         value.val
    end


    def test_lambda_with_type_error
        assert_raises(X::TypeError) do
            Api.eval_expr @interp, "{ _ : String -> 4 } 3"
        end
    end
end



class BraketTest < Minitest::Test
=begin
<basic-variable-pattern> ::= ID [ ":" ID ] ; ;
=end
    def setup
        @interp = Api.setup_interpreter
    end


    def test_value
        interp = Api.eval_decls @interp, "val (x) = 3"

        value = Api.eval_expr interp, "x"
        assert_instance_of VCAN::Int, value
        assert_equal       3,         value.val
    end


    def test_lambda
        value = Api.eval_expr @interp, "{ (x) -> x + 4 } 3"
        assert_instance_of VCAN::Int, value
        assert_equal       7,         value.val
    end
end



class InfixOperatorTest < Minitest::Test
=begin
<infix-operator-pattern> ::= "(" <infix-operator> ")" ;

/* <infix-operator> ::= ... ;
        See IdentifierTest (Expression::Atomic) */
=end
    def setup
        @interp = Api.setup_interpreter
    end


    def test_value
        interp = Api.eval_decls @interp, "val (*) = (+)"

        value = Api.eval_expr interp, "3 * 4"
        assert_instance_of VCAN::Int, value
        assert_equal       7,         value.val
    end


    def test_lambda
        value = Api.eval_expr @interp, "{ (*) -> 3 * 4 } (+)"
        assert_instance_of VCAN::Int, value
        assert_equal       7,         value.val
    end
end

end # Umu::Test::Grammar::CoreLanguage::Pattern::Variable

end # Umu::Test::Grammar::CoreLanguage::Pattern

end # Umu::Test::Grammar::CoreLanguage

end # Umu::Test::Grammar

end # Umu::Test

end # Umu
