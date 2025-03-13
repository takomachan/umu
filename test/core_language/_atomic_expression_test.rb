# frozen_string_literal: true

require "test_helper"


module Umu

module Test

module Grammar

module CoreLanguage

module AtomicExpression
=begin
<atomic-expression> ::= 
    <identifier>
  | <constant>
  | <round-braket-expression>
  | <square-braket-expression>
  | <lambda-expression>
  | <stream-expression>
  ;
=end
end # Umu::Test::Grammar::CoreLanguage::AtomicExpression

end # Umu::Test::Grammar::CoreLanguage

end # Umu::Test::Grammar

end # Umu::Test

end # Umu
