# frozen_string_literal: true

require "test_helper"


module Umu

module Test

module T3Syntax

module T31CoreLang

class T311AtomicExpressionTest < Minitest::Test
=begin
<atomic-expression> ::= 
    <identifier>                    /* T3111 */
  | <constant>                      /* T3112 */
  | <round-braket-expression>       /* T3113 */
  | <square-braket-expression>      /* T3114 */
  | <lambda-expression>             /* T3115 */
  | <cell-stream-expression>        /* T---- */
  | <memo-stream-expression>        /* T---- */
  | <interval-stream-expression>    /* T---- */
  ;
=end
end



class T3111IdentifierTest < Minitest::Test
=begin
<identifier> ::= 
    ID
  | "(" <infix-operator> ")"
  | MODULE-DIR <module-path> ID
  | MODULE-DIR <module-path> "(" <infix-operator> ")"
  | "&" ID
  ;

<module-path> ::= /* empty */ | MODULE-DIR <module-path> ;
=end


    def setup
        @interp = Api.setup_interpreter
    end


    def test_short_identifier
        value = Api.eval_expr @interp, "TRUE"
        assert_instance_of  VCA::Bool, value
        assert_equal        true,      value.val
    end


    def test_infix_operator
        value = Api.eval_expr @interp, "(+)"
        assert_instance_of  VC::Fun, value

        value = Api.eval_expr @interp, "(+) 3 4"
        assert_instance_of  VCAN::Int, value
        assert_equal        7,         value.val
    end


    def test_long_identifier
        value = Api.eval_expr @interp, "Umu::TRUE"
        assert_instance_of  VCA::Bool, value
        assert_equal        true,      value.val
    end


    def test_long_infix_operator
        value = Api.eval_expr @interp, "Umu::Prelude::(+)"
        assert_instance_of  VC::Fun, value

        value = Api.eval_expr @interp, "Umu::Prelude::(+) 3 4"
        assert_instance_of  VCAN::Int, value
        assert_equal        7,         value.val
    end


    def test_class_instance
        value = Api.eval_expr @interp, "&(Int)"
        # FIXME -- Never return from assert_instance_of
        #assert_instance_of  VC::Class, value
    end
end



class T3112ConstantTest < Minitest::Test
=begin
<constant> ::= 
    INT
  | FLOAT
  | STRING
  | SYMBOL
  | __FILE__
  | __LINE__
  ;
=end


    def setup
        @interp = Api.setup_interpreter
    end


    def test_int
        value = Api.eval_expr @interp, "3"
        assert_instance_of  VCAN::Int, value
        assert_equal        3,         value.val
    end


    def test_float
        value = Api.eval_expr @interp, "3.4"
        assert_instance_of  VCAN::Float, value
        assert_equal        3.4,         value.val
    end


    def test_string
        value = Api.eval_expr @interp, '"apple"'
        assert_instance_of  VCA::String, value
        assert_equal        "apple",     value.val
    end


    def test_symbol
        value = Api.eval_expr @interp, "@apple"
        assert_instance_of  VCA::Symbol, value
        assert_equal        :apple,      value.val
    end


    def test_file_identifier
        value = Api.eval_expr @interp, "__FILE__"
        assert_instance_of  VCA::String, value
    end


    def test_line_identifier
        value = Api.eval_expr @interp, "__LINE__"
        assert_instance_of  VCAN::Int, value
    end
end



class T3113RoundBracketExpressionTest < Minitest::Test
=begin
<round-braket-expression> ::= 
     <unit-expression>
  | "(" <expression> ")"
  | <prefixed-operator-expression>
  | <tuple-expression>
  | <named-tuple-expression>
  | <functionalized-message-expression>
  ;

<unit-expression> ::= "(" ")" ;

<prefixed-operator-expression> ::= "(" <infix-operator> <expression> ")" ;

<tuple-expression> ::=
    "(" <expression> "," <expression> { "," <expression> } ")" ;

<named-tuple-expression> ::=
    "(" <named-field> <named-field> { <named-field> } ")" ;
<named-field> ::= LABEL <expression> ;

