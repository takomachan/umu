# coding: utf-8
# frozen_string_literal: true



module Umu

module Environment

module Context

module Value

class Initial < Abstract

private

    def __extend__(sym, target)
        ASSERT.kind_of sym,     ::Symbol
        ASSERT.kind_of target,  Target::Abstract

        [{sym => target}, self]
    end
end

INITIAL = Initial.new.freeze


module_function

    def make_initial
        INITIAL
    end

end # Umu::Environment::Context::Value

end # Umu::Environment::Context

end # Umu::Environment

end # Umu
