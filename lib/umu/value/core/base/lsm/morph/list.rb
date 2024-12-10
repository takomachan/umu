# coding: utf-8
# frozen_string_literal: true



module Umu

module Value

module Core

module Base

module LSM

module Morph

module List

class Abstract < Morph::Abstract
    CLASS_METHOD_INFOS = [
        [:meth_make_empty,      self,
            :'empty']
    ]

    INSTANCE_METHOD_INFOS = [
        [ :meth_cons,           self,
            :cons,              VC::Top],
        [ :meth_map,            self,
            :map,               VC::Fun],
        [ :meth_select,         self,
            :select,            VC::Fun],
        [ :meth_append,         self,
            :append,            self],
        [ :meth_concat,         self,
            :concat],
        [ :meth_concat_map,    self,
            :'concat-map',     VC::Fun],
        [ :meth_zip,            self,
            :zip,               self],
        [ :meth_sort,           self,
            :sort]
    ]


    def self.make(xs)
        ASSERT.kind_of xs, ::Array

        VC.make_list xs
    end


    def self.meth_make_empty(_loc, _env, _event)
        VC.make_nil
    end


    def meth_cons(_loc, _env, _event, value)
        ASSERT.kind_of value, VC::Top

        VC.make_cons value, self
    end


    def to_s
        format "[%s]", self.map(&:to_s).join(', ')
    end


    def pretty_print(q)
        PRT.group_nary q, self, bb: '[', eb: ']', join: ', '
    end


    def meth_to_string(loc, env, event)
        VC.make_string(
            format("[%s]",
                self.map { |elem|
                    elem.meth_to_string(loc, env, event).val
                }.join(', ')
            )
        )
    end
end



class Nil < Abstract
    INSTANCE_METHOD_INFOS = [
        [:meth_contents,    VCBA::Unit,
            :contents]
    ]


    def meth_empty?(_loc, _env, _event)
        VC.make_true
    end


    def des!
        raise ::StopIteration
    end


    def contents
        VC.make_unit
    end
end

NIL = Nil.new.freeze



class Cons < Abstract
    INSTANCE_METHOD_INFOS = [
        [:meth_contents,    VCBLP::Tuple,
            :contents]
    ]


    attr_reader :head, :tail


    def initialize(head, tail)
        ASSERT.kind_of head,    VC::Top
        ASSERT.kind_of tail,    List::Abstract

        super()

        @head   = head
        @tail   = tail
    end


    def meth_empty?(_loc, _env, _event)
        VC.make_false
    end


    def des!
        VC.make_tuple [self.head, self.tail]
    end


    alias meth_contents meth_des!
end

end # Umu::Value::Core::LSM::Base::Morph::List

end # Umu::Value::Core::LSM::Base::Morph

end # Umu::Value::Core::LSM::Base

end # Umu::Value::Core::LSM


module_function

    def make_nil
        Base::LSM::Morph::List::NIL
    end


    def make_cons(head, tail)
        ASSERT.kind_of head,    VC::Top
        ASSERT.kind_of tail,    Base::LSM::Morph::List::Abstract

        Base::LSM::Morph::List::Cons.new(head, tail).freeze
    end


    def make_list(xs, tail = VC.make_nil)
        ASSERT.kind_of xs,      ::Array
        ASSERT.kind_of tail,    Base::LSM::Morph::List::Abstract

        xs.reverse_each.inject(tail) { |ys, x|
            VC.make_cons x, ys
        }
    end

end # Umu::Value::Core

end # Umu::Value

end # Umu
