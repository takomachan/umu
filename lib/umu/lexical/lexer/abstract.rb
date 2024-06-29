# coding: utf-8
# frozen_string_literal: true



module Umu

module Lexical

module Lexer

class Abstract < Abstraction::Record
    attr_reader :loc
    attr_reader :braket_stack


    def self.deconstruct_keys
        {
            :loc            => LOC::Entry,
            :braket_stack   => ::Array
        }
    end


    def initialize(loc, braket_stack)
        ASSERT.kind_of loc,             LOC::Entry
        ASSERT.kind_of braket_stack,    ::Array

        @loc            = loc
        @braket_stack   = braket_stack
    end


    def to_s
        format("%s {braket_stack=%s} -- %s",
            E::Tracer.class_to_string(self.class),
            self.braket_stack.inspect,
            self.loc.to_s
        )
    end


    def comment_depth
        0
    end


    def braket_depth
        self.braket_stack.length
    end


    def in_comment?
        false
    end


    def in_braket?
        not self.braket_stack.empty?
    end


    def between_braket?
        if self.in_comment?
            false
        elsif self.in_braket?
            false
        else
            true
        end
    end


    def next_line_num(n = 1)
        ASSERT.kind_of n, ::Integer

        self.update(loc: self.loc.next_line_num(n))
    end


    def recover
        __make_separator__ self.loc.next_line_num, []
    end


    def lex(scanner)
        raise X::SubclassResponsibility
    end


private

    def __make_separator__(
        loc             = self.loc,
        braket_stack    = self.braket_stack
    )
        ASSERT.kind_of loc, LOC::Entry

        Separator.new(
            loc, braket_stack.freeze
        ).freeze
    end


    def __make_comment__(
        saved_loc,
        comment_depth,
        buf,
        loc             = self.loc,
        braket_stack    = self.braket_stack
    )
        ASSERT.kind_of saved_loc,       LOC::Entry
        ASSERT.kind_of comment_depth,   ::Integer
        ASSERT.kind_of buf,             ::String
        ASSERT.kind_of loc,             LOC::Entry

        Comment.new(
            loc, braket_stack.freeze, buf.freeze, saved_loc, comment_depth
        ).freeze
    end


    def __make_token__(
        loc             = self.loc,
        braket_stack    = self.braket_stack
    )
        ASSERT.kind_of loc, LOC::Entry

        Token.new(
            loc, braket_stack.freeze
        ).freeze
    end


    def __make_string__(
        buf,
        loc             = self.loc,
        braket_stack    = self.braket_stack
    )
        ASSERT.kind_of buf, ::String
        ASSERT.kind_of loc, LOC::Entry

        String::Basic.new(
            loc, braket_stack.freeze, buf.freeze
        ).freeze
    end


    def __make_symbolized_string__(
        buf,
        loc             = self.loc,
        braket_stack    = self.braket_stack
    )
        ASSERT.kind_of buf, ::String
        ASSERT.kind_of loc, LOC::Entry

        String::Symbolized.new(
            loc, braket_stack.freeze, buf.freeze
        ).freeze
    end
end

end # Umu::Lexical::Lexer

end # Umu::Lexical

end # Umu
