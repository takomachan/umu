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
        when scanner.scan(/(#.*)?(\R)/)
            comment_matched = scanner[1]
            newline_matched = scanner[2]

            [
                :NewLine,

                scanner.matched,

                (
                    if (! comment_matched) || comment_matched.empty?
                        []
                    else
                        [LT.make_comment(loc, comment_matched)]
                    end
                ) + [
                    LT.make_newline(loc, newline_matched)
                ],

                __make_separator__(self.loc.next_line_num)
            ]

        # Other space-chars
        when scanner.scan(/ +/)
            [
                :Space,

                scanner.matched,

                [LT.make_space(loc, scanner.matched)],

                self
            ]

        # Tab char
        when scanner.scan(/\t/)
            raise X::LexicalError.new(
                loc,
                "Hard tab '\\t' is prohibited",
            )

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
