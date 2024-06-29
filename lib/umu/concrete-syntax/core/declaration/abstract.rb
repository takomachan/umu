# coding: utf-8
# frozen_string_literal: true



module Umu

module ConcreteSyntax

module Core

module Declaration

class Abstract < ConcreteSyntax::Abstract
    def exported_vars
        raise X::SubclassResponsibility
    end
end

end # Umu::ConcreteSyntax::Core::Declaration

end # Umu::ConcreteSyntax::Core

end # Umu::ConcreteSyntax

end # Umu
