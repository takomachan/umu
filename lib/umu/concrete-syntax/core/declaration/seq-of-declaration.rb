# coding: utf-8
# frozen_string_literal: true



module Umu

module ConcreteSyntax

module Core

module Declaration

class SeqOfDeclaration < Declaration::Abstract
    include Enumerable

    attr_reader :decls


    def initialize(loc, decls)
        ASSERT.kind_of loc,     LOC::Entry
        ASSERT.kind_of decls,   ::Array

        super(loc)

        @decls = decls
    end


    def empty?
        self.decls.empty?
    end


    def +(other)
        ASSERT.kind_of other, SeqOfDeclaration

        CSCD.make_seq_of_declaration(self.decls + other.decls)
    end


    def each
        self.decls.each do |decl|
            ASSERT.kind_of decl, CSCD::Abstract

            yield decl
        end
    end


    alias to_a decls


    def to_s
        self.map(&:to_s).join(' ')
    end


    def pretty_print(q)
        PRT.group_for_enum q, self
    end


private

    def __desugar__(env, event)
        new_env = env.enter event

        ASCD.make_seq_of_declaration(
            self.loc,

            self.decls.map { |decl|
                decl.desugar(new_env)
            }
        )
    end
end


EMPTY_SEQ_OF_DECRALATION = SeqOfDeclaration.new(
                       LOC.make_location(__FILE__, __LINE__),
                       [].freeze
                   ).freeze



module_function

    def make_empty_seq_of_declaration
        EMPTY_SEQ_OF_DECRALATION
    end


    def make_seq_of_declaration(decls)
        ASSERT.kind_of decls, ::Array

        SeqOfDeclaration.new(
            LOC.make_location(__FILE__, __LINE__),
            decls.freeze
        ).freeze
    end

end # Umu::ConcreteSyntax::Core::Declaration

end # Umu::ConcreteSyntax::Core

end # Umu::ConcreteSyntax

end # Umu
