# coding: utf-8
# frozen_string_literal: true



module Umu

module Value

module Core

module Union

class Datum < Abstract
    attr_reader :tag_sym, :contents


    def initialize(tag_sym, contents)
        ASSERT.kind_of tag_sym,     ::Symbol
        ASSERT.kind_of contents,    VC::Top

        super()

        @tag_sym    = tag_sym
        @contents   = contents
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


    def to_s
        format "%s %s", self.tag_sym.to_s, self.contents.to_s
    end


    def pretty_print(q)
        q.text format("%s ", self.tag_sym.to_s)
        q.pp self.contents
    end


    def meth_to_string(loc, env, event)
        VC.make_string(
            format("%s %s",
                    self.tag_sym.to_s,
                    self.contents.meth_to_string(loc, env, event).val
            )
        )
    end


    def meth_equal(loc, env, event, other)
        ASSERT.kind_of other, VC::Top

        VC.make_bool(
            (
                other.kind_of?(self.class) &&
                self.tag_sym == other.tag_sym &&
                self.contents.meth_equal(
                    loc, env, event, other.contents
                ).true?
            )
        )
    end


    define_instance_method(
        :meth_tag,
        :tag, [],
        [], VCA::Symbol
    )
    def meth_tag(_loc, _env, _event)
        VC.make_symbol self.tag_sym
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
