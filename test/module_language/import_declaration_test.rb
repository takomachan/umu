# frozen_string_literal: true

require "test_helper"


module Umu

module Test

module Grammar

module ModuleLanguage

module Declaration

class ImportTest < Minitest::Test
=begin
<md-structure-declaration> ::=
    IMPORT <me-long-id> [
        "{"
            { <md-import-field> }
        "}"
    ]
    ;

<md-import-field> ::=
    VAL       <md-import-field-contents>
  | FUN       <md-import-field-contents>
  | STRUCTURE <md-import-field-contents>
  ;

<md-import-field-contents> ::=
    <md-atomic-import-field>
  | "("
        <md-atomic-import-field>
        { "," <md-atomic-import-field> }
    ")"
  ;

<md-atomic-import-field> ::=
    <variable-pattern> [ "=" <me-long-id> ] ;
=end
    def setup
        @interp = Api.setup_interpreter
    end


    def test_value
        interp = Api.eval_decls @interp, <<-EOS
            structure M = struct { val x = 3 }

            import M
            EOS

        value = Api.eval_expr interp, "x"
        assert_instance_of VCAN::Int, value
        assert_equal       3,         value.val
    end


    def test_function
        interp = Api.eval_decls @interp, <<-EOS
            structure M = struct { fun add = x y -> x + y }

            import M
            EOS

        value = Api.eval_expr interp, "add 3 4"
        assert_instance_of VCAN::Int, value
        assert_equal       7,         value.val
    end


    def test_structure
        interp = Api.eval_decls @interp, <<-EOS
            structure M = struct {
                structure N = struct { val x = 3 }
            }

            import M
            EOS

        value = Api.eval_expr interp, "N::x"
        assert_instance_of VCAN::Int, value
        assert_equal       3,         value.val

        assert_raises(X::NameError) do
            Api.eval_expr interp, "x"
        end
    end


    def test_single_field
        interp = Api.eval_decls @interp, <<-EOS
            structure M = struct { val x = 3 }

            import M { val x }
            EOS

        value = Api.eval_expr interp, "x"
        assert_instance_of VCAN::Int, value
        assert_equal       3,         value.val
    end


    def test_some_fields
        interp = Api.eval_decls @interp, <<-EOS
            structure M = struct { val x = 3 val y = 4}

            import M { val x val y }
            EOS

        value_1 = Api.eval_expr interp, "x"
        assert_instance_of VCAN::Int, value_1
        assert_equal       3,         value_1.val

        value_2 = Api.eval_expr interp, "y"
        assert_instance_of VCAN::Int, value_2
        assert_equal       4,         value_2.val
    end


    def test_rename
        interp = Api.eval_decls @interp, <<-EOS
            structure M = struct { val x = 3 }

            import M { val x' = x }
            EOS

        value = Api.eval_expr interp, "x'"
        assert_instance_of VCAN::Int, value
        assert_equal       3,         value.val

        assert_raises(X::NameError) do
            Api.eval_expr interp, "x"
        end
    end


    def test_single_group_field_single_ident
        interp = Api.eval_decls @interp, <<-EOS
            structure M = struct { val x = 3 }

            import M { val (x) }
            EOS

        value = Api.eval_expr interp, "x"
        assert_instance_of VCAN::Int, value
        assert_equal       3,         value.val
    end


    def test_single_group_field_some_idents
        interp = Api.eval_decls @interp, <<-EOS
            structure M = struct { val x = 3 val y = 4}

            import M { val (x, y) }
            EOS

        value_1 = Api.eval_expr interp, "x"
        assert_instance_of VCAN::Int, value_1
        assert_equal       3,         value_1.val

        value_2 = Api.eval_expr interp, "y"
        assert_instance_of VCAN::Int, value_2
        assert_equal       4,         value_2.val
    end


    def test_some_group_fields
        interp = Api.eval_decls @interp, <<-EOS
            structure M = struct { val x = 3 val y = 4 val z = 5}

            import M { val (x) val (y, z) }
            EOS

        value_1 = Api.eval_expr interp, "x"
        assert_instance_of VCAN::Int, value_1
        assert_equal       3,         value_1.val

        value_2 = Api.eval_expr interp, "y"
        assert_instance_of VCAN::Int, value_2
        assert_equal       4,         value_2.val

        value_3 = Api.eval_expr interp, "z"
        assert_instance_of VCAN::Int, value_3
        assert_equal       5,         value_3.val
    end
end

end # Umu::Test::Grammar::ModuleLanguage::Declaration

end # Umu::Test::Grammar::ModuleLanguage

end # Umu::Test::Grammar

end # Umu::Test

end # Umu