<functionalized-message-expression> ::=
    "&(" ID ")"
  | "&(" ID MSG ")"
  | "&(" <redefinable-infix-operator> ")"
=end


    def setup
        @interp = Api.setup_interpreter
    end


    def test_unit
        value = Api.eval_expr @interp, "()"
        assert_instance_of  VC::Unit, value
    end


    def test_prefixed_operator_expression
        value = Api.eval_expr @interp, "(- 3)"
        assert_instance_of  VC::Fun, value

        value = Api.eval_expr @interp, "(- 3) 4"
        assert_instance_of  VCAN::Int, value
        assert_equal        1,         value.val
    end


    def test_tuple
        value = Api.eval_expr @interp, "(@apple, 100)"
        assert_instance_of  VCP::Tuple,  value
        assert_equal        2,           value.arity
        assert_instance_of  VCA::Symbol, value.values[0]
        assert_equal        :apple,      value.values[0].val
        assert_instance_of  VCAN::Int,   value.values[1]
        assert_equal        100,         value.values[1].val

        value = Api.eval_expr @interp, '(@apple, 100, "APPLE")'
        assert_instance_of  VCP::Tuple,  value
        assert_equal        3,           value.arity
        assert_instance_of  VCA::Symbol, value.values[0]
        assert_equal        :apple,      value.values[0].val
        assert_instance_of  VCAN::Int,   value.values[1]
        assert_equal        100,         value.values[1].val
        assert_instance_of  VCA::String, value.values[2]
        assert_equal        "APPLE",     value.values[2].val
    end


    def test_named_tuple
        value = Api.eval_expr(
                    @interp,
                    "(key:@apple price:100)"
                )
        assert_instance_of  VCP::Named,  value
        assert_equal        2,           value.arity
        assert_instance_of  VCA::Symbol, value.values[0]
        assert_equal        :apple,      value.values[0].val
        assert_instance_of  VCAN::Int,   value.values[1]
        assert_equal        100,         value.values[1].val

        value = Api.eval_expr(
                    @interp,
                    '(key:@apple price:100 name:"APPLE")'
                )
        assert_instance_of  VCP::Named,  value
        assert_equal        3,           value.arity
        assert_instance_of  VCA::Symbol, value.values[0]
        assert_equal        :apple,      value.values[0].val
        assert_instance_of  VCAN::Int,   value.values[1]
        assert_equal        100,         value.values[1].val
        assert_instance_of  VCA::String, value.values[2]
        assert_equal        "APPLE",     value.values[2].val
    end


    def test_generic_functionalized_message
        value = Api.eval_expr @interp, "&(show)"
        assert_instance_of  VC::Fun, value

        value = Api.eval_expr @interp, "&(show) 3"
        assert_instance_of  VCA::String, value
        assert_equal        "3",         value.val
    end


    def test_functionalized_message
        value = Api.eval_expr @interp, "&(Int.negate)"
        assert_instance_of  VC::Fun, value

        value = Api.eval_expr @interp, "&(Int.negate) 3"
        assert_instance_of  VCAN::Int, value
        assert_equal(       -3,        value.val)
    end
end



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



class T3115LambdaExpressionTest < Minitest::Test
=begin
<lambda-expression> ::=
    "{" <pattern> { <pattern> } "->"
        <expression> 
        [ WHERE <declaration> { declaration> } ]
    "}"
    ;
=end


    def setup
        @interp = Api.setup_interpreter
    end


    def test_lambda_expression
        value = Api.eval_expr @interp, "{ x -> x }"
        assert_instance_of  VC::Fun, value

        value = Api.eval_expr @interp, "{ x -> x } 1"
        assert_instance_of  VCAN::Int, value
        assert_equal        1,         value.val

        value = Api.eval_expr @interp, "{ x y -> x.+ y }"
        assert_instance_of  VC::Fun, value

        value = Api.eval_expr @interp, "{ x y -> x.+ y } 3 4"
        assert_instance_of  VCAN::Int, value
        assert_equal        7,         value.val
    end
end

end # Umu::Test::T3Syntax::T31CoreLang

end # Umu::Test::T3Syntax

end # Umu::Test

end # Umu
