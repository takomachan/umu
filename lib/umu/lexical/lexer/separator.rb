# coding: utf-8
# frozen_string_literal: true



module Umu

module Lexical

module Lexer

class Separator < Abstract
    def lex(scanner)
        ASSERT.kind_of scanner, ::StringScanner

        case
        # Begin-Comment
        when scanner.scan(/\(#/)
            [
                :BeginComment,

                scanner.matched,

                [],

                __make_comment__(
                    self.loc,   # Save current location
                    1,
                    ''
                )
            ]

        # New-line with optional Line-comment
        when scanner.scan(/(#.*)?\R/)
            [
                :NewLine,

                scanner.matched,

                [LT.make_newline(loc, scanner.matched)],

                __make_separator__(self.loc.next_line_num)
            ]

        # Other space-chars -- space or new-line (Tab is NOT included)
        when scanner.scan(/[ \R]+/)
            [
                :White,

                scanner.matched,

                [LT.make_space(loc, scanner.matched)],

                self
            ]

        # Unmatched
        else
            [
                :Unmatched,

                '',
                
                [],

                __make_token__
            ]
        end
    end
end

end # Umu::Lexical::Lexer

end # Umu::Lexical

end # Umu
