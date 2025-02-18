# coding: utf-8
# frozen_string_literal: true



module Umu

module ConcreteSyntax

module Core

module Pattern

module Container

module Morph

module Monomorph

class List < Abstract
    def initialize(loc, pats, opt_last_pat)
        ASSERT.kind_of      pats,           ::Array
        ASSERT.opt_kind_of  opt_last_pat,   ElementOfContainer::Variable

        super

        if opt_last_pat && opt_last_pat.opt_type_sym
            raise X::SyntaxError.new(
                loc,
                "Can not assert type to tail pattern: '%s'",
                opt_last_pat.to_s
            )
        end
    end



private

    def __bb__
        '['
    end


    def __eb__
        ']'
    end


    def __opt_type_sym_of_morph__
        :List
    end


    def __opt_type_sym_of_nil__
        :Nil
    end


    def __opt_type_sym_of_cons__
        :Cons
    end
end

end # Umu::ConcreteSyntax::Core::Pattern::Container::Morph::Monomorph

end # Umu::ConcreteSyntax::Core::Pattern::Container::Morph

end # Umu::ConcreteSyntax::Core::Pattern::Container


module_function

    def make_list(loc, pats = [], opt_last_pat = nil)
        ASSERT.kind_of      loc,            LOC::Entry
        ASSERT.kind_of      pats,           ::Array
        ASSERT.opt_kind_of  opt_last_pat,   ElementOfContainer::Variable

        Container::Morph::Monomorph::List.new(
            loc, pats.freeze, opt_last_pat
        ).freeze
    end

end # Umu::ConcreteSyntax::Core::Pattern

end # Umu::ConcreteSyntax::Core

end # Umu::ConcreteSyntax

end # Umu
