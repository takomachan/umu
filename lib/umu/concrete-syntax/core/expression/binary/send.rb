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



class NumberSelector < Abstract
    attr_reader :sel_num


    def initialize(loc, sel_num)
        ASSERT.kind_of sel_num, ::Integer

        super(loc)

        @sel_num = sel_num
    end


    def to_s
        '$' + self.sel_num.to_s
    end


private

    def __desugar__(_env, _event)
        ASCE.make_number_selector self.loc, self.sel_num
    end
end



class LabelSelector < Abstract
    attr_reader :sel_sym


    def initialize(loc, sel_sym)
        ASSERT.kind_of sel_sym, ::Symbol

        super(loc)

        @sel_sym = sel_sym
    end


    def to_s
        '$' + self.sel_sym.to_s
    end


private

    def __desugar__(_env, _event)
        ASCE.make_label_selector self.loc, self.sel_sym
    end
end



class Modifier < Abstract
    attr_reader :fields


    def initialize(loc, fields)
        ASSERT.kind_of fields, ::Array

        super(loc)

        @fields = fields
    end


    def to_s
        format("$(%s)",
            self.fields.map { |label, opt_expr|
                format("%s%s",
                        label.to_s,

                        if opt_expr
                            ' ' + opt_expr.to_s
                        else
                            ''
                        end
                )
            }.join(', ')
        )
    end


    def pretty_print(q)
        q.group(PP_INDENT_WIDTH, '$(', ')') do
            hd_field, *tl_fields = self.fields
            hd_label, hd_opt_expr = hd_field

            q.text hd_label.to_s
            if hd_opt_expr
                q.text ' '
                q.pp hd_opt_expr
            end

            self.tl_fields.each do |label, opt_expr|
                q.breakable

                q.text label.to_s
                if opt_expr
                    q.text ' '
                    q.pp opt_expr
                end
            end
        end
    end


private

    def __desugar__(env, event)
        expr_by_label = self.fields.inject({}) { |hash, (label, opt_expr)|
            ASSERT.kind_of     label,    CSCEU::Container::Named::Label
            ASSERT.opt_kind_of opt_expr, CSCE::Abstract

            expr = if opt_expr
                        opt_expr
                    else
                        CSCE.make_identifier label.loc, label.sym
                    end

            new_env = env.enter event
            hash.merge(label.desugar(new_env) => expr.desugar(new_env)) {
                |lab, _, _|

                raise X::SyntaxError.new(
                    label.loc,
                    format("In modifier of named tuple, " +
                                                "duplicated label: '%s'",
                            label.to_s
                    )
                )
            }
        }.freeze

        ASCE.make_modifier self.loc, expr_by_label
    end
end



class Method < Abstract
    attr_reader :sym, :exprs


    def initialize(loc, sym, exprs)
        ASSERT.kind_of sym,     ::Symbol
        ASSERT.kind_of exprs,   ::Array

        super(loc)

        @sym    = sym
        @exprs  = exprs
    end


    def to_s
        format(".(%s%s)",
            self.sym.to_s,

            if self.exprs.empty?
                ''
            else
                ' ' + self.exprs.map(&:to_s).join(' ')
            end
        )
    end


    def pretty_print(q)
        q.group(PP_INDENT_WIDTH, '.(', ')') do
            q.text self.sym.to_s

            self.exprs.each do |expr|
                q.breakable

                q.pp expr
            end
        end
    end


private

    def __desugar__(env, event)
        new_env = env.enter event

        ASCE.make_method(
            self.loc,
            self.sym,
            self.exprs.map { |expr| expr.desugar(new_env) },
        )
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
        q.group(PP_INDENT_WIDTH, '(', ')') do
            q.pp self.lhs_expr
        end

        q.group(PP_INDENT_WIDTH, '', '') do
            self.rhs_messages.each do |message|
                q.breakable ''

                q.pp message
            end
        end
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

    def make_number_selector(loc, sel_num)
        ASSERT.kind_of loc,     LOC::Entry
        ASSERT.kind_of sel_num, ::Integer

        Binary::Send::Message::NumberSelector.new(loc, sel_num).freeze
    end


    def make_label_selector(loc, sel_sym)
        ASSERT.kind_of loc,     LOC::Entry
        ASSERT.kind_of sel_sym, ::Symbol

        Binary::Send::Message::LabelSelector.new(loc, sel_sym).freeze
    end


    def make_modifier(loc, fields)
        ASSERT.kind_of loc,     LOC::Entry
        ASSERT.kind_of fields,  ::Array

        Binary::Send::Message::Modifier.new(loc, fields.freeze).freeze
    end


    def make_method(loc, sym, exprs = [])
        ASSERT.kind_of loc,     LOC::Entry
        ASSERT.kind_of sym,     ::Symbol
        ASSERT.kind_of exprs,   ::Array

        Binary::Send::Message::Method.new(loc, sym, exprs.freeze).freeze
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
