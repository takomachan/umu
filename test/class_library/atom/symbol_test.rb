# frozen_string_literal: true

require "test_helper"


module Umu

module Test

module Library

module Class

module Atom

class SymbolTest < Minitest::Test
    def setup
        @interp = Api.setup_interpreter
    end


    def test_imess_show
        value = Api.eval_expr @interp, '@Apple.show'
        assert_instance_of VCA::String, value
        assert_equal       '@Apple',    value.val
    end


    def test_imess_to_s
        value = Api.eval_expr @interp, '@Apple.to-s'
        assert_instance_of VCA::String, value
        assert_equal       'Apple',     value.val
    end


    def test_imess_less_than
        value = Api.eval_expr @interp, '@Apple.< @Banana'
        assert_instance_of VCA::Bool,   value
        assert_equal       true,        value.val

        value = Api.eval_expr @interp, '@Apple.< @Apple'
        assert_instance_of VCA::Bool,   value
        assert_equal       false,       value.val
    end
end

end # Umu::Test::Library::Class::Atom

end # Umu::Test::Library::Class

end # Umu::Test::Library

end # Umu::Test

end # Umu
