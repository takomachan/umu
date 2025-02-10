# coding: utf-8
# frozen_string_literal: true



module Umu

module Value

module Core

class Dir < Object
    attr_reader :obj


    def initialize(obj)
        ASSERT.kind_of obj, ::Dir

        super()

        @obj = obj
    end


    def to_s
        format "#Dir<\"%s\">", self.obj.path
    end


    define_instance_method(
        :meth_seen,
        :seen, [],
        [], VC::Unit
    )
    def meth_seen(_loc, _env, _event)
        self.obj.close

        VC.make_unit
    end


    define_instance_method(
        :meth_to_string,
        :'to-s', [],
        [], VCA::String
    )
    def meth_to_string(_loc, _env, _event)
        VC.make_string self.obj.path
    end


    FN_IS_EMPTY = lambda { |_dir| VC.make_false }

    FN_DEST = lambda { |dir|
                         s = dir.obj.read
                         unless s
                            raise ::StopIteration
                         end

                         str_val = VC.make_string s

                         VC.make_tuple str_val, dir
                     }

    define_instance_method(
        :meth_each,
        :'each', [],
        [], VCM::Enum
    )
    def meth_each(_loc, _env, _event)
        VC.make_enumerator self, FN_IS_EMPTY, FN_DEST
    end
end
Dir.freeze


module_function

    def make_dir(obj)
        ASSERT.kind_of obj, ::Dir

        Dir.new(obj).freeze
    end

end # Umu::Value::Core

end # Umu::Value

end # Umu
