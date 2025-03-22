# coding: utf-8
# frozen_string_literal: true



module Umu

module Value

module Core

module Union

class Datum < Abstract
    def self.base_type_sym
        :Datum
    end


    def self.order_num
        __LINE__
    end


    define_class_method(
        :meth_make,
        :make, [:'tag:contents:'],
        [VCA::Symbol, VC::Top], self
    )
    def self.meth_make(_loc, _env, _event, tag, contents)
        ASSERT.kind_of tag,         VCA::Symbol
        ASSERT.kind_of contents,    VC::Top

        VC.make_datum tag.val, contents
    end


    attr_reader :tag_sym, :contents

    def initialize(tag_sym, contents)
        ASSERT.kind_of tag_sym,     ::Symbol
        ASSERT.kind_of contents,    VC::Top

        super()

        @tag_sym    = tag_sym
        @contents   = contents
    end


    define_instance_method(
        :meth_tag,
        :tag, [],
        [], VCA::Symbol
    )
    def meth_tag(_loc, _env, _event)
        VC.make_symbol self.tag_sym
    end


    def to_s
        format "%s %s", self.tag_sym.to_s, self.contents.to_s
    end


    def pretty_print(q)
        q.text format("%s ", self.tag_sym.to_s)
        q.pp self.contents
    end


    define_instance_method(
        :meth_to_string,
        :'to-s', [],
        [], VCA::String
    )
    def meth_to_string(loc, env, event)
        VC.make_string(
            format("%s %s",
                    self.tag_sym.to_s,
                    self.contents.meth_to_string(loc, env, event).val
            )
        )
    end


    define_instance_method(
        :meth_is_equal,
        :'==', [],
        [VC::Top], VCA::Bool
    )
    def meth_is_equal(loc, env, event, other)
        ASSERT.kind_of other, VC::Top

        VC.make_bool(
            super.true? && self.tag_sym == other.tag_sym
        )
    end


    define_instance_method(
        :meth_is_less_than,
        :'<', [],
        [VCU::Datum], VCA::Bool
    )
    def meth_is_less_than(loc, env, event, other)
        ASSERT.kind_of other, VCU::Datum

        unless other.contents.kind_of?(self.contents.class)
            raise X::TypeError.new(
                loc,
                env,
                "Expected a %s, but %s : %s",
                    self.contents.type_sym,
                    other.contents.to_s,
                    other.contents.type_sym
            )
        end

        VC.make_bool(
            if self.tag_sym == other.tag_sym
                self.contents.meth_is_less_than(
                    loc, env, event, other.contents
                ).true?
            else
                self.tag_sym < other.tag_sym
            end
        )
    end
end
Datum.freeze

end # Umu::Value::Core::Union


module_function

    def make_datum(tag_sym, contents)
        ASSERT.kind_of tag_sym,     ::Symbol
        ASSERT.kind_of contents,    VC::Top

        Union::Datum.new(tag_sym, contents).freeze
    end

end # Umu::Value::Core

end # Umu::Value

end # Umu
