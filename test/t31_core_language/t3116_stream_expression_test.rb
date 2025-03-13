# frozen_string_literal: true

require "test_helper"


module Umu

module Test

module T3Language

module T31Core

module T311AtomicExpression

module T3116StreamExpression
=begin
<stream-expression> ::= 
    <cell-stream-expression>        /* T31161 */
  | <memo-stream-expression>        /* T31162 */
  | <interval-stream-expression>    /* T31163 */
  | <stream-comprehension>          /* T31164 */
  ;
=end

class T31161CellStreamExpressionTest < Minitest::Test
=begin
<cell-stream-expression> ::=
    "&[" "]"
  | "&[" <expression> { "," <expression> } [ "|" <expression> ] "]"
  ;
=end

    def setup
        @interp = Api.setup_interpreter
    end


    def test_empty_stream
        interp_1 = Api.eval_decls @interp, "val it = &[]"
        value    = Api.eval_expr interp_1, "it"
        assert_instance_of VCM::Stream::Entry::Cell, value
        assert_instance_of VCM::Stream::Cell::Nil,   value.cell

        forced_value = Api.eval_expr interp_1, "it.force"
        assert_instance_of VCU::Option::None, forced_value
    end


    def test_singleton_stream
        interp_1 = Api.eval_decls @interp,  "val it = &[3]"
        value    = Api.eval_expr  interp_1, "it"
        assert_instance_of VCM::Stream::Entry::Cell, value
        assert_instance_of VCM::Stream::Cell::Cons,  value.cell

        interp_2 = Api.eval_decls interp_1, "val it = it.force"
        forced_value_1 = Api.eval_expr interp_2, "it"
        assert_instance_of VCU::Option::Some, forced_value_1

        interp_3 = Api.eval_decls interp_2, "val (hd, tl) = it.contents"
        head_value = Api.eval_expr interp_3, "hd"
        tail_value = Api.eval_expr interp_3, "tl"

        assert_instance_of VCAN::Int,                head_value
        assert_equal       3,                        head_value.val
        assert_instance_of VCM::Stream::Entry::Cell, tail_value
        assert_instance_of VCM::Stream::Cell::Nil,   tail_value.cell
    end


    def test_some_stream
        interp_1 = Api.eval_decls @interp, "val it = &[3, 4]"
        value_1  = Api.eval_expr  interp_1, "it"
        assert_instance_of VCM::Stream::Entry::Cell, value_1
        assert_instance_of VCM::Stream::Cell::Cons,  value_1.cell

        interp_2 = Api.eval_decls interp_1, "val it = it.force"
        forced_value_1 = Api.eval_expr interp_2, "it"
        assert_instance_of VCU::Option::Some, forced_value_1

        interp_3 = Api.eval_decls interp_2, "val (hd, tl) = it.contents"
        head_value_1 = Api.eval_expr interp_3, "hd"
        tail_value_1 = Api.eval_expr interp_3, "tl"

        assert_instance_of VCAN::Int,                head_value_1
        assert_equal       3,                        head_value_1.val
        assert_instance_of VCM::Stream::Entry::Cell, tail_value_1
        assert_instance_of VCM::Stream::Cell::Cons,  tail_value_1.cell

        interp_4 = Api.eval_decls interp_3, "val it = tl.force"
        forced_value_2 = Api.eval_expr interp_4, "it"
        assert_instance_of VCU::Option::Some, forced_value_2

        interp_5 = Api.eval_decls interp_4, "val (hd, tl) = it.contents"
        head_value_2 = Api.eval_expr interp_5, "hd"
        tail_value_2 = Api.eval_expr interp_5, "tl"

        assert_instance_of VCAN::Int,                head_value_2
        assert_equal       4,                        head_value_2.val
        assert_instance_of VCM::Stream::Entry::Cell, tail_value_2
        assert_instance_of VCM::Stream::Cell::Nil,   tail_value_2.cell
    end


    def test_singleton_stream_with_last_expression
        interp_1 = Api.eval_decls @interp,  "val it = &[3 | &[]]"
        value    = Api.eval_expr  interp_1, "it"
        assert_instance_of VCM::Stream::Entry::Cell, value
        assert_instance_of VCM::Stream::Cell::Cons,  value.cell

        forced_value = Api.eval_expr interp_1, "it.force"
        assert_instance_of VCU::Option::Some, forced_value

        pair_value = forced_value.contents
        assert_instance_of  VCP::Tuple, pair_value
        assert_equal        2,          pair_value.arity

        head_value, tail_value = pair_value.values
        assert_instance_of VCAN::Int,                head_value
        assert_equal       3,                        head_value.val
        assert_instance_of VCM::Stream::Entry::Cell, tail_value
        assert_instance_of VCM::Stream::Cell::Nil,   tail_value.cell
    end


    def test_some_stream_with_last_expression
        interp_1 = Api.eval_decls @interp, "val it = &[3 | &[4]]"
        value_1  = Api.eval_expr  interp_1, "it"
        assert_instance_of VCM::Stream::Entry::Cell, value_1
        assert_instance_of VCM::Stream::Cell::Cons,  value_1.cell

        interp_2 = Api.eval_decls interp_1, "val it = it.force"
        forced_value_1 = Api.eval_expr interp_2, "it"
        assert_instance_of VCU::Option::Some, forced_value_1

        interp_3 = Api.eval_decls interp_2, "val (hd, tl) = it.contents"
        head_value_1 = Api.eval_expr interp_3, "hd"
        tail_value_1 = Api.eval_expr interp_3, "tl"

        assert_instance_of VCAN::Int,                head_value_1
        assert_equal       3,                        head_value_1.val
        assert_instance_of VCM::Stream::Entry::Cell, tail_value_1
        assert_instance_of VCM::Stream::Cell::Cons,  tail_value_1.cell

        interp_4 = Api.eval_decls interp_3, "val it = tl.force"
        forced_value_2 = Api.eval_expr interp_4, "it"
        assert_instance_of VCU::Option::Some, forced_value_2

        interp_5 = Api.eval_decls interp_4, "val (hd, tl) = it.contents"
        head_value_2 = Api.eval_expr interp_5, "hd"
        tail_value_2 = Api.eval_expr interp_5, "tl"

        assert_instance_of VCAN::Int,                head_value_2
        assert_equal       4,                        head_value_2.val
        assert_instance_of VCM::Stream::Entry::Cell, tail_value_2
        assert_instance_of VCM::Stream::Cell::Nil,   tail_value_2.cell
    end


    def test_infinite_stream_generator
        interp_1 = Api.eval_decls @interp, <<-EOS
            fun rec g = n -> &[ n | g (n + 1) ]
            EOS
        interp_2 = Api.eval_decls interp_1, "val it = g 3"
        value_1  = Api.eval_expr  interp_2, "it"
        assert_instance_of VCM::Stream::Entry::Cell, value_1

        actual_list_value  = Api.eval_expr  interp_2, "it.take-to-list 4"
        assert_instance_of VCM::List::Cons, actual_list_value

        [3, 4, 5, 6].zip(actual_list_value).each do |expected, actual_value|
            assert_instance_of VCAN::Int, actual_value
            assert_equal       expected,  actual_value.val
        end
    end
