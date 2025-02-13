# coding: utf-8
# frozen_string_literal: true



module Umu

module ConcreteSyntax

module Core

module Expression

module Unary

module Container

class Stream < Container::Abstract
    attr_reader :opt_last_expr


    def initialize(loc, is_memorized, exprs, opt_last_expr)
        ASSERT.bool         is_memorized
        ASSERT.kind_of      exprs,          ::Array
        ASSERT.opt_kind_of  opt_last_expr,  CSCE::Abstract
        ASSERT.assert (
            if exprs.empty? then opt_last_expr.nil? else true end
        )

        super(loc, exprs)

        @is_memorized  = is_memorized
        @opt_last_expr = opt_last_expr
    end


    def memorized?
        @is_memorized
    end


    def to_s
        [
            '&',

            __bb_str__,

            self.map(&:to_s).join(', '),

            if self.opt_last_expr
                '|' + self.opt_last_expr.to_s
            else
                ''
            end,

            __eb_str__
        ].join
    end


    def pretty_print(q)
        bb = '&' + __bb_str__
        eb = __eb_str__

        if self.opt_last_expr
            PRT.group_for_enum q, self, bb:bb, join:', '
            PRT.group q, bb:'|', eb:eb do
                q.pp self.opt_last_expr
            end
        else
            PRT.group_for_enum q, self, bb:bb, eb:eb, join:', '
        end
    end


private

    def __bb_str__
        self.memorized? ? '{' : '['
    end


    def __eb_str__
        self.memorized? ? '}' : ']'
    end


    def __desugar__(env, event)
        new_env = env.enter event

        exprs = self.map { |expr| expr.desugar new_env }

        opt_last_expr = if self.opt_last_expr
                            self.opt_last_expr.desugar new_env
                        else
                            nil
                        end

        ASCE.make_stream self.loc, self.memorized?, exprs, opt_last_expr
    end
end

end # Umu::ConcreteSyntax::Core::Expression::Unary::Container

end # Umu::ConcreteSyntax::Core::Expression::Unary


module_function

    def make_stream(loc, exprs, opt_last_expr = nil)
        ASSERT.kind_of      loc,            LOC::Entry
        ASSERT.kind_of      exprs,          ::Array
        ASSERT.opt_kind_of  opt_last_expr,  CSCE::Abstract

        Unary::Container::Stream.new(
            loc, false, exprs.freeze, opt_last_expr
        ).freeze
    end


    def make_memo_stream_nil(loc)
        ASSERT.kind_of loc, LOC::Entry

        Unary::Container::Stream.new(
            loc, true, [].freeze, nil
        ).freeze
    end


    def make_memo_stream_cons(loc, head_expr, tail_expr)
        ASSERT.kind_of loc,         LOC::Entry
        ASSERT.kind_of head_expr,   CSCE::Abstract
        ASSERT.kind_of tail_expr,   CSCE::Abstract

        Unary::Container::Stream.new(
            loc, true, [head_expr].freeze, tail_expr
        ).freeze
    end

end # Umu::ConcreteSyntax::Core::Expression

end # Umu::ConcreteSyntax::Core

end # Umu::ConcreteSyntax

end # Umu
