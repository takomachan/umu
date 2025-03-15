# frozen_string_literal: true

require "test_helper"


module Umu

module Test

module Grammar

module CoreLanguage

module Expression

module Atomic

class IdentifierTest < Minitest::Test
=begin
<identifier> ::= 
    ID
  | "(" <infix-operator> ")"
  | MODULE-DIR <module-path> ID
  | MODULE-DIR <module-path> "(" <infix-operator> ")"
  | "&" ID
  ;

<module-path> ::= /* empty */ | MODULE-DIR <module-path> ;
=end


    def setup
        @interp = Api.setup_interpreter
    end


    def test_short_identifier
        value = Api.eval_expr @interp, "TRUE"
        assert_instance_of  VCA::Bool, value
        assert_equal        true,      value.val
    end


    def test_infix_operator
        value = Api.eval_expr @interp, "(+)"
        assert_instance_of  VC::Fun, value

        value = Api.eval_expr @interp, "(+) 3 4"
        assert_instance_of  VCAN::Int, value
        assert_equal        7,         value.val
    end


    def test_long_identifier
        value = Api.eval_expr @interp, "Umu::TRUE"
        assert_instance_of  VCA::Bool, value
        assert_equal        true,      value.val
    end


    def test_long_infix_operator
        value = Api.eval_expr @interp, "Umu::Prelude::(+)"
        assert_instance_of  VC::Fun, value

        value = Api.eval_expr @interp, "Umu::Prelude::(+) 3 4"
        assert_instance_of  VCAN::Int, value
        assert_equal        7,         value.val
    end


    def test_class_instance
        value = Api.eval_expr @interp, "&Int"
        assert_instance_of  VC::Class, value
    end
end

end # Umu::Test::Grammar::CoreLanguage::Expression::Atomic

end # Umu::Test::Grammar::CoreLanguage::Expression

end # Umu::Test::Grammar::CoreLanguage

end # Umu::Test::Grammar

end # Umu::Test

end # Umu
