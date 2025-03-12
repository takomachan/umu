# frozen_string_literal: true

require "test_helper"


module Umu

class T3SyntaxTest <  Minitest::Test; end

class T31CoreLangTest <  Minitest::Test; end

class T311AtomicExpressionTest < Minitest::Test
=begin
<atomic-expression> ::= 
    <identifier>
  | <constant>
=end
end



class T3111IdentifierTest < Minitest::Test
=begin
<identifier> ::= 
    ID
  | "(" <infix-operator> ")"
  | MODULE-DIR <module-path> ID
  | MODULE-DIR <module-path> "(" <infix-operator> ")"
  | "&" ID

<module-path> ::= /* empty */ | MODULE-DIR <module-path>
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
    end


    def test_long_identifier
        value = Api.eval_expr @interp, "Umu::TRUE"
        assert_instance_of  VCA::Bool, value
        assert_equal        true,      value.val
    end


    def test_long_infix_operator
        value = Api.eval_expr @interp, "Umu::Prelude::(+)"
        assert_instance_of  VC::Fun, value
    end


    def test_class_instance
        value = Api.eval_expr @interp, "&(Int)"
        # FIXME -- Never return from assert_instance_of
        #assert_instance_of  VC::Class, value
    end
end

end # Umu
