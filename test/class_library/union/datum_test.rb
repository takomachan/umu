# frozen_string_literal: true

require "test_helper"


module Umu

module Test

module Library

module Class

module Union

class DatumTest < Minitest::Test
    def setup
        @interp = Api.setup_interpreter
    end


    def test_cmeth_make
        value_1 = Api.eval_expr @interp, <<-EOS
            &Datum.make @Fruits (@Apple, "Aomori")
            EOS
        assert_instance_of VCU::Datum,      value_1
        assert_instance_of ::Symbol,        value_1.tag_sym
        assert_equal       :Fruits,         value_1.tag_sym
        assert_instance_of VCP::Tuple,      value_1.contents

        value_2 = Api.eval_expr @interp, <<-EOS
            &Datum.(tag:@Fruits contents:(@Apple, "Aomori"))
            EOS
        assert_instance_of VCU::Datum,      value_2
        assert_instance_of ::Symbol,        value_2.tag_sym
        assert_equal       :Fruits,         value_2.tag_sym
        assert_instance_of VCP::Tuple,      value_2.contents
    end


    def test_imeth_show
        value = Api.eval_expr @interp, <<-EOS
            &Datum.make @Fruits (@Apple, "Aomori").show
            EOS
        assert_instance_of VCA::String,                 value
        assert_equal       'Fruits (@Apple, "Aomori")', value.val
    end


    def test_imeth_to_s
        value = Api.eval_expr @interp, <<-EOS
            &Datum.make @Fruits (@Apple, "Aomori").to-s
            EOS
        assert_instance_of VCA::String,                 value
        assert_equal       'Fruits (Apple, Aomori)', value.val
    end


    def test_imess_equal
        interp_1 = Api.eval_decls @interp, <<-EOS
            val d1 = &Datum.make @Fruits (@Apple, 300)
            val d2 = &Datum.make @Fruits (@Apple, 300)
            EOS

        value = Api.eval_expr interp_1, "d1.== d2"
        assert_instance_of VCA::Bool,   value
        assert_equal       true,        value.val

        value = Api.eval_expr interp_1, "d1.== 4"
        assert_instance_of VCA::Bool,   value
        assert_equal       false,       value.val

        value = Api.eval_expr interp_1, <<-EOS
            d1.== (&Datum.make @Vegetables (@Apple, 300))
            EOS
        assert_instance_of VCA::Bool,   value
        assert_equal       false,       value.val

        value = Api.eval_expr interp_1, <<-EOS
            d1.== (&Datum.make @Fruits (@Apple, 500))
            EOS
        assert_instance_of VCA::Bool,   value
        assert_equal       false,       value.val
    end


    def test_imess_less_than
        interp_1 = Api.eval_decls @interp, <<-EOS
            val d = &Datum.make @Fruits (@Apple, 300)
            EOS

        value = Api.eval_expr interp_1, "d.< d"
        assert_instance_of VCA::Bool,   value
        assert_equal       false,       value.val

        value = Api.eval_expr interp_1, <<-EOS
            d.< (&Datum.make @Alpha (@Apple, 300))
            EOS
        assert_instance_of VCA::Bool,   value
        assert_equal       false,        value.val

        value = Api.eval_expr interp_1, <<-EOS
            d.< (&Datum.make @Gamma (@Apple, 300))
            EOS
        assert_instance_of VCA::Bool,   value
        assert_equal       true,       value.val

        value = Api.eval_expr interp_1, <<-EOS
            d.< (&Datum.make @Fruits (@Apple, 500))
            EOS
        assert_instance_of VCA::Bool,   value
        assert_equal       true,         value.val

        value = Api.eval_expr interp_1, <<-EOS
            d.< (&Datum.make @Fruits (@Apple, 100))
            EOS
        assert_instance_of VCA::Bool,   value
        assert_equal       false,      value.val
    end
end

end # Umu::Test::Library::Class::Union

end # Umu::Test::Library::Class

end # Umu::Test::Library

end # Umu::Test

end # Umu
