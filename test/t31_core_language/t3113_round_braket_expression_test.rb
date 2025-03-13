# frozen_string_literal: true

require "test_helper"


module Umu

module Test

module T3Language

module T31Core

module T311AtomicExpression

module T3113RoundBracketExpression
=begin
<round-braket-expression> ::= 
    <unit-expression>                   /* T31131 */
  | <expression-in-expression>          /* T31132 */
  | <prefixed-operator-expression>      /* T31133 */
  | <tuple-expression>                  /* T31134 */
  | <named-tuple-expression>            /* T31135 */
  | <functionalized-message-expression> /* T31136 */
  ;
=end

class T31131UnitExpressionTest < Minitest::Test
=begin
<unit-expression> ::= "(" ")" ;
=end

    def setup
        @interp = Api.setup_interpreter
    end


    def test_unit
        value = Api.eval_expr @interp, "()"
        assert_instance_of  VC::Unit, value
    end
end



class T31132ExpressionInExpressionTest < Minitest::Test
=begin
<expression-in-expression> ::= "(" <expression> ")"
=end

    def setup
        @interp = Api.setup_interpreter
    end


    def test_expression_in_expression
        value = Api.eval_expr @interp, "(3)"
        assert_instance_of  VCAN::Int, value
        assert_equal        3,         value.val

        value = Api.eval_expr @interp, "((3))"
        assert_instance_of  VCAN::Int, value
        assert_equal        3,         value.val
    end
end



class T31133PrefixedOperatorExpressionTest < Minitest::Test
=begin
<prefixed-operator-expression> ::= "(" <infix-operator> <expression> ")" ;
=end

    def setup
        @interp = Api.setup_interpreter
    end


    def test_prefixed_operator_expression
        value = Api.eval_expr @interp, "(- 3)"
        assert_instance_of  VC::Fun, value

        value = Api.eval_expr @interp, "(- 3) 4"
        assert_instance_of  VCAN::Int, value
        assert_equal        1,         value.val
    end
end



class T31134TupleExpressionTest < Minitest::Test
=begin
<tuple-expression> ::=
    "(" <expression> "," <expression> { "," <expression> } ")" ;
=end

    def setup
        @interp = Api.setup_interpreter
    end


    def test_pair
        value = Api.eval_expr @interp, "(@apple, 100)"
        assert_instance_of  VCP::Tuple,  value
        assert_equal        2,           value.arity
        assert_instance_of  VCA::Symbol, value.values[0]
        assert_equal        :apple,      value.values[0].val
        assert_instance_of  VCAN::Int,   value.values[1]
        assert_equal        100,         value.values[1].val
    end


    def test_triple
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
end



class T31135NamedTupleExpressionTest < Minitest::Test
=begin
<named-tuple-expression> ::=
    "(" <named-field> <named-field> { <named-field> } ")" ;

<named-field> ::= LABEL [ <expression> ] ;
=end

    def setup
        @interp = Api.setup_interpreter
    end


    def test_named_pair
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
    end


    def test_named_triple
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
end



class T31136FunctionalizedMessageExpressionTest < Minitest::Test
=begin
<functionalized-message-expression> ::=
    "&(" ID ")"
  | "&(" ID MSG ")"
  | "&(" <redefinable-infix-operator> ")"
=end

    def setup
        @interp = Api.setup_interpreter
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

end # Umu::Test::T3Language::T31Core::T311AtomicExpression::T3113RoundBracketExpression

end # Umu::Test::T3Language::T31Core::T311AtomicExpression

end # Umu::Test::T3Language::T31Core

end # Umu::Test::T3Language

end # Umu::Test

end # Umu
