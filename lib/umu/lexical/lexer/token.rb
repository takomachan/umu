# coding: utf-8
# frozen_string_literal: true



module Umu

module Lexical

module Lexer

class Token < Abstract

IDENT_WORD = '(_*[[:alpha:]][[:alnum:]]*(\-[[:alnum:]]+)*_*[\?!]?\'*)'
# See -> https://qiita.com/Takayuki_Nakano/items/8d38beaddb84b488d683

MODULE_DIRECTORY_PATTERN    = Regexp.new IDENT_WORD + '::'
IDENT_PATTERN               = Regexp.new '([@$\.])?' + IDENT_WORD + '(:)?'

RESERVED_WORDS = [
    '__FILE__',     '__LINE__',
    'and',          'assert',
    'case',         'cond',
    'do',
    'else',         'elsif',
    'fun',
    'if',           'import',           'in',
    'kind-of?',
    'let',
    'mod',
    'of',
    'pow',
    'rec',
    'struct',       'structure',
    'then',
    'val',
    'where',

    # Not used, but reserved for future

    # For pattern matching
    'as',

    # For pragma
    'pragma', 'use',

    # For module language
    'functor', 'signat', 'signature',

    # For data type declaration
    'datum', 'type',

    # For object type (OOP)
    'abstract', 'alias', 'class', 'def',
    'is-a', 'protocol', 'self', 'super', 'with',

    # For infix operator declaration
    'infix', 'infixr',

    # For continuation
    'callcc', 'throw',

    # For refernce type
    'peek', 'poke', 'ref',

    # For lazy evaluation
    'delay', 'force', 'lazy',

    # For non-determinism
    'none', 'or'
].inject({}) { |hash, word|
    hash.merge(word => true) { |key, _, _|
        ASSERT.abort format("Duplicated reserved-word: '%s'", key)
    }
}

RESERVED_SYMBOLS = [
    '=',    '$',    '!',    '_',    ',',
    '&',    '|',
    '&&',   '||',
    '.',    ':',    ';',
    '..',   '::',   ';;',
    '->',   '<-',

    # Redefinable symbols
    '+',    '-',    '*',    '/',    '^',
    '==',   '<>',   '<',    '>',    '<=',   '>=',   '<=>',
    '++',   '<<',   '>>',   '<|',   '|>',

    # Not used, but reserved for future
    '...'   # Interval (exclude last value)
].inject({}) { |hash, x|
    hash.merge(x => true) { |key, _, _|
        ASSERT.abort format("Duplicated reserved-symbol: '%s'", key)
    }
}


IDENTIFIER_SYMBOLS = [
    # empty
].inject({}) { |hash, x|
    hash.merge(x => true) { |key, _, _|
        ASSERT.abort format("Duplicated identifier-symbol: '%s'", key)
    }
}


BRAKET_PAIRS = [
    ['(',   ')'],   # Tuple, etc
    ['[',   ']'],   # List
    ['{',   '}'],   # Lambda, etc
    ['&(',  ')'],   # Instance method
    ['$(',  ')'],   # Named tuple modifier


    # Not used, but reserved for future

    ['%[',  ']'],   # Morph -- Polymorphism
    ['%q[', ']'],   # Queue
    ['%v[', ']'],   # Vector
    ['%a[', ']'],   # Array
    ['%(',  ')'],   # Set
    ['%{',  '}'],   # Map
    ['@[',  ']'],   # Assoc -- Key-Value list
    ['&{',  '}'],   # Class method
    ['&[',  ']'],   # Stream -- Deffered list
    ['$[',  ']'],   # Channel -- For concurrency
    ['${',  '}']    # Suspended list
]


BRAKET_MAP_OF_BEGIN_TO_END = BRAKET_PAIRS.inject({}) { |hash, (bb, eb)|
    hash.merge(bb => eb) { |key, _, _|
        ASSERT.abort format("Duplicated begin-braket: '%s'", key)
    }
}


BEGIN_BRAKET_SYMBOLS = BRAKET_PAIRS.inject({}) { |hash, (bb, _eb)|
    hash.merge(bb => true) { |key, _, _|
        ASSERT.abort format("Duplicated begin-braket: '%s'", key)
    }
}


END_BRAKET_SYMBOLS = BRAKET_PAIRS.inject({}) { |hash, (_bb, eb)|
    hash.merge(eb => true)
}


