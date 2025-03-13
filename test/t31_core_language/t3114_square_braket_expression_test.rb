# frozen_string_literal: true

require "test_helper"


module Umu

module Test

module T3Language

module T31Core

module T311AtomicExpression

module T3114SquareBracketExpression
=begin
<square-braket-expression> ::= 
    <list-expression>       /* T31141 */
  | <list-interval>         /* T31142 */
  | <list-comprehension>    /* T31143 */
  ;
=end

class T31141ListExpressionTest < Minitest::Test
=begin
<list-expression> ::=
    "[" "]"
  | "[" <expression> { "," <expression> } [ "|" <expression> ] "]"
  ;
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
end



class T31142ListInterval < Minitest::Test
=begin
<list-interval> ::=
  "[" <expression> { "," <expression> } ".." <expression> "]" ;
=end

    def setup
        @interp = Api.setup_interpreter
    end


    def test_list_interval
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


    def test_list_interval_with_second_expression
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



class T31143ListComprehension < Minitest::Test
=begin
<list-comprehension> ::=
  | "[" "|" <expression> { "," <expression> } "|"
        { <qualifier> }
    "]"
  | "[" "|" <named-field> <<named-field> { <named-field> } "|"
        { <qualifier> }
    "]"
  ;

<qualifier> ::= <generator> | <guard> ;
<generator> ::= VAL <pattern> "<-" <expression> :
<guard>     ::= IF <expression> ;

/* <named-field> ::= ... ;  See T31135 */
=end

    def setup
        @interp = Api.setup_interpreter
    end


    def test_singleton_comprehension
        value = Api.eval_expr @interp, "[|3|]"
        assert_instance_of  VCM::List::Cons, value
        assert_instance_of  VCAN::Int,       value.head
        assert_equal        3,               value.head.val
        assert_instance_of  VCM::List::Nil,  value.tail
    end


    def test_comprehension_with_generator
        list_value = Api.eval_expr @interp, <<-EOS
            [|x| val x <- [1..5]]
            EOS
        assert_instance_of  VCM::List::Cons, list_value

        expected_list = (1 .. 5).to_a
        assert_equal expected_list.count, list_value.count

        expected_list.zip(list_value).each do |expected, actual_value|
            assert_instance_of  VCAN::Int,     actual_value
            assert_equal        expected,      actual_value.val
        end
    end


    def test_comprehension_with_guard
        list_value = Api.eval_expr @interp, <<-EOS
            [|x| val x <- [1..5] if odd? x]
            EOS
        assert_instance_of  VCM::List::Cons, list_value

        expected_list = [1, 3, 5]
        assert_equal expected_list.count, list_value.count

        expected_list.zip(list_value).each do |expected, actual_value|
            assert_instance_of  VCAN::Int,     actual_value
            assert_equal        expected,      actual_value.val
        end
    end


    def test_comprehension_returned_tuple
        list_value = Api.eval_expr @interp, <<-EOS
            [|k, v| val k <- [@Apple, @Banana] val v <- [1, 2, 3]]
            EOS
        assert_instance_of  VCM::List::Cons, list_value

        expected_list = [
                [:Apple,  1], [:Apple,  2], [:Apple,  3],
                [:Banana, 1], [:Banana, 2], [:Banana, 3]
            ]
        assert_equal expected_list.count, list_value.count

        expected_list.zip(list_value).each do |expected, actual_value|
            assert_instance_of  VCP::Tuple,    actual_value
            assert_equal        2,             actual_value.arity

            assert_instance_of  VCA::Symbol,   actual_value.values[0]
            assert_equal        expected[0],   actual_value.values[0].val

            assert_instance_of  VCAN::Int,     actual_value.values[1]
            assert_equal        expected[1],   actual_value.values[1].val
        end
    end


    def test_comprehension_returned_named_tuple
        list_value = Api.eval_expr @interp, <<-EOS
            [|key:k value:v| val k <- [@Apple, @Banana] val v <- [1, 2, 3]]
            EOS
        assert_instance_of  VCM::List::Cons, list_value

        expected_list = [
                [:Apple,  1], [:Apple,  2], [:Apple,  3],
                [:Banana, 1], [:Banana, 2], [:Banana, 3]
            ]
        assert_equal expected_list.count, list_value.count

        expected_list.zip(list_value).each do |expected, actual_value|
            assert_instance_of  VCP::Named,    actual_value
            assert_equal        2,             actual_value.arity

            assert_instance_of  VCA::Symbol,   actual_value.values[0]
            assert_equal        expected[0],   actual_value.values[0].val

            assert_instance_of  VCAN::Int,     actual_value.values[1]
            assert_equal        expected[1],   actual_value.values[1].val
        end
    end
end

end # Umu::Test::T3Language::T31Core::T311AtomicExpression::T3114SquareBracketExpression

end # Umu::Test::T3Language::T31Core::T311AtomicExpression

end # Umu::Test::T3Language::T31Core

end # Umu::Test::T3Language

end # Umu::Test

end # Umu
