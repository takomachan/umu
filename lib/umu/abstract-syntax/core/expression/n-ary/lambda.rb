require 'umu/common'
require 'umu/environment/tracer/tracer'


module Umu

module AbstractSyntax

module Core

module Expression

module Nary

module Lambda

class Parameter < Abstraction::Model
	attr_reader :ident, :opt_type_sym


	def initialize(loc, ident, opt_type_sym)
		ASSERT.kind_of		ident,			SACEU::Identifier::Short
		ASSERT.opt_kind_of	opt_type_sym,	::Symbol

		super(loc)

		@ident			= ident
		@opt_type_sym	= opt_type_sym
	end


	def to_s
		format("%s%s",
			self.ident.to_s,

			if self.opt_type_sym
				format " : %s", self.opt_type_sym
			else
				''
			end
		)
	end
end



class Entry < Expression::Abstract
	attr_reader	:params, :expr, :opt_name


	def initialize(loc, params, expr, opt_name)
		ASSERT.kind_of		params,		::Array
		ASSERT.kind_of		expr,		SACE::Abstract
		ASSERT.opt_kind_of	opt_name,	::Symbol

		super(loc)

		@params		= params
		@expr		= expr
		@opt_name	= opt_name
	end


	def to_s
		format("{%s -> %s}",
			self.params.map(&:to_s).join(' ').to_s,
			self.expr.to_s
		)
	end


	def __evaluate__(env, event)
		ASSERT.kind_of env,		E::Entry
		ASSERT.kind_of event,	E::Tracer::Event

		VC.make_function self, env.va_context
	end
end

end	# Umu::AbstractSyntax::Core::Expression::Nary::Lambda

end	# Umu::AbstractSyntax::Core::Expression::Nary


module_function

	def make_parameter(loc, ident, opt_type_sym = nil)
		ASSERT.kind_of		loc,			L::Location
		ASSERT.kind_of		ident,			SACEU::Identifier::Short
		ASSERT.opt_kind_of	opt_type_sym,	::Symbol

		Nary::Lambda::Parameter.new(loc, ident, opt_type_sym).freeze
	end


	def make_lambda(loc, params, expr, opt_name = nil)
		ASSERT.kind_of		loc,			L::Location
		ASSERT.kind_of		params,			::Array
		ASSERT.kind_of		expr,			SACE::Abstract
		ASSERT.opt_kind_of	opt_name,		::Symbol

		Nary::Lambda::Entry.new(loc, params, expr, opt_name).freeze
	end

end	# Umu::AbstractSyntax::Core::Expression

end	# Umu::AbstractSyntax::Core

end	# Umu::AbstractSyntax

end	# Umu
