# frozen_string_literal: true

require "test_helper"


module Umu

module Test

module Grammar

module CoreLanguage

module Pattern

class ListTest < Minitest::Test
=begin
<list-pattern> ::=
    "[" "]"
  | "["
        <variable-pattern> { "," <variable-pattern> }
        [ "|" <variable-pattern> ]
    "]"
    ;
=end
    def setup
        @interp = Api.setup_interpreter
    end


    def test_value_empty
        assert (
            Api.eval_decls @interp, <<-EOS
                val [] = []
                EOS
        )
    end


    def test_value_empty_error
        assert_raises(X::TypeError) do
            Api.eval_decls @interp, <<-EOS
                val [] = [3]
                EOS
        end
    end


    def test_value_singleton
        interp = Api.eval_decls @interp, <<-EOS
            val [x] = [3]
            EOS

        value = Api.eval_expr interp, "x"
        assert_instance_of VCAN::Int, value
        assert_equal       3,         value.val
    end


    def test_value
        interp = Api.eval_decls @interp, <<-EOS
            val [x, y] = [3, 4]
            EOS

        value = Api.eval_expr interp, "x"
        assert_instance_of VCAN::Int, value
        assert_equal       3,         value.val

        value = Api.eval_expr interp, "y"
        assert_instance_of VCAN::Int, value
        assert_equal       4,         value.val
    end


    def test_value_with_last_1
        interp = Api.eval_decls @interp, <<-EOS
            val [x|xs] = [3]
            EOS

        value = Api.eval_expr interp, "x"
        assert_instance_of VCAN::Int, value
        assert_equal       3,         value.val

        value = Api.eval_expr interp, "xs"
        assert_instance_of VCM::List::Nil, value
    end


    def test_value_with_last_2
        interp = Api.eval_decls @interp, <<-EOS
            val [x|xs] = [3, 4]
            EOS

        value = Api.eval_expr interp, "x"
        assert_instance_of VCAN::Int, value
        assert_equal       3,         value.val

        value = Api.eval_expr interp, "xs"
        assert_instance_of VCM::List::Cons, value
        assert_instance_of VCAN::Int,       value.head
        assert_equal       4,               value.head.val
        assert_instance_of VCM::List::Nil,  value.tail
    end


    def test_value_with_last_empty_error
        assert_raises(X::EmptyError) do
            Api.eval_decls @interp, <<-EOS
                val [x, y|xs] = [3]
                EOS
        end
    end


    def test_value_less_than_rhs
        assert_raises(X::TypeError) do
            Api.eval_decls @interp, <<-EOS
                val [x] = [3, 4]
                EOS
        end
    end


    def test_value_more_than_rhs
        assert_raises(X::EmptyError) do
            Api.eval_decls @interp, <<-EOS
                val [x, y, z] = [3, 4]
                EOS
        end
    end


    def test_value_type
        interp = Api.eval_decls @interp, <<-EOS
            val [x : Int|xs] = [3, 4]
            EOS

        value = Api.eval_expr interp, "x"
        assert_instance_of VCAN::Int, value
        assert_equal       3,         value.val

        value = Api.eval_expr interp, "xs"
        assert_instance_of VCM::List::Cons, value
    end


    def test_value_type_error
        assert_raises(X::TypeError) do
            Api.eval_decls @interp, <<-EOS
                val [x : String|xs] = [3, 4]
                EOS
        end
    end


    def test_value_syntax_error
        assert_raises(X::SyntaxError) do
            Api.eval_decls @interp, <<-EOS
                val [x|xs : List] = [3, 4]
                EOS
        end
    end


    def test_lambda
        value = Api.eval_expr @interp, <<-EOS
            { [x, y] -> x + y } [3, 4]
            EOS
        assert_instance_of VCAN::Int, value
        assert_equal       7,         value.val
    end


    def test_lambda_empty
        value = Api.eval_expr @interp, <<-EOS
            { [] -> 3 } []
            EOS
        assert_instance_of VCAN::Int, value
        assert_equal       3,         value.val
    end


    def test_lambda_empty_error_nil
        assert_raises(X::TypeError) do
            Api.eval_expr @interp, <<-EOS
                { [] -> 3 } 4
            EOS
        end
    end


    def test_lambda_singleton
        value = Api.eval_expr @interp, <<-EOS
            { [x] -> x + 4 } [3]
            EOS
        assert_instance_of VCAN::Int, value
        assert_equal       7,         value.val
    end


    def test_lambda_with_last_1
        value = Api.eval_expr @interp, <<-EOS
            { [x|xs] -> (x, xs) } [3]
            EOS
        assert_instance_of VCP::Tuple, value
        assert_equal       2,          value.arity

        head_value, tail_value = value.values
        assert_instance_of VCAN::Int,      head_value
        assert_equal       3,              head_value.val
        assert_instance_of VCM::List::Nil, tail_value
    end


    def test_lambda_with_last_2
        value = Api.eval_expr @interp, <<-EOS
            { [x|xs] -> (x, xs) } [3, 4]
            EOS
        assert_instance_of VCP::Tuple, value
        assert_equal       2,          value.arity

        head_value, tail_value = value.values

        assert_instance_of VCAN::Int,       head_value
        assert_equal       3,               head_value.val

        assert_instance_of VCM::List::Cons, tail_value
        assert_instance_of VCAN::Int,       tail_value.head
        assert_equal       4,               tail_value.head.val
        assert_instance_of VCM::List::Nil,  tail_value.tail
    end


    def test_lambda_empty_error_cons
        assert_raises(X::EmptyError) do
            Api.eval_expr @interp, <<-EOS
                { [x, y|xs] -> (x, y, xs) } [3]
            EOS
        end
    end


    def test_lambda_less_than_rhs
        assert_raises(X::TypeError) do
            Api.eval_expr @interp, <<-EOS
                { [x] -> x } [3, 4]
            EOS
        end
    end


    def test_lambda_more_than_rhs
        assert_raises(X::EmptyError) do
            Api.eval_expr @interp, <<-EOS
                { [x, y, z] -> x } [3, 4]
            EOS
        end
    end


    def test_lambda_type
        value = Api.eval_expr @interp, <<-EOS
            { [x : Int|xs] -> (x, xs) } [3, 4]
            EOS
        assert_instance_of VCP::Tuple, value
        assert_equal       2,          value.arity

        head_value, tail_value = value.values
        assert_instance_of VCAN::Int,       head_value
        assert_equal       3,               head_value.val
        assert_instance_of VCM::List::Cons, tail_value
    end


    def test_lambda_type_error
        assert_raises(X::TypeError) do
            Api.eval_expr @interp, <<-EOS
                { [x : String|xs] -> (x, xs) } [3, 4]
            EOS
        end
    end


    def test_lambda_syntax_error
        assert_raises(X::SyntaxError) do
            Api.eval_expr @interp, <<-EOS
                { [x|xs : List] -> (x, xs) } [3, 4]
            EOS
        end
    end
end

end # Umu::Test::Grammar::CoreLanguage::Pattern

end # Umu::Test::Grammar::CoreLanguage

end # Umu::Test::Grammar

end # Umu::Test

end # Umu
