# coding: utf-8
# frozen_string_literal: true



module Umu

module Lexical

module Token

module Separator

class Newline < Abstraction::Abstract
    alias opt_val val


    def initialize(loc, opt_val)
        ASSERT.opt_kind_of opt_val, ::String

        super
    end


    def to_s
        if self.opt_val
            format "NL(%s)", self.val.inspect
        else
            "NL"
        end
    end


    def separator?
        true
    end
end



class Comment < Abstraction::String
    def to_s
        format "COMMENT(%s)", self.val.inspect
    end


    def separator?
        true
    end
end



class Space < Abstraction::String
    def to_s
        if self.val == " "
            'SP'
        else
            format "SP(%s)", self.val.inspect
        end
    end


    def separator?
        true
    end
end

end # Umu::Lexical::Token::Separator



module_function

    def make_newline(loc, opt_val)
        ASSERT.kind_of      loc,        LOC::Entry
        ASSERT.opt_kind_of  opt_val,    ::String

        Separator::Newline.new(loc, opt_val.freeze).freeze
    end


    def make_comment(loc, val)
        ASSERT.kind_of loc, LOC::Entry
        ASSERT.kind_of val, ::String

        Separator::Comment.new(loc, val.freeze).freeze
    end


    def make_space(loc, val)
        ASSERT.kind_of loc, LOC::Entry
        ASSERT.kind_of val, ::String

        Separator::Space.new(loc, val.freeze).freeze
    end

end # Umu::Lexical::Token

end # Umu::Lexical

end # Umu
