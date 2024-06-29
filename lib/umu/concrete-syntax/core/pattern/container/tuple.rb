# coding: utf-8
# frozen_string_literal: true



module Umu

module ConcreteSyntax

module Core

module Pattern

module Container

class Tuple < Abstraction::Abstract
    alias pats array


    def initialize(loc, pats)
        ASSERT.kind_of  pats, ::Array
        ASSERT.assert   pats.size >= 2

        pats.reject(&:wildcard?).inject({}) do |hash, vpat|
            ASSERT.kind_of vpat,    Variable
            ASSERT.kind_of hash,    ::Hash

            hash.merge(vpat.var_sym => true) { |key, _, _|
                raise X::SyntaxError.new(
                    loc,
                    "Duplicated pattern variable: '%s'", key.to_s
                )
            }
        end

        super
    end


    def to_s
        format "(%s)", self.map(&:to_s).join(', ')
    end


    def exported_vars
        self.reject(&:wildcard?).inject([]) { |array, vpat|
            ASSERT.kind_of array,   ::Array
            ASSERT.kind_of vpat,    Variable

            array + vpat.exported_vars
        }.freeze
    end


private

    def __desugar_value__(expr, env, _event)
        ASSERT.kind_of expr, ASCE::Abstract

        ASCD.make_declarations(
            self.loc,
            [
                ASCD.make_value(self.loc, :'%t', expr, :Product)
            ] + (
                __desugar__(:'%t', env)
            )
        )
    end


    def __desugar_lambda__(seq_num, env, _event)
        ASSERT.kind_of seq_num, ::Integer

        var_sym = __gen_sym__ seq_num

        CSCP.make_result(
            ASCE.make_identifier(self.loc, var_sym),
            __desugar__(var_sym, env),
            :Product
        )
    end


    def __desugar__(var_sym, _env)
        self.each_with_index.reject { |vpat, _index|
            ASSERT.kind_of vpat, Variable

            vpat.wildcard? && vpat.opt_type_sym.nil?
        }.map { |vpat, index|
            ASSERT.kind_of vpat,    Variable
            ASSERT.kind_of index,   ::Integer

            expr = ASCE.make_send(
                        vpat.loc,
                        ASCE.make_identifier(vpat.loc, var_sym),
                        ASCE.make_number_selector(vpat.loc, index + 1)
                    )

            ASCD.make_value vpat.loc, vpat.var_sym, expr, vpat.opt_type_sym
        }
    end
end

end # Umu::ConcreteSyntax::Core::Pattern::Container


module_function

    def make_tuple(loc, pats)
        ASSERT.kind_of loc,     LOC::Entry
        ASSERT.kind_of pats,    ::Array

        Container::Tuple.new(loc, pats.freeze).freeze
    end

end # Umu::ConcreteSyntax::Core::Pattern

end # Umu::ConcreteSyntax::Core

end # Umu::ConcreteSyntax

end # Umu
