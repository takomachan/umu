require 'umu/common'
require 'umu/abstract-syntax/result'


module Umu

module AbstractSyntax

module Core

module Declaration

module Simple

class Abstract < Declaration::Abstract
	attr_reader :sym


	def initialize(loc, sym)
		ASSERT.kind_of loc,	L::Location
		ASSERT.kind_of sym,	::Symbol

		super(loc)

		@sym = sym
	end
end



class Value < Abstract
	attr_reader :expr


	def initialize(loc, sym, expr)
		ASSERT.kind_of expr, SACE::Abstract

		super(loc, sym)

		@expr = expr
	end


	def to_s
		format "%%VAL %s = %s", self.sym.to_s, self.expr.to_s
	end


private

	def __evaluate__(env)
		ASSERT.kind_of env, E::Entry

		result = self.expr.evaluate env
		ASSERT.kind_of result, SAR::Value

		env.va_extend_value self.sym, result.value
	end
end



class Recursive < Abstract
	attr_reader :lam_expr


	def initialize(loc, sym, lam_expr)
		ASSERT.kind_of lam_expr, SACE::Nary::Lambda

		super(loc, sym)

		@lam_expr = lam_expr
	end


	def to_s
		format "%%VAL %%REC %s = %s", self.sym.to_s, self.lam_expr.to_s
	end


private

	def __evaluate__(env)
		ASSERT.kind_of env, E::Entry

		env.va_extend_recursive self.sym, self.lam_expr
	end
end

end	# Umu::AbstractSyntax::Core::Declaration::Simple



module_function

	def make_value(loc, sym, expr)
		ASSERT.kind_of loc,		L::Location
		ASSERT.kind_of sym,		::Symbol
		ASSERT.kind_of expr,	SACE::Abstract

		Simple::Value.new(loc, sym, expr).freeze
	end


	def make_recursive(loc, sym, lam_expr)
		ASSERT.kind_of loc,			L::Location
		ASSERT.kind_of sym,			::Symbol
		ASSERT.kind_of lam_expr,	SACE::Nary::Lambda

		Simple::Recursive.new(loc, sym, lam_expr).freeze
	end

end	# Umu::AbstractSyntax::Core::Declaration

end	# Umu::AbstractSyntax::Core

end	# Umu::AbstractSyntax

end	# Umu
