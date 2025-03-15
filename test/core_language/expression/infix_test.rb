# frozen_string_literal: true

require "test_helper"


module Umu

module Test

module Grammar

module CoreLanguage

module Expression

module InfixOperator
=begin
<infix-expression> ::=
    <send-expression>
  | <pipe-operator-expression>
  | <composite-operator-expression>
  | <shortcut-operator-expression>
  | <redefinable-operator-expression>
  ;

/* <send-expression> ::= ...  See SendExpression */
=end

class PipeTest < Minitest::Test
=begin
<pipe-operator-expression> ::=
    <composite-operator-expression> "|>"
        <composite-operator-expression>
        { "|>" <composite-operator-expression> }
  | <composite-operator-expression> "<|"
        <composite-operator-expression>
        { "<|" <composite-operator-expression> }
  ;
=end
    def setup
        @interp = Api.setup_interpreter
    end


    def test_pipe_left
        value = Api.eval_expr @interp, "3 |> succ"
        assert_instance_of VCAN::Int, value
        assert_equal       4,         value.val

        value = Api.eval_expr @interp, "3 |> succ |> negate"
        assert_instance_of VCAN::Int, value
        assert_equal(      -4,        value.val)

        value = Api.eval_expr @interp, "3 |> succ |> negate |> to-s"
        assert_instance_of VCA::String, value
        assert_equal       "-4",        value.val
    end


    def test_pipe_right
        value = Api.eval_expr @interp, "succ <| 3"
        assert_instance_of VCAN::Int, value
        assert_equal       4,         value.val

        value = Api.eval_expr @interp, "negate <| succ <| 3"
        assert_instance_of VCAN::Int, value
        assert_equal(      -4,        value.val)

        value = Api.eval_expr @interp, "to-s <| negate <| succ <| 3"
        assert_instance_of VCA::String, value
        assert_equal       "-4",        value.val
    end
end



class CompositeTest < Minitest::Test
=begin
<composite-operator-expression> ::=
    <shortcut-operator-expression> ">>"
        <shortcut-operator-expression>
        { ">>" <shortcut-operator-expression> }
  | <shortcut-operator-expression> "<<"
        <shortcut-operator-expression>
        { "<<" <shortcut-operator-expression> }
  ;
=end
    def setup
        @interp = Api.setup_interpreter
    end


    def test_composite_left
        interp = Api.eval_decls @interp, "val f = succ >> negate"
        value  = Api.eval_expr  interp,  "f 3"
        assert_instance_of VCAN::Int, value
        assert_equal(      -4,        value.val)

        interp = Api.eval_decls @interp, "val f = succ >> negate >> to-s"
        value  = Api.eval_expr  interp,  "f 3"
        assert_instance_of VCA::String, value
        assert_equal       "-4",        value.val
    end


    def test_composite_right
        interp = Api.eval_decls @interp, "val f = negate << succ"
        value  = Api.eval_expr  interp,  "f 3"
        assert_instance_of VCAN::Int, value
        assert_equal(      -4,        value.val)

        interp = Api.eval_decls @interp, "val f = to-s << negate << succ"
        value  = Api.eval_expr  interp,  "f 3"
        assert_instance_of VCA::String, value
        assert_equal       "-4",        value.val
    end
end



class ShortcutTest < Minitest::Test
=begin
<shortcut-operator-expression> ::=
    <redefinable-operator-expression> "&&" <redefinable-operator-expression>
  | <redefinable-operator-expression> "||" <redefinable-operator-expression>
  ;
=end
    def setup
        @interp = Api.setup_interpreter
    end


    def test_shortcut_and
        value = Api.eval_expr @interp, "TRUE  && TRUE"
        assert_instance_of VCA::Bool, value
        assert_equal       true,      value.val

        value = Api.eval_expr @interp, "FALSE && TRUE"
        assert_instance_of VCA::Bool, value
        assert_equal       false,     value.val

        value = Api.eval_expr @interp, "TRUE  && FALSE"
        assert_instance_of VCA::Bool, value
        assert_equal       false,     value.val

        value = Api.eval_expr @interp, "FALSE && FALSE"
        assert_instance_of VCA::Bool, value
        assert_equal       false,     value.val
    end


    def test_shortcut_or
        value = Api.eval_expr @interp, "TRUE  || TRUE"
        assert_instance_of VCA::Bool, value
        assert_equal       true,      value.val

        value = Api.eval_expr @interp, "FALSE || TRUE"
        assert_instance_of VCA::Bool, value
        assert_equal       true,      value.val

        value = Api.eval_expr @interp, "TRUE  || FALSE"
        assert_instance_of VCA::Bool, value
        assert_equal       true,      value.val

        value = Api.eval_expr @interp, "FALSE || FALSE"
        assert_instance_of VCA::Bool, value
        assert_equal       false,     value.val
    end
