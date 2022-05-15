require 'umu/common'
require 'umu/environment/tracer/tracer'


module Umu

module AbstractSyntax

module Core

module Expression

module Nary

class Lambda < Expression::Abstract
	attr_reader	:idents, :expr, :opt_name


	def initialize(pos, idents, expr, opt_name)
		ASSERT.kind_of		idents,		::Array
		ASSERT.kind_of		expr,		SACE::Abstract
		ASSERT.opt_kind_of	opt_name,	::Symbol

		super(pos)

		@idents		= idents
		@expr		= expr
		@opt_name	= opt_name
	end


	def to_s
		format("{%s -> %s}",
			self.idents.map(&:to_s).join(' ').to_s,
			self.expr.to_s
		)
	end


	def __evaluate__(env, event)
		ASSERT.kind_of env,		E::Entry
		ASSERT.kind_of event,	E::Tracer::Event

		VC.make_closure self, env.va_context
	end
end

end	# Umu::AbstractSyntax::Core::Expression::Nary


module_function

	def make_lambda(pos, idents, expr, opt_name = nil)
		ASSERT.kind_of		pos,			L::Position
		ASSERT.kind_of		idents,			::Array
		ASSERT.kind_of		expr,			SACE::Abstract
		ASSERT.opt_kind_of	opt_name,		::Symbol

		Nary::Lambda.new(pos, idents, expr, opt_name).freeze
	end

end	# Umu::AbstractSyntax::Core::Expression

end	# Umu::AbstractSyntax::Core

end	# Umu::AbstractSyntax

end	# Umu
