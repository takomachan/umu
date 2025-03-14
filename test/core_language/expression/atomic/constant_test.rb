# frozen_string_literal: true

require "test_helper"


module Umu

module Test

module Grammar

module CoreLanguage

module Expression

module Atomic

class ConstantTest < Minitest::Test
=begin
<constant> ::= 
    INT
  | FLOAT
  | STRING
  | SYMBOL
  | __FILE__
  | __LINE__
  ;
=end


    def setup
        @interp = Api.setup_interpreter
    end


    def test_int
        value = Api.eval_expr @interp, "3"
        assert_instance_of  VCAN::Int, value
        assert_equal        3,         value.val
    end


    def test_float
        value = Api.eval_expr @interp, "3.4"
        assert_instance_of  VCAN::Float, value
        assert_equal        3.4,         value.val
    end


    def test_string
        value = Api.eval_expr @interp, '"apple"'
        assert_instance_of  VCA::String, value
        assert_equal        "apple",     value.val
    end


    def test_symbol
        value = Api.eval_expr @interp, "@apple"
        assert_instance_of  VCA::Symbol, value
        assert_equal        :apple,      value.val
    end


    def test_file_identifier
        value = Api.eval_expr @interp, "__FILE__"
        assert_instance_of  VCA::String, value
    end


    def test_line_identifier
        value = Api.eval_expr @interp, "__LINE__"
        assert_instance_of  VCAN::Int, value
    end
end

end # Umu::Test::Grammar::CoreLanguage::Expression::Atomic

end # Umu::Test::Grammar::CoreLanguage::Expression

end # Umu::Test::Grammar::CoreLanguage

end # Umu::Test::Grammar

end # Umu::Test

end # Umu
