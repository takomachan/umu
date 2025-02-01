# coding: utf-8
# frozen_string_literal: true



module Umu

module ConcreteSyntax

module Core

module Expression

module Binary

module Send

module Message

class Abstract < Expression::Abstract; end



class BasicMessage < Abstract
    attr_reader :sym, :exprs


    def initialize(loc, sym, exprs)
        ASSERT.kind_of sym,     ::Symbol
        ASSERT.kind_of exprs,   ::Array

        super(loc)

        @sym    = sym
        @exprs  = exprs
    end


    def to_s
        format(".%s",
            if self.exprs.empty?
                self.sym.to_s
            else
                format "(%s %s)",
                        self.sym.to_s,
                        self.exprs.map(&:to_s).join(' ')
            end
        )
    end


    def pretty_print(q)
        PRT.group_for_enum(
            q,

            self.exprs,

            bb: format(self.exprs.empty? ? ".%s" : ".(%s ", self.sym.to_s),

            eb: self.exprs.empty? ? '' : ')',

            join: ' '
        )
    end


private

    def __desugar__(env, event)
        new_env = env.enter event

        ASCE.make_message(
            self.loc,
            self.sym,
            self.exprs.map { |expr| expr.desugar(new_env) },
        )
    end
end



class ApplyMessage < Abstract
    attr_reader :head_expr, :tail_exprs


    def initialize(loc, head_expr, tail_exprs)
        ASSERT.kind_of head_expr,  CSCE::Abstract
        ASSERT.kind_of tail_exprs, ::Array

        super(loc)

        @head_expr   = head_expr
        @tail_exprs  = tail_exprs
    end


    def to_s
        format(".[%s]",
            ([self.head_expr.to_s] + self.tail_exprs).map(&:to_s).join(', ')
        )
    end


    def pretty_print(q)
        PRT.group_for_enum(
            q,
            [self.head_expr] + self.tail_exprs,
            bb: '.[',
            eb: ']',
            join: ', '
        )
    end


private

    def __desugar__(env, event)
        new_env = env.enter event

        message = case self.tail_exprs.size
                when 0
                    expr = [self.head_expr.desugar(new_env)]

                    ASCE.make_message self.loc, :apply, expr
                when 1
                    exprs = [
                        self.head_expr.desugar(new_env),
                        self.tail_exprs[0].desugar(new_env)
                    ]

                    ASCE.make_message self.loc, :'apply-binary', exprs
                else
                    second_expr, *tail_exprs = self.tail_exprs
                    exprs = [
                        self.head_expr.desugar(new_env),

                        second_expr.desugar(new_env),

                        ASCE.make_list(
                            tail_exprs[0].loc,
                            tail_exprs.map { |expr| expr.desugar new_env }
                        )
                    ]

                    ASCE.make_message self.loc, :'apply-nary', exprs
                end

        ASSERT.kind_of message, ASCE::Binary::Send::Message
    end
end



class KeywordMessage < Abstract
    attr_reader :head_field, :tail_fields


    def initialize(loc, head_field, tail_fields)
        ASSERT.tuple_of    head_field,    [
                            CSCEU::Container::Named::Label, ::Object
                        ]
        ASSERT.opt_kind_of head_field[1], CSCE::Abstract
        ASSERT.kind_of     tail_fields,   ::Array
        tail_fields.each do |lab, expr|
            ASSERT.kind_of     lab,  CSCEU::Container::Named::Label
            ASSERT.opt_kind_of expr, CSCE::Abstract
        end

        super(loc)

        @head_field   = head_field
        @tail_fields  = tail_fields
    end


    def to_s
        format(".(%s)",
            ([self.head_field] + self.tail_fields).map { |lab, opt_expr|
                lab.to_s + (opt_expr ? opt_expr.to_s : '')
            }.join(' ')
        )
    end


    def pretty_print(q)
        PRT.group_for_enum(
            q,
            [self.head_field] + self.tail_fields,
            bb: '.(',
            eb: ')',
            join: ' '
        ) do |lab, opt_expr|
            q.text lab.to_s
            q.text opt_expr.to_s if opt_expr
        end
    end


