# frozen_string_literal: true

require "test_helper"


module Umu

module Test

module Grammar

module CoreLanguage

module Expression

module Entry

module CaseExpression

class ClassTest < Minitest::Test
=begin
<case-rule-head-class> ::= "&" ID [ <pattern> ] ;
=end

    def setup
        @interp = Api.setup_interpreter
    end


    def test_class
        script = <<-EOS
            case x of {
              | &Int   -> @I
              | &Float -> @F
            }
            EOS

        value = Api.eval_expr(
            @interp, script, x:VC.make_integer(1)
        )
        assert_instance_of  VCA::Symbol, value
        assert_equal        :I,          value.val

        value = Api.eval_expr(
            @interp, script, x:VC.make_float(1.0)
        )
        assert_instance_of  VCA::Symbol, value
        assert_equal        :F,          value.val
    end


    def test_with_contents
        script = <<-EOS
            case x of {
              | &Some c -> c
              | &None   -> "NONE"
            }
            EOS

        value = Api.eval_expr(
            @interp, script, x:VC.make_some(VC.make_string("Apple"))
        )
        assert_instance_of  VCA::String, value
        assert_equal        "Apple",     value.val

        value = Api.eval_expr(
            @interp, script, x:VC.make_none
        )
        assert_instance_of  VCA::String, value
        assert_equal        "NONE",      value.val
    end
end

end # Umu::Test::Grammar::CoreLanguage::Expression::Entry::CaseExpression

end # Umu::Test::Grammar::CoreLanguage::Expression::Entry

end # Umu::Test::Grammar::CoreLanguage::Expression

end # Umu::Test::Grammar::CoreLanguage

end # Umu::Test::Grammar

end # Umu::Test

end # Umu