end



class T31162MemoStreamExpressionTest < Minitest::Test
=begin
<memo-stream-expression> ::=
    "&{" "}"
  | "&{" <expression> "|" <expression> "}"
  ;
=end

    def setup
        @interp = Api.setup_interpreter
    end


    def test_empty_stream
        interp_1 = Api.eval_decls @interp, "val it = &{}"
        value    = Api.eval_expr interp_1, "it"
        assert_instance_of VCM::Stream::Entry::Memorization, value

        forced_value = Api.eval_expr interp_1, "it.force"
        assert_instance_of VCU::Option::None, forced_value
    end


    def test_singleton_stream
        interp_1 = Api.eval_decls @interp,  "val it = &{3 | &{}}"
        value    = Api.eval_expr  interp_1, "it"
        assert_instance_of VCM::Stream::Entry::Memorization, value

        interp_2 = Api.eval_decls interp_1,  "val it = it.force"
        forced_value_1 = Api.eval_expr interp_2, "it"
        assert_instance_of VCU::Option::Some, forced_value_1

        interp_3 = Api.eval_decls interp_2,  "val (hd, tl) = it.contents"
        head_value = Api.eval_expr interp_3, "hd"
        tail_value = Api.eval_expr interp_3, "tl"

        assert_instance_of VCAN::Int, head_value
        assert_equal       3,         head_value.val
        assert_instance_of VCM::Stream::Entry::Memorization, tail_value

        forced_value_2 = Api.eval_expr interp_3, "tl.force"
        assert_instance_of VCU::Option::None, forced_value_2
    end


    def test_some_stream_with
        interp_1 = Api.eval_decls @interp, "val it = &{3 | &{4 | &{}}}"
        value_1  = Api.eval_expr  interp_1, "it"
        assert_instance_of VCM::Stream::Entry::Memorization, value_1

        interp_2 = Api.eval_decls interp_1, "val it = it.force"
        forced_value_1 = Api.eval_expr interp_2, "it"
        assert_instance_of VCU::Option::Some, forced_value_1

        interp_3 = Api.eval_decls interp_2, "val (hd, tl) = it.contents"
        head_value_1 = Api.eval_expr interp_3, "hd"
        tail_value_1 = Api.eval_expr interp_3, "tl"

        assert_instance_of VCAN::Int, head_value_1
        assert_equal       3,         head_value_1.val
        assert_instance_of VCM::Stream::Entry::Memorization, tail_value_1

        interp_4 = Api.eval_decls interp_3, "val it = tl.force"
        forced_value_2 = Api.eval_expr interp_4, "it"
        assert_instance_of  VCU::Option::Some, forced_value_2

        interp_5 = Api.eval_decls interp_4, "val (hd, tl) = it.contents"
        head_value_2 = Api.eval_expr interp_5, "hd"
        tail_value_2 = Api.eval_expr interp_5, "tl"

        assert_instance_of VCAN::Int, head_value_2
        assert_equal       4,         head_value_2.val
        assert_instance_of VCM::Stream::Entry::Memorization, tail_value_2

        forced_value_3 = Api.eval_expr interp_5, "tl.force"
        assert_instance_of VCU::Option::None, forced_value_3
    end


    def test_infinite_stream_generator
        interp_1 = Api.eval_decls @interp, <<-EOS
            fun rec g = n -> &{ n | g (n + 1) }
            EOS
        interp_2 = Api.eval_decls interp_1, "val it = g 3"
        value_1  = Api.eval_expr  interp_2, "it"
        assert_instance_of VCM::Stream::Entry::Memorization, value_1

        actual_list_value  = Api.eval_expr  interp_2, "it.take-to-list 4"
        assert_instance_of VCM::List::Cons, actual_list_value

        [3, 4, 5, 6].zip(actual_list_value).each do |expected, actual_value|
            assert_instance_of VCAN::Int, actual_value
            assert_equal       expected,  actual_value.val
        end
    end
