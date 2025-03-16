# coding: utf-8
# frozen_string_literal: true



module Umu

module AbstractSyntax

module Core

module Expression

module Binary

module Product

module Operator

module Abstraction

class Abstract < Umu::Abstraction::Model
    def apply(_value, _env, _event)
        raise X::InternalSubclassResponsibility
    end
end



class Selector < Abstract
    attr_reader :sel


    def initialize(loc, sel)
        ASSERT.kind_of sel, ::Object        # Polymopic

        super(loc)

        @sel = sel
    end
end

end # Umu::AbstractSyntax::Core::Expression::Binary::Product::Operator::Abstraction



class ByNumber < Abstraction::Selector
    alias sel_num sel


    def initialize(loc, sel_num)
        ASSERT.kind_of sel_num, ::Integer

        super
    end


    def to_s
        '$' + self.sel_num.to_s
    end


    def pretty_print(q)
        q.text format("$%d", self.sel_num)
    end


    def apply(value, env, _event)
        ASSERT.kind_of value,   VC::Top
        ASSERT.kind_of env,     E::Entry

        unless value.kind_of? VCP::Abstract
            raise X::TypeError.new(
                self.loc,
                env,
                "Selection operator '$' require a Product, but %s : %s",
                    value.to_s,
                    value.type_sym.to_s
            )
        end

        result = value.select_by_number self.sel_num, self.loc, env
        ASSERT.kind_of result, VC::Top
    end
end



class ByLabel < Abstraction::Selector
    alias sel_sym sel

    def initialize(loc, sel_sym)
        ASSERT.kind_of sel_sym, ::Symbol

        super
    end


    def to_s
        '$' + self.sel_sym.to_s
    end


    def pretty_print(q)
        q.text format("$%s", self.sel_sym.to_s)
    end


    def apply(value, env, _event)
        ASSERT.kind_of value,   VC::Top
        ASSERT.kind_of env,         E::Entry

        unless value.kind_of? VCP::Named
            raise X::TypeError.new(
                self.loc,
                env,
                "Selection operator '$' require a Named, but %s : %s",
                    value.to_s,
                    value.type_sym.to_s
            )
        end

        result = value.select_by_label self.sel_sym, self.loc, env
        ASSERT.kind_of result, VC::Top
    end
end



class Modifier < Abstraction::Selector
    alias expr_by_label sel

    def initialize(loc, expr_by_label)
        ASSERT.kind_of expr_by_label, ::Hash

        super
    end


    def to_s
        format("$(%s)",
            self.expr_by_label.map { |label, expr|
                format "%s %s", label.to_s, expr.to_s
            }.join(', ')
        )
    end


    def pretty_print(q)
        PRT.group_for_enum(
             q, self.expr_by_label, bb:'$(', eb:')', join:' '
        ) do |label, expr|

            q.text label.to_s
            q.pp expr
        end
    end


    def apply(value, env, event)
        ASSERT.kind_of value, VC::Top

        unless value.kind_of? VCP::Named
            raise X::TypeError.new(
                self.loc,
                env,
                "Modifier operator '$(..)' require a Named, but %s : %s",
                    value.to_s,
                    value.type_sym.to_s
            )
        end

        new_env = env.enter event
        value_by_label = self.expr_by_label.inject({}) {
            |hash, (label, expr)|
            ASSERT.kind_of hash,    ::Hash
            ASSERT.kind_of label,   ASCEU::Container::Named::Label
            ASSERT.kind_of expr,    ASCE::Abstract

            result = expr.evaluate new_env
            ASSERT.kind_of result, ASR::Value

            hash.merge(label.sym => result.value) { |lab, _, _|
                ASSERT.abort "No case - label: $s", lab.to_s
            }
        }

        result = value.modify value_by_label, self.loc, env
        ASSERT.kind_of result, VC::Top
    end
end

end # Umu::AbstractSyntax::Core::Expression::Binary::Product::Operator