private

    def __desugar__(env, event)
        new_env = env.enter event

        labels, exprs = (
            [self.head_field] + self.tail_fields
        ).inject([[], []]) { |(ls, es), fld|
            lab, opt_expr = fld
            expr = if opt_expr
                        opt_expr.desugar new_env
                    else
                        ASCE.make_identifier lab.loc, lab.sym
                    end

            [ls + [lab], es + [expr]]
        }
        sym = labels.map { |lab| lab.sym.to_s + ':' }.join.to_sym

        ASCE.make_message self.loc, sym, exprs
    end
end

end # Umu::ConcreteSyntax::Core::Expression::Binary::Send::Message



class Entry < Binary::Abstract
    alias       lhs_expr            lhs
    alias       rhs_head_message    rhs
    attr_reader :rhs_tail_messages


    def initialize(loc, lhs_expr, rhs_head_message, rhs_tail_messages)
        ASSERT.kind_of lhs_expr,            CSCE::Abstract
        ASSERT.kind_of rhs_head_message,    Message::Abstract
        ASSERT.kind_of rhs_tail_messages,   ::Array

        super(loc, lhs_expr, rhs_head_message)

        @rhs_tail_messages = rhs_tail_messages
    end


    def to_s
        format("(%s)%s",
                self.lhs_expr.to_s,
                self.rhs_messages.map(&:to_s).join
        )
    end


    def pretty_print(q)
        PRT.group q, bb:'(', eb:')' do
            q.pp self.lhs_expr
        end

        PRT.group_for_enum q, self.rhs_messages
    end


    def rhs_messages
        [self.rhs_head_message] + self.rhs_tail_messages
    end


private

    def __desugar__(env, event)
        new_env = env.enter event

        ASCE.make_send(
            self.loc,
            self.lhs_expr.desugar(new_env),
            self.rhs_head_message.desugar(new_env),
            self.rhs_tail_messages.map { |mess|
                ASSERT.kind_of mess, Message::Abstract

                mess.desugar(new_env)
            }
        )
    end
end

end # Umu::ConcreteSyntax::Core::Expression::Binary::Send

end # Umu::ConcreteSyntax::Core::Expression::Binary


module_function

    def make_message(loc, sym, exprs = [])
        ASSERT.kind_of loc,     LOC::Entry
        ASSERT.kind_of sym,     ::Symbol
        ASSERT.kind_of exprs,   ::Array

        Binary::Send::Message::BasicMessage.new(
            loc, sym, exprs.freeze
        ).freeze
    end


    def make_apply_message(loc, expr, exprs = [])
        ASSERT.kind_of loc,     LOC::Entry
        ASSERT.kind_of expr,    CSCE::Abstract
        ASSERT.kind_of exprs,   ::Array

        Binary::Send::Message::ApplyMessage.new(
            loc, expr, exprs.freeze
        ).freeze
    end


    def make_keyword_message(loc, field, fields = [])
        ASSERT.kind_of  loc,     LOC::Entry
        ASSERT.tuple_of field,   [CSCEU::Container::Named::Label, ::Object]
        ASSERT.kind_of  fields,  ::Array

        Binary::Send::Message::KeywordMessage.new(
            loc, field, fields.freeze
        ).freeze
    end


    def make_send(loc, lhs_expr, rhs_head_message, rhs_tail_messages = [])
        ASSERT.kind_of loc,                 LOC::Entry
        ASSERT.kind_of lhs_expr,            CSCE::Abstract
        ASSERT.kind_of rhs_head_message,    Binary::Send::Message::Abstract
        ASSERT.kind_of rhs_tail_messages,   ::Array

        Binary::Send::Entry.new(
            loc, lhs_expr, rhs_head_message, rhs_tail_messages.freeze
        ).freeze
    end

end # Umu::ConcreteSyntax::Core::Expression

end # Umu::ConcreteSyntax::Core

end # Umu::ConcreteSyntax

end # Umu