end



class T31163IntervalStream < Minitest::Test
=begin
<list-interval> ::=
  "[" <expression> { "," <expression> } ".." [ <expression> ] "]" ;
=end

    def setup
        @interp = Api.setup_interpreter
    end


    def test_finite_interval
        value = Api.eval_expr @interp, "&[3 .. 7]"
        assert_instance_of  VCM::Stream::Entry::Interval, value
        assert_instance_of  VCAN::Int, value.current_value
        assert_equal        3,         value.current_value.val
        assert_instance_of  VCAN::Int, value.step_value
        assert_equal        1,         value.step_value.val
        assert_instance_of  VCAN::Int, value.opt_stop_value
        assert_equal        7,         value.opt_stop_value.val

        list_value = Api.eval_expr @interp, "&[3 .. 7].to-list"
        assert_instance_of  VCM::List::Cons, list_value

        expected_list = (3 .. 7).to_a
        assert_equal expected_list.count, list_value.count

        expected_list.zip(list_value).each do |expected, actual_value|
            assert_instance_of  VCAN::Int,     actual_value
            assert_equal        expected,      actual_value.val
        end
    end


    def test_finite_interval_with_second_expression
        value = Api.eval_expr @interp, "&[3, 5 .. 10]"
        assert_instance_of  VCM::Stream::Entry::Interval, value
        assert_instance_of  VCAN::Int, value.current_value
        assert_equal        3,         value.current_value.val
        assert_instance_of  VCAN::Int, value.step_value
        assert_equal        2,         value.step_value.val
        assert_instance_of  VCAN::Int, value.opt_stop_value
        assert_equal        10,        value.opt_stop_value.val

        list_value = Api.eval_expr @interp, "[3, 5 .. 10].to-list"
        assert_instance_of  VCM::List::Cons, list_value

        expected_list = [3, 5, 7, 9]
        assert_equal expected_list.count, list_value.count

        expected_list.zip(list_value).each do |expected, actual_value|
            assert_instance_of  VCAN::Int, actual_value
            assert_equal        expected,  actual_value.val
        end
    end


    def test_infinite_interval
        value = Api.eval_expr @interp, "&[3 ..]"
        assert_instance_of  VCM::Stream::Entry::Interval, value
        assert_instance_of  VCAN::Int, value.current_value
        assert_equal        3,         value.current_value.val
        assert_instance_of  VCAN::Int, value.step_value
        assert_equal        1,         value.step_value.val
        assert_nil                     value.opt_stop_value

        list_value = Api.eval_expr @interp, "&[3 ..].take-to-list 5"
        assert_instance_of  VCM::List::Cons, list_value

        expected_list = (3 .. 7).to_a
        assert_equal expected_list.count, list_value.count

        expected_list.zip(list_value).each do |expected, actual_value|
            assert_instance_of  VCAN::Int, actual_value
            assert_equal        expected,  actual_value.val
        end
    end


    def test_infinite_interval_with_second_expression
        value = Api.eval_expr @interp, "&[3, 5 ..]"
        assert_instance_of  VCM::Stream::Entry::Interval, value
        assert_instance_of  VCAN::Int, value.current_value
        assert_equal        3,         value.current_value.val
        assert_instance_of  VCAN::Int, value.step_value
        assert_equal        2,         value.step_value.val
        assert_nil                     value.opt_stop_value

        list_value = Api.eval_expr @interp, "&[3, 5 ..].take-to-list 4"
        assert_instance_of  VCM::List::Cons, list_value

        expected_list = [3, 5, 7, 9]
        assert_equal expected_list.count, list_value.count

        expected_list.zip(list_value).each do |expected, actual_value|
            assert_instance_of  VCAN::Int, actual_value
            assert_equal        expected,  actual_value.val
        end
    end
