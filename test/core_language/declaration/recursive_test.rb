# frozen_string_literal: true

require "test_helper"


module Umu

module Test

module Grammar

module CoreLanguage

module Declaration

class RecursiveTest < Minitest::Test
=begin
<recursive-declaration> ::=
    FUN REC <pattern> "=" <binding> { AND <binding> } ;

<binding> ::= ID "=" <function-body> ;

/* <function-body> ::= ... ;  See FunctionTest */
=end
    def setup
        @interp = Api.setup_interpreter
    end


    def test_recursive
        interp = Api.eval_decls @interp, <<-EOS
            fun rec fact = x ->
                if x <= 1 then
                    1
                else
                    x * fact (x - 1)
            EOS

        value = Api.eval_expr interp, "fact 1"
        assert_instance_of VCAN::Int, value
        assert_equal       1,         value.val

        value = Api.eval_expr interp, "fact 3"
        assert_instance_of VCAN::Int, value
        assert_equal       6,         value.val
    end


    def test_mutual_recursive
        interp = Api.eval_decls @interp, <<-EOS
            fun rec even? = x -> if x == 0 then TRUE  else odd?  (x - 1)
            and     odd?  = x -> if x == 0 then FALSE else even? (x - 1)
            EOS

        value = Api.eval_expr interp, "even? 2"
        assert_instance_of VCA::Bool, value
        assert_equal       true,      value.val

        value = Api.eval_expr interp, "even? 3"
        assert_instance_of VCA::Bool, value
        assert_equal       false,      value.val

        value = Api.eval_expr interp, "odd? 2"
        assert_instance_of VCA::Bool, value
        assert_equal       false,     value.val

        value = Api.eval_expr interp, "odd? 3"
        assert_instance_of VCA::Bool, value
        assert_equal       true,      value.val
    end
end

end # Umu::Test::Grammar::CoreLanguage::Declaration

end # Umu::Test::Grammar::CoreLanguage

end # Umu::Test::Grammar

end # Umu::Test

end # Umu
