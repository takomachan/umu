# coding: utf-8
# frozen_string_literal: true



module Umu

module ConcreteSyntax

module Core

module Declaration

class Value < Declaration::Abstract
    attr_reader :pat, :expr, :decls


    def initialize(loc, pat, expr, decls)
        ASSERT.kind_of pat,     CSCP::Abstract
        ASSERT.kind_of expr,    CSCE::Abstract
        ASSERT.kind_of decls,   CSCD::SeqOfDeclaration

        super(loc)

        @pat    = pat
        @expr   = expr
        @decls  = decls
    end


    def to_s
        format("%%VAL %s = %s%s",
                self.pat.to_s,

                self.expr.to_s,

                if self.decls.empty?
                    ''
                else
                    format " %%WHERE {%s}", self.decls.to_s
                end
        )
    end


    def pretty_print(q)
        q.text '%VAL '
        q.pp self.pat
        q.text ' = '
        PRT.group q do
            q.pp self.expr
        end

        q.breakable

        unless self.decls.empty?
            PRT.group q, bb:'%WHERE {', eb:'}' do
                q.pp self.decls
            end
        end
    end


    def exported_vars
        self.pat.exported_vars
    end


private

    def __desugar__(env, event)
        new_env = env.enter event

        self.pat.desugar_value(
            (
                if self.decls.empty?
                    self.expr
                else
                    CSCE.make_let(self.loc, self.decls, self.expr)
                end
            ).desugar(new_env),

            new_env
        )
    end
end



module_function

    def make_value(loc, pat, expr, decls)
        ASSERT.kind_of loc,     LOC::Entry
        ASSERT.kind_of pat,     CSCP::Abstract
        ASSERT.kind_of expr,    CSCE::Abstract
        ASSERT.kind_of decls,   CSCD::SeqOfDeclaration

        Value.new(loc, pat, expr, decls).freeze
    end

end # Umu::ConcreteSyntax::Core::Declaration

end # Umu::ConcreteSyntax::Core

end # Umu::ConcreteSyntax

end # Umu
