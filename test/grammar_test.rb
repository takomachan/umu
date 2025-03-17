# frozen_string_literal: true

require "test_helper"


module Umu

module Test

module Grammar

class GrammarTest < Minitest::Test
=begin
<entry> ::= <statement> { ";;" <statement> } ;

<statement> ::=
    { <md-module-declaration> }
  | <expression>
  ;
=end
    def setup
        @interp = Api.setup_interpreter
    end


    def test_empty_declaration
        assert (
            Api.eval_decls @interp, ""
        )
    end


    def test_empty_expression
        assert_nil (
            Api.eval_expr @interp, ""
        )
    end


    def test_single_declaration
        assert (
            Api.eval_decls @interp, "val x = 3"
        )
    end


    def test_some_declarations
        assert (
            Api.eval_decls @interp, "val x = 3 val y = 4"
        )
    end


    def test_expression
        value = Api.eval_expr @interp, "3"
        assert_instance_of VCAN::Int, value
        assert_equal       3,         value.val
    end


    def test_declarations_followed_by_expression
        value = Api.eval_expr @interp, <<-EOS
            val x = 3
            val y = 4
            ;;
            x + y
            EOS
        assert_instance_of VCAN::Int, value
        assert_equal       7,         value.val
    end


    def test_expression_followed_by_declaration
        interp = Api.eval_decls @interp, <<-EOS
            3
            ;;
            val y = 4
            EOS

        value = Api.eval_expr interp, "y"
        assert_instance_of VCAN::Int, value
        assert_equal       4,         value.val
    end


    def test_some_expressions
        value = Api.eval_expr @interp, <<-EOS
                3
                ;;
                4
            EOS

        assert_instance_of VCAN::Int, value
        assert_equal       4,         value.val
    end
end

end # Umu::Test::Grammar

end # Umu::Test

end # Umu
