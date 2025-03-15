# frozen_string_literal: true

require "test_helper"


module Umu

module Test

module Grammar

module CoreLanguage

module Expression

module Entry

module CaseExpression

class DatumTest < Minitest::Test
=begin
<case-rule-head-datum> ::= ID [ <pattern> ] ;
=end

    def setup
        @interp = Api.setup_interpreter
    end


    def test_class
        script = <<-EOS
            case x of {
              | Apple  -> @A
              | Banana -> @B
            }
            EOS

        value = Api.eval_expr(
            @interp, script, x:VC.make_datum(:Apple, VC.make_unit)
        )
        assert_instance_of  VCA::Symbol, value
        assert_equal        :A,          value.val

        value = Api.eval_expr(
            @interp, script, x:VC.make_datum(:Banana, VC.make_unit)
        )
        assert_instance_of  VCA::Symbol, value
        assert_equal        :B,          value.val
    end


    def test_with_contents
        script = <<-EOS
            case x of {
              | Apple  price -> price
              | Banana price -> price
            }
            EOS

        value = Api.eval_expr(
            @interp, script, x:VC.make_datum(:Apple, VC.make_integer(300))
        )
        assert_instance_of  VCAN::Int, value
        assert_equal        300,       value.val

        value = Api.eval_expr(
            @interp, script, x:VC.make_datum(:Banana, VC.make_integer(500))
        )
        assert_instance_of  VCAN::Int, value
        assert_equal        500,       value.val
    end
end

end # Umu::Test::Grammar::CoreLanguage::Expression::Entry::CaseExpression

end # Umu::Test::Grammar::CoreLanguage::Expression::Entry

end # Umu::Test::Grammar::CoreLanguage::Expression

end # Umu::Test::Grammar::CoreLanguage

end # Umu::Test::Grammar

end # Umu::Test

end # Umu
