# frozen_string_literal: true

require "test_helper"


module Umu

module Test

module Grammar

module CoreLanguage

module Expression

module Entry
=begin
<expression> ::= 
    <infix-expression>  /* See InfixOperator */
  | <if-expression>
  | <cond-expression>
  | <case-expression>
  | <let-expression>
  | <do-expression>
  ;
=end
end # Umu::Test::Grammar::CoreLanguage::Expression::Entry

end # Umu::Test::Grammar::CoreLanguage::Expression

end # Umu::Test::Grammar::CoreLanguage

end # Umu::Test::Grammar

end # Umu::Test

end # Umu
