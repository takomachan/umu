# frozen_string_literal: true

require "test_helper"


module Umu

module Test

module Grammar

module ModuleLanguage

module Declaration

class StructureTest < Minitest::Test
=begin
<md-structure-declaration> ::=
    STRUCTURE ID "=" <me-expression>
    [ WHERE "{" { <md-declaration> } "}"
    ;
=end
    def setup
        @interp = Api.setup_interpreter
    end


    def test_structure
        interp = Api.eval_decls @interp, <<-EOS
            structure M = struct { val x = 3 }
            EOS

        value = Api.eval_expr interp, "M::x"
        assert_instance_of VCAN::Int, value
        assert_equal       3,         value.val
    end


    def test_with_empty_declaration
        interp = Api.eval_decls @interp, <<-EOS
            structure M = struct { val x = 3 } where { }
            EOS

        value = Api.eval_expr interp, "M::x"
        assert_instance_of VCAN::Int, value
        assert_equal       3,         value.val
    end


    def test_with_single_declaration
        interp = Api.eval_decls @interp, <<-EOS
            structure M = struct {
                val x = y
            } where {
                val y = 3
            }
            EOS

        value = Api.eval_expr interp, "M::x"
        assert_instance_of VCAN::Int, value
        assert_equal       3,         value.val

        assert_raises(X::SelectionError) do
            Api.eval_expr interp, "M::y"
        end
    end


    def test_with_some_declarations
        interp = Api.eval_decls @interp, <<-EOS
            structure M = struct {
                val x = y + z
            } where {
                val y = 3
                val z = 4
            }
            EOS

        value = Api.eval_expr interp, "M::x"
        assert_instance_of VCAN::Int, value
        assert_equal       7,         value.val

        assert_raises(X::SelectionError) do
            Api.eval_expr interp, "M::y"
        end

        assert_raises(X::SelectionError) do
            Api.eval_expr interp, "M::z"
        end
    end


    def test_nested_structure
        interp = Api.eval_decls @interp, <<-EOS
            structure M = struct {
                val x = 3
                structure N = struct { val y = 4 }
                val z = 5
            }
            EOS

        value = Api.eval_expr interp, "M::x"
        assert_instance_of VCAN::Int, value
        assert_equal       3,         value.val

        value = Api.eval_expr interp, "M::N::y"
        assert_instance_of VCAN::Int, value
        assert_equal       4,         value.val

        value = Api.eval_expr interp, "M::z"
        assert_instance_of VCAN::Int, value
        assert_equal       5,         value.val

        assert_raises(X::SelectionError) do
            Api.eval_expr interp, "M::y"
        end
    end
end

end # Umu::Test::Grammar::ModuleLanguage::Declaration

end # Umu::Test::Grammar::ModuleLanguage

end # Umu::Test::Grammar

end # Umu::Test

end # Umu
