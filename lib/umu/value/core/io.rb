# coding: utf-8
# frozen_string_literal: true



module Umu

module Value

module Core

class IO < Top
    define_class_method(
        :meth_make_stdin,
        :stdin, [],
        [], self
    )
    def self.meth_make_stdin(_loc, _env, _event)
        VC.make_stdin
    end


    define_class_method(
        :meth_make_stdout,
        :stdout, [],
        [], self
    )
    def self.meth_make_stdout(_loc, _env, _event)
        VC.make_stdout
    end


    define_class_method(
        :meth_make_stderr,
        :stderr, [],
        [], self
    )
    def self.meth_make_stderr(_loc, _env, _event)
        VC.make_stderr
    end


    attr_reader :io


    def initialize(io)
        ASSERT.kind_of io, ::IO

        super()

        @io = io
    end


    def to_s
        self.io.inspect
    end


    define_instance_method(
        :meth_get_string,
        :gets, [],
        [], VCBLU::Option::Abstract
    )
    def meth_get_string(_loc, _env, _event)
        s = self.io.gets

        if s
            VC.make_some VC.make_string(s.chomp)
        else
            VC.make_none
        end
    end


    define_instance_method(
        :meth_put_string,
        :puts, [],
        [VCBA::String], VC::Unit
    )
    def meth_put_string(_loc, _env, event, value)
        ASSERT.kind_of value, VCBA::String

        self.io.print value.val

        VC.make_unit
    end


    define_instance_method(
        :meth_pretty_print,
        :pp, [],
        [VC::Top], VC::Unit
    )
    def meth_pretty_print(_loc, _env, event, value)
        ASSERT.kind_of value, VC::Top

        PP.pp value, self.io

        VC.make_unit
    end
end
IO.freeze

STDIN   = IO.new(::STDIN).freeze
STDOUT  = IO.new(::STDOUT).freeze
STDERR  = IO.new(::STDERR).freeze


module_function

    def make_stdin
        STDIN
    end


    def make_stdout
        STDOUT
    end


    def make_stderr
        STDERR
    end

end # Umu::Value::Core

end # Umu::Value

end # Umu
