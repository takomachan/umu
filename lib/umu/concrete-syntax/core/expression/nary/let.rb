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
        ASSERT.kind_of decls,   ::Array
        ASSERT.kind_of expr,    CSCE::Abstract

        super(loc)

        @decls  = decls
        @expr   = expr
    end


    def to_s
        format("%%LET { %s %%IN %s }",
            self.decls.map(&:to_s).join(' '),
            self.expr.to_s
        )
    end


    def pretty_print(q)
        q.group(PP_INDENT_WIDTH, '%LET {', '') do
            self.decls.each do |decl|
                q.breakable

                q.pp decl
            end
        end

        q.breakable

        q.group(PP_INDENT_WIDTH, '%IN', '') do
            q.breakable

            q.pp self.expr
        end

        q.breakable

        q.text '}'
    end


private

    def __desugar__(env, event)
        new_env = env.enter event

        if self.decls.empty?
            self.expr.desugar(new_env)
        else
            ASCE.make_let(
                self.loc,

                ASCD.make_seq_of_declaration(
                    self.loc,

                    self.decls.map { |decl|
                        ASSERT.kind_of decl, CSCD::Abstract

                        decl.desugar(new_env)
                    }
                ),

                self.expr.desugar(new_env)
            )
        end
    end
end

end # Umu::ConcreteSyntax::Core::Expression::Nary


module_function

    def make_let(loc, decls, expr)
        ASSERT.kind_of loc,     LOC::Entry
        ASSERT.kind_of decls,   ::Array
        ASSERT.kind_of expr,    CSCE::Abstract

        Nary::Let.new(loc, decls.freeze, expr).freeze
    end

end # Umu::ConcreteSyntax::Core::Expression

end # Umu::ConcreteSyntax::Core

end # Umu::ConcreteSyntax

end # Umu
