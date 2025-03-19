# frozen_string_literal: true

require "test_helper"


module Umu

module Test

module Grammar

module CoreLanguage

module Expression

module ProductOperator
=begin
<product-expression> ::=
    <atomic-expression> { <product-operation> } ;

<product-operation> ::=
    <number-selector>
  | <label-selector>
  | <named-tuple-modifier>
  ;
=end

class NumberSelectorTest < Minitest::Test
=begin
<number-selector> ::= "$" INT ;
=end
    def setup
        @interp = Api.setup_interpreter
    end


    def test_tuple
        interp = Api.eval_decls @interp, "val t = (@Apple, 300)"

        value = Api.eval_expr interp, "t$1"
        assert_instance_of VCA::Symbol, value
        assert_equal       :Apple,      value.val

        value = Api.eval_expr interp, "t$2"
        assert_instance_of VCAN::Int, value
        assert_equal       300,       value.val
    end


    def test_named_tuple
        interp = Api.eval_decls @interp, "val n = (name:@Apple price:300)"

        value = Api.eval_expr interp, "n$1"
        assert_instance_of VCA::Symbol, value
        assert_equal       :Apple,      value.val

        value = Api.eval_expr interp, "n$2"
        assert_instance_of VCAN::Int, value
        assert_equal       300,       value.val
    end


    def test_left_hand_should_be_a_product_type
        assert_raises(X::TypeError) do
            Api.eval_expr @interp, "@foo$1"
        end
    end


    def test_selection_number_should_be_in_the_range_of_1_to_arity
        interp_t = Api.eval_decls @interp, "val t = (@Apple, 300)"
        interp_n = Api.eval_decls @interp, "val n = (name:@Apple price:300)"

        assert_raises(X::SelectionError) do
            Api.eval_expr interp_t, "t$0"
        end

        assert_raises(X::SelectionError) do
            Api.eval_expr interp_t, "t$3"
        end

        assert_raises(X::SelectionError) do
            Api.eval_expr interp_n, "n$0"
        end

        assert_raises(X::SelectionError) do
            Api.eval_expr interp_n, "n$3"
        end
    end
end



class LabelSelectorTest < Minitest::Test
=begin
<label-selector> ::= SEL ;
=end
    def setup
        @interp = Api.setup_interpreter
    end


    def test_named_tuple
        interp = Api.eval_decls @interp, "val t = (name:@Apple price:300)"

        value_1 = Api.eval_expr interp, "t$name"
        assert_instance_of VCA::Symbol, value_1
        assert_equal       :Apple,      value_1.val

        value_2 = Api.eval_expr interp, "t$price"
        assert_instance_of VCAN::Int, value_2
        assert_equal       300,       value_2.val
    end


    def test_left_hand_should_be_a_named_tuple_type
        assert_raises(X::TypeError) do
            Api.eval_expr @interp, "@foo$name"
        end
    end


    def test_selection_label_should_be_known
        interp = Api.eval_decls @interp, "val n = (name:@Apple price:300)"

        assert_raises(X::SelectionError) do
            Api.eval_expr interp, "n$foo"
        end
    end
end



class NamedTupleModifierTest < Minitest::Test
=begin
<named-tuple-modifier> ::= "$(" <named-field> { <named-field> } ")" ;

/* <named-field> ::= ... ;  See NamedTupleExpressionTest */
=end
    def setup
        @interp = Api.setup_interpreter
    end


    def test_named_tuple
        interp = Api.eval_decls @interp, "val t = (name:@Apple price:300)"

        n1_value = Api.eval_expr interp, "t$(name:@Banana)"
        assert_instance_of VCP::Named,  n1_value
        assert_equal       2,           n1_value.arity
        assert_instance_of VCA::Symbol, n1_value.values[0]
        assert_equal       :Banana,     n1_value.values[0].val
        assert_instance_of VCAN::Int,   n1_value.values[1]
        assert_equal       300,         n1_value.values[1].val

        n1_value = Api.eval_expr interp, "t$(price:250)"
        assert_instance_of VCP::Named,  n1_value
        assert_equal       2,           n1_value.arity
        assert_instance_of VCA::Symbol, n1_value.values[0]
        assert_equal       :Apple,      n1_value.values[0].val
        assert_instance_of VCAN::Int,   n1_value.values[1]
        assert_equal       250,         n1_value.values[1].val

        n1_value = Api.eval_expr interp, "t$(name:@Banana price:250)"
        assert_instance_of VCP::Named,  n1_value
        assert_equal       2,           n1_value.arity
        assert_instance_of VCA::Symbol, n1_value.values[0]
        assert_equal       :Banana,     n1_value.values[0].val
        assert_instance_of VCAN::Int,   n1_value.values[1]
        assert_equal       250,         n1_value.values[1].val
    end


    def test_left_hand_should_be_a_named_tuple_type
        assert_raises(X::TypeError) do
            Api.eval_expr @interp, "@foo$(name:@Banana)"
        end
    end


    def test_selection_label_should_be_known
        interp = Api.eval_decls @interp, "val n = (name:@Apple price:300)"

        assert_raises(X::SelectionError) do
            Api.eval_expr interp, "n$(foo:@Bar)"
        end
    end


    def test_modifier_labels_should_not_be_duplicated
        interp = Api.eval_decls @interp, "val t = (name:@Apple price:300)"

        assert_raises(X::SyntaxError) do
            Api.eval_expr interp, "t$(name:@Banana name:@Orange)"
        end
    end
end

end # Umu::Test::Grammar::CoreLanguage::Expression::ProductOperator

end # Umu::Test::Grammar::CoreLanguage::Expression

end # Umu::Test::Grammar::CoreLanguage

end # Umu::Test::Grammar

end # Umu::Test

end # Umu
