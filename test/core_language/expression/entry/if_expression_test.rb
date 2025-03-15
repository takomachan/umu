# frozen_string_literal: true

require "test_helper"


module Umu

module Test

module Grammar

module CoreLanguage

module Expression

module Entry

class IfExpressionTest < Minitest::Test
=begin
<if-expression> ::=
    IF <if-rule> { <elsif-rule> } ELSE <expression> ;

<elsif-rule> ::= "ELSIF" <if-rule> ;
<if-rule>    ::= <expression> THEN <expression> ;
=end


    def setup
        @interp = Api.setup_interpreter
    end


    def test_if_expression
        value = Api.eval_expr @interp, "if TRUE then 1 else 2"
        assert_instance_of  VCAN::Int, value
        assert_equal        1,         value.val

        value = Api.eval_expr @interp, "if FALSE then 1 else 2"
        assert_instance_of  VCAN::Int, value
        assert_equal        2,         value.val
    end


    def test_with_elsif
        value = Api.eval_expr @interp, <<-EOS
            if TRUE then 1 elsif TRUE then 2 else 3
            EOS
        assert_instance_of  VCAN::Int, value
        assert_equal        1,         value.val

        value = Api.eval_expr @interp, <<-EOS
            if FALSE then 1 elsif TRUE then 2 else 3
            EOS
        assert_instance_of  VCAN::Int, value
        assert_equal        2,         value.val

        value = Api.eval_expr @interp, <<-EOS
            if FALSE then 1 elsif FALSE then 2 else 3
            EOS
        assert_instance_of  VCAN::Int, value
        assert_equal        3,         value.val

        value = Api.eval_expr @interp, <<-EOS
            if TRUE then 1 elsif FALSE then 2 else 3
            EOS
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
