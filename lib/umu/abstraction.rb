# coding: utf-8
# frozen_string_literal: true

require_relative 'common'
require_relative 'lexical/location'


module Umu

module Abstraction

class Model
    attr_reader :loc


    def initialize(loc)
        ASSERT.kind_of loc, L::Location

        @loc = loc
    end


    def to_s
        raise X::SubclassResponsibility
    end
end



class LabelValuePair < Model
    attr_reader :label, :value


    def initialize(loc, label, value)
        ASSERT.kind_of label,   ::Symbol
        ASSERT.kind_of value,   ::Object    # Polymophic

        super(loc)

        @label  = label
        @value  = value
    end


    def <=>(other)
        ASSERT.kind_of other, self.class

        self.label <=> other.label
    end


    def to_s
        format("%s%s",
                self.label.to_s,

                if self.value
                    format("%s%s",
                            __infix_string__,

                            if block_given?
                                yield self.value
                            else
                                self.value.to_s
                            end
                    )
                else
                    ''
                end
        )
    end


private

    def __infix_string__
        ':'
    end
end



class Record
    def self.__deconstruct_keys__
        (
            if superclass.respond_to? :__deconstruct_keys__
                superclass.__deconstruct_keys__
            else
                {}.freeze
            end
        ).merge(
            if self.respond_to? :deconstruct_keys
                ASSERT.kind_of self.deconstruct_keys, ::Hash
            else
                {}.freeze
            end
        ).freeze
    end


    def deconstruct_keys
        self.class.__deconstruct_keys__.inject({}) { |hash, (key, _val)|
            hash.merge(key => self.public_send(key))
        }.freeze
    end


    def update(args)
        ASSERT.kind_of args, ::Hash

        class_keys = self.class.deconstruct_keys
        args.each do |key, value|
            unless class_keys.has_key? key
                ASSERT.abort "Unknown key: %s", key
            end

            klass = class_keys[key]
            ASSERT.kind_of value, klass
        end

        self.class.new(*self.deconstruct_keys.merge(args).values).freeze
    end
end



class Collection
    include Enumerable
end

end # Umu::Abstraction

end # Umu
