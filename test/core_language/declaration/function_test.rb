# frozen_string_literal: true

require "test_helper"


module Umu

module Test

module Grammar

module CoreLanguage

module Declaration

class FunctionTest < Minitest::Test
=begin
<function-declaration> ::=
    FUN <pattern> "=" <function-body> ;

<function-body> ::=
    <pattern> { <pattern> } "->" 
    [ WHERE "{" { <declaration> } "}"
    ;
=end
    def setup
        @interp = Api.setup_interpreter
    end


    def test_function
        interp = Api.eval_decls @interp, "fun add4 = x -> x + 4"

        value = Api.eval_expr interp, "add4 3"
        assert_instance_of VCAN::Int, value
        assert_equal       7,         value.val
    end


    def test_binary_pattern
        interp = Api.eval_decls @interp, "fun add = x y -> x + y"

        value = Api.eval_expr interp, "add 3 4"
        assert_instance_of VCAN::Int, value
        assert_equal       7,         value.val
    end


    def test_with_empty_local_declaration
        interp = Api.eval_decls @interp, <<-EOS
            fun add4 = x -> x + 4 where { }
            EOS

        value = Api.eval_expr interp, "add4 3"
        assert_instance_of VCAN::Int, value
        assert_equal       7,         value.val
    end


    def test_with_single_local_declaration
        interp = Api.eval_decls @interp, <<-EOS
            fun add4 = x -> x + y where { val y = 4 }
            EOS

        value = Api.eval_expr interp, "add4 3"
        assert_instance_of VCAN::Int, value
        assert_equal       7,         value.val
    end


    def test_with_some_local_declarations
        interp = Api.eval_decls @interp, <<-EOS
            fun add4 = x -> x + y + z where { val y = 4 val z = 5 }
            EOS

        value = Api.eval_expr interp, "add4 3"
        assert_instance_of VCAN::Int, value
        assert_equal       12,        value.val
    end
end

end # Umu::Test::Grammar::CoreLanguage::Declaration

end # Umu::Test::Grammar::CoreLanguage

end # Umu::Test::Grammar

end # Umu::Test

end # Umu
