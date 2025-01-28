# coding: utf-8
# frozen_string_literal: true



module Umu

module Value

module Core

class Dir < Object
    attr_reader :dir_enum


    def initialize(dir_enum)
        ASSERT.kind_of dir_enum, ::Enumerator

        super()

        @dir_enum = dir_enum
    end


    def to_s
        self.dir_enum.inspect
    end


    define_instance_method(
        :meth_seen,
        :seen, [],
        [], VC::Unit
    )
    def meth_seen(_loc, _env, _event)
        VC.make_unit
    end


    define_instance_method(
        :meth_get_string,
        :gets, [],
        [], VCLU::Option::Abstract
    )
    def meth_get_string(_loc, _env, _event)
        begin
            str = self.dir_enum.next

            VC.make_some VC.make_string str
        rescue ::StopIteration
            VC.make_none
        end
    end
end
Dir.freeze


module_function

    def make_dir(dir_enum)
        ASSERT.kind_of dir_enum, ::Enumerator

        Dir.new(dir_enum).freeze
    end

end # Umu::Value::Core

end # Umu::Value

end # Umu
