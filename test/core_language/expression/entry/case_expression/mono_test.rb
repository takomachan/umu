# frozen_string_literal: true

require "test_helper"


module Umu

module Test

module Grammar

module CoreLanguage

module Expression

module Entry

module CaseExpression

class MonoTest < Minitest::Test
=begin
<case-rule-head-list> ::=
    "[" "]"
  | "[" <var-pattern> "|" <var-pattern> "]"
  ;

<case-rule-head-cell-stream> ::=
    "&[" "]"
  | "&[" <var-pattern> "|" <var-pattern> "]"
  ;

<case-rule-head-memo-stream> ::=
    "&{" "}"
  | "&{" <var-pattern> "|" <var-pattern> "}"
  ;
=end

    def setup
        @interp = Api.setup_interpreter

        @loc = LOC.make_location __FILE__, __LINE__
    end


    def test_list
        script = <<-EOS
            case xs of {
              | []      -> Datum @N ()
              | [x|xs'] -> Datum @C (x, xs')
            }
            EOS

        value = Api.eval_expr(
                        @interp, script, xs:VC.make_nil
                    )
        assert_instance_of VCU::Datum, value
        assert_equal       :N,         value.tag_sym

        value = Api.eval_expr(
                        @interp,
                        script,
                        xs:VC.make_cons(VC.make_integer(3), VC.make_nil)
                    )
        assert_instance_of VCU::Datum, value
        assert_equal       :C,         value.tag_sym
        assert_instance_of VCP::Tuple, value.contents

        head_value, tail_value = value.contents.values
        assert_instance_of VCAN::Int,      head_value
        assert_equal       3,              head_value.val
        assert_instance_of VCM::List::Nil, tail_value
    end


    def test_cell_stream
        script = <<-EOS
            val ys = case xs of {
                       | &[]      -> Datum @N ()
                       | &[x|xs'] -> Datum @C (x, xs')
                     }
            EOS

        interp_1 = Api.eval_decls(
                        @interp,
                        script,
                        xs:VC.make_cell_stream_nil(
                            Api.va_context(@interp)
                        )
                    )
        value_1 = Api.eval_expr interp_1, "ys"
        assert_instance_of VCU::Datum, value_1
        assert_equal       :N,         value_1.tag_sym

        interp_2 = Api.eval_decls(
                        @interp,
                        script,
                        xs:VC.make_cell_stream_cons(
                            ASCE.make_integer(@loc, 3),
                            VC.make_cell_stream_nil(
                                Api.va_context(@interp)
                            ),
                            Api.va_context(@interp)
                        )
                    )
        value_2 = Api.eval_expr interp_2, "ys"
        assert_instance_of VCU::Datum, value_2
        assert_equal       :C,         value_2.tag_sym
        assert_instance_of VCP::Tuple, value_2.contents

        interp_3 = Api.eval_decls interp_2, "val (hd, tl) = ys.contents"
        head_value = Api.eval_expr interp_3, "hd"
        tail_value = Api.eval_expr interp_3, "tl"

        assert_instance_of VCAN::Int,                head_value
        assert_equal       3,                        head_value.val
        assert_instance_of VCM::Stream::Entry::Cell, tail_value
        assert_instance_of VCM::Stream::Cell::Nil,   tail_value.cell
    end


    def test_memo_stream
        script = <<-EOS
            val ys = case xs of {
                       | &{}      -> Datum @N ()
                       | &{x|xs'} -> Datum @C (x, xs')
                     }
            EOS

        interp_1 = Api.eval_decls(
                        @interp,
                        script,
                        xs:VC.make_memo_stream_nil(
                            Api.va_context(@interp)
                        )
                    )
        value_1 = Api.eval_expr interp_1, "ys"
        assert_instance_of VCU::Datum, value_1
        assert_equal       :N,         value_1.tag_sym

        interp_2 = Api.eval_decls(
                        @interp,

                        script,

                        xs:VC.make_memo_stream_entry(
                            ASCE.make_memo_stream_cons(
                                @loc,
                                ASCE.make_integer(@loc, 3),
                                ASCE.make_memo_stream_nil(@loc)
                            ),

                            Api.va_context(@interp)
                        )
                    )
        value_2 = Api.eval_expr interp_2, "ys"
        assert_instance_of VCU::Datum, value_2
        assert_equal       :C,         value_2.tag_sym
        assert_instance_of VCP::Tuple, value_2.contents

        interp_3 = Api.eval_decls interp_2, "val (hd, tl) = ys.contents"
        head_value = Api.eval_expr interp_3, "hd"
        tail_value = Api.eval_expr interp_3, "tl"

        assert_instance_of VCAN::Int,                        head_value
        assert_equal       3,                                head_value.val
        assert_instance_of VCM::Stream::Entry::Memorization, tail_value

        forced_value_2 = Api.eval_expr interp_3, "tl.force"
        assert_instance_of VCU::Option::None, forced_value_2
    end
end

end # Umu::Test::Grammar::CoreLanguage::Expression::Entry::CaseExpression

end # Umu::Test::Grammar::CoreLanguage::Expression::Entry

end # Umu::Test::Grammar::CoreLanguage::Expression

end # Umu::Test::Grammar::CoreLanguage

end # Umu::Test::Grammar

end # Umu::Test

end # Umu
