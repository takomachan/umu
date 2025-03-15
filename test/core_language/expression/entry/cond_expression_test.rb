# frozen_string_literal: true

require "test_helper"


module Umu

module Test

module Grammar

module CoreLanguage

module Expression

module Entry

class CondExpressionTest < Minitest::Test
=begin
<cond-expression> ::=
    COND <expression> OF "{"
        [ "|" ] <cond-rule>
        { "|" <cond-rule> }
        [ ELSE "->" <expression> ]
    "}"
    ;

<cond-rule> ::= <expression> "->" <expression> ;
=end


    def setup
        @interp = Api.setup_interpreter
    end


    def test_cond_expression
        script = <<-EOS
            cond x of {
              | positive? -> @P
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
            cond 1 of {
                positive? -> @P
            }
            EOS
        assert_instance_of  VCA::Symbol, value
        assert_equal        :P,          value.val
    end


    def test_with_else_clause
        script = <<-EOS
            cond x of {
                positive? -> @P
                else      -> @E
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
            cond x of {
              | positive? -> @P
              | zero?     -> @Z
              | negative? -> @N
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
        assert_equal        :Z,          value.val

        value = Api.eval_expr(
            @interp, script, x:VC::make_integer(-1)
        )
        assert_instance_of  VCA::Symbol, value
        assert_equal        :N,          value.val
    end
end

end # Umu::Test::Grammar::CoreLanguage::Expression::Entry

end # Umu::Test::Grammar::CoreLanguage::Expression

end # Umu::Test::Grammar::CoreLanguage

end # Umu::Test::Grammar

end # Umu::Test

end # Umu
