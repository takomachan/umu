# frozen_string_literal: true

require "test_helper"


module Umu

module Test

module Grammar

module CoreLanguage

module Expression

module Entry

class DoExpressionTest < Minitest::Test
=begin
<do-expression> ::= DO "(" {  "!" <expression> } "}" ;
=end


    def setup
        @interp = Api.setup_interpreter
    end


    def test_do_expression
        value = Api.eval_expr @interp, "do ()"
        assert_instance_of  VC::Unit, value

        interp = Api.eval_decls @interp, "val rx = ref 3"
        value = Api.eval_expr interp, <<-EOS
            do (
                ! rx := !!rx + 1
                ! !!rx
            )
            EOS
        assert_instance_of  VCAN::Int, value
        assert_equal        4,         value.val
    end
end

end # Umu::Test::Grammar::CoreLanguage::Expression::Entry

end # Umu::Test::Grammar::CoreLanguage::Expression

end # Umu::Test::Grammar::CoreLanguage

end # Umu::Test::Grammar

end # Umu::Test

end # Umu
