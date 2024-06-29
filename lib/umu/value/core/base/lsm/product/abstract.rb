# coding: utf-8
# frozen_string_literal: true



module Umu

module Value

module Core

module Base

module LSM

module Product

class Abstract < LSM::Abstract
    include Enumerable

    attr_reader :objs


    def initialize(objs)
        ASSERT.kind_of objs, ::Object

        super()

        @objs = objs
    end


    def arity
        self.objs.size
    end


    def each
        self.objs.each do |obj|
            yield obj
        end
    end


    def select_by_number(sel_num, loc, env)
        ASSERT.kind_of sel_num,     ::Integer
        ASSERT.kind_of loc,         L::Location

        unless 1 <= sel_num && sel_num <= self.arity
            raise X::SelectionError.new(
                loc,
                env,
                "Selector expected 1..%d, but %d",
                    self.arity, sel_num
            )
        end
        value = self.values[sel_num - 1]

        ASSERT.kind_of value, VC::Top
    end
end

end # Umu::Value::Core::Base::LSM::Product

end # Umu::Value::Core::Base::LSM

end # Umu::Value::Core::Base

end # Umu::Value::Core

end # Umu::Value

end # Umu
