# coding: utf-8
# frozen_string_literal: true



module Umu

module ConcreteSyntax

module Core

module Expression

module Nary     # N-ary, where N >= 3

class Let < Expression::Abstract
    attr_reader :decls, :expr


    def initialize(loc, decls, expr)
        ASSERT.kind_of decls,   CSCD::SeqOfDeclaration
        ASSERT.kind_of expr,    CSCE::Abstract

        super(loc)

        @decls  = decls
        @expr   = expr
    end


    def to_s
        format "%%LET { %s %%IN %s }", self.decls.to_s, self.expr.to_s
    end


    def pretty_print(q)
        PRT.group_for_enum q, self.decls, bb:'%LET {', sep:' '

        q.breakable

        PRT.group q, bb:'%IN', eb:'}', sep:' ' do
            q.pp self.expr
        end
    end


private

    def __desugar__(env, event)
        new_env = env.enter event

        if self.decls.empty?
            self.expr.desugar(new_env)
        else
            ASCE.make_let(
                self.loc,
                self.decls.desugar(new_env),
                self.expr.desugar(new_env)
            )
        end
    end
end

end # Umu::ConcreteSyntax::Core::Expression::Nary


module_function

    def make_let(loc, decls, expr)
        ASSERT.kind_of loc,     LOC::Entry
        ASSERT.kind_of decls,   CSCD::SeqOfDeclaration
        ASSERT.kind_of expr,    CSCE::Abstract

        Nary::Let.new(loc, decls.freeze, expr).freeze
    end

end # Umu::ConcreteSyntax::Core::Expression

end # Umu::ConcreteSyntax::Core

end # Umu::ConcreteSyntax

end # Umu