end



class RedefinableTest < Minitest::Test
=begin
<redefinable-operator-expression> ::=
    <send-expression> "+"   <send-expression>
  | <send-expression> "-"   <send-expression>
  | <send-expression> "^"   <send-expression>
  | <send-expression> "*"   <send-expression>
  | <send-expression> "/"   <send-expression>
  | <send-expression> MOD   <send-expression>
  | <send-expression> POW   <send-expression>
  | <send-expression> "=="  <send-expression>
  | <send-expression> "<>"  <send-expression>
  | <send-expression> "<"   <send-expression>
  | <send-expression> ">"   <send-expression>
  | <send-expression> "<="  <send-expression>
  | <send-expression> ">="  <send-expression>
  | <send-expression> "<=>" <send-expression>
  | <send-expression> "++"  <send-expression>
  | <send-expression> ":="  <send-expression>
  ;
=end
    def setup
        @interp = Api.setup_interpreter
    end


    def test_add
        value = Api.eval_expr @interp, "3 + 4"
        assert_instance_of VCAN::Int, value
        assert_equal       7,         value.val
    end


    def test_sub
        value = Api.eval_expr @interp, "7 - 4"
        assert_instance_of VCAN::Int, value
        assert_equal       3,         value.val
    end


    def test_append_string
        value = Api.eval_expr @interp, '"Apple" ^ "Banana"'
        assert_instance_of VCA::String,   value
        assert_equal       "AppleBanana", value.val
    end


    def test_multiply
        value = Api.eval_expr @interp, "3 * 4"
        assert_instance_of VCAN::Int, value
        assert_equal       12,        value.val
    end


    def test_divide
        value = Api.eval_expr @interp, "7 / 3"
        assert_instance_of VCAN::Int, value
        assert_equal       2,         value.val
    end


    def test_moduulo
        value = Api.eval_expr @interp, "7 mod 3"
        assert_instance_of VCAN::Int, value
        assert_equal       1,         value.val
    end


    def test_power
        value = Api.eval_expr @interp, "2 pow 3"
        assert_instance_of VCAN::Int, value
        assert_equal       8,         value.val
    end


    def test_equal
        value = Api.eval_expr @interp, "3 == 4"
        assert_instance_of VCA::Bool, value
        assert_equal       false,     value.val
    end


    def test_not_equal
        value = Api.eval_expr @interp, "3 <> 4"
        assert_instance_of VCA::Bool, value
        assert_equal       true,      value.val
    end


    def test_less_than
        value = Api.eval_expr @interp, "3 < 4"
        assert_instance_of VCA::Bool, value
        assert_equal       true,      value.val
    end


    def test_greater_than
        value = Api.eval_expr @interp, "3 > 4"
        assert_instance_of VCA::Bool, value
        assert_equal       false,     value.val
    end


    def test_less_equal
        value = Api.eval_expr @interp, "3 <= 4"
        assert_instance_of VCA::Bool, value
        assert_equal       true,      value.val
    end


    def test_greater_equal
        value = Api.eval_expr @interp, "3 >= 4"
        assert_instance_of VCA::Bool, value
        assert_equal       false,     value.val
    end


    def test_compare
        value = Api.eval_expr @interp, "3 <=> 4"
        assert_instance_of VCAN::Int, value
        assert_equal(      -1,        value.val)
    end


    def test_append_morph
        value = Api.eval_expr @interp, "[1, 2] ++ [3, 4]"
        assert_instance_of VCM::List::Cons, value
        [1, 2, 3, 4].zip(value.to_a).each do |expected, actual_value|
            assert_instance_of VCAN::Int, actual_value
            assert_equal       expected,  actual_value.val
        end
    end


    def test_assigin
        interp  = Api.eval_decls @interp, "val rx = ref 3"
        value_1 = Api.eval_expr  interp,  "rx := 4"
        assert_instance_of VC::Unit, value_1

        value_2  = Api.eval_expr interp,  "!!rx"
        assert_instance_of VCAN::Int, value_2
        assert_equal       4,         value_2.val
    end
end

end # Umu::Test::Grammar::CoreLanguage::Expression::InfixOperator

end # Umu::Test::Grammar::CoreLanguage::Expression

end # Umu::Test::Grammar::CoreLanguage

end # Umu::Test::Grammar

end # Umu::Test

end # Umu
