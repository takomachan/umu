# frozen_string_literal: true

require "test_helper"


module Umu

module Test

module Grammar

module CoreLanguage

module Pattern

class TupleTest < Minitest::Test
=begin
<tuple-pattern> ::=
    "("
        <variable-pattern> "," <variable-pattern>
        { "," <variable-pattern> }
    ")"
    ;
=end
    def setup
        @interp = Api.setup_interpreter
    end


    def test_value
        interp = Api.eval_decls @interp, <<-EOS
            val (name, price) = (@Apple, 300)
            EOS

        value = Api.eval_expr interp, "name"
        assert_instance_of VCA::Symbol, value
        assert_equal       :Apple,      value.val

        value = Api.eval_expr interp, "price"
        assert_instance_of VCAN::Int, value
        assert_equal       300,       value.val
    end


    def test_value_less_than_rhs
        interp = Api.eval_decls @interp, <<-EOS
            val (name, price) = (@Apple, 300, "Aomori")
            EOS

        value = Api.eval_expr interp, "name"
        assert_instance_of VCA::Symbol, value
        assert_equal       :Apple,      value.val

        value = Api.eval_expr interp, "price"
        assert_instance_of VCAN::Int, value
        assert_equal       300,       value.val
    end


    def test_value_more_than_rhs
        assert_raises(X::SelectionError) do
            Api.eval_decls @interp, <<-EOS
                val (name, price, area) = (@Apple, 300)
                EOS
        end
    end


    def test_value_triple
        interp = Api.eval_decls @interp, <<-EOS
            val (name, price, area) = (@Apple, 300, "Aomori")
            EOS

        value = Api.eval_expr interp, "name"
        assert_instance_of VCA::Symbol, value
        assert_equal       :Apple,      value.val

        value = Api.eval_expr interp, "price"
        assert_instance_of VCAN::Int, value
        assert_equal       300,       value.val

        value = Api.eval_expr interp, "area"
        assert_instance_of VCA::String, value
        assert_equal       "Aomori",    value.val
    end


    def test_value_type
        interp = Api.eval_decls @interp, <<-EOS
            val (name : Symbol, price : Int) = (@Apple, 300)
            EOS

        value = Api.eval_expr interp, "name"
        assert_instance_of VCA::Symbol, value
        assert_equal       :Apple,      value.val

        value = Api.eval_expr interp, "price"
        assert_instance_of VCAN::Int, value
        assert_equal       300,       value.val
    end


    def test_value_type_error
        assert_raises(X::TypeError) do
            Api.eval_decls @interp, <<-EOS
                val (name :Int, price) = (@Apple, 300)
            EOS
        end
    end


    def test_lambda
        value = Api.eval_expr @interp, <<-EOS
            { (x, y) -> x + y } (3, 4)
            EOS
        assert_instance_of VCAN::Int, value
        assert_equal       7,         value.val
    end


    def test_lambda_triple
        value = Api.eval_expr @interp, <<-EOS
            { (x, y, z) -> x + y + z } (3, 4, 5)
            EOS
        assert_instance_of VCAN::Int, value
        assert_equal       12,        value.val
    end


    def test_lambda_type
        value = Api.eval_expr @interp, <<-EOS
            { (x : Int, y : Int) -> x + y } (3, 4)
            EOS
        assert_instance_of VCAN::Int, value
        assert_equal       7,         value.val
    end


    def test_lambda_type_error
        assert_raises(X::TypeError) do
            Api.eval_expr @interp, <<-EOS
                { (x : String, y : Int) -> x + y } (3, 4)
                EOS
        end
    end
end

end # Umu::Test::Grammar::CoreLanguage::Pattern

end # Umu::Test::Grammar::CoreLanguage

end # Umu::Test::Grammar

end # Umu::Test

end # Umu
