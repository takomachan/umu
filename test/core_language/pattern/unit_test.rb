# frozen_string_literal: true

require "test_helper"


module Umu

module Test

module Grammar

module CoreLanguage

module Pattern

class UnitTest < Minitest::Test
=begin
<unit-pattern> ::= "(" ")" ;
=end
    def setup
        @interp = Api.setup_interpreter
    end


    def test_value
        assert (
            Api.eval_decls @interp, "val () = ()"
        )
    end


    def test_should_be_unit_in_declaration
        assert_raises(X::TypeError) do
            Api.eval_decls @interp, "val () = 3"
        end
    end


    def test_lambda
        value = Api.eval_expr @interp, "{ () -> 3 } ()"
        assert_instance_of VCAN::Int, value
        assert_equal       3,         value.val
    end


    def test_should_be_unit_in_lambda
        assert_raises(X::TypeError) do
            Api.eval_expr @interp, "{ () -> 3 } 4"
        end
    end
end

end # Umu::Test::Grammar::CoreLanguage::Pattern

end # Umu::Test::Grammar::CoreLanguage

end # Umu::Test::Grammar

end # Umu::Test

end # Umu
