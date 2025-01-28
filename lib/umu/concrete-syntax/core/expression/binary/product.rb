# coding: utf-8
# frozen_string_literal: true



module Umu

module ConcreteSyntax

module Core

module Expression

module Binary

module Product

module Operator

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
        PRT.group_for_enum(
            q, self.fields, bb: '$(', eb: ')', join: ', '
        ) do |label, opt_expr|
            q.text label.to_s
            if opt_expr
                q.text ' '
                q.pp opt_expr
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

end # Umu::ConcreteSyntax::Core::Expression::Binary::Product::Operator



class Entry < Binary::Abstract
    alias       lhs_expr        lhs
    alias       rhs_head_opr    rhs
    attr_reader :rhs_tail_oprs


    def initialize(loc, lhs_expr, rhs_head_opr, rhs_tail_oprs)
        ASSERT.kind_of lhs_expr,        CSCE::Abstract
        ASSERT.kind_of rhs_head_opr,    Operator::Abstract
        ASSERT.kind_of rhs_tail_oprs,   ::Array

        super(loc, lhs_expr, rhs_head_opr)

        @rhs_tail_oprs = rhs_tail_oprs
    end


    def to_s
        format("(%s)%s",
                self.lhs_expr.to_s,
                self.rhs_oprs.map(&:to_s).join
        )
    end


    def pretty_print(q)
        PRT.group q, bb: '(', eb: ')' do
            q.pp self.lhs_expr
        end

        PRT.group_for_enum q, self.rhs_oprs
    end


    def rhs_oprs
        [self.rhs_head_opr] + self.rhs_tail_oprs
    end


private

    def __desugar__(env, event)
        new_env = env.enter event

        ASCE.make_product(
            self.loc,
            self.lhs_expr.desugar(new_env),
            self.rhs_head_opr.desugar(new_env),
            self.rhs_tail_oprs.map { |mess|
                ASSERT.kind_of mess, Operator::Abstract

                mess.desugar(new_env)
            }
        )
    end
end

end # Umu::ConcreteSyntax::Core::Expression::Binary::Product

end # Umu::ConcreteSyntax::Core::Expression::Binary


module_function

    def make_number_selector(loc, sel_num)
        ASSERT.kind_of loc,     LOC::Entry
        ASSERT.kind_of sel_num, ::Integer

        Binary::Product::Operator::NumberSelector.new(loc, sel_num).freeze
    end


    def make_label_selector(loc, sel_sym)
        ASSERT.kind_of loc,     LOC::Entry
        ASSERT.kind_of sel_sym, ::Symbol

        Binary::Product::Operator::LabelSelector.new(loc, sel_sym).freeze
    end


    def make_modifier(loc, fields)
        ASSERT.kind_of loc,     LOC::Entry
        ASSERT.kind_of fields,  ::Array

        Binary::Product::Operator::Modifier.new(loc, fields.freeze).freeze
    end


    def make_product(loc, lhs_expr, rhs_head_opr, rhs_tail_oprs = [])
        ASSERT.kind_of loc,             LOC::Entry
        ASSERT.kind_of lhs_expr,        CSCE::Abstract
        ASSERT.kind_of rhs_head_opr,    Binary::Product::Operator::Abstract
        ASSERT.kind_of rhs_tail_oprs,   ::Array

        Binary::Product::Entry.new(
            loc, lhs_expr, rhs_head_opr, rhs_tail_oprs.freeze
        ).freeze
    end

end # Umu::ConcreteSyntax::Core::Expression

end # Umu::ConcreteSyntax::Core

end # Umu::ConcreteSyntax

end # Umu
