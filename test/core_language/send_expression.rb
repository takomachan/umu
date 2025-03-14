# frozen_string_literal: true

require "test_helper"


module Umu

module Test

module Grammar

module CoreLanguage

module SendExpression
=begin
<send-expression> ::=
    <apply-expression> { <message> } ;

<message> ::=
    <basic-message>
  | <infix-message>
  | <apply-message>
  | <keyword-message>
  ;
=end

class BasicMessageTest < Minitest::Test
=begin
<basic-message> ::=
    MSG { <product-expression> }
  | ".(" ID { <product-expression> } ")"
  ;
=end
    def setup
        @interp = Api.setup_interpreter
    end


    def test_basic_message_1
        value = Api.eval_expr @interp, "3.show"
        assert_instance_of VCA::String, value
        assert_equal       "3",         value.val

        value = Api.eval_expr @interp, "1.to 9"
        assert_instance_of VCM::Interval, value
        assert_equal       1,             value.current_value.val
        assert_equal       9,             value.stop_value.val

        value = Api.eval_expr @interp, "1.to-by 9 2"
        assert_instance_of VCM::Interval, value
        assert_equal       1,             value.current_value.val
        assert_equal       9,             value.stop_value.val
        assert_equal       2,             value.step_value.val
    end


    def test_basic_message_2
        value = Api.eval_expr @interp, "3.(show)"
        assert_instance_of VCA::String, value
        assert_equal       "3",         value.val

        value = Api.eval_expr @interp, "1.(to 9)"
        assert_instance_of VCM::Interval, value
        assert_equal       1,             value.current_value.val
        assert_equal       9,             value.stop_value.val

        value = Api.eval_expr @interp, "1.(to-by 9 2)"
        assert_instance_of VCM::Interval, value
        assert_equal       1,             value.current_value.val
        assert_equal       9,             value.stop_value.val
        assert_equal       2,             value.step_value.val
    end
end



class InfixMessageTest < Minitest::Test
=begin
<basic-message> ::=
    "." <redefinable-infix-operator> <product-expression>
  | ".(" <redefinable-infix-operator> <product-expression> ")"
  ;
=end
    def setup
        @interp = Api.setup_interpreter
    end


    def test_infix_oprrator_message_1
        value = Api.eval_expr @interp, "3.+ 4"
        assert_instance_of VCAN::Int, value
        assert_equal       7,         value.val
    end


    def test_infix_oprrator_message_2
        value = Api.eval_expr @interp, "3.(+ 4)"
        assert_instance_of VCAN::Int, value
        assert_equal       7,         value.val
    end
end



class ApplyMessageTest < Minitest::Test
=begin
<basic-message> ::=
    ".[" <expression> { "," <expression> "]" ;
=end
    def setup
        @interp = Api.setup_interpreter
    end


    def test_apply_message_unary
        interp = Api.eval_decls @interp, "val xs = [3, 4, 5]"

        value  = Api.eval_expr  interp,  "xs.[1]"
        assert_instance_of VCAN::Int, value
        assert_equal       4,         value.val
    end


    def test_apply_message_binary
        value = Api.eval_expr @interp, "(+).[3, 4]"
        assert_instance_of VCAN::Int, value
        assert_equal       7,         value.val
    end
end



class KeywordMessageTest < Minitest::Test
=begin
<basic-message> ::=
  ".(" <named-field> { <named-field> } ")" ;

/* <named-field> ::= ... ;  See NamedTupleExpressionTest */
=end
    def setup
        @interp = Api.setup_interpreter
    end


    def test_keyword_message
        value = Api.eval_expr @interp, "1.(to:9)"
        assert_instance_of VCM::Interval, value
        assert_equal       1,             value.current_value.val
        assert_equal       9,             value.stop_value.val

        value = Api.eval_expr @interp, "1.(to:9 by:2)"
        assert_instance_of VCM::Interval, value
        assert_equal       1,             value.current_value.val
        assert_equal       9,             value.stop_value.val
        assert_equal       2,             value.step_value.val
    end
end

end # Umu::Test::Grammar::CoreLanguage::SendExpression

end # Umu::Test::Grammar::CoreLanguage

end # Umu::Test::Grammar

end # Umu::Test

end # Umu
