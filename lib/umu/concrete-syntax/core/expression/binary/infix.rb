# coding: utf-8
# frozen_string_literal: true



module Umu

module ConcreteSyntax

module Core

module Expression

module Binary

module Infix

module Abstraction

class Abstract < Binary::Abstract
    alias       lhs_opnd lhs
    attr_reader :opr_sym
    alias       rhs_opnd rhs


    def initialize(loc, lhs_opnd, opr_sym, rhs_opnd)
        ASSERT.kind_of lhs_opnd,    Umu::Abstraction::Model
        ASSERT.kind_of opr_sym,     ::Symbol
        ASSERT.kind_of rhs_opnd,    Umu::Abstraction::Model

        super(loc, lhs_opnd, rhs_opnd)

        @opr_sym = opr_sym
    end


    def to_s
        _opr = self.opr_sym.to_s
        opr = if /^[a-zA-Z\-]+\??$/ =~ _opr
                    '%' + _opr.upcase
                else
                    _opr
                end

        format "(%s %s %s)", self.lhs_opnd.to_s, opr, self.rhs_opnd.to_s
    end
end



class Simple < Abstract
    def initialize(loc, lhs_opnd, opr_sym, rhs_opnd)
        ASSERT.kind_of lhs_opnd,    CSCE::Abstract
        ASSERT.kind_of opr_sym,     ::Symbol
        ASSERT.kind_of rhs_opnd,    CSCE::Abstract

        super
    end
end



class WithRepetition < Abstract
    include Enumerable

    alias       hd_rhs_opnd rhs_opnd
    attr_reader :tl_rhs_opnds


    def initialize(loc, lhs_opnd, opr_sym, hd_rhs_opnd, tl_rhs_opnds)
        ASSERT.kind_of lhs_opnd,        CSCE::Abstract
        ASSERT.kind_of opr_sym,         ::Symbol
        ASSERT.kind_of hd_rhs_opnd,     CSCE::Abstract
        ASSERT.kind_of tl_rhs_opnds,    ::Array

        super(loc, lhs_opnd, opr_sym, hd_rhs_opnd)

        @tl_rhs_opnds = tl_rhs_opnds
    end


    def each
        yield self.hd_rhs_opnd

        self.tl_rhs_opnds.each do |rhs_opnd|
            ASSERT.kind_of rhs_opnd, CSCE::Abstract

            yield rhs_opnd
        end
    end


    def to_s
        opr = self.opr_sym.to_s

        format("(%s %s %s)",
                 self.lhs_opnd.to_s,
                 opr.to_s,
                 self.map(&:to_s).join(format(" %s ", opr.to_s))
        )
    end
end

end # Umu::ConcreteSyntax::Core::Expression::Binary::Infix::Abstraction



class Redefinable < Abstraction::Simple

private

    def __desugar__(env, event)
        new_env = env.enter event

        ASCE.make_apply(
            self.loc,
            ASCE.make_identifier(loc, self.opr_sym),
            self.lhs_opnd.desugar(new_env),
            [self.rhs_opnd.desugar(new_env)]
        )
    end
end



class KindOf < Abstraction::Abstract
    alias rhs_ident rhs_opnd

    def initialize(loc, lhs_opnd, opr_sym, rhs_ident)
        ASSERT.kind_of lhs_opnd,    CSCE::Abstract
        ASSERT.kind_of opr_sym,     ::Symbol
        ASSERT.kind_of rhs_ident,   CSCEU::Identifier::Short

        super
    end


private

    def __desugar__(env, event)
        new_env = env.enter event

        ASCE.make_test_kind_of(
            self.loc,
            self.lhs_opnd.desugar(new_env),
            self.rhs_ident.desugar(new_env)
        )
    end
end



class PipeLeft < Abstraction::WithRepetition

