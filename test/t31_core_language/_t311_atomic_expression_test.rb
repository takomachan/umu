# frozen_string_literal: true

require "test_helper"


module Umu

module Test

module T3Language

module T31Core

class T311AtomicExpressionTest < Minitest::Test
=begin
<atomic-expression> ::= 
    <identifier>                    /* T3111 */
  | <constant>                      /* T3112 */
  | <round-braket-expression>       /* T3113 */
  | <square-braket-expression>      /* T3114 */
  | <lambda-expression>             /* T3115 */
  | <cell-stream-expression>        /* T---- */
  | <memo-stream-expression>        /* T---- */
  | <interval-stream-expression>    /* T---- */
  ;
=end
end

end # Umu::Test::T3Language::T31Core

end # Umu::Test::T3Language

end # Umu::Test

end # Umu
