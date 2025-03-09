# coding: utf-8
# frozen_string_literal: true



module Umu

module Value

module Core

module Morph

module Stream

module Cell

class Abstract < Top
    TYPE_SYM = :StreamCell


    def nil?
        raise X::InternalSubclassResponsibility
    end


    def step(env)
        VC.make_cell_stream_entry self, env.va_context
    end


    def force(_loc, _env, _event)
        raise X::InternalSubclassResponsibility
    end
end



class Nil < Abstract
    TYPE_SYM = :StreamNil


    def nil?
        true
    end


    def to_s
        '&{}'
    end


    def force(_loc, _env, _event)
        VC.make_none
    end
end
Nil.freeze

NIL = Nil.new.freeze



class Cons < Abstract
    TYPE_SYM = :StreamCons



    attr_reader :head_expr, :tail_stream

    def initialize(head_expr, tail_stream)
        ASSERT.kind_of head_expr,   ASCE::Abstract
        ASSERT.kind_of tail_stream, Stream::Entry::Abstract

        @head_expr   = head_expr
        @tail_stream = tail_stream
    end


    def nil?
        false
    end


    def to_s
        format("&{ %s | %s }",
                 self.head_expr.to_s,
                 self.tail_stream.to_s
        )
    end


    def force(loc, env, event)
        new_env = env.enter event

        head_value  = self.head_expr.evaluate(new_env).value

        tail_stream  = self.tail_stream.step(new_env)
        unless tail_stream.kind_of? Stream::Entry::Abstract
            raise X::TypeError.new(
                loc,
                new_env,
                "force: Expected a Stream, but %s : %s",
                tail_stream.to_s,
                tail_stream.type_sym.to_s
            )
        end

        if (
            head_value.kind_of?(Stream::Entry::Abstract) &&
            head_value.cell.nil? &&
            tail_stream.cell.nil?
        )
            VC.make_none
        else
            VC.make_some VC.make_tuple(head_value, tail_stream)
        end
    end
end
Cons.freeze



module_function

    def make_nil
        NIL
    end


    def make_cons(head_expr, tail_stream)
        ASSERT.kind_of head_expr,   ASCE::Abstract
        ASSERT.kind_of tail_stream, Stream::Entry::Abstract

        Cons.new(head_expr, tail_stream).freeze
    end

end # Umu::Value::Morph::Core::Stream::Cell

end # Umu::Value::Morph::Core::Stream

end # Umu::Value::Morph::Core

end # Umu::Value::Morph

end # Umu::Value

end # Umu
