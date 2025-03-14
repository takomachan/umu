# frozen_string_literal: true

require "test_helper"


module Umu

module Test

module Grammar

module CoreLanguage

module Expression

class ApplyTest < Minitest::Test
=begin
<apply-expression> ::=
    <product-expression> { <product-expression> } ;
=end
    def setup
        @interp = Api.setup_interpreter
    end


    def test_apply_expression
        value = Api.eval_expr @interp, "(+) 3 4"
        assert_instance_of VCAN::Int, value
        assert_equal       7,         value.val

        interp_1 = Api.eval_decls @interp,  "val op = (+)"

        interp_2 = Api.eval_decls interp_1, "val it = op 3"
        value_fun = Api.eval_expr interp_2, "it"
        assert_instance_of VC::Fun, value_fun

        interp_3 = Api.eval_decls interp_2, "val it = it 4"
        value_int = Api.eval_expr interp_3, "it"
        assert_instance_of VCAN::Int, value_int
        assert_equal       7,         value_int.val
    end


    def test_with_product_expression
        interp = Api.eval_decls @interp, <<-EOS
            val t1 = (name:@Apple  price:300)
            val t2 = (name:@Banana price:500)
            EOS

        value = Api.eval_expr interp, "(+) t1$2 t2$2"
        assert_instance_of VCAN::Int, value
        assert_equal       800,       value.val
    end
end

end # Umu::Test::Grammar::CoreLanguage::Expression

end # Umu::Test::Grammar::CoreLanguage

end # Umu::Test::Grammar

end # Umu::Test

end # Umu