SYMBOL_PATTERNS = [
    RESERVED_SYMBOLS,
    IDENTIFIER_SYMBOLS,
    BEGIN_BRAKET_SYMBOLS,
    END_BRAKET_SYMBOLS
].inject({}) { |acc_hash, elem_hash|
    acc_hash.merge(elem_hash) { |key, _, _|
        ASSERT.abort format("Duplicated symbol: '%s'", key)
    }
}.keys.sort { |x, y|
    y.length <=> x.length   # For longest-match
}.map { |s|
    Regexp.new Regexp.escape(s)
}


    def lex(scanner)
        ASSERT.kind_of scanner, ::StringScanner

        case
        # Float or Int
        when scanner.scan(/[+-]?\d+(\.\d+)?/)
            [
                :Number,

                scanner.matched,

                if scanner[1]
                    LT.make_float self.loc, scanner.matched.to_f
                else
                    LT.make_integer self.loc, scanner.matched.to_i
                end,

                __make_separator__
            ]

        # Begin-String
        when scanner.scan(/(@)?"/)
            [
                :BeginString,

                scanner.matched,

                nil,

                if scanner[1]
                    __make_symbolized_string__('')
                else
                    __make_string__('')
                end
            ]


        # Module identifier word
        when scanner.scan(MODULE_DIRECTORY_PATTERN)
            body_matched = scanner[1]

            [
                :Word,

                scanner.matched,

                LT.make_module_directory(self.loc, body_matched),

                __make_separator__
            ]


        # Symbol, Message, Reserved-word or Identifier-word
        when scanner.scan(IDENT_PATTERN)
            head_matched = scanner[1]
            body_matched = scanner[2]
            tail_matched = scanner[4]

            [
                :Word,

                scanner.matched,

                if head_matched
                    if tail_matched
                        raise X::LexicalError.new(
                            self.loc,
                            "Invalid character: ':' in Symbol: '%s'",
                                scanner.matched
                        )
                    end

                    case head_matched
                    when '@'
                        LT.make_symbol   self.loc, body_matched
                    when '$'
                        LT.make_selector self.loc, body_matched
                    when '.'
                        LT.make_message  self.loc, body_matched
                    else
                        ASSERT.abort head_matched
                    end
                else
                    if tail_matched
                        LT.make_label self.loc, body_matched
                    else
                        if RESERVED_WORDS[body_matched]
                            LT.make_reserved_word self.loc, body_matched
                        else
                            LT.make_identifier self.loc, body_matched
                        end
                    end
                end,

                __make_separator__
            ]


        # Reserved-symbol or Identifier-symbol
        when SYMBOL_PATTERNS.any? { |pat| scanner.scan pat }
            matched = scanner.matched

            if RESERVED_SYMBOLS[matched]
                [
                    :ReservedSymbol,

                    scanner.matched,

                    LT.make_reserved_symbol(self.loc, matched),

                    __make_separator__
                ]
            elsif IDENTIFIER_SYMBOLS[matched]
                [
                    :IdentifierSymbol,

                    scanner.matched,

                    LT.make_identifier(self.loc, matched),

                    __make_separator__
                ]
            elsif BEGIN_BRAKET_SYMBOLS[matched]
                [
                    :BeginBraket,

                    scanner.matched,

                    LT.make_reserved_symbol(self.loc, matched),

                    __make_separator__(
                        self.loc, [matched] + self.braket_stack
                    )
                ]
            elsif END_BRAKET_SYMBOLS[matched]
                bb, *stack = self.braket_stack
                unless bb   # Is stack empty?
                    raise X::LexicalError.new(
                        self.loc,
                        "Unexpected end-braket: '%s'", matched
                    )
                end

                eb = BRAKET_MAP_OF_BEGIN_TO_END[bb]
                unless eb
                    ASSERT.abort self.inspect
                end

                if matched == eb
                    [
                        :EndBraket,

                        scanner.matched,
                        
                        LT.make_reserved_symbol(self.loc, matched),

                        __make_separator__(self.loc, stack)
                    ]
                else
                    raise X::LexicalError.new(
                        self.loc,
                        "Mismatch of brakets: '%s' .... '%s'",
                                              bb,       matched
                    )
                end
            else
                ASSERT.abort matched
            end

        # Unmatched
        else
            raise X::LexicalError.new(
                self.loc,
                "Can't recognized as token: '%s'", scanner.inspect
            )
        end
    end
end

end # Umu::Lexical::Lexer

end # Umu::Lexical

end # Umu
