require 'umu/lexical/lexer/abstract'
require 'umu/lexical/lexer/separator'
require 'umu/lexical/lexer/comment'
require 'umu/lexical/lexer/token'
require 'umu/lexical/lexer/string'
require 'umu/lexical/lexer/lexer'



=begin
#######################################
##### State Machine Specification  ####
#######################################

	DATATYPE Token =
	  TkNewline		(String, Int)
	| TkWhite		(String, Int)
	| TkComment		(String, Int)
	| TkBeginBraket	(String, Int)
	| TkEndBraket	(String, Int)
	| TkNumber		(Number, Int)
	| TkReserved	(Symbol, Int)
	| TkIdentifier	(Symbol, Int)
	| TkSymbol		(Symbol, Int)
	| TkString		(String, Int)

	DATATYPE Pattern =
	  BeginComment	String
	| EndComment	String
	| Newline		String
	| White			String
	| BeginString	String
	| EndString		String
	| BeginBraket	String
	| EndBraket		String
	| Number		String
	| Word			String
	| Any			String

	INPUT EVENT  = Pattern
	OUTPUT EVENT = Token


	ABSTRACT STATE Abstract = {
		line-num:		Int,
		braket-stack:	String List
	}
	ABSTRACT STATE AbstractString ISA Abstract = {
		buf:			String
	}

	STATE Separator ISA Abstract
	STATE Comment   ISA Abstract = {
		buf:			String,
		saved-line-num:	Int,
		comment-depth:	Int
	}
	STATE Token     ISA Abstract WITH {
		VAL braket-map = %{"(" => ")", "[" => "]", "{" => "}", ....}
	}
	STATE BasicString      ISA AbstractString
	STATE SymbolizedString ISA AbstractString

	INITIAL STATE Separator {line-num = 1, braket-stack = []}


	TRANSITION {
	  FROM Separator {line-num}
		WHEN BeginComment _
			TO Comment {
					buf = "", saved-line-num = line-num, comment-depth = 1
				}
		WHEN Newline matched
			OUTPUT TkNewline (matched, line-num)
			TO SAME {line-num = line-num + 1}
		WHEN White matched
			OUTPUT TkWhite (matched, line-num)
		WHEN _
			TO Token
	| FROM Comment {
			buf,
			saved-line-num = saved-line-num,
			comment-depth = depth
			..
		}
		WHEN BeginComment matched
			TO SAME {buf = buf + matched, comment-depth = depth + 1}
		WHEN EndComment matched
			IF depth <= 1 THEN
				OUTPUT TkComment (buf, saved-line-num)
				TO Separator
			ELSE
				TO SAME {buf = buf + matched, comment-depth = depth - 1}
			END
		WHEN Newline matched
			TO SAME {line-num = line-num + 1, buf = buf + matched}
		WHEN Any matched
			TO SAME {buf = buf + matched}
		WHEN _
			ABORT
	| FROM Token {line-num, braket-stack = stack}
		WHEN BeginString
			IF symbol?
				TO SymbolizedString {buf = ""}
			ELSE
				TO BasicString {buf = ""}
			END
		WHEN BeginBraket matched
			OUTPUT BeginBraket (matched, line-num)
			TO Separator {braket-stack = [matched|stack]}
		WHEN EndBraket matched-eb
			CASE stack OF
			   [] -> ERROR "Unexpected end-braket"
			OR [bb|stack'] ->
				CASE braket-map#[bb] OF
				   NONE -> ABORT
				OR Some found-eb ->
					IF matched-eb == found-eb THEN
						OUTPUT EndBraket (matched-eb, line-num)
						TO Separator {braket-stack = stack'}
					ELSE
						ERROR "Mismatched brakets"
					END
				END
			END
		WHEN Number matched
			OUTPUT TkNumber (to-number matched, line-num)
			TO Separator
		WHEN Word matched
			IF symbol?
				OUTPUT TkSymbol (to-symbol matched, line-num)
			ELSE
				IF reserved?
					OUTPUT TkReserved (to-symbol matched, line-num)
				ELSE
					OUTPUT TkIdentifier (to-symbol matched, line-num)
				END
			END
			TO Separator
		WHEN _
			ERROR "Can't recognized as token"
	| FROM AbstractString {buf ..}
		WHEN Newline
			ERROR "Unexpected end-of-string"
		WHEN Any matched
			TO SAME {buf = buf + matched}
	| FROM BasicString {line-num, buf ..}
		WHEN EndString
			OUTPUT TkString (buf, line-num)
			TO Separator
		WHEN _
			ABORT
	| FROM SymbolizedString {line-num, buf ..}
		WHEN EndString
			OUTPUT TkSymbol (buf, line-num)
			TO Separator
		WHEN _
			ABORT
	}
=end