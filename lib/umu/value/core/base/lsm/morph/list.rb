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
    def self.make(xs)
        ASSERT.kind_of xs, ::Array

        VC.make_list xs
    end


    define_class_method(
        :meth_make_empty,
        :empty, [],
        [], self
    )
    def self.meth_make_empty(_loc, _env, _event)
        VC.make_nil
    end


    define_instance_method(
        :meth_cons,
        :cons, [],
        [VC::Top], self
    )
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


    def meth_to_list(loc, env, event)
        self
    end
end
Abstract.freeze



class Nil < Abstract
    def meth_is_empty(_loc, _env, _event)
        VC.make_true
    end


    def dest!
        raise ::StopIteration
    end
end
Nil.freeze

NIL = Nil.new.freeze



class Cons < Abstract
    define_class_method(
        :meth_make,
        :make, [:'head:tail:'],
        [VC::Top, VCBLM::List::Abstract], self
    )
    def self.meth_make(_loc, _env, _event, head, tail)
        ASSERT.kind_of head,    VC::Top
        ASSERT.kind_of tail,    List::Abstract

        VC.make_cons head, tail
    end


    attr_reader :head, :tail


    def initialize(head, tail)
        ASSERT.kind_of head,    VC::Top
        ASSERT.kind_of tail,    List::Abstract

        super()

        @head   = head
        @tail   = tail
    end


    def meth_head(_loc, _env, _event)
        self.head
    end


    def meth_tail(_loc, _env, _event)
        self.tail
    end


    def meth_is_empty(_loc, _env, _event)
        VC.make_false
    end


    def dest!
        VC.make_tuple self.head, self.tail
    end
    alias contents dest!


    define_instance_method(
        :meth_contents,
        :contents, [],
        [], VCBLP::Tuple
    )
    alias meth_contents meth_dest!
end
Cons.freeze

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
