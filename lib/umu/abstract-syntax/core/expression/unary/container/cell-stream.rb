# coding: utf-8
# frozen_string_literal: true



module Umu

module AbstractSyntax

module Core

module Expression

module Unary

module Container

class CellStream < Abstraction::Expressions
    attr_reader :opt_last_expr


    def initialize(loc, exprs, opt_last_expr, is_memorized)
        ASSERT.kind_of     exprs,           ::Array
        ASSERT.opt_kind_of opt_last_expr,   ASCE::Abstract
        ASSERT.bool        is_memorized
        ASSERT.assert (
            if exprs.empty? then opt_last_expr.nil? else true end
        )

        super(loc, exprs)

        @opt_last_expr = opt_last_expr
        @is_memorized  = is_memorized
    end


    def empty?
        self.exprs.empty? && self.opt_last_expr.nil?
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


    def __evaluate__(env, event)
        new_env = env.enter event

        result = (
             if self.memorized?
                VC.make_memo_stream_entry self, new_env.va_context
            else
                init_stream =
                    if self.opt_last_expr
                        VC.make_expr_stream_entry(
                            self.opt_last_expr,
                            new_env.va_context
                        )
                    else
                        VC.make_cell_stream_nil new_env.va_context
                    end

                self.exprs.reverse.inject(init_stream) {
                    |stream, expr|

                    VC.make_cell_stream_cons(
                        expr, stream, new_env.va_context
                    )
                }
            end
        )

        ASSERT.kind_of result, VCM::Stream::Entry::Abstract
    end
end

end # Umu::AbstractSyntax::Core::Expression::Unary::Container

end # Umu::AbstractSyntax::Core::Expression::Unary


module_function

    def make_stream(loc, exprs, opt_last_expr = nil, is_memorized = false)
        ASSERT.kind_of     loc,             LOC::Entry
        ASSERT.kind_of     exprs,           ::Array
        ASSERT.opt_kind_of opt_last_expr,   ASCE::Abstract
        ASSERT.bool        is_memorized

        Unary::Container::CellStream.new(
            loc, exprs.freeze, opt_last_expr, is_memorized
        ).freeze
    end

end # Umu::AbstractSyntax::Core::Expression

end # Umu::AbstractSyntax::Core

end # Umu::AbstractSyntax

end # Umu