private

    def __desugar__(env, event)
        new_env = env.enter event

        opnd_expr,
        hd_opr_exprs,
        *tl_opr_exprs = ([self.lhs_opnd] + self.to_a)
                        .map { |expr| expr.desugar new_env }

        ASCE.make_pipe self.loc, opnd_expr, hd_opr_exprs, tl_opr_exprs
    end
end



class PipeRight < Abstraction::WithRepetition

private

    def __desugar__(env, event)
        new_env = env.enter event

        opnd_expr,
        hd_opr_exprs,
        *tl_opr_exprs = ([self.lhs_opnd] + self.to_a)
                        .reverse
                        .map { |expr| expr.desugar new_env }

        ASCE.make_pipe self.loc, opnd_expr, hd_opr_exprs, tl_opr_exprs
    end
end



class ComposeLeft < Abstraction::WithRepetition

private

=begin
    f1 >> f2 >> f3 = { x -> x |> f1 |> f2 |> f3 }
=end

    def __desugar__(env, event)
        new_env = env.enter event
        ident_x = ASCE.make_identifier self.loc, :'%x'

        hd_opnd,
        *tl_opnds = ([self.lhs_opnd] + self.to_a)
                    .map { |opnd| opnd.desugar new_env }

        ASCE.make_lambda(
            self.loc,
            [ASCE.make_parameter(self.loc, ident_x)],
            ASCE.make_pipe(self.loc, ident_x, hd_opnd, tl_opnds)
        )
    end
end



class ComposeRight < Abstraction::WithRepetition

private

=begin
    f1 << f2 << f3 = { x -> x |> f3 |> f2 |> f1 }
=end

    def __desugar__(env, event)
        new_env = env.enter event
        ident_x = ASCE.make_identifier self.loc, :'%x'

        hd_opnd,
        *tl_opnds = ([self.lhs_opnd] + self.to_a)
                    .reverse
                    .map { |opnd| opnd.desugar new_env }

        ASCE.make_lambda(
            self.loc,
            [ASCE.make_parameter(self.loc, ident_x)],
            ASCE.make_pipe(self.loc, ident_x, hd_opnd, tl_opnds)
        )
    end
end



class AndAlso < Abstraction::Simple

private

    def __desugar__(env, event)
        new_env = env.enter event

        ASCE.make_if(
            self.loc,
            [
                ASCE.make_rule(
                    self.loc,
                    self.lhs_opnd.desugar(new_env),
                    self.rhs_opnd.desugar(new_env)
                )
            ],
            ASCE.make_bool(self.loc, false)
        )
    end
end



class OrElse < Abstraction::Simple

private

    def __desugar__(env, event)
        new_env = env.enter event

        ASCE.make_if(
            self.loc,
            [
                ASCE.make_rule(
                    self.loc,
                    self.lhs_opnd.desugar(new_env),
                    ASCE.make_bool(loc, true)
                )
            ],
            self.rhs_opnd.desugar(new_env)
        )
    end
end

end # Umu::ConcreteSyntax::Core::Expression::Binary::Infix

end # Umu::ConcreteSyntax::Core::Expression::Binary


