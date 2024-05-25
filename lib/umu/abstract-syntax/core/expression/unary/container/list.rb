require 'umu/common'


module Umu

module AbstractSyntax

module Core

module Expression

module Unary

module Container

class List < Abstraction::ArrayBased
	alias		exprs array
	attr_reader	:opt_last_expr


	def initialize(loc, exprs, opt_last_expr)
		ASSERT.kind_of		exprs,			::Array
		ASSERT.opt_kind_of	opt_last_expr,	ASCE::Abstract
		ASSERT.assert (
			if exprs.empty? then opt_last_expr.nil? else true end
		)

		super(loc, exprs)

		@opt_last_expr = opt_last_expr
	end


	def to_s
		format("[%s%s]",
			self.map(&:to_s).join(', '),

			if self.opt_last_expr
				'|' + self.opt_last_expr.to_s
			else
				''
			end
		)
	end


private

	def __evaluate__(env, event)
		ASSERT.kind_of env,		E::Entry
		ASSERT.kind_of event,	E::Tracer::Event

		new_env = env.enter event

		xs = self.map { |x|
			ASSERT.kind_of x, ASCE::Abstract

			x.evaluate(new_env).value
		}

		tail = if self.opt_last_expr
					t = self.opt_last_expr.evaluate(new_env).value
					unless t.kind_of? VCLM::List::Abstract
						raise X::TypeError.new(
							opt_last_expr.loc,
							env,
							"expected a List, but %s : %s", t, t.type_sym
						)
					end

					t
				else
					VC.make_nil
				end

		VC.make_list xs, tail
	end
end


end	# Umu::AbstractSyntax::Core::Expression::Unary::Container

end	# Umu::AbstractSyntax::Core::Expression::Unary


module_function

	def make_list(loc, exprs, opt_last_expr = nil)
		ASSERT.kind_of		loc,			L::Location
		ASSERT.kind_of		exprs,			::Array
		ASSERT.opt_kind_of	opt_last_expr,	ASCE::Abstract

		Unary::Container::List.new(loc, exprs.freeze, opt_last_expr).freeze
	end

end	# Umu::AbstractSyntax::Core::Expression

end	# Umu::AbstractSyntax::Core

end	# Umu::AbstractSyntax

end	# Umu
