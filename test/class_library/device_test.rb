# frozen_string_literal: true

require "test_helper"


module Umu

module Test

module Library

module Class

class DeviceTest < Minitest::Test
    def setup
        @interp = Api.setup_interpreter
    end


    def test_cmess_stdin
        value = Api.eval_expr @interp, "&Device.stdin"
        assert_instance_of VC::IO::Input,   value
        assert_equal       ::STDIN,         value.io
    end


    def test_cmess_stdout
        value = Api.eval_expr @interp, "&Device.stdout"
        assert_instance_of  VC::IO::Output, value
        assert_equal       ::STDOUT,        value.io
    end


    def test_cmess_stderr
        value = Api.eval_expr @interp, "&Device.stderr"
        assert_instance_of  VC::IO::Output, value
        assert_equal       ::STDERR,        value.io
    end
end

end # Umu::Test::Library::Class

end # Umu::Test::Library

end # Umu::Test

end # Umu
