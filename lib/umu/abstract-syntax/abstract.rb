# coding: utf-8
# frozen_string_literal: true



module Umu

module AbstractSyntax

class Abstract < Abstraction::Model
    def pretty_print(q)
        q.text self.to_s
    end


    def evaluate(env)
        raise X::InternalSubclassResponsibility
    end
end

end # Umu::AbstractSyntax

end # Umu
