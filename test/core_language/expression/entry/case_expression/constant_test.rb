# frozen_string_literal: true

require "test_helper"


module Umu

module Test

module Grammar

module CoreLanguage

module Expression

module Entry

module CaseExpression

class ConstantTest < Minitest::Test
=begin
<case-rule-head-constant> ::= INT | FLOAT | STRING | SYMBOL ;
=end

    def setup
        @interp = Api.setup_interpreter
    end


    def test_int
        script = <<-EOS
            case x of {
              | 0 -> @Z
              | 1 -> @O
            }
            EOS

        value = Api.eval_expr(
            @interp, script, x:VC.make_integer(0)
        )
        assert_instance_of  VCA::Symbol, value
        assert_equal        :Z,          value.val

        value = Api.eval_expr(
            @interp, script, x:VC.make_integer(1)
        )
        assert_instance_of  VCA::Symbol, value
        assert_equal        :O,          value.val
    end


    def test_float
        script = <<-EOS
            case x of {
              | 0.0 -> @Z
              | 0.1 -> @O
            }
            EOS

        value = Api.eval_expr(
            @interp, script, x:VC.make_float(0.0)
        )
        assert_instance_of  VCA::Symbol, value
        assert_equal        :Z,          value.val

        value = Api.eval_expr(
            @interp, script, x:VC.make_float(0.1)
        )
        assert_instance_of  VCA::Symbol, value
        assert_equal        :O,          value.val
    end


    def test_string
        script = <<-EOS
            case x of {
              | "Apple"  -> @A
              | "Banana" -> @B
            }
            EOS

        value = Api.eval_expr(
            @interp, script, x:VC.make_string("Apple")
        )
        assert_instance_of  VCA::Symbol, value
        assert_equal        :A,          value.val

        value = Api.eval_expr(
            @interp, script, x:VC.make_string("Banana")
        )
        assert_instance_of  VCA::Symbol, value
        assert_equal        :B,          value.val
    end


    def test_symbol
        script = <<-EOS
            case x of {
              | @Apple  -> @A
              | @Banana -> @B
            }
            EOS

        value = Api.eval_expr(
            @interp, script, x:VC.make_symbol(:Apple)
        )
        assert_instance_of  VCA::Symbol, value
        assert_equal        :A,          value.val

        value = Api.eval_expr(
            @interp, script, x:VC.make_symbol(:Banana)
        )
        assert_instance_of  VCA::Symbol, value
        assert_equal        :B,          value.val
    end
end

end # Umu::Test::Grammar::CoreLanguage::Expression::Entry::CaseExpression

end # Umu::Test::Grammar::CoreLanguage::Expression::Entry

end # Umu::Test::Grammar::CoreLanguage::Expression

end # Umu::Test::Grammar::CoreLanguage

end # Umu::Test::Grammar

end # Umu::Test

end # Umu
