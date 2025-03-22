# frozen_string_literal: true

require "test_helper"


module Umu

module Test

module Library

module Class

module Product

class NamedTupleTest < Minitest::Test
    def setup
        @interp = Api.setup_interpreter
    end


    def test_imess_show
        value = Api.eval_expr @interp, '(name:@Apple area:"Aomori").show'
        assert_instance_of VCA::String,                     value
        assert_equal       '(name:@Apple area:"Aomori")',   value.val
    end


    def test_imess_to_s
        value = Api.eval_expr @interp, '(name:@Apple area:"Aomori").to-s'
        assert_instance_of VCA::String,                 value
        assert_equal       '(name:Apple area:Aomori)',    value.val
    end


    def test_imess_equal
        value = Api.eval_expr @interp, <<-EOS
            (name:@Apple price:300).== (name:@Apple price:300)
            EOS
        assert_instance_of VCA::Bool,   value
        assert_equal       true,        value.val

        value = Api.eval_expr @interp, <<-EOS
            (name:@Apple price:300).== 4
            EOS
        assert_instance_of VCA::Bool,   value
        assert_equal       false,       value.val

        value = Api.eval_expr @interp, <<-EOS
            (name:@Apple price:300).== (name:@Banana price:300)
            EOS
        assert_instance_of VCA::Bool,   value
        assert_equal       false,       value.val

        value = Api.eval_expr @interp, <<-EOS
            (name:@Apple price:300).== (name:@Apple  price:500)
            EOS
        assert_instance_of VCA::Bool,   value
        assert_equal       false,       value.val
    end


    def test_imess_less_than
        value = Api.eval_expr @interp, <<-EOS
            (name:@Apple price:300).< (name:@Banana price:300)
            EOS
        assert_instance_of VCA::Bool,   value
        assert_equal       true,        value.val

        value = Api.eval_expr @interp, <<-EOS
            (name:@Apple price:300).< (name:@Apple  price:500)
            EOS
        assert_instance_of VCA::Bool,   value
        assert_equal       true,        value.val

        assert_raises(X::TypeError) do
            Api.eval_expr @interp, <<-EOS
                (name:@Apple price:300).< 4
                EOS
        end

        value = Api.eval_expr @interp, <<-EOS
            (name:@Apple  price:300).< (name:@Apple  price:300)
            EOS
        assert_instance_of VCA::Bool,   value
        assert_equal       false,       value.val
    end
end

end # Umu::Test::Library::Class::Product

end # Umu::Test::Library::Class

end # Umu::Test::Library

end # Umu::Test

end # Umu
