module Umu
	module Abstraction
		class Model; end
		class Record; end
		class Collection; end
	end
	module Lexical
		module Lexer;	end
		module Token;	end
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
				module Unary;	end
				module Binary;	end
				module Nary;	end
			end
			module Pattern;     end
		end

		WILDCARD = :_
	end
	module AbstractSyntax
		module Result;		end
		module Core
			module Declaration;	end
			module Expression
				module Unary;	end
				module Binary;	end
				module Nary;	end
			end
		end
	end
	module Value
		module Core
			class Top < ::Object; end
			module Atom
				class Abstract < Top; end
				class Bool < Abstract; end
				module Number
					class Abstract < Atom::Abstract; end
					class Int < Abstract; end
					class Real < Abstract; end
				end
				class String < Abstract; end
			end
			module LSM
				class Abstract < Top; end
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
			class Function < Top; end
		end
	end
	module Environment
		module Context
			module Type
				module Specification
					module Class; end
				end
			end
			module Value; end
		end
	end

	module Assertion;	end
	module Exception;	end


	L		= Lexical
	LL		= Lexical::Lexer
	LT		= Lexical::Token
	CS		= ConcreteSyntax
	CSM		= ConcreteSyntax::Module
	CSMD	= ConcreteSyntax::Module::Declaration
	CSME	= ConcreteSyntax::Module::Expression
	CSMP	= ConcreteSyntax::Module::Pattern
	CSC		= ConcreteSyntax::Core
	CSCD	= ConcreteSyntax::Core::Declaration
	CSCE	= ConcreteSyntax::Core::Expression
	CSCEU	= ConcreteSyntax::Core::Expression::Unary
	CSCEB	= ConcreteSyntax::Core::Expression::Binary
	CSCEN	= ConcreteSyntax::Core::Expression::Nary
	CSCP	= ConcreteSyntax::Core::Pattern
	AS		= AbstractSyntax
	ASR		= AbstractSyntax::Result
	ASC		= AbstractSyntax::Core
	ASCD	= AbstractSyntax::Core::Declaration
	ASCE	= AbstractSyntax::Core::Expression
	ASCEU	= AbstractSyntax::Core::Expression::Unary
	ASCEB	= AbstractSyntax::Core::Expression::Binary
	ASCEN	= AbstractSyntax::Core::Expression::Nary
	V		= Value
	VC		= Value::Core
	VCA		= Value::Core::Atom
	VCAN	= Value::Core::Atom::Number
	VCL		= Value::Core::LSM
	VCLP	= Value::Core::LSM::Product
	VCLU	= Value::Core::LSM::Union
	VCLM	= Value::Core::LSM::Morph
	E		= Environment
	EC		= Environment::Context
	ECT		= Environment::Context::Type
	ECTS	= Environment::Context::Type::Specification
	ECTSC	= Environment::Context::Type::Specification::Class
	ECV		= Environment::Context::Value

	ASSERT	= Assertion
	X		= Exception
end # Umu
