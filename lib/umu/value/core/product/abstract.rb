# coding: utf-8
# frozen_string_literal: true



module Umu

module Value

module Core

module Product

class Abstract < Object
    include Enumerable

    attr_reader :fst_obj, :snd_obj, :tail_objs


    def initialize(fst_obj, snd_obj, tail_objs)
        ASSERT.kind_of fst_obj,   ::Object
        ASSERT.kind_of snd_obj,   ::Object
        ASSERT.kind_of tail_objs, ::Array

        super()

        @fst_obj   = fst_obj
        @snd_obj   = snd_obj
        @tail_objs = tail_objs
    end


    def objs
        [self.fst_obj, self.snd_obj] + self.tail_objs
    end


    def arity
        2 + self.tail_objs.size
    end


    def each
        yield self.fst_obj

        yield self.snd_obj

        self.tail_objs.each do |obj|
            yield obj
        end
    end


    def select_by_number(sel_num, loc, env)
        ASSERT.kind_of sel_num,     ::Integer
        ASSERT.kind_of loc,         LOC::Entry

        value = case sel_num
            when 1
                self.fst_obj
            when 2
                self.snd_obj
            else
                unless 3 <= sel_num && sel_num <= self.arity
                    raise X::SelectionError.new(
                        loc,
                        env,
                        "Selector expected 1..%d, but %d",
                            self.arity, sel_num
                    )
                end

                self.tail_objs[sel_num - 3]
            end

        ASSERT.kind_of value, VC::Top
    end
end

end # Umu::Value::Core::Product

end # Umu::Value::Core

end # Umu::Value

end # Umu
