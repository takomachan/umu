# coding: utf-8
# frozen_string_literal: true


require 'strscan'

require_relative 'lexer/abstract'
require_relative 'lexer/separator'
require_relative 'lexer/comment'
require_relative 'lexer/token'
require_relative 'lexer/string'
require_relative 'lexer/entry'



=begin
The lexcical analyzer is modeled as a finite state machine with a stack.
Here we show the definition of a model using a fictitious domain
specific language (DSL).
This domain specific language was inspired by Estelle,
a formal specification description language for communication protocols.


字句解析器は、スタック付き有限状態機械としてモデル化される。
ここでは、架空のドメイン固有言語(DSL)によるモデルの定義を示す。
このドメイン記述言語は、通信プロトコルの
形式的仕様記述言語であるEstelleから発想を得て考案した。

Estelleに関する文献を以下に示す。
* 通信システムの形式記述技法の標準化：
    Estelle言語の特質と処理系の現状と動向
    情報処理, Vol.31 No.1, Jan. 1990, 岡田康治, IPSJ-MGN310109
* プロトコル言語
    1994年, 監修 水野忠則, 発行 (株)カットシステム, ISBN 4-906391-08-7


#######################################
##### State Machine Specification  ####
#######################################

%STRUCTURE Lexer {
    %DATA Pattern {
      | PatBeginComment  String
      | PatEndComment    String
      | PatNewline       String
      | PatSpace         String
      | PatBeginString   String
      | PatEndString     String
      | PatBeginBraket   String
      | PatEndBraket     String
      | PatNumber        String
      | PatWord          String
      | Any              String
    }

    %DATA Token {
      | TokNewline     (String, Int)    /* NL(String)       */
      | TokSpace       (String, Int)    /* SP(String)       */
      | TokComment     (String, Int)    /* COMMENT(String)  */

      | TokBeginBraket (String, Int)
      | TokEndBraket   (String, Int)

      | TokReserved    (Symbol, Int)    /* IF, THEN, ELSE, ... etc */

      | TokIdentifier  (Symbol, Int)    /* ID(Symbol) or    */
                                        /* MSG(Symbol) or   */
                                        /* LABEL(Symbol) or */
                                        /* DIR(Symbol) or   */
                                        /* NSEL(Int) or     */
                                        /* LSEL(Symbol) or  */

      | TokNumber      (Number, Int)    /* INT(Int) or      */
                                        /* FLOAT(Float)     */

      | TokSymbol      (Symbol, Int)    /* SYM(Symbol)      */
      | TokString      (String, Int)    /* STRING(String)   */
    }

    %INPUT %EVENT  = Pattern
    %OUTPUT %EVENT = Token


    %STRUCTURE Abstraction {
        %ABSTRACT %STATE Abstract %HAS {
            line-num:       Int,
            braket-stack:   String List
        }

        %ABSTRACT %STATE String %IS-A Abstract %HAS {
            buf:            String
        }
    }

    %STATE Separator %IS-A Abstraction::Abstract

    %STATE Comment %IS-A Abstraction::Abstract %HAS {
        buf:            String,
        saved-line-num: Int,
        comment-depth:  Int
    }

    %STATE Token %IS-A Abstraction::Abstract

    %STATE BasicString      %IS-A Abstraction::String
    %STATE SymbolizedString %IS-A Abstraction::String

    %INITIAL %STATE = %NEW Separator {line-num: 1 braket-stack: []}

    %VAL braket-map = %{"(" -> ")", "[" -> "]", "{" -> "}", ....}


    %TRANSITION {
      %FROM Separator {line-num:}
        %WHEN PatBeginComment _
            %TO Comment {
                    buf: "" saved-line-num: line-num comment-depth: 1
                }
        %WHEN PatNewline matched
            %OUTPUT TokNewline (matched, line-num)
            %TO %SAME {line-num: line-num + 1}
        %WHEN PatSpace matched
            %OUTPUT TokSpace (matched, line-num)
        %WHEN %ANY
            %TO Token
    | %FROM Comment {
            buf:
            saved-line-num: saved-line-num
            comment-depth: depth
        }
        %WHEN PatBeginComment matched
            %TO %SAME {buf: buf ^ matched comment-depth: depth + 1}
        %WHEN PatEndComment matched
            ! %IF depth <= 1 %THEN
                %OUTPUT TokComment (buf, saved-line-num)
                %TO Separator
              %ELSE
                %TO %SAME {buf: buf ^ matched comment-depth: depth - 1}
        %WHEN PatNewline matched
            %TO %SAME {line-num: line-num + 1 buf: buf ^ matched}
        %WHEN PatAny matched
            %TO %SAME {buf: buf ^ matched}
        %WHEN %ANY
            %ABORT "No case"
    | %FROM Token {line-num: braket-stack: stack}
        %WHEN PatBeginString
            ! %IF symbol?
                %TO SymbolizedString {buf: ""}
              %ELSE
                %TO BasicString {buf: ""}
        %WHEN PatBeginBraket matched
            %OUTPUT BeginBraket (matched, line-num)
            %TO Separator {braket-stack: [matched|stack]}
        %WHEN PatEndBraket matched-eb
            ! %CASE stack %OF {
                [] -> %ERROR "Unexpected end-braket"
              | [bb|stack'] ->
                    %CASE braket-map.(lookup bb) %OF {
                      | NONE -> %ABORT ("Unknown bracket: " ^ bb)
                      | Some found-eb ->
                            %IF matched-eb == found-eb %THEN
                                %OUTPUT EndBraket (matched-eb, line-num)
                                %TO Separator {braket-stack: stack'}
                            %ELSE
                                %ERROR "Mismatched brakets"
                    }
            }
        %WHEN PatNumber matched
            %OUTPUT TokNumber (to-number matched, line-num)
            %TO Separator
        %WHEN PatWord matched
            ! %IF symbol? %THEN
                %OUTPUT TokSymbol (to-symbol matched, line-num)
              %ELSE
                %IF reserved? %THEN
                    %OUTPUT TokReserved (to-symbol matched, line-num)
                %ELSE
                    %OUTPUT TokIdentifier (to-symbol matched, line-num)
            %TO Separator
        %WHEN %ANY
            %ERROR "Can't recognized as token"
    | %FROM AbstractString {buf: ..}
        %WHEN PatNewline
            %ERROR "Unexpected end-of-string"
        %WHEN PatAny matched
            %TO %SAME {buf: buf ^ matched}
    | %FROM BasicString {line-num:, buf: ..}
        %WHEN PatEndString
            %OUTPUT TokString (buf, line-num)
            %TO Separator
        %WHEN %ANY
            %ABORT
    | %FROM SymbolizedString {line-num:, buf: ..}
        %WHEN PatEndString
            %OUTPUT TokSymbol (buf, line-num)
            %TO Separator
        %WHEN %ANY
            %ABORT
    }
}
=end
