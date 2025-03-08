# coding: utf-8
# frozen_string_literal: true



module Umu

module Value

module Core

module IO

class Abstract < Object
    attr_reader :io


    def initialize(io)
        ASSERT.kind_of io, ::IO

        super()

        @io = io
    end


    def to_s
        self.io.inspect
    end
end
Abstract.freeze



class Input  < Abstract
    define_instance_method(
        :meth_seen,
        :seen, [],
        [], VC::Unit
    )
    def meth_seen(_loc, _env, _event)
        self.io.close unless self.io.tty?

        VC.make_unit
    end


    define_instance_method(
        :meth_get_string,
        :gets, [],
        [], VCU::Option::Abstract
    )
    def meth_get_string(_loc, _env, _event)
        s = self.io.gets

        if s
            VC.make_some VC.make_string(s.chomp)
        else
            VC.make_none
        end
    end


    FN_DEST = lambda { |input|
            result = (
                if input.io.eof?
                    VC.make_none
                else
                    s = input.io.gets
                    if s
                        str_val = VC.make_string s.chomp

                        VC.make_some(
                            VC.make_tuple(
                                str_val,
                                VC.make_enumerator(input, FN_DEST)
                            )
                        )
                    else
                       VC.make_none
                    end
                end
            )

            ASSERT.kind_of result, VCU::Option::Abstract
        }

    define_instance_method(
        :meth_each_line,
        :'each-line', [],
        [], VCM::Enum::Abstract
    )
    def meth_each_line(_loc, _env, _event)
        VC.make_enumerator self, FN_DEST
    end
end
Input.freeze



class Output < Abstract
    define_instance_method(
        :meth_told,
        :told, [],
        [], VC::Unit
    )
    def meth_told(_loc, _env, _event)
        self.io.close unless self.io.tty?

        VC.make_unit
    end


    define_instance_method(
        :meth_put_string,
        :puts, [],
        [VCA::String], VC::Unit
    )
    def meth_put_string(_loc, _env, _event, value)
        ASSERT.kind_of value, VCA::String

        self.io.print value.val

        VC.make_unit
    end


    define_instance_method(
        :meth_flush,
        :flush, [],
        [], VC::Unit
    )
    def meth_flush(_loc, _env, _event)
        self.io.flush

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
Output.freeze

end # Umu::Value::Core::IO



module_function

    def make_input(io)
        ASSERT.kind_of io, ::IO

        IO::Input.new(io).freeze
    end


    def make_output(io)
        ASSERT.kind_of io, ::IO

        IO::Output.new(io).freeze
    end

end # Umu::Value::Core

end # Umu::Value

end # Umu
