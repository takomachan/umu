# frozen_string_literal: true

require "test_helper"


module Umu

module Test

module T3Syntax

module T31CoreLang

class T3114SquareBracketExpressionTest < Minitest::Test
=begin
<square-braket-expression> ::= 
    "[" "]"
  | "[" <expression> { "," <expression> } [ "|" <expression> ] "]"
  | "[" <expression> { "," <expression> } ".." <expression> "]"
  | "[" "|" <expression> { "," <expression> } "|"
        { <qualifier> }
    "]"
  | "[" "|" <named-field> <<named-field> { <named-field> } "|"
        { <qualifier> }
    "]"
  ;

<named-field> ::= LABEL <expression> ;
=end


    def setup
        @interp = Api.setup_interpreter
    end


    def test_empty_list
        value = Api.eval_expr @interp, "[]"
        assert_instance_of  VCM::List::Nil, value
    end


    def test_singleton_list
        value = Api.eval_expr @interp, "[3]"
        assert_instance_of  VCM::List::Cons, value
        assert_instance_of  VCAN::Int,       value.head
        assert_equal        3,               value.head.val
        assert_instance_of  VCM::List::Nil,  value.tail
    end


    def test_some_list
        value = Api.eval_expr @interp, "[3, 4]"
        assert_instance_of  VCM::List::Cons, value
        assert_instance_of  VCAN::Int,       value.head
        assert_equal        3,               value.head.val
        assert_instance_of  VCM::List::Cons, value.tail

        tail_value = value.tail
        assert_instance_of  VCAN::Int,       tail_value.head
        assert_equal        4,               tail_value.head.val
        assert_instance_of  VCM::List::Nil,  tail_value.tail
    end


    def test_list_with_last_expression
        value = Api.eval_expr @interp, "[3 | []]"
        assert_instance_of  VCM::List::Cons, value
        assert_instance_of  VCAN::Int,       value.head
        assert_equal        3,               value.head.val
        assert_instance_of  VCM::List::Nil,  value.tail

        value = Api.eval_expr @interp, "[3 | [4]]"
        assert_instance_of  VCM::List::Cons, value
        assert_instance_of  VCAN::Int,       value.head
        assert_equal        3,               value.head.val
        assert_instance_of  VCM::List::Cons, value.tail

        tail_value = value.tail
        assert_instance_of  VCAN::Int,       tail_value.head
        assert_equal        4,               tail_value.head.val
        assert_instance_of  VCM::List::Nil,  tail_value.tail
    end


    def test_interval_list
        value = Api.eval_expr @interp, "[3 .. 10]"
        assert_instance_of  VCM::Interval, value
        assert_instance_of  VCAN::Int,     value.current_value
        assert_equal        3,             value.current_value.val
        assert_instance_of  VCAN::Int,     value.step_value
        assert_equal        1,             value.step_value.val
        assert_instance_of  VCAN::Int,     value.stop_value
        assert_equal        10,            value.stop_value.val

        list_value = Api.eval_expr @interp, "[3 .. 10].to-list"
        assert_instance_of  VCM::List::Cons, list_value

        expected_list = (3 .. 10).to_a
        assert_equal expected_list.count, list_value.count

        expected_list.zip(list_value).each do |expected, actual_value|
            assert_instance_of  VCAN::Int,     actual_value
            assert_equal        expected,      actual_value.val
        end
    end


    def test_interval_list_with_second_expression
        value = Api.eval_expr @interp, "[3, 5 .. 10]"
        assert_instance_of  VCM::Interval, value
        assert_instance_of  VCAN::Int,     value.current_value
        assert_equal        3,             value.current_value.val
        assert_instance_of  VCAN::Int,     value.step_value
        assert_equal        2,             value.step_value.val
        assert_instance_of  VCAN::Int,     value.stop_value
        assert_equal        10,            value.stop_value.val

        list_value = Api.eval_expr @interp, "[3, 5 .. 10].to-list"
        assert_instance_of  VCM::List::Cons, list_value

        expected_list = [3, 5, 7, 9]
        assert_equal expected_list.count, list_value.count

        expected_list.zip(list_value).each do |expected, actual_value|
            assert_instance_of  VCAN::Int,     actual_value
            assert_equal        expected,      actual_value.val
        end
    end
end

end # Umu::Test::T3Syntax::T31CoreLang

end # Umu::Test::T3Syntax

end # Umu::Test

end # Umu