module_function

    def make_infix(loc, lhs_opnd, opr_sym, rhs_opnd)
        ASSERT.kind_of loc,         LOC::Entry
        ASSERT.kind_of lhs_opnd,    CSCE::Abstract
        ASSERT.kind_of opr_sym,     ::Symbol
        ASSERT.kind_of rhs_opnd,    CSCE::Abstract

        Binary::Infix::Redefinable.new(
            loc, lhs_opnd, opr_sym, rhs_opnd
        ).freeze
    end


    def make_pipe_left(loc, lhs_opnd, opr_sym, hd_rhs_opnd, tl_rhs_opnds)
        ASSERT.kind_of loc,             LOC::Entry
        ASSERT.kind_of lhs_opnd,        CSCE::Abstract
        ASSERT.kind_of opr_sym,         ::Symbol
        ASSERT.kind_of hd_rhs_opnd,     CSCE::Abstract
        ASSERT.kind_of tl_rhs_opnds,    ::Array

        Binary::Infix::PipeLeft.new(
            loc, lhs_opnd, opr_sym, hd_rhs_opnd, tl_rhs_opnds.freeze
        ).freeze
    end


    def make_pipe_right(loc, lhs_opnd, opr_sym, hd_rhs_opnd, tl_rhs_opnds)
        ASSERT.kind_of loc,             LOC::Entry
        ASSERT.kind_of lhs_opnd,        CSCE::Abstract
        ASSERT.kind_of opr_sym,         ::Symbol
        ASSERT.kind_of hd_rhs_opnd,     CSCE::Abstract
        ASSERT.kind_of tl_rhs_opnds,    ::Array

        Binary::Infix::PipeRight.new(
            loc, lhs_opnd, opr_sym, hd_rhs_opnd, tl_rhs_opnds.freeze
        ).freeze
    end


    def make_comp_left(loc, lhs_opnd, opr_sym, hd_rhs_opnd, tl_rhs_opnds)
        ASSERT.kind_of loc,             LOC::Entry
        ASSERT.kind_of lhs_opnd,        CSCE::Abstract
        ASSERT.kind_of opr_sym,         ::Symbol
        ASSERT.kind_of hd_rhs_opnd,     CSCE::Abstract
        ASSERT.kind_of tl_rhs_opnds,    ::Array

        Binary::Infix::ComposeLeft.new(
            loc, lhs_opnd, opr_sym, hd_rhs_opnd, tl_rhs_opnds.freeze
        ).freeze
    end


    def make_comp_right(loc, lhs_opnd, opr_sym, hd_rhs_opnd, tl_rhs_opnds)
        ASSERT.kind_of loc,             LOC::Entry
        ASSERT.kind_of lhs_opnd,        CSCE::Abstract
        ASSERT.kind_of opr_sym,         ::Symbol
        ASSERT.kind_of hd_rhs_opnd,     CSCE::Abstract
        ASSERT.kind_of tl_rhs_opnds,    ::Array

        Binary::Infix::ComposeRight.new(
            loc, lhs_opnd, opr_sym, hd_rhs_opnd, tl_rhs_opnds.freeze
        ).freeze
    end


    def make_kindof(loc, lhs_opnd, opr_sym, rhs_ident)
        ASSERT.kind_of loc,         LOC::Entry
        ASSERT.kind_of lhs_opnd,    CSCE::Abstract
        ASSERT.kind_of opr_sym,     ::Symbol
        ASSERT.kind_of rhs_ident,   CSCEU::Identifier::Short

        Binary::Infix::KindOf.new(
            loc, lhs_opnd, opr_sym, rhs_ident
        ).freeze
    end


    def make_andalso(loc, lhs_opnd, opr_sym, rhs_opnd)
        ASSERT.kind_of loc,         LOC::Entry
        ASSERT.kind_of lhs_opnd,    CSCE::Abstract
        ASSERT.kind_of opr_sym,     ::Symbol
        ASSERT.kind_of rhs_opnd,    CSCE::Abstract

        Binary::Infix::AndAlso.new(
            loc, lhs_opnd, opr_sym, rhs_opnd
        ).freeze
    end


    def make_orelse(loc, lhs_opnd, opr_sym, rhs_opnd)
        ASSERT.kind_of loc,         LOC::Entry
        ASSERT.kind_of lhs_opnd,    CSCE::Abstract
        ASSERT.kind_of opr_sym,     ::Symbol
        ASSERT.kind_of rhs_opnd,    CSCE::Abstract

        Binary::Infix::OrElse.new(
            loc, lhs_opnd, opr_sym, rhs_opnd
        ).freeze
    end

end # Umu::ConcreteSyntax::Core::Expression

end # Umu::ConcreteSyntax::Core

end # Umu::ConcreteSyntax

end # Umu
