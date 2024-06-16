# coding: utf-8
# frozen_string_literal: true

require 'umu/common/assertion'



module Umu

module Lexical

class Location < Abstraction::Record
    attr_reader :file_name
    attr_reader :line_num


    def self.deconstruct_keys
        {
            file_name:  ::String,
            line_num:   ::Integer
        }.freeze
    end


    def initialize(file_name, line_num)
        ASSERT.kind_of file_name, ::String
        ASSERT.kind_of line_num,  ::Integer
        ASSERT.assert line_num >= 0

        @file_name = file_name
        @line_num  = line_num
    end


    def ==(other)
        other.kind_of?(self.class) &&
            self.file_name == other.file_name &&
            self.line_num == other.line_num
    end


    def to_s
        format "#%d in \"%s\"", self.line_num + 1, self.file_name
    end


    def next_line_num(n = 1)
        ASSERT.kind_of n, ::Integer

        self.update(line_num: line_num + n)
    end
end


INITIAL_LOCATION = Location.new('', 0).freeze


module_function

    def make_location(file_name, line_num)
        ASSERT.kind_of file_name, ::String
        ASSERT.kind_of line_num,  ::Integer

        Location.new(file_name.freeze, line_num).freeze
    end


    def make_initial_location
        INITIAL_LOCATION
    end

end # Umu::Lexcical

end # Umu
