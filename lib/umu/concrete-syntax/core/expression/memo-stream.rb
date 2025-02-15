# coding: utf-8
# frozen_string_literal: true



module Umu

module ConcreteSyntax

module Core

module Expression

module MemoStream

class Abstract < Expression::Abstract; end




class Nil < Abstract
    def to_s
        '&{}'
    end


    def pretty_print(q)
        q.text '&{}'
    end


private

    def __desugar__(env, event)
        ASCE.make_memo_stream_nil self.loc
    end
end



class Cons < Abstract
    attr_reader :head_expr, :tail_expr

    def initialize(loc, head_expr, tail_expr)
        ASSERT.kind_of head_expr,   CSCE::Abstract
        ASSERT.kind_of tail_expr,   CSCE::Abstract

        super(loc)

        @head_expr = head_expr
        @tail_expr = tail_expr
    end


    def to_s
        format("&{%s | %s}",
            self.head_expr.to_s,
            self.tail_expr.to_s
        )
    end


    def pretty_print(q)
        PRT.group q, bb:'&{', eb:'}' do
            q.pp self.head_expr

            q.breakable

            q.text '|'

            q.breakable

            q.pp self.tail_expr
        end
    end




private

    def __desugar__(env, event)
        new_env = env.enter event

        ASCE.make_memo_stream_cons(
            self.loc,
            self.head_expr.desugar(new_env),
            self.tail_expr.desugar(new_env)
        )
    end
end



class Suspended < Abstract
    attr_reader :expr

    def initialize(loc, expr)
        ASSERT.kind_of expr, CSCE::Abstract

        super(loc)

        @expr = expr
    end


    def to_s
        format "&{ %s }", self.expr.to_s
    end


    def pretty_print(q)
        PRT.group q, bb:'&{', eb:'}', sep:' ' do
            q.pp self.expr
        end
    end




private

    def __desugar__(env, event)
        new_env = env.enter event

        ASCE.make_suspended_stream(
            self.loc,
            self.expr.desugar(new_env)
        )
    end
end

end # Umu::ConcreteSyntax::Core::Expression::MemoStream


module_function

    def make_memo_stream_nil(loc)
        ASSERT.kind_of loc, LOC::Entry

        MemoStream::Nil.new(loc).freeze
    end


    def make_memo_stream_cons(loc, head_expr, tail_expr)
        ASSERT.kind_of loc,         LOC::Entry
        ASSERT.kind_of head_expr,   CSCE::Abstract
        ASSERT.kind_of tail_expr,   CSCE::Abstract

        MemoStream::Cons.new(loc, head_expr, tail_expr).freeze
    end


    def make_suspended_stream(loc, expr)
        ASSERT.kind_of loc,     LOC::Entry
        ASSERT.kind_of expr,    CSCE::Abstract

        MemoStream::Suspended.new(loc, expr).freeze
    end

end # Umu::ConcreteSyntax::Core::Expression

end # Umu::ConcreteSyntax::Core

end # Umu::ConcreteSyntax

end # Umu
