# frozen_string_literal: true

require "test_helper"


module Umu

module Test

module Grammar

module CoreLanguage

module Expression

module Entry

module CaseExpression

class CaseExpressionTest < Minitest::Test
=begin
<cond-expression> ::=
    CASE <expression> OF "{"
        [ "|" ] <cond-rule>
        { "|" <cond-rule> }
        [ ELSE "->" <expression> ]
    "}"
    ;

<cond-rule> ::= <case-rule-head> "->" <expression> ;

<case-rule-head> ::=
    <case-rule-head-constant>
  | <case-rule-head-datum>
  | <case-rule-head-class>
  | <case-rule-head-poly>
  | <case-rule-head-list>
  | <case-rule-head-cell-stream>
  | <case-rule-head-memo-stream>
=end

    def setup
        @interp = Api.setup_interpreter
    end


    def test_case_expression
        script = <<-EOS
            case x of {
              | 1 -> @P
            }
            EOS

        value = Api.eval_expr(
            @interp, script, x:VC.make_integer(1)
        )
        assert_instance_of  VCA::Symbol, value
        assert_equal        :P,          value.val

        assert_raises(X::UnmatchError) do
            value = Api.eval_expr(
                @interp, script, x:VC.make_integer(0)
            )
        end
    end


    def test_no_vert_bar
        value = Api.eval_expr @interp, <<-EOS
            case 1 of {
                1 -> @P
            }
            EOS
        assert_instance_of  VCA::Symbol, value
        assert_equal        :P,          value.val
    end


    def test_with_else_clause
        script = <<-EOS
            case x of {
                1    -> @P
                else -> @E
            }
            EOS

        value = Api.eval_expr(
            @interp, script, x:VC::make_integer(1)
        )
        assert_instance_of  VCA::Symbol, value
        assert_equal        :P,          value.val

        value = Api.eval_expr(
            @interp, script, x:VC::make_integer(0)
        )
        assert_instance_of  VCA::Symbol, value
        assert_equal        :E,          value.val
    end


    def test_with_rules
        script = <<-EOS
            case x of {
              | 0    -> @Z
              | 1    -> @O
                else -> @E
            }
            EOS

        value = Api.eval_expr(
            @interp, script, x:VC::make_integer(0)
        )
        assert_instance_of  VCA::Symbol, value
        assert_equal        :Z,          value.val

        value = Api.eval_expr(
            @interp, script, x:VC::make_integer(1)
        )
        assert_instance_of  VCA::Symbol, value
        assert_equal        :O,          value.val

        value = Api.eval_expr(
            @interp, script, x:VC::make_integer(2)
        )
        assert_instance_of  VCA::Symbol, value
        assert_equal        :E,          value.val
    end
end

end # Umu::Test::Grammar::CoreLanguage::Expression::Entry::CaseExpression

end # Umu::Test::Grammar::CoreLanguage::Expression::Entry

end # Umu::Test::Grammar::CoreLanguage::Expression

end # Umu::Test::Grammar::CoreLanguage

end # Umu::Test::Grammar

end # Umu::Test

end # Umu
