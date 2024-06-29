# coding: utf-8
# frozen_string_literal: true



module Umu

module Value

module Core

module Struct

class Field < ::Object
    attr_reader :label, :value


    def initialize(label, value)
        ASSERT.kind_of label,   ::Symbol
        ASSERT.kind_of value,   VC::Top

        super()

        @label  = label
        @value  = value
    end


    def to_s
        case self.value
        when Entry
            format "structure %s", self.label.to_s
        when Fun
            format "fun %s",       self.label.to_s
        else
            format "val %s : %s",  self.label.to_s, self.value.type_sym.to_s
        end
    end


    def pretty_print(q)
        case self.value
        when Entry
            q.text format(
                 "structure %s", self.label.to_s
            )
        when Fun
            q.text format(
                 "fun %s",       self.label.to_s
            )
        else
            q.text format(
                 "val %s : %s",  self.label.to_s, self.value.type_sym.to_s
            )
        end
    end
end



class Entry < Top
    TYPE_SYM = :Struct

    include Enumerable

    attr_reader :value_by_label


    def initialize(value_by_label)
        ASSERT.kind_of value_by_label, ::Hash

        @value_by_label = value_by_label
    end


    def each
        self.value_by_label.each do |label, value|
            ASSERT.kind_of label,   ::Symbol
            ASSERT.kind_of value,   VC::Top

            yield VC.make_struct_field label, value
        end
    end


    def to_s
        format "struct {%s}", self.map(&:to_s).join(' ')
    end


    def pretty_print(q)
        P.seplist q, self, 'struct {', '}', ' '
    end


    def select(sel_lab, loc, env)
        ASSERT.kind_of sel_lab,     ::Symbol
        ASSERT.kind_of loc,         LOC::Entry

        value = self.value_by_label[sel_lab]
        unless value
            raise X::SelectionError.new(
                loc,
                env,
                "Unknown selector label: '%s'", sel_lab
            )
        end

        ASSERT.kind_of value, VC::Top
    end
end

end # Umu::Value::Core::Struct


module_function

    def make_struct_field(label, value)
        ASSERT.kind_of label,   ::Symbol
        ASSERT.kind_of value,   VC::Top

        Struct::Field.new(label, value).freeze
    end


    def make_struct(value_by_label)
        ASSERT.kind_of value_by_label, ::Hash

        Struct::Entry.new(value_by_label.freeze).freeze
    end

end # Umu::Value::Core

end # Umu::Value

end # Umu
