# frozen_string_literal: true

require "test_helper"


module Umu

module Test

module Grammar

module CoreLanguage

module Pattern

class NamedTupleTest < Minitest::Test
=begin
<named-tuple-pattern> ::=
    "("
        <field-pattern> { <field-pattern> }
    ")"
    ;

<field-pattern> ::= LABEL [ <variable-pattern> ] ;

/* <variable-pattern> ::= ... ;  See Variable */
=end
    def setup
        @interp = Api.setup_interpreter
    end


    def test_value
        interp = Api.eval_decls @interp, <<-EOS
            val (name:n price:p) = (name:@Apple price:300)
            EOS

        value = Api.eval_expr interp, "n"
        assert_instance_of VCA::Symbol, value
        assert_equal       :Apple,      value.val

        value = Api.eval_expr interp, "p"
        assert_instance_of VCAN::Int, value
        assert_equal       300,       value.val
    end


    def test_value_swap
        interp = Api.eval_decls @interp, <<-EOS
            val (price:p name:n) = (name:@Apple price:300)
            EOS

        value = Api.eval_expr interp, "p"
        assert_instance_of VCAN::Int, value
        assert_equal       300,       value.val

        value = Api.eval_expr interp, "n"
        assert_instance_of VCA::Symbol, value
        assert_equal       :Apple,      value.val
    end


    def test_value_less_than_rhs
        interp = Api.eval_decls @interp, <<-EOS
            val (name:n) = (name:@Apple price:300)
            EOS

        value = Api.eval_expr interp, "n"
        assert_instance_of VCA::Symbol, value
        assert_equal       :Apple,      value.val
    end


    def test_value_more_than_rhs
        assert_raises(X::SelectionError) do
            Api.eval_decls @interp, <<-EOS
                val (name:n price:p area:a) = (name:@Apple price:300)
                EOS
        end
    end


    def test_value_triple
        interp = Api.eval_decls @interp, <<-EOS
            val (name:n price:p area:a) =
                    (name:@Apple price:300 area:"Aomori")
            EOS

        value = Api.eval_expr interp, "n"
        assert_instance_of VCA::Symbol, value
        assert_equal       :Apple,      value.val

        value = Api.eval_expr interp, "p"
        assert_instance_of VCAN::Int, value
        assert_equal       300,       value.val

        value = Api.eval_expr interp, "a"
        assert_instance_of VCA::String, value
        assert_equal       "Aomori",    value.val
    end


    def test_value_none_variable
        interp = Api.eval_decls @interp, <<-EOS
            val (name: price:) = (name:@Apple price:300)
            EOS

        value = Api.eval_expr interp, "name"
        assert_instance_of VCA::Symbol, value
        assert_equal       :Apple,      value.val

        value = Api.eval_expr interp, "price"
        assert_instance_of VCAN::Int, value
        assert_equal       300,       value.val
    end


    def test_value_type
        interp = Api.eval_decls @interp, <<-EOS
            val (name:n : Symbol price:p : Int) =
                    (name:@Apple price:300)
            EOS

        value = Api.eval_expr interp, "n"
        assert_instance_of VCA::Symbol, value
        assert_equal       :Apple,      value.val

        value = Api.eval_expr interp, "p"
        assert_instance_of VCAN::Int, value
        assert_equal       300,       value.val
    end


    def test_should_be_kind_of_specified_type_in_declaration
        assert_raises(X::TypeError) do
                Api.eval_decls @interp, <<-EOS
                    val (name:n : Unit price:p : Int) =
                             (name:@Apple price:300)
                EOS
        end
    end


    def test_lambda
        value = Api.eval_expr @interp, <<-EOS
            { (x:x y:y) -> x + y } (x:3 y:4)
            EOS
        assert_instance_of VCAN::Int, value
        assert_equal       7,         value.val
    end


    def test_lambda_swap
        value = Api.eval_expr @interp, <<-EOS
            { (y:y x:x) -> x + y } (x:3 y:4)
            EOS
        assert_instance_of VCAN::Int, value
        assert_equal       7,         value.val
    end


    def test_lambda_less_than_param
        value = Api.eval_expr @interp, <<-EOS
            { (x:x) -> x + 5 } (x:3 y:4)
            EOS
        assert_instance_of VCAN::Int, value
        assert_equal       8,         value.val
    end


    def test_lambda_more_than_param
        assert_raises(X::SelectionError) do
            Api.eval_expr @interp, <<-EOS
                { (x:x y:y z:z) -> x + y + z } (x:3 y:4)
                EOS
        end
    end


    def test_lambda_triple
        value = Api.eval_expr @interp, <<-EOS
            { (x:x y:y z:z) -> x + y + z } (x:3 y:4 z:5)
            EOS
        assert_instance_of VCAN::Int, value
        assert_equal       12,        value.val
    end


    def test_lambda_none_variable
        value = Api.eval_expr @interp, <<-EOS
            { (x: y:) -> x + y } (x:3 y:4)
            EOS
        assert_instance_of VCAN::Int, value
        assert_equal       7,         value.val
    end


    def test_lambda_type
        value = Api.eval_expr @interp, <<-EOS
            { (x:x : Int y:y : Int) -> x + y } (x:3 y:4)
            EOS
        assert_instance_of VCAN::Int, value
        assert_equal       7,         value.val
    end


    def test_should_be_kind_of_specified_type_in_lambda
        assert_raises(X::TypeError) do
            Api.eval_expr @interp, <<-EOS
                { (x:x : String y:y : Int) -> x + y } (x:3 y:4)
                EOS
        end
    end
end

end # Umu::Test::Grammar::CoreLanguage::Pattern

end # Umu::Test::Grammar::CoreLanguage

end # Umu::Test::Grammar

end # Umu::Test

end # Umu
