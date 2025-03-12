# frozen_string_literal: true

require "test_helper"



class UmuTest < Minitest::Test
    def test_that_it_has_a_version_number
        refute_nil ::Umu::VERSION
    end

    def test_it_does_something_useful
        assert true
    end
end



class BasicTest < Minitest::Test
    API = Umu::Api


    def test_int
        interp = API.make_interpreter

        value = API.eval_expr interp, "3"

        assert_kind_of  Umu::VCAN::Int, value
        assert_equal    3,              value.val
    end
end
