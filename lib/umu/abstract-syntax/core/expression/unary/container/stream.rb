# coding: utf-8
# frozen_string_literal: true



module Umu

module AbstractSyntax

module Core

module Expression

module Unary

module Container

class Stream < Abstraction::Expressions
    attr_reader :opt_last_expr


    def initialize(loc, exprs, opt_last_expr = nil)
        ASSERT.kind_of     exprs,           ::Array
        ASSERT.opt_kind_of opt_last_expr,   ASCE::Abstract
        ASSERT.assert (
            if exprs.empty? then opt_last_expr.nil? else true end
        )

        super(loc, exprs)

        @opt_last_expr = opt_last_expr
    end


    def empty?
        self.exprs.empty? && self.opt_last_expr.nil?
    end


    def to_s
        format("&{%s%s}",
            self.map(&:to_s).join(', '),

            if self.opt_last_expr
                '|' + self.opt_last_expr.to_s
            else
                ''
            end
        )
    end


    def pretty_print(q)
        if self.opt_last_expr
            PRT.group_for_enum q, self, bb:'&{', join:', '
            PRT.group q, bb:'|', eb:'}' do
                q.pp self.opt_last_expr
            end
        else
            PRT.group_for_enum q, self, bb:'&{', eb:'}', join:', '
        end
    end


private

    def __evaluate__(env, event)
        new_env = env.enter event

        init_stream =
            if self.opt_last_expr
                VC.make_stream_expr_entry(
                    self.opt_last_expr,
                    new_env.va_context
                )
            else
                VC.make_stream_nil new_env.va_context
            end

        result = self.exprs.reverse.inject(init_stream) { |stream, expr|
                    VC.make_stream_cons expr, stream, new_env.va_context
                }

        ASSERT.kind_of result, VC::Stream::Entry::Cell
    end
end

end # Umu::AbstractSyntax::Core::Expression::Unary::Container

end # Umu::AbstractSyntax::Core::Expression::Unary


module_function

    def make_stream(loc, exprs, opt_last_expr = nil)
        ASSERT.kind_of     loc,             LOC::Entry
        ASSERT.kind_of     exprs,           ::Array
        ASSERT.opt_kind_of opt_last_expr,   ASCE::Abstract

        Unary::Container::Stream.new(
            loc, exprs.freeze, opt_last_expr
        ).freeze
    end

end # Umu::AbstractSyntax::Core::Expression

end # Umu::AbstractSyntax::Core

end # Umu::AbstractSyntax

end # Umu
