# coding: utf-8
# frozen_string_literal: true

require 'umu/common'


module Umu

module Escape

EACAPE_PAIRS = [
    ["\\n",     "\n"],
    ["\\t",     "\t"],
    ["\\\"",    "\""],
    ["\\\\",    "\\"]
]

MAP_OF_UNESCAPE_TO_ESCAPE = EACAPE_PAIRS.inject({}) { |hash, (unesc, esc)|
    hash.merge(unesc => esc) { |key, _, _|
        ASSERT.abort format("Duplicated unescape-char: '%s'", key)
    }
}

MAP_OF_ESCAPE_TO_UNESCAPE = EACAPE_PAIRS.inject({}) { |hash, (unesc, esc)|
    hash.merge(esc => unesc) { |key, _, _|
        ASSERT.abort format("Duplicated escape-char: '%s'", key)
    }
}


module_function

    def opt_escape(unesc)
        ASSERT.kind_of unesc, ::String

        opt_esc = MAP_OF_UNESCAPE_TO_ESCAPE[unesc]

        ASSERT.opt_kind_of opt_esc.freeze, ::String
    end


    def unescape(esc)
        ASSERT.kind_of esc, ::String

        esc.each_char.map { |esc_char|
            opt_unesc_char = MAP_OF_ESCAPE_TO_UNESCAPE[esc_char]

            if opt_unesc_char
                opt_unesc_char
            else
                esc_char
            end
        }.join
    end


    def find_escape(unesc)
        ASSERT.kind_of unesc, ::String

        opt_esc = unesc.each_char.find { |unesc_char|
            ! MAP_OF_ESCAPE_TO_UNESCAPE[unesc_char].nil?
        }

        ASSERT.opt_kind_of opt_esc.freeze, ::String
    end

end # Umu::Escape

end # Umu
