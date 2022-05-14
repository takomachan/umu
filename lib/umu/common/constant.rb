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
			module Expression;  end
			module Pattern;     end
		end

		WILDCARD = :_
	end
	module AbstractSyntax
		module Result;		end
		module Core
			module Declaration;	end
			module Expression;	end
		end
	end
	module Value
		module Core
			class Top < Abstraction::Model; end
			module Base
				class Abstract < Top; end
				class Bool < Abstract; end
				module Number
					class Abstract < Base::Abstract; end
					class Integer < Abstract; end
					class Float < Abstract; end
				end
				class String < Abstract; end
			end
			module Product
				class Abstract < Top; end
				class Tuple < Abstract; end
			end
			module Data
				class Abstract < Top; end
				module Option
					class Abstract < Data::Abstract; end
				end
			end
			module Function; end
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
	SC		= ConcreteSyntax
	SCM		= ConcreteSyntax::Module
	SCMD	= ConcreteSyntax::Module::Declaration
	SCME	= ConcreteSyntax::Module::Expression
	SCMP	= ConcreteSyntax::Module::Pattern
	SCC		= ConcreteSyntax::Core
	SCCD	= ConcreteSyntax::Core::Declaration
	SCCE	= ConcreteSyntax::Core::Expression
	SCCP	= ConcreteSyntax::Core::Pattern
	SA		= AbstractSyntax
	SAR		= AbstractSyntax::Result
	SAC		= AbstractSyntax::Core
	SACD	= AbstractSyntax::Core::Declaration
	SACE	= AbstractSyntax::Core::Expression
	V		= Value
	VC		= Value::Core
	VCB		= Value::Core::Base
	VCBN	= Value::Core::Base::Number
	VCP		= Value::Core::Product
	VCD		= Value::Core::Data
	VCF		= Value::Core::Function
	E		= Environment
	EC		= Environment::Context
	ECT		= Environment::Context::Type
	ECTS	= Environment::Context::Type::Specification
	ECTSC	= Environment::Context::Type::Specification::Class
	ECV		= Environment::Context::Value

	ASSERT	= Assertion
	X		= Exception
end # Umu
