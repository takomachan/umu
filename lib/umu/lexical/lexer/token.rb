require 'strscan'

require 'umu/common'
require 'umu/lexical/location'
require 'umu/lexical/token'



module Umu

module Lexical

module Lexer

class Token < Abstract

HEAD_WORD		= '[a-zA-Z][a-zA-Z0-9]*'
TAIL_WORD		= '[a-zA-Z0-9]*'
WORD_PATTERN	= Regexp.new(
						"(@)?(_*#{HEAD_WORD}(\\-#{TAIL_WORD})*_*'*\\??)"
					)


RESERVED_WORDS = [
	'__FILE__',		'__LINE__',
	'and',			'andalso',		'assert',
	'cond',
	'else',			'elsif',
	'fun',
	'if', 			'in',			'isa?',
	'let',
	'mod',
	'orelse',
	'pow',
	'rec',
	'struct',		'structure',
	'val',
	'where',


	# Not used, but reserved for future

	# For pattern matching
	'as', 'case', 'match',

	# For pragma
	'package', 'pragma', 'useing',

	# For module language
	'functor', 'including', 'opening', 'signat', 'signature',

	# For data type declaration
	'data',	'datum', 'newtype', 'type',

	# For object type
	'abstract', 'alias', 'class', 'def', 'extending',
	'isa', 'new', 'self', 'super',

	# For infix operator declaration
	'infix', 'infixr', 'nofix',

	# For continuation
	'callcc', 'throw',

	# For delayed evaluation
	'delay', 'force', 'lazy',

	# For non-determinism
	'none', 'or',

	# For monad
	'do',

	# For general purpose
	'with'
].inject({}) { |hash, word|
	hash.merge(word => true) { |key, _, _|
		ASSERT.abort format("Duplicated reserved-word: '%s'", key)
	}
}

RESERVED_SYMBOLS = [
	'+',	'-',	'*',	'/',
	'==',	'<>',	'<',	'<=',	'>',	'>=',
	'<<',	'>>',	'<|',	'|>',
	'^',	'++',
	'=',	'&',	'$',	'|',	'_',
	'.',	',',	';',
	'->',	'::',	';;',


	# Not used, but reserved for future

	# For data type declaration
	':', '<:',

	# For refernce type
	'!', ':=',

	# For monad and ZF-notation
	'<-',

	# For general purpose
	'..'
].inject({}) { |hash, x|
	hash.merge(x => true) { |key, _, _|
		ASSERT.abort format("Duplicated reserved-symbol: '%s'", key)
	}
}


IDENTIFIER_SYMBOLS = [
	'~'
].inject({}) { |hash, x|
	hash.merge(x => true) { |key, _, _|
		ASSERT.abort format("Duplicated identifier-symbol: '%s'", key)
	}
}


BRAKET_PAIRS = [
	['(',	')'],	# Tuple, etc
	['&(',	')'],	# Class
	['[',	']'],	# List
	['{',	'}'],	# Lambda, etc


	# Not used, but reserved for future

	['%[',	']'],	# Stream
	['%(',	')'],	# Set
	['%{',	'}'],	# Map
	['@[',	']']	# Dictionary(Key-Value list)
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
	y.length <=> x.length	# For longest-match
}.map { |s|
	Regexp.new(
		s.each_char.map { |c| '\\' + c }.join
	)
}


	def lex(scanner)
		ASSERT.kind_of scanner, ::StringScanner

		case
		# Float or Integer
		when scanner.scan(/\d+(\.\d+)?/)
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


		# Symbol, Reserved-word or Identifier-word
		when scanner.scan(WORD_PATTERN)
			head_matched = scanner[1]
			body_matched = scanner[2]

			[
				:Word,

				scanner.matched,

				if head_matched
					LT.make_symbol self.loc, body_matched
				else
					if RESERVED_WORDS[body_matched]
						LT.make_reserved_word self.loc, body_matched
					else
						LT.make_identifier self.loc, body_matched
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
				unless bb	# Is stack empty?
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
											  bb,		matched
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
