# frozen_string_literal: true

require "test_helper"


module Umu

module Test

module Lexcical
=begin
/* See state machine specification in "lib/umu/lexical/lexer.rb" */


/* Token (Entry rule of Lexcical ruleset) */

<token> ::=
    <separator>
  | <number>
  | <string>
  | <word>
  ;


/* Separator */

<separator> ::=
    <space>
  | <newlinw>
  | <comment>
  ;

<space>   ::= " "+                 ;    /* PatSpace */
<newline> ::= "\n" | "\r" | "\n\r" ;    /* PatNewline */
<comment> ::=
    <line-comment>
  | <begein-comment>
  | <end-comment>
  ;

<line-comment>  ::= "#" ( ^ <newlinw> )* ;   /* PatComment       */
<begin-comment> ::= "(#"                 ;   /* PatBeginComment  */
<end-comment>   ::= "#)"                 ;   /* PatEndComment    */


/* Number */

<number> ::= <int> | <float> ;

<int>   ::= <sign>? <digit>+              ;  /* PatNumber */
<float> ::= <sign>? <digit>+ "." <digit>+ ;  /* PatNumber */

<sign> ::= "+" | "-" ;


/* String */

<string> ::=
    <begin-string>
  | <begin-symbolized-string>
  | <end-string> ;

<begin-string>           ::= "\""     ;  /* PatBeginString  */
<begin-symbolizedstring> ::= "@" "\"" ;  /* PatBeginString  */
<end-string>             ::= "\""     ;  /* PatEndString    */


/* Word */

<word> ::=
/*  <reserved>  -- Reserved words are not defined in test suite */
  | <id>
  | <symbol>
  | <message>
  | <label>
  | <directory>
  | <symbol>
  | <selector>
  ;

<id>        ::= <id-word>      ;    /* PatWord */
<symbol>    ::= "@" <id-word>  ;    /* PatWord */
<message>   ::= "." <id-word>  ;    /* PatWord */
<label>     ::= <id-word> ":"  ;    /* PatWord */
<directory> ::= <id-word> "::" ;    /* PatWord */

<basic-symbol>      ::= "@" <id-word> ; /* PatWord */
<symbolized-symbol> ::= "@" <string>  ; /* PatWord */

<selector> ::=
    <number-selector>
  | <label-selector>
  ;

<number-selector> ::= "$" <digit>+  ;    /* PatWord */
<label-selector>  ::= "$" <id-word> ;    /* PatWord */


/* Common rules */

<id-ward> ::=
    "_"*
    <alpha> <alnum>*
    ( "-" <alnum>+ )*
    "_"*
    ( "?" | "!" )
    "'"*
    "_"*
    ;

<alnum> ::= <alpha> | <digit>   ;
<alpha> ::= "a" .. "z" | "A" .. "Z" ;
<digit> ::= "0" .. "9"              ;
=end

class LexcicalTest < Minitest::Test
    def setup
        @interp = Api.setup_interpreter
    end


    def test_int
        value = Api.eval_expr @interp, "3"
        assert_instance_of  VCAN::Int, value
        assert_equal        3,         value.val
    end


    def test_float
        value = Api.eval_expr @interp, "3.4"
        assert_instance_of  VCAN::Float, value
        assert_equal        3.4,         value.val
    end


    def test_number
        value = Api.eval_expr @interp, "3"
        assert_instance_of  VCAN::Int, value
        assert_equal        3,         value.val

        value = Api.eval_expr @interp, "30"
        assert_instance_of  VCAN::Int, value
        assert_equal        30,        value.val

        value = Api.eval_expr @interp, "+3"
        assert_instance_of  VCAN::Int, value
        assert_equal        3,         value.val

        value = Api.eval_expr @interp, "-3"
        assert_instance_of  VCAN::Int, value
        assert_equal(       -3,        value.val)
    end


    def test_string
        value = Api.eval_expr @interp, '"Hello world"'
        assert_instance_of  VCA::String,   value
        assert_equal        "Hello world", value.val
    end


    def test_symbol
        value = Api.eval_expr @interp, "@apple"
        assert_instance_of  VCA::Symbol, value
        assert_equal        :apple,      value.val

        value = Api.eval_expr @interp, '@"Hello world"'
        assert_instance_of  VCA::Symbol,    value
        assert_equal        :"Hello world", value.val
    end


    def test_identifier
        value = Api.eval_expr @interp, "@apple"
        assert_instance_of  VCA::Symbol, value
        assert_equal        :apple,      value.val

        value = Api.eval_expr @interp, "@mp130"
        assert_instance_of  VCA::Symbol, value
        assert_equal        :mp130,      value.val

        value = Api.eval_expr @interp, "@apple-banana"
        assert_instance_of  VCA::Symbol,     value
        assert_equal        :"apple-banana", value.val

        value = Api.eval_expr @interp, "@apple-20"
        assert_instance_of  VCA::Symbol, value
        assert_equal        :"apple-20", value.val

        value = Api.eval_expr @interp, "@apple-20-banana"
        assert_instance_of  VCA::Symbol,        value
        assert_equal        :"apple-20-banana", value.val

        value = Api.eval_expr @interp, "@__apple__"
        assert_instance_of  VCA::Symbol, value
        assert_equal        :__apple__,  value.val

        value = Api.eval_expr @interp, "@apple?"
        assert_instance_of  VCA::Symbol, value
        assert_equal        :"apple?",   value.val

        value = Api.eval_expr @interp, "@apple!"
        assert_instance_of  VCA::Symbol, value
        assert_equal        :"apple!",   value.val

        value = Api.eval_expr @interp, "@apple''"
        assert_instance_of  VCA::Symbol, value
        assert_equal        :"apple''",  value.val

        value = Api.eval_expr @interp, "@__mp130-0-mp2000__?''"
        assert_instance_of  VCA::Symbol, value
        assert_equal        :"__mp130-0-mp2000__?''",  value.val
    end


    def test_line_comment
        value = Api.eval_expr @interp, <<-EOS
            3 # 4
            EOS
        assert_instance_of  VCAN::Int, value
        assert_equal        3,         value.val

        value = Api.eval_expr @interp, <<-EOS
            # AAA
            # BBB
            3
            # DCC
            EOS
        assert_instance_of  VCAN::Int, value
        assert_equal        3,         value.val
    end


    def test_block_comment
        value = Api.eval_expr @interp, <<-EOS
            (# 1 #) 3 (# 2 #)
            EOS
        assert_instance_of  VCAN::Int, value
        assert_equal        3,         value.val

        value = Api.eval_expr @interp, <<-EOS
            (# 1 (# 1.1 #) #) 3 (# 2 #)
            EOS
        assert_instance_of  VCAN::Int, value
        assert_equal        3,         value.val
    end
end

end # Umu::Test::Lexcical

end # Umu::Test

end # Umu
