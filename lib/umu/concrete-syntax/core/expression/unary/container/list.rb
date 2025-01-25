# coding: utf-8
# frozen_string_literal: true



module Umu

module ConcreteSyntax

module Core

module Expression

module Unary

module Container

class List < Container::Abstract
    attr_reader :opt_last_expr


    def initialize(loc, exprs, opt_last_expr)
        ASSERT.kind_of      exprs,          ::Array
        ASSERT.opt_kind_of  opt_last_expr,  CSCE::Abstract
        ASSERT.assert (
            if exprs.empty? then opt_last_expr.nil? else true end
        )

        super(loc, exprs)

        @opt_last_expr = opt_last_expr
    end


    def to_s
        format("[%s%s]",
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
            PRT.group_for_enum q, self, bb: '[', join: ', '
            PRT.group q, bb: '|', eb: ']' do
                q.pp self.opt_last_expr
            end
        else
            PRT.group_for_enum q, self, bb: '[', eb: ']', join: ', '
        end
    end


private

    def __desugar__(env, event)
        new_env = env.enter event

        ASCE.make_list(
            self.loc,

            self.map { |elem| elem.desugar(new_env) },

            if self.opt_last_expr
                self.opt_last_expr.desugar(new_env)
            else
                nil
            end
        )
    end
end

end # Umu::ConcreteSyntax::Core::Expression::Unary::Container

end # Umu::ConcreteSyntax::Core::Expression::Unary


module_function

    def make_list(loc, exprs, opt_last_expr = nil)
        ASSERT.kind_of      loc,            LOC::Entry
        ASSERT.kind_of      exprs,          ::Array
        ASSERT.opt_kind_of  opt_last_expr,  CSCE::Abstract

        Unary::Container::List.new(loc, exprs.freeze, opt_last_expr).freeze
    end

end # Umu::ConcreteSyntax::Core::Expression

end # Umu::ConcreteSyntax::Core

end # Umu::ConcreteSyntax

end # Umu
