# frozen_string_literal: true

require "test_helper"


module Umu

module Test

module Grammar

module CoreLanguage

module Declaration

class ValueTest < Minitest::Test
=begin
<value-declaration> ::=
    VAL <pattern> "=" <expression>
    [ WHERE "{" { <declaration> } "}"
    ;
=end
    def setup
        @interp = Api.setup_interpreter
    end


    def test_value
        interp = Api.eval_decls @interp, "val x = 3"

        value = Api.eval_expr interp, "x"
        assert_instance_of VCAN::Int, value
        assert_equal       3,         value.val
    end


    def test_with_empty_declaration
        interp = Api.eval_decls @interp, "val x = 3 where { }"

        value = Api.eval_expr interp, "x"
        assert_instance_of VCAN::Int, value
        assert_equal       3,         value.val
    end


    def test_with_single_declaration
        interp = Api.eval_decls @interp, "val x = y where { val y = 3 }"

        value = Api.eval_expr interp, "x"
        assert_instance_of VCAN::Int, value
        assert_equal       3,         value.val
    end


    def test_with_some_declarations
        interp = Api.eval_decls @interp, <<-EOS
            val x = y + z where { val y = 3 val z = 4 }
            EOS

        value = Api.eval_expr interp, "x"
        assert_instance_of VCAN::Int, value
        assert_equal       7,         value.val
    end
end

end # Umu::Test::Grammar::CoreLanguage::Declaration

end # Umu::Test::Grammar::CoreLanguage

end # Umu::Test::Grammar

end # Umu::Test

end # Umu
