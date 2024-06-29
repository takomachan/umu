# coding: utf-8
# frozen_string_literal: true



module Umu

module ConcreteSyntax

module Core

module Declaration

class Assert < Declaration::Abstract
    attr_reader :test_expr, :else_expr


    def initialize(loc, test_expr, else_expr)
        ASSERT.kind_of test_expr,   CSCE::Abstract
        ASSERT.kind_of else_expr,   CSCE::Abstract

        super(loc)

        @test_expr  = test_expr
        @else_expr  = else_expr
    end


    def to_s
        format("%%ASSERT (%s) %s",
                self.test_expr.to_s,
                self.else_expr.to_s
        )
    end


    def exported_vars
        [].freeze
    end


private

    def __desugar__(env, event)
        new_env = env.enter event

        ASCD.make_value(
            self.loc,

            WILDCARD,

            ASCE.make_if(
                self.loc,

                [
                    ASCE.make_rule(
                        self.test_expr.loc,
                        self.test_expr.desugar(new_env),
                        ASCE.make_unit(self.test_expr.loc)
                    )
                ],

                ASCE.make_send(
                    self.else_expr.loc,
                    self.else_expr.desugar(new_env),
                    ASCE.make_method(self.else_expr.loc, :panic)
                )

            )
        )
    end
end



module_function

    def make_assert(loc, test_expr, else_expr)
        ASSERT.kind_of loc,         L::Location
        ASSERT.kind_of test_expr,   CSCE::Abstract
        ASSERT.kind_of else_expr,   CSCE::Abstract

        Assert.new(loc, test_expr, else_expr).freeze
    end

end # Umu::ConcreteSyntax::Core::Declaration

end # Umu::ConcreteSyntax::Core

end # Umu::ConcreteSyntax

end # Umu
