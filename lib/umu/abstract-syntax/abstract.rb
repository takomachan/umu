# coding: utf-8
# frozen_string_literal: true

require 'umu/common'
require 'umu/abstraction'


module Umu

module AbstractSyntax

class Abstract < Abstraction::Model
    def evaluate(env)
        raise X::SubclassResponsibility
    end
end

end # Umu::AbstractSyntax

end # Umu
