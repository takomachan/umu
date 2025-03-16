# frozen_string_literal: true

require "test_helper"


module Umu

module Test

module Grammar

module CoreLanguage

module Expression

module Entry

class LetExpressionTest < Minitest::Test
=begin
<let-expression> ::=
    LET "{" { <declaration> } IN <expression> "}" ;
=end


    def setup
        @interp = Api.setup_interpreter
    end


    def test_with_empty_declaration
        value = Api.eval_expr @interp, "let { in 1 }"
        assert_instance_of  VCAN::Int, value
        assert_equal        1,         value.val
    end


    def test_with_single_declaration
        value = Api.eval_expr @interp, "let { val x = 1 in x }"
        assert_instance_of  VCAN::Int, value
        assert_equal        1,         value.val
    end


    def test_with_some_declarations
        value = Api.eval_expr @interp, <<-EOS
            let {
                val x = 3
                val y = 4
            in
                x + y
            }
            EOS
        assert_instance_of  VCAN::Int, value
        assert_equal        7,         value.val
    end


    def test_shadowing
        value = Api.eval_expr @interp, <<-EOS
            let {
                val x = 3
                val x = 4
            in
                x
            }
            EOS
        assert_instance_of  VCAN::Int, value
        assert_equal        4,         value.val
    end


    def test_nesting
        value = Api.eval_expr @interp, <<-EOS
            let {
                val x = 3
            in
                let {
                    val y = 4
                in
                    x + y
                }
            }
            EOS
        assert_instance_of  VCAN::Int, value
        assert_equal        7,         value.val
    end


    def test_nesting_and_shadowing_1
        value = Api.eval_expr @interp, <<-EOS
            let {
                val x = 3
            in
                let {
                    val x = 4
                in
                    x
                }
            }
            EOS
        assert_instance_of  VCAN::Int, value
        assert_equal        4,         value.val
    end


    def test_nesting_and_shadowing_2
        value = Api.eval_expr @interp, <<-EOS
            let {
                val x = 3
            in
                let {
                    val y = x
                    val x = 4
                in
                    x + y
                }
            }
            EOS
        assert_instance_of  VCAN::Int, value
        assert_equal        7,         value.val
    end
end

end # Umu::Test::Grammar::CoreLanguage::Expression::Entry

end # Umu::Test::Grammar::CoreLanguage::Expression

end # Umu::Test::Grammar::CoreLanguage

end # Umu::Test::Grammar

end # Umu::Test

end # Umu
