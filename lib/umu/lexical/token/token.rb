# coding: utf-8
# frozen_string_literal: true



module Umu

module Lexical

module Token

class ReservedWord < Abstraction::Symbol
    def initialize(loc, val)
        ASSERT.kind_of val, ::String

        super(loc, val.upcase)
    end


    def to_s
        self.sym.to_s
    end


    alias to_racc_token sym
end



class ReservedSymbol < Abstraction::Symbol
    def to_s
        format "'%s'", self.sym
    end


    def to_racc_token
        self.sym.to_s
    end
end



class Symbol < Abstraction::Symbol
    def to_s
        format "SYM(%s)", self.sym
    end


    def to_racc_token
        :SYMBOL
    end
end



class ModuleDirectory < Abstraction::Symbol
    def to_s
        format "DIR(%s::)", self.sym
    end


    def to_racc_token
        :MODULE_DIR
    end
end



class Identifier < Abstraction::Symbol
    def to_s
        format "ID(%s)", self.sym
    end


    def to_racc_token
        :ID
    end
end



class Label < Abstraction::Symbol
    def to_s
        format "LABEL(%s:)", self.sym
    end


    def to_racc_token
        :LABEL
    end
end



class LabelSelector < Abstraction::Symbol
    def to_s
        format "LSEL($%s)", self.sym
    end


    def to_racc_token
        :LSEL
    end
end



class NumberSelector < Abstraction::Abstract
    def initialize(loc, val)
        ASSERT.kind_of val, ::Integer

        super
    end


    def to_s
        format "NSEL($%s)", self.val.to_s
    end


    def to_racc_token
        :NSEL
    end
end



class Message < Abstraction::Symbol
    def to_s
        format "MSG(.%s)", self.sym
    end


    def to_racc_token
        :MSG
    end
end



class String < Abstraction::String
    def initialize(loc, val)
        ASSERT.kind_of val, ::String

        super
    end


    def to_s
        format "STRING(\"%s\")", Escape.unescape(self.val)
    end


    def to_racc_token
        :STRING
    end
end



class Int < Abstraction::Abstract
    def initialize(loc, val)
        ASSERT.kind_of val, ::Integer

        super
    end


    def to_s
        format "INT(%s)", self.val.to_s
    end


    def to_racc_token
        :INT
    end
end



class Float < Abstraction::Abstract
    def initialize(loc, val)
        ASSERT.kind_of val, ::Float

        super
    end


    def to_s
        format "FLOAT(%s)", self.val.to_s
    end


    def to_racc_token
        :FLOAT
    end
end



module_function

    def make_reserved_word(loc, val)
        ASSERT.kind_of loc, LOC::Entry
        ASSERT.kind_of val, ::String

        ReservedWord.new(loc, val.freeze).freeze
    end


    def make_reserved_symbol(loc, val)
        ASSERT.kind_of loc, LOC::Entry
        ASSERT.kind_of val, ::String

        ReservedSymbol.new(loc, val.freeze).freeze
    end


    def make_symbol(loc, val)
        ASSERT.kind_of loc, LOC::Entry
        ASSERT.kind_of val, ::String

        Symbol.new(loc, val.freeze).freeze
    end


    def make_module_directory(loc, val)
        ASSERT.kind_of loc, LOC::Entry
        ASSERT.kind_of val, ::String

        ModuleDirectory.new(loc, val.freeze).freeze
    end


    def make_identifier(loc, val)
        ASSERT.kind_of loc, LOC::Entry
        ASSERT.kind_of val, ::String

        Identifier.new(loc, val.freeze).freeze
    end


    def make_label(loc, val)
        ASSERT.kind_of loc, LOC::Entry
        ASSERT.kind_of val, ::String

        Label.new(loc, val.freeze).freeze
    end


    def make_label_selector(loc, val)
        ASSERT.kind_of loc, LOC::Entry
        ASSERT.kind_of val, ::String

        LabelSelector.new(loc, val.freeze).freeze
    end


    def make_number_selector(loc, val)
        ASSERT.kind_of loc, LOC::Entry
        ASSERT.kind_of val, ::Integer

        NumberSelector.new(loc, val).freeze
    end


    def make_message(loc, val)
        ASSERT.kind_of loc, LOC::Entry
        ASSERT.kind_of val, ::String

        Message.new(loc, val.freeze).freeze
    end


    def make_string(loc, val)
        ASSERT.kind_of loc, LOC::Entry
        ASSERT.kind_of val, ::String

        String.new(loc, val.freeze).freeze
    end


    def make_integer(loc, val)
        ASSERT.kind_of loc, LOC::Entry
        ASSERT.kind_of val, ::Integer

        Int.new(loc, val).freeze
    end


    def make_float(loc, val)
        ASSERT.kind_of loc, LOC::Entry
        ASSERT.kind_of val, ::Float

        Float.new(loc, val).freeze
    end

end # Umu::Lexical::Token

end # Umu::Lexical

end # Umu
