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


    def test_let_expression
        value = Api.eval_expr @interp, "let { in 1 }"
        assert_instance_of  VCAN::Int, value
        assert_equal        1,         value.val

        value = Api.eval_expr @interp, "let { val x = 1 in x }"
        assert_instance_of  VCAN::Int, value
        assert_equal        1,         value.val
    end
end

end # Umu::Test::Grammar::CoreLanguage::Expression::Entry

end # Umu::Test::Grammar::CoreLanguage::Expression

end # Umu::Test::Grammar::CoreLanguage

end # Umu::Test::Grammar

end # Umu::Test

end # Umu
