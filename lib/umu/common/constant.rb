# coding: utf-8
# frozen_string_literal: true

module Umu
    PP_INDENT_WIDTH = 4    # for pretty printing


    module Abstraction
        class Model; end
        class Record; end
        class Collection; end
    end
    module Lexical
        module Lexer;   end
        module Token;   end
    end
    module ConcreteSyntax
        module Module
            module Declaration; end
            module Expression;  end
            module Pattern;     end
        end
        module Core
            module Declaration; end
            module Expression
                module Unary;   end
                module Binary;  end
                module Nary;    end
            end
            module Pattern;     end
        end

        WILDCARD = :_
    end
    module AbstractSyntax
        module Result;      end
        module Core
            module Declaration; end
            module Expression
                module Unary;   end
                module Binary;  end
                module Nary;    end
            end
        end
    end
    module Value
        module Core
            class Top < ::Object; end
            class Object < Top; end
            class Unit < Object; end
            module Atom
                class Abstract < Object; end
                class Bool < Abstract; end
                module Number
                    class Abstract < Atom::Abstract; end
                    class Int < Abstract; end
                    class Float < Abstract; end
                end
                class String < Abstract; end
            end
            module LSM
                module Product
                    class Abstract < Object; end
                    class Tuple < Abstract; end
                end
                module Union
                    class Abstract < Object; end
                    module Option
                        class Abstract < Union::Abstract; end
                    end
                end
                module Morph
                    class Abstract < Object; end
                    class Interval < Abstract; end
                    module List
                        class Abstract < Morph::Abstract; end
                    end
                end
            end
            class Fun < Object; end
            module IO
                class Abstract < Object; end
                class Input  < Abstract; end
                class Output < Abstract; end
            end
            class Dir < Object; end
        end
    end
    module Environment
        module Context
            module Type
                module Signature
                    module Class; end
                    module Method; end
                end
            end
            module Value; end
        end
    end

    module Assertion;   end
    module Exception;   end
    module Location;   end
    module PrettyPrint; end


    L       = Lexical
    LL      = Lexical::Lexer
    LT      = Lexical::Token
    CS      = ConcreteSyntax
    CSM     = ConcreteSyntax::Module
    CSMD    = ConcreteSyntax::Module::Declaration
    CSME    = ConcreteSyntax::Module::Expression
    CSMP    = ConcreteSyntax::Module::Pattern
    CSC     = ConcreteSyntax::Core
    CSCD    = ConcreteSyntax::Core::Declaration
    CSCE    = ConcreteSyntax::Core::Expression
    CSCEU   = ConcreteSyntax::Core::Expression::Unary
    CSCEB   = ConcreteSyntax::Core::Expression::Binary
    CSCEN   = ConcreteSyntax::Core::Expression::Nary
    CSCP    = ConcreteSyntax::Core::Pattern
    AS      = AbstractSyntax
    ASR     = AbstractSyntax::Result
    ASC     = AbstractSyntax::Core
    ASCD    = AbstractSyntax::Core::Declaration
    ASCE    = AbstractSyntax::Core::Expression
    ASCEU   = AbstractSyntax::Core::Expression::Unary
    ASCEB   = AbstractSyntax::Core::Expression::Binary
    ASCEN   = AbstractSyntax::Core::Expression::Nary
    V       = Value
    VC      = Value::Core
    VCA     = Value::Core::Atom
    VCAN    = Value::Core::Atom::Number
    VCL     = Value::Core::LSM
    VCLP    = Value::Core::LSM::Product
    VCLU    = Value::Core::LSM::Union
    VCLM    = Value::Core::LSM::Morph
    E       = Environment
    EC      = Environment::Context
    ECT     = Environment::Context::Type
    ECTS    = Environment::Context::Type::Signature
    ECTSC   = Environment::Context::Type::Signature::Class
    ECTSM   = Environment::Context::Type::Signature::Method
    ECV     = Environment::Context::Value

    ASSERT  = Assertion
    X       = Exception
    LOC     = Location
    PRT     = PrettyPrint
end # Umu
