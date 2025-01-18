# coding: utf-8
# frozen_string_literal: true



module Umu

module Value

module Core

class File < Object
    define_class_method(
        :meth_make_stdin,
        :stdin, [],
        [], VC::IO::Input
    )
    def self.meth_make_stdin(_loc, _env, _event)
        VC.make_input ::STDIN
    end


    define_class_method(
        :meth_make_stdout,
        :stdout, [],
        [], VC::IO::Output
    )
    def self.meth_make_stdout(_loc, _env, _event)
        VC.make_output ::STDOUT
    end


    define_class_method(
        :meth_make_stderr,
        :stderr, [],
        [], VC::IO::Output
    )
    def self.meth_make_stderr(_loc, _env, _event)
        VC.make_output ::STDOUT
    end


    define_class_method(
        :meth_see,
        :see, [],
        [VCBA::String], VC::IO::Input
    )
    def self.meth_see(_loc, _env, _event, file_path)
        ASSERT.kind_of file_path, VCBA::String

        file = ::File.open file_path.val, "r"

        VC.make_input file
    end


    define_class_method(
        :meth_see_with,
        :'see-with', [],
        [VCBA::String, VC::Fun], VC::Unit
    )
    def self.meth_see_with(loc, env, event, file_path, func)
        ASSERT.kind_of file_path, VCBA::String
        ASSERT.kind_of func,      VC::Fun

        ::File.open(file_path.val, "r") do |file|
            func.apply VC.make_input(file), [], loc, env.enter(event)
        end

        VC.make_unit
    end


    define_class_method(
        :meth_tell,
        :tell, [],
        [VCBA::String], VC::IO::Output
    )
    def self.meth_tell(_loc, _env, _event, file_path)
        ASSERT.kind_of file_path, VCBA::String

        file = ::File.open file_path.val, "a"

        VC.make_output file
    end


    define_class_method(
        :meth_tell_with,
        :'tell-with', [],
        [VCBA::String, VC::Fun], VC::Unit
    )
    def self.meth_tell_with(loc, env, event, file_path, func)
        ASSERT.kind_of file_path, VCBA::String
        ASSERT.kind_of func,      VC::Fun

        ::File.open(file_path.val, "a") do |file|
            func.apply VC.make_output(file), [], loc, env.enter(event)
        end

        VC.make_unit
    end
end
File.freeze

end # Umu::Value::Core

end # Umu::Value

end # Umu
