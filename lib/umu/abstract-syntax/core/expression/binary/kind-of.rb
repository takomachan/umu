require 'umu/common'
require 'umu/environment/tracer/tracer'


module Umu

module AbstractSyntax

module Core

module Expression

module Binary

class KindOf < Binary::Abstract
	alias expr		lhs_expr
	alias type_sym	rhs


	def initialize(loc, expr, type_sym)
		ASSERT.kind_of loc,			L::Location
		ASSERT.kind_of expr,		SACE::Abstract
		ASSERT.kind_of type_sym,	::Symbol

		super
	end


	def to_s
		format "(%s %%ISA? %s)", self.expr.to_s, self.type_sym.to_s
	end


	def __evaluate__(env, event)
		ASSERT.kind_of env,		E::Entry
		ASSERT.kind_of event,	E::Tracer::Event

		rhs_spec = env.ty_lookup self.type_sym, self.loc
		ASSERT.kind_of rhs_spec, ECTSC::Base

		lhs_value = self.expr.evaluate(env.enter event).value
		ASSERT.kind_of lhs_value, VC::Top

		VC.make_bool env.ty_kind_of?(lhs_value, rhs_spec)
	end
end

end	# Umu::AbstractSyntax::Core::Expression::Binary


module_function

	def make_kind_of(loc, expr, type)
		ASSERT.kind_of loc,		L::Location
		ASSERT.kind_of expr,	SACE::Abstract
		ASSERT.kind_of type,	::Symbol

		Binary::KindOf.new(loc, expr, type).freeze
	end

end	# Umu::AbstractSyntax::Core::Expression

end	# Umu::AbstractSyntax::Core

end	# Umu::AbstractSyntax

end	# Umu
