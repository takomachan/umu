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
		ASSERT.kind_of sym, ::Symbol

		super(loc)

		@sym = sym
	end
end



class Value < Abstract
	attr_reader :expr
	attr_reader :opt_type_sym


	def initialize(loc, sym, expr, opt_type_sym)
		ASSERT.kind_of		expr,			SACE::Abstract
		ASSERT.opt_kind_of	opt_type_sym,	::Symbol

		super(loc, sym)

		@expr			= expr
		@opt_type_sym	= opt_type_sym
	end


	def to_s
		format("%%VAL %s%s = %s",
				self.sym.to_s,

				if self.opt_type_sym
					format " : %s", self.opt_type_sym
				else
					''
				end,

				self.expr.to_s
		)
	end


private

	def __evaluate__(env)
		ASSERT.kind_of env, E::Entry

		result	= self.expr.evaluate env
		ASSERT.kind_of result, SAR::Value
		value	= result.value

		if self.opt_type_sym
			type_sym = opt_type_sym

			spec = env.ty_lookup type_sym, self.loc
			ASSERT.kind_of spec, ECTSC::Base
			unless env.ty_kind_of?(value, spec)
				raise X::TypeError.new(
					self.loc,
					env,
					"Expected a %s, but %s : %s",
					type_sym,
					value,
					value.type_sym
				)
			end
		end

		env.va_extend_value self.sym, value
	end
end



class Recursive < Abstract
	attr_reader :lam_expr


	def initialize(loc, sym, lam_expr)
		ASSERT.kind_of lam_expr, SACEN::Lambda::Entry

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

	def make_value(loc, sym, expr, opt_type_sym = nil)
		ASSERT.kind_of		loc,			L::Location
		ASSERT.kind_of		sym,			::Symbol
		ASSERT.kind_of		expr,			SACE::Abstract
		ASSERT.opt_kind_of	opt_type_sym,	::Symbol

		Simple::Value.new(loc, sym, expr, opt_type_sym).freeze
	end


	def make_recursive(loc, sym, lam_expr)
		ASSERT.kind_of loc,			L::Location
		ASSERT.kind_of sym,			::Symbol
		ASSERT.kind_of lam_expr,	SACEN::Lambda::Entry

		Simple::Recursive.new(loc, sym, lam_expr).freeze
	end

end	# Umu::AbstractSyntax::Core::Declaration

end	# Umu::AbstractSyntax::Core

end	# Umu::AbstractSyntax

end	# Umu
