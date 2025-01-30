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
escription language.
This domain description language was inspired by Estelle,
a formal specification description language for communication protocols.


字句解析器は、スタック付き有限状態機械としてモデル化される。
ここでは、架空のドメイン記述言語によるモデルの定義を示す。
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

    %DATA Token =
      TkNewline     (String, Int)
    | TkWhite       (String, Int)
    | TkComment     (String, Int)
    | TkBeginBraket (String, Int)
    | TkEndBraket   (String, Int)
    | TkNumber      (Number, Int)
    | TkReserved    (Symbol, Int)
    | TkIdentifier  (Symbol, Int)
    | TkSymbol      (Symbol, Int)
    | TkString      (String, Int)

    %DATA Pattern =
      BeginComment  String
    | EndComment    String
    | Newline       String
    | White         String
    | BeginString   String
    | EndString     String
    | BeginBraket   String
    | EndBraket     String
    | Number        String
    | Word          String
    | Any           String

    %INPUT %EVENT  = Pattern
    %OUTPUT %EVENT = Token


    %ABSTRACT %STATE Abstract {
        line-num:       Int,
        braket-stack:   String List
    }
    %ABSTRACT %STATE AbstractString %IS-A Abstract {
        buf:            String
    }

    %STATE Separator %IS-A Abstract
    %STATE Comment   %IS-A Abstract {
        buf:            String,
        saved-line-num: Int,
        comment-depth:  Int
    }
    %STATE Token     %IS-A Abstract

    %STATE BasicString      %IS-A AbstractString
    %STATE SymbolizedString %IS-A AbstractString

    %INITIAL %STATE Separator {line-num: 1, braket-stack: []}

    %VAL braket-map = %{"(" -> ")", "[" -> "]", "{" -> "}", ....}


    %TRANSITION {
      %FROM Separator {line-num:}
        %WHEN BeginComment _
            %TO Comment {
                    buf: "", saved-line-num: line-num, comment-depth: 1
                }
        %WHEN Newline matched
            %OUTPUT TkNewline (matched, line-num)
            %TO %SAME {line-num: line-num + 1}
        %WHEN White matched
            %OUTPUT TkWhite (matched, line-num)
        %WHEN %ANY
            %TO Token
    | %FROM Comment {
            buf:,
            saved-line-num: saved-line-num,
            comment-depth: depth
            ..
        }
        %WHEN BeginComment matched
            %TO %SAME {buf: buf ^ matched, comment-depth: depth + 1}
        %WHEN EndComment matched
            %IF depth <= 1 %THEN
                %OUTPUT TkComment (buf, saved-line-num)
                %TO Separator
            %ELSE
                %TO %SAME {buf: buf ^ matched, comment-depth: depth - 1}
            %END
        %WHEN Newline matched
            %TO %SAME {line-num: line-num + 1, buf: buf ^ matched}
        %WHEN Any matched
            %TO %SAME {buf: buf ^ matched}
        %WHEN %ANY
            %ABORT
    | %FROM Token {line-num:, braket-stack: stack}
        %WHEN BeginString
            %IF symbol?
                %TO SymbolizedString {buf: ""}
            %ELSE
                %TO BasicString {buf: ""}
            %END
        %WHEN BeginBraket matched
            %OUTPUT BeginBraket (matched, line-num)
            %TO Separator {braket-stack: [matched|stack]}
        %WHEN EndBraket matched-eb
            %CASE stack %OF
               [] -> %ERROR "Unexpected end-braket"
            %OR [bb|stack'] ->
                %CASE braket-map.(lookup bb) %OF
                   NONE -> %ABORT
                %OR Some found-eb ->
                    %IF matched-eb == found-eb %THEN
                        %OUTPUT EndBraket (matched-eb, line-num)
                        %TO Separator {braket-stack: stack'}
                    %ELSE
                        %ERROR "Mismatched brakets"
                    %END
                %END
            %END
        %WHEN Number matched
            %OUTPUT TkNumber (to-number matched, line-num)
            %TO Separator
        %WHEN Word matched
            %IF symbol?
                %OUTPUT TkSymbol (to-symbol matched, line-num)
            %ELSE
                %IF reserved?
                    %OUTPUT TkReserved (to-symbol matched, line-num)
                %ELSE
                    %OUTPUT TkIdentifier (to-symbol matched, line-num)
                %END
            %END
            %TO Separator
        %WHEN %ANY
            %ERROR "Can't recognized as token"
    | %FROM AbstractString {buf: ..}
        %WHEN Newline
            %ERROR "Unexpected end-of-string"
        %WHEN Any matched
            %TO %SAME {buf: buf ^ matched}
    | %FROM BasicString {line-num:, buf: ..}
        %WHEN EndString
            %OUTPUT TkString (buf, line-num)
            %TO Separator
        %WHEN %ANY
            %ABORT
    | %FROM SymbolizedString {line-num:, buf: ..}
        %WHEN EndString
            %OUTPUT TkSymbol (buf, line-num)
            %TO Separator
        %WHEN %ANY
            %ABORT
    }
=end
