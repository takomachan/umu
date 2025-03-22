# frozen_string_literal: true

require "test_helper"


module Umu

module Test

module Library

module Class

class UnitTest < Minitest::Test
    def setup
        @interp = Api.setup_interpreter
    end


    def test_imess_equal
        value = Api.eval_expr @interp, "().== ()"
        assert_instance_of VCA::Bool,   value
        assert_equal       true,        value.val

        value = Api.eval_expr @interp, "().== 4"
        assert_instance_of VCA::Bool,   value
        assert_equal       false,       value.val
    end
end

end # Umu::Test::Library::Class

end # Umu::Test::Library

end # Umu::Test

end # Umu