class Entry < Binary::Abstract
    alias       rhs_head_operator rhs
    attr_reader :rhs_tail_operators
    attr_reader :opt_operand_type_sym


    def initialize(
        loc, lhs_expr,
        rhs_head_operator, rhs_tail_operators,
        opt_operand_type_sym
    )
        ASSERT.kind_of      lhs_expr,               ASCE::Abstract
        ASSERT.kind_of      rhs_head_operator,
                        Binary::Product::Operator::Abstraction::Abstract
        ASSERT.kind_of      rhs_tail_operators,     ::Array
        ASSERT.opt_kind_of  opt_operand_type_sym,   ::Symbol

        super(loc, lhs_expr, rhs_head_operator)

        @rhs_tail_operators     = rhs_tail_operators
        @opt_operand_type_sym   = opt_operand_type_sym
    end


    def rhs_operators
        [self.rhs_head_operator] + self.rhs_tail_operators
    end


    def to_s
        format("(%s%s)%s",
            self.lhs_expr.to_s,

            if self.opt_operand_type_sym
                format " : %s", self.opt_operand_type_sym.to_s
            else
                ''
            end,

            self.rhs_operators.map(&:to_s).join
        )
    end


    def pretty_print(q)
        PRT.group q, bb:'(', eb:')' do
            q.pp lhs_expr
            if self.opt_operand_type_sym
                q.text format(" : %s", self.opt_operand_type_sym.to_s)
            end
        end

        PRT.group_for_enum q, self.rhs_operators
    end


private

    def __evaluate__(env, event)
        ASSERT.kind_of env,     E::Entry
        ASSERT.kind_of event,   E::Tracer::Event

        new_env = env.enter event

        lhs_result = self.lhs_expr.evaluate new_env
        ASSERT.kind_of lhs_result, ASR::Value
        init_operand = lhs_result.value

        if self.opt_operand_type_sym
            operand_type_sym = opt_operand_type_sym

            operand_signat = new_env.ty_lookup operand_type_sym, self.loc
            ASSERT.kind_of operand_signat, ECTSC::Base
            unless env.ty_kind_of?(init_operand, operand_signat)
                raise X::TypeError.new(
                    self.loc,
                    env,
                    "Expected a %s, but %s : %s",
                    operand_type_sym,
                    init_operand,
                    init_operand.type_sym
                )
            end
        end

        final_operand = self.rhs_operators.inject(init_operand) {
            |operand, operator|
            ASSERT.kind_of operand,     VC::Top
            ASSERT.kind_of operator,    Operator::Abstraction::Abstract

            operator.apply operand, new_env, event
        }
        ASSERT.kind_of final_operand, VC::Top
    end
end

end # Umu::AbstractSyntax::Core::Expression::Binary::Product

end # Umu::AbstractSyntax::Core::Expression::Binary


module_function
    def make_number_selector(loc, sel_num)
        ASSERT.kind_of loc,     LOC::Entry
        ASSERT.kind_of sel_num, ::Integer

        Binary::Product::Operator::ByNumber.new(loc, sel_num).freeze
    end


    def make_label_selector(loc, sel_sym)
        ASSERT.kind_of loc,     LOC::Entry
        ASSERT.kind_of sel_sym, ::Symbol

        Binary::Product::Operator::ByLabel.new(loc, sel_sym).freeze
    end


    def make_modifier(loc, expr_by_label)
        ASSERT.kind_of loc,             LOC::Entry
        ASSERT.kind_of expr_by_label,   ::Hash

        Binary::Product::Operator::Modifier.new(loc, expr_by_label).freeze
    end


    def make_product(
        loc, lhs_expr,
        rhs_head_operator, rhs_tail_operators = [],
        opt_operand_type_sym = nil
    )
        ASSERT.kind_of      loc,                    LOC::Entry
        ASSERT.kind_of      lhs_expr,               ASCE::Abstract
        ASSERT.kind_of      rhs_head_operator,
                        Binary::Product::Operator::Abstraction::Abstract
        ASSERT.kind_of      rhs_tail_operators,     ::Array
        ASSERT.opt_kind_of  opt_operand_type_sym,   ::Symbol

        Binary::Product::Entry.new(
            loc, lhs_expr, rhs_head_operator, rhs_tail_operators.freeze,
            opt_operand_type_sym
        ).freeze
    end

end # Umu::AbstractSyntax::Core::Expression

end # Umu::AbstractSyntax::Core

end # Umu::AbstractSyntax

end # Umu
