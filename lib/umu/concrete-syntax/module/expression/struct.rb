# coding: utf-8
# frozen_string_literal: true



module Umu

module ConcreteSyntax

module Module

module Expression

class Struct < Expression::Abstract
    attr_reader :body_decls


    def initialize(loc, body_decls)
        ASSERT.kind_of body_decls,  ::Array

        super(loc)

        @body_decls = body_decls
    end


    def to_s
        format("%%STRUCT {%s}",
            if self.body_decls.empty?
                ' '
            else
                self.body_decls.map(&:to_s).join(' ')
            end
        )
    end


    def pretty_print(q)
        PRT.group_for_enum(
            q, self.body_decls, bb: '%STRUCT {', eb: '}', sep: '  '
        ) do |decl| q.pp decl end
    end


private

    def __desugar__(env, event)
        expr_by_label = (
            self.body_decls.inject([]) {
                |array, decl|
                ASSERT.kind_of array,   ::Array
                ASSERT.kind_of decl,    Declaration::Abstract

                array + decl.exported_vars
            }.inject({}) { |hash, vpat|
                ASSERT.kind_of hash,    ::Hash
                ASSERT.kind_of vpat,    CSCP::ElementOfContainer::Variable

                label = vpat.var_sym
                expr  = ASCE.make_identifier(vpat.loc, vpat.var_sym)

                hash.merge(label => expr) { |_lab, _old_expr, new_expr|
                    new_expr
                }
            }
        )

        expr = ASCE.make_struct self.loc, expr_by_label

        if self.body_decls.empty?
            expr
        else
            new_env = env.enter event

            ASCE.make_let(
                self.loc,

                ASCD.make_seq_of_declaration(
                    self.loc,
                    self.body_decls.map { |decl| decl.desugar new_env }
                ),

                expr
            )
        end
    end
end


module_function

    def make_struct(loc, body_decls)
        ASSERT.kind_of loc,         LOC::Entry
        ASSERT.kind_of body_decls,  ::Array

        Struct.new(loc, body_decls.freeze).freeze
    end

end # Umu::ConcreteSyntax::Module::Expression

end # Umu::ConcreteSyntax::Module

end # Umu::ConcreteSyntax

end # Umu