end



class T31164StreamComprehension < Minitest::Test
=begin
<stream-comprehension> ::=
  | "&[" "|" <expression> { "," <expression> } "|"
        { <qualifier> }
    "]"
  | "&[" "|" <named-field> <<named-field> { <named-field> } "|"
        { <qualifier> }
    "]"
  ;


/* <qualifier>   ::= ... ;  See T31143 */

/* <named-field> ::= ... ;  See T31135 */
=end

    def setup
        @interp = Api.setup_interpreter
    end


    def test_singleton_comprehension
        interp_1 = Api.eval_decls @interp,  "val it = &[|3|]"
        value    = Api.eval_expr  interp_1, "it"
        assert_instance_of VCM::Stream::Entry::Cell, value
        assert_instance_of VCM::Stream::Cell::Cons,  value.cell

        interp_2 = Api.eval_decls interp_1, "val it = it.force"
        forced_value_1 = Api.eval_expr interp_2, "it"
        assert_instance_of VCU::Option::Some, forced_value_1

        interp_3 = Api.eval_decls interp_2, "val (hd, tl) = it.contents"
        head_value = Api.eval_expr interp_3, "hd"
        tail_value = Api.eval_expr interp_3, "tl"

        assert_instance_of VCAN::Int, head_value
        assert_equal       3,         head_value.val
        assert_instance_of VCM::Stream::Entry::Cell, tail_value
        assert_instance_of VCM::Stream::Cell::Nil,   tail_value.cell
    end


    def test_comprehension_with_generator
        list_value = Api.eval_expr @interp, <<-EOS
            &[|x| val x <- &[3..]].take-to-list 4
            EOS
        assert_instance_of VCM::List::Cons, list_value

        expected_list = [3, 4, 5, 6]
        assert_equal expected_list.count, list_value.count

        expected_list.zip(list_value).each do |expected, actual_value|
            assert_instance_of  VCAN::Int,     actual_value
            assert_equal        expected,      actual_value.val
        end
    end


    def test_comprehension_with_guard
        list_value = Api.eval_expr @interp, <<-EOS
            &[|x| val x <- &[1..] if odd? x].take-to-list 3
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
            &[|i, n|
                val i <- &[1 ..]
                val n <- [@Apple, @Banana]
            ].take-to-list 6
            EOS
        assert_instance_of  VCM::List::Cons, list_value

        expected_list = [
                [1, :Apple], [1, :Banana],
                [2, :Apple], [2, :Banana],
                [3, :Apple], [3, :Banana]
            ]
        assert_equal expected_list.count, list_value.count

        expected_list.zip(list_value).each do |expected, actual_value|
            assert_instance_of  VCP::Tuple,    actual_value
            assert_equal        2,             actual_value.arity

            assert_instance_of  VCAN::Int,     actual_value.values[0]
            assert_equal        expected[0],   actual_value.values[0].val

            assert_instance_of  VCA::Symbol,   actual_value.values[1]
            assert_equal        expected[1],   actual_value.values[1].val
        end
    end


    def test_comprehension_returned_named_tuple
        list_value = Api.eval_expr @interp, <<-EOS
            &[|index:i name:n|
                val i <- &[1 ..]
                val n <- [@Apple, @Banana]
            ].take-to-list 6
            EOS
        assert_instance_of  VCM::List::Cons, list_value

        expected_list = [
                [1, :Apple], [1, :Banana],
                [2, :Apple], [2, :Banana],
                [3, :Apple], [3, :Banana]
            ]
        assert_equal expected_list.count, list_value.count

        expected_list.zip(list_value).each do |expected, actual_value|
            assert_instance_of  VCP::Named,    actual_value
            assert_equal        2,             actual_value.arity

            assert_instance_of  VCAN::Int,     actual_value.values[0]
            assert_equal        expected[0],   actual_value.values[0].val

            assert_instance_of  VCA::Symbol,   actual_value.values[1]
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
