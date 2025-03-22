# frozen_string_literal: true

require "test_helper"


module Umu

module Test

module Library

module Class

module Union

module Option

class NoneTest < Minitest::Test
    def setup
        @interp = Api.setup_interpreter
    end


    def test_cmeth_make
        value = Api.eval_expr @interp, "&None.make"
        assert_instance_of VCU::Option::None,   value
    end


    def test_imeth_show
        value = Api.eval_expr @interp, "&None.make.show"
        assert_instance_of VCA::String, value
        assert_equal       '&None ()',  value.val
    end


    def test_imeth_to_s
        value = Api.eval_expr @interp, "&None.make.to-s"
        assert_instance_of VCA::String,  value
        assert_equal       '&None ()',   value.val
    end


    def test_imeth_is_none
        value = Api.eval_expr @interp, "&None.make.None?"
        assert_instance_of VCA::Bool,   value
        assert_equal       true,        value.val
    end


    def test_imeth_is_some
        value = Api.eval_expr @interp, "&None.make.Some?"
        assert_instance_of VCA::Bool,   value
        assert_equal       false,       value.val
    end


    def test_imess_equal
        interp_1 = Api.eval_decls @interp, <<-EOS
            val n1 = &None.make
            val n2 = &None.make
            EOS

        value = Api.eval_expr interp_1, "n1.== n1"
        assert_instance_of VCA::Bool,   value
        assert_equal       true,        value.val

        value = Api.eval_expr interp_1, "n1.== 4"
        assert_instance_of VCA::Bool,   value
        assert_equal       false,       value.val

        value = Api.eval_expr interp_1, <<-EOS
            n1.== (&Some.make @Apple)
            EOS
        assert_instance_of VCA::Bool,   value
        assert_equal       false,       value.val
    end


    def test_imess_less_than
        interp_1 = Api.eval_decls @interp, <<-EOS
            val n = &None.make
            EOS

        value = Api.eval_expr interp_1, "n.< n"
        assert_instance_of VCA::Bool,   value
        assert_equal       false,       value.val

        value = Api.eval_expr interp_1, "n.< (&Some.make @Apple)"
        assert_instance_of VCA::Bool,   value
        assert_equal       true,        value.val
    end
end



class SomeTest < Minitest::Test
    def setup
        @interp = Api.setup_interpreter
    end


    def test_cmeth_make
        value = Api.eval_expr @interp, "&Some.make @Apple"
        assert_instance_of VCU::Option::Some,   value
        assert_instance_of VCA::Symbol,         value.contents
        assert_equal       :Apple,              value.contents.val
    end


    def test_imeth_show
        value = Api.eval_expr @interp, "&Some.make @Apple.show"
        assert_instance_of VCA::String,     value
        assert_equal       '&Some @Apple',  value.val
    end


    def test_imeth_to_s
        value = Api.eval_expr @interp, "&Some.make @Apple.to-s"
        assert_instance_of VCA::String,     value
        assert_equal       '&Some Apple',   value.val
    end


    def test_imeth_is_none
        value = Api.eval_expr @interp, "&Some.make @Apple.None?"
        assert_instance_of VCA::Bool,   value
        assert_equal       false,       value.val
    end


    def test_imeth_is_some
        value = Api.eval_expr @interp, "&Some.make @Apple.Some?"
        assert_instance_of VCA::Bool,   value
        assert_equal       true,        value.val
    end


    def test_imess_equal
        interp_1 = Api.eval_decls @interp, <<-EOS
            val s1 = &Some.make @Apple
            val s2 = &Some.make @Apple
            EOS

        value = Api.eval_expr interp_1, "s1.== s2"
        assert_instance_of VCA::Bool,   value
        assert_equal       true,        value.val

        value = Api.eval_expr interp_1, "s1.== 4"
        assert_instance_of VCA::Bool,   value
        assert_equal       false,       value.val

        value = Api.eval_expr interp_1, <<-EOS
            s1.== (&Some.make @Banana)
            EOS
        assert_instance_of VCA::Bool,   value
        assert_equal       false,       value.val
    end


    def test_imess_less_than
        interp_1 = Api.eval_decls @interp, <<-EOS
            val s = &Some.make @Apple
            EOS

        value = Api.eval_expr interp_1, "s.< s"
        assert_instance_of VCA::Bool,   value
        assert_equal       false,       value.val

        value = Api.eval_expr interp_1, "s.< (&Some.make @Banana)"
        assert_instance_of VCA::Bool,   value
        assert_equal       true,         value.val

        value = Api.eval_expr interp_1, "s.< (&Some.make @A)"
        assert_instance_of VCA::Bool,   value
        assert_equal       false,        value.val
    end
end

end # Umu::Test::Library::Class::Union::Option

end # Umu::Test::Library::Class::Union

end # Umu::Test::Library::Class

end # Umu::Test::Library

end # Umu::Test

end # Umu
