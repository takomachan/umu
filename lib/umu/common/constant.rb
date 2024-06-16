# coding: utf-8
# frozen_string_literal: true

module Umu
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
            module Base
                class Abstract < Top; end
                module Atom
                    class Abstract < Base::Abstract; end
                    class Bool < Abstract; end
                    module Number
                        class Abstract < Atom::Abstract; end
                        class Int < Abstract; end
                        class Real < Abstract; end
                    end
                    class String < Abstract; end
                end
                module LSM
                    class Abstract < Base::Abstract; end
                    module Product
                        class Abstract < LSM::Abstract; end
                        class Tuple < Abstract; end
                    end
                    module Union
                        class Abstract < LSM::Abstract; end
                        module Option
                            class Abstract < Union::Abstract; end
                        end
                    end
                    module Morph
                        class Abstract < LSM::Abstract; end
                        module List
                            class Abstract < Morph::Abstract; end
                        end
                    end
                end
            end
            class Function < Top; end
        end
    end
    module Environment
        module Context
            module Type
                module Signature
                    module Class; end
                end
            end
            module Value; end
        end
    end

    module Assertion;   end
    module Exception;   end


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
    VCB     = Value::Core::Base
    VCBA    = Value::Core::Base::Atom
    VCBAN   = Value::Core::Base::Atom::Number
    VCBL    = Value::Core::Base::LSM
    VCBLP   = Value::Core::Base::LSM::Product
    VCBLU   = Value::Core::Base::LSM::Union
    VCBLM   = Value::Core::Base::LSM::Morph
    E       = Environment
    EC      = Environment::Context
    ECT     = Environment::Context::Type
    ECTS    = Environment::Context::Type::Signature
    ECTSC   = Environment::Context::Type::Signature::Class
    ECV     = Environment::Context::Value

    ASSERT  = Assertion
    X       = Exception
end # Umu
