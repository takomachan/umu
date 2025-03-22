# frozen_string_literal: true

require "test_helper"


module Umu

module Test

module Grammar

module CoreLanguage

module Expression

module Entry

module CaseExpression

class PolyTest < Minitest::Test
=begin
<case-rule-head-poly> ::=
    "&[" "]"
  | "&[" <var-pattern> "|" <var-pattern> "]"
  :
=end

    def setup
        @interp = Api.setup_interpreter

        @nil_value  = VC.make_nil
        @cons_value = VC.make_cons(
                                VC.make_integer(3),
                                VC.make_nil
                            )
    end


    def test_1_nil_cons_else
        script = <<-EOS
            case xs of {
              | %[]      -> Datum @N ()
              | %[x|xs'] -> Datum @C (x, xs')
                else     -> Datum @E ()
            }
            EOS

        assert_raises(X::SyntaxError) do
            Api.eval_expr @interp, script, xs:@nil_value
        end

        assert_raises(X::SyntaxError) do
            Api.eval_expr @interp, script, xs:@cons_value
        end
    end


    def test_2_nil_cons_no_else
        script = <<-EOS
            case xs of {
              | %[]      -> Datum @N ()
              | %[x|xs'] -> Datum @C (x, xs')
            }
            EOS

        value = Api.eval_expr @interp, script, xs:@nil_value
        assert_instance_of VCU::Datum, value
        assert_equal       :N,         value.tag_sym

        value = Api.eval_expr @interp, script, xs:@cons_value
        assert_instance_of VCU::Datum, value
        assert_equal       :C,         value.tag_sym
        assert_instance_of VCP::Tuple, value.contents

        head_value, tail_value = value.contents.values
        assert_instance_of VCAN::Int,      head_value
        assert_equal       3,              head_value.val
        assert_instance_of VCM::List::Nil, tail_value
    end


    def test_3_nil_no_cons_else
        script = <<-EOS
            case xs of {
                %[]  -> Datum @N ()
                else -> Datum @E ()
            }
            EOS

        value = Api.eval_expr @interp, script, xs:@nil_value
        assert_instance_of VCU::Datum, value
        assert_equal       :N,         value.tag_sym

        value = Api.eval_expr @interp, script, xs:@cons_value
        assert_instance_of VCU::Datum, value
        assert_equal       :E,         value.tag_sym
    end


    def test_4_nil_no_cons_no_else
        script = <<-EOS
            case xs of {
                %[]  -> Datum @N ()
            }
            EOS

        value = Api.eval_expr @interp, script, xs:@nil_value
        assert_instance_of VCU::Datum, value
        assert_equal       :N,         value.tag_sym

        assert_raises(X::UnmatchError) do
            value = Api.eval_expr @interp, script, xs:@cons_value
        end
    end


    def test_5_no_nil_cons_else
        script = <<-EOS
            case xs of {
              | %[x|xs'] -> Datum @C (x, xs')
                else     -> Datum @E ()
            }
            EOS

        value = Api.eval_expr @interp, script, xs:@nil_value
        assert_instance_of VCU::Datum, value
        assert_equal       :E,         value.tag_sym

        value = Api.eval_expr @interp, script, xs:@cons_value
        assert_instance_of VCU::Datum, value
        assert_equal       :C,         value.tag_sym
        assert_instance_of VCP::Tuple, value.contents

        head_value, tail_value = value.contents.values
        assert_instance_of VCAN::Int,      head_value
        assert_equal       3,              head_value.val
        assert_instance_of VCM::List::Nil, tail_value
    end


    def test_6_no_nil_cons_no_else
        script = <<-EOS
            case xs of {
                %[x|xs'] -> Datum @C (x, xs')
            }
            EOS

        assert_raises(X::UnmatchError) do
            Api.eval_expr @interp, script, xs:@nil_value
        end
    end


    def test_7_no_nil_no_cons
        script = <<-EOS
            case xs of {
                else -> Datum @E ()
            }
            EOS

        assert_raises(X::SyntaxError) do
            Api.eval_expr @interp, script, xs:@nil_value
        end
    end
end

end # Umu::Test::Grammar::CoreLanguage::Expression::Entry::CaseExpression

end # Umu::Test::Grammar::CoreLanguage::Expression::Entry

end # Umu::Test::Grammar::CoreLanguage::Expression

end # Umu::Test::Grammar::CoreLanguage

end # Umu::Test::Grammar

end # Umu::Test

end # Umu
