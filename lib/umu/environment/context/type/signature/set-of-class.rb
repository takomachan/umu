# coding: utf-8
# frozen_string_literal: true

require 'umu/common'


module Umu

module Environment

module Context

module Type

module Signature

class SetOfClass < Abstraction::Collection
    attr_reader :hash


    def initialize(signats)
        ASSERT.kind_of signats, ::Array

        @hash = signats.inject({}) { |hash, signat|
            ASSERT.kind_of signat, ECTSC::Base

            hash.merge(signat => true) {
                ASSERT.abort(
                    "Duplicated a class signature: %s", signat.inspect
                )
            }
        }.freeze
    end

    def empty?
        self.hash.empty?
    end


    def member?(signat)
        ASSERT.kind_of signat, ECTSC::Base

        self.hash.has_key? signat
    end


    def each
        self.hash.each_key do |signat|
            yield signat
        end
    end


    def union(other)
        ASSERT.kind_of other, SetOfClass

        SetOfClass.new(
            self.hash.merge(other.hash) { |signat, _, _|
                ASSERT.abort(
                    "Duplicated a class signature: %s", signat.inspect
                )
            }.keys.freeze
        ).freeze
    end
end



module_function

    def make_set(signats)
        ASSERT.kind_of signats, ::Array

        SetOfClass.new(signats.freeze).freeze
    end

EMPTY_SET = make_set([])

end # Umu::Environment::Context::Type::Signature

end # Umu::Environment::Context::Type

end # Umu::Environment::Context

end # Umu::Environment

end # Umu
