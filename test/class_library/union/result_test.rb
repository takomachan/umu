# frozen_string_literal: true

require "test_helper"


module Umu

module Test

module Library

module Class

module Union

module Result

class OkTest < Minitest::Test
    def setup
        @interp = Api.setup_interpreter
    end


    def test_cmeth_make
        value = Api.eval_expr @interp, "&Ok.make @Apple"
        assert_instance_of VCU::Result::Ok, value
        assert_instance_of VCA::Symbol,     value.contents
        assert_equal       :Apple,          value.contents.val
    end


    def test_imeth_show
        value = Api.eval_expr @interp, "&Ok.make @Apple.show"
        assert_instance_of VCA::String,     value
        assert_equal       '&Ok @Apple',    value.val
    end


    def test_imeth_to_s
        value = Api.eval_expr @interp, "&Ok.make @Apple.to-s"
        assert_instance_of VCA::String, value
        assert_equal       '&Ok Apple', value.val
    end


    def test_imeth_is_ok
        value = Api.eval_expr @interp, "&Ok.make @Apple.Ok?"
        assert_instance_of VCA::Bool,   value
        assert_equal       true,        value.val
    end


    def test_imeth_is_err
        value = Api.eval_expr @interp, "&Ok.make @Apple.Err?"
        assert_instance_of VCA::Bool,   value
        assert_equal       false,       value.val
    end


    def test_imess_equal
        interp_1 = Api.eval_decls @interp, <<-EOS
            val o1 = &Ok.make @Apple
            val o2 = &Ok.make @Apple
            EOS

        value = Api.eval_expr interp_1, "o1.== o2"
        assert_instance_of VCA::Bool,   value
        assert_equal       true,        value.val

        value = Api.eval_expr interp_1, "o1.== 4"
        assert_instance_of VCA::Bool,   value
        assert_equal       false,       value.val

        value = Api.eval_expr interp_1, <<-EOS
            o1.== (&Err.make @Banana)
            EOS
        assert_instance_of VCA::Bool,   value
        assert_equal       false,       value.val

        value = Api.eval_expr interp_1, <<-EOS
            o1.== (&Ok.make @Banana)
            EOS
        assert_instance_of VCA::Bool,   value
        assert_equal       false,       value.val
    end


    def test_imess_less_than
        interp_1 = Api.eval_decls @interp, <<-EOS
            val o = &Ok.make @Apple
            EOS

        value = Api.eval_expr interp_1, "o.< o"
        assert_instance_of VCA::Bool,   value
        assert_equal       false,       value.val

        value = Api.eval_expr interp_1, "o.< (&Ok.make @Banana)"
        assert_instance_of VCA::Bool,   value
        assert_equal       true,         value.val

        value = Api.eval_expr interp_1, "o.< (&Ok.make @A)"
        assert_instance_of VCA::Bool,   value
        assert_equal       false,        value.val

        value = Api.eval_expr interp_1, "o.< (&Err.make @Carrot)"
        assert_instance_of VCA::Bool,   value
        assert_equal       true,        value.val

        value = Api.eval_expr interp_1, 'o.< (&Err.make "Carrot")'
        assert_instance_of VCA::Bool,   value
        assert_equal       true,        value.val
    end
end



class ErrTest < Minitest::Test
    def setup
        @interp = Api.setup_interpreter
    end


    def test_cmeth_make
        value = Api.eval_expr @interp, "&Err.make @Apple"
        assert_instance_of VCU::Result::Err,    value
        assert_instance_of VCA::Symbol,         value.contents
        assert_equal       :Apple,              value.contents.val
    end


    def test_imeth_show
        value = Api.eval_expr @interp, "&Err.make @Apple.show"
        assert_instance_of VCA::String,     value
        assert_equal       '&Err @Apple',   value.val
    end


    def test_imeth_to_s
        value = Api.eval_expr @interp, "&Err.make @Apple.to-s"
        assert_instance_of VCA::String,     value
        assert_equal       '&Err Apple',    value.val
    end


    def test_imeth_is_ok
        value = Api.eval_expr @interp, "&Err.make @Apple.Ok?"
        assert_instance_of VCA::Bool,   value
        assert_equal       false,       value.val
    end


    def test_imeth_is_err
        value = Api.eval_expr @interp, "&Err.make @Apple.Err?"
        assert_instance_of VCA::Bool,   value
        assert_equal       true,        value.val
    end


    def test_imess_equal
        interp_1 = Api.eval_decls @interp, <<-EOS
            val e1 = &Err.make @Apple
            val e2 = &Err.make @Apple
            EOS

        value = Api.eval_expr interp_1, "e1.== e2"
        assert_instance_of VCA::Bool,   value
        assert_equal       true,        value.val

        value = Api.eval_expr interp_1, "e1.== 4"
        assert_instance_of VCA::Bool,   value
        assert_equal       false,       value.val

        value = Api.eval_expr interp_1, <<-EOS
            e1.== (&Ok.make @Banana)
            EOS
        assert_instance_of VCA::Bool,   value
        assert_equal       false,       value.val

        value = Api.eval_expr interp_1, <<-EOS
            e1.== (&Err.make @Banana)
            EOS
        assert_instance_of VCA::Bool,   value
        assert_equal       false,       value.val
    end


    def test_imess_less_than
        interp_1 = Api.eval_decls @interp, <<-EOS
            val o = &Err.make @Apple
            EOS

        value = Api.eval_expr interp_1, "o.< o"
        assert_instance_of VCA::Bool,   value
        assert_equal       false,       value.val

        value = Api.eval_expr interp_1, "o.< (&Err.make @Banana)"
        assert_instance_of VCA::Bool,   value
        assert_equal       true,         value.val

        value = Api.eval_expr interp_1, "o.< (&Err.make @A)"
        assert_instance_of VCA::Bool,   value
        assert_equal       false,        value.val

        value = Api.eval_expr interp_1, "o.< (&Ok.make @Carrot)"
        assert_instance_of VCA::Bool,   value
        assert_equal       false,       value.val

        value = Api.eval_expr interp_1, 'o.< (&Ok.make "Carrot")'
        assert_instance_of VCA::Bool,   value
        assert_equal       false,       value.val
    end
end

end # Umu::Test::Library::Class::Union::Result

end # Umu::Test::Library::Class::Union

end # Umu::Test::Library::Class

end # Umu::Test::Library

end # Umu::Test

end # Umu
