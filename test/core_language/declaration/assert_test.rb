# frozen_string_literal: true

require "test_helper"


module Umu

module Test

module Grammar

module CoreLanguage

module Declaration

class AssertTest < Minitest::Test
=begin
<value-declaration> ::=
    ASSERT <expression> "-> <expression> ;
=end
    def setup
        @interp = Api.setup_interpreter
    end


    def test_assert

        assert (
            Api.eval_decls @interp, 'assert TRUE -> "SUCCESS!!"'
        )

        assert_raises(X::AssertionFailure) do
            Api.eval_decls @interp, 'assert FALSE -> "FAILURE!!"'
        end
    end
end

end # Umu::Test::Grammar::CoreLanguage::Declaration

end # Umu::Test::Grammar::CoreLanguage

end # Umu::Test::Grammar

end # Umu::Test

end # Umu
