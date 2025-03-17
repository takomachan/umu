# frozen_string_literal: true

require "test_helper"


module Umu

module Test

module Grammar

module ModuleLanguage
=begin
<md-declaration> ::= 
    <core-declaration>        /* See CoreLanguage::Declaration */
  | <md-structure-declaration>
  | <md-import-declaration>
  ;
=end

=begin
<me-expression> ::= 
    <me-struct-expression>
  | <me-long-expression>
  ;

<me-struct-expression> ::=
    STRUCT "{" { <md-declaration> } "}" ;

<me-long-id> ::= { MODULE-DIR } ID ;
=end
end # Umu::Test::Grammar::ModuleLanguage

end # Umu::Test::Grammar

end # Umu::Test

end # Umu
