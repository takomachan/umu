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
