# coding: utf-8
# frozen_string_literal: true



module Umu

module AbstractSyntax

module Core

module Expression

module SExpression

class Abstract < Expression::Abstract; end



class Nil < Abstract
    def to_s
        '()'
    end


    def __evaluate__(_env, _event)
        VC.make_s_expr_nil
    end
end



class Atom < Abstract
    attr_reader :val

    def initialize(loc, val)
        ASSERT.kind_of val, VCA::Abstract

        super(loc)

        @val = val
    end


    def to_s
        self.val.to_s
    end


    def __evaluate__(_env, _event)
        VC.make_s_expr_atom self.val
    end
end



class List < Abstract
    attr_reader :fst_expr, :snd_exprs, :opt_expr

    def initialize(loc, fst_expr, snd_exprs, opt_expr)
        ASSERT.kind_of     fst_expr,  SExpression::Abstract
        ASSERT.kind_of     snd_exprs, ::Array
        ASSERT.opt_kind_of opt_expr,  SExpression::Abstract
        snd_exprs.each do |expr|
            ASSERT.kind_of expr, SExpression::Abstract
        end

        super(loc)

        @fst_expr  = fst_expr
        @snd_exprs = snd_exprs
        @opt_expr  = opt_expr
    end


    def exprs
        [self.fst_expr] + self.snd_exprs
    end


    def to_s
        format("(%s%s)",
            self.exprs.map(&:to_s).join(' '),

            if self.opt_expr
                format " . %s", self.opt_expr.to_s
            else
                ''
            end
        )
    end


    def __evaluate__(env, event)
        new_env = env.enter event

        head_vals = self.exprs.map { |expr| expr.evaluate(new_env).value }

        tail_val = if self.opt_expr
                        self.opt_expr.evaluate(new_env).value
                    else
                        VC.make_s_expr_nil
                    end

        head_vals.reverse.inject(tail_val) { |xs, x|
            VC.make_s_expr_cons x, xs
        }
    end
end

end # Umu::AbstractSyntax::Core::Expression::SExpression


module_function

    def make_s_expr_nil(loc)
        ASSERT.kind_of loc, LOC::Entry

        SExpression::Nil.new(loc).freeze
    end


    def make_s_expr_atom(loc, val)
        ASSERT.kind_of loc, LOC::Entry
        ASSERT.kind_of val, VCA::Abstract

        SExpression::Atom.new(loc, val).freeze
    end


    def make_s_expr_list(loc, fst_expr, snd_exprs, opt_expr = nil)
        ASSERT.kind_of     loc,       LOC::Entry
        ASSERT.kind_of     fst_expr,  SExpression::Abstract
        ASSERT.kind_of     snd_exprs, ::Array
        ASSERT.opt_kind_of opt_expr,  SExpression::Abstract

        SExpression::List.new(
            loc, fst_expr, snd_exprs.freeze, opt_expr
        ).freeze
    end

end # Umu::AbstractSyntax::Core::Expression

end # Umu::AbstractSyntax::Core

end # Umu::AbstractSyntax

end # Umu
