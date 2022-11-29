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
		ASSERT.opt_kind_of	opt_last_expr,	SACE::Abstract
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

		xs = if opt_last_expr
					tail_value = opt_last_expr.evaluate(new_env).value
					unless tail_value.kind_of? VCO::List::Abstract
						raise X::TypeError.new(
							tail_value.loc,
							env,
							"expected a List, but %s : %s",
											tail_value, tail_value.type_sym
						)
					end

					tail_value
				else
					VC.make_nil
				end

		self.exprs.reverse_each do |x|
			ASSERT.kind_of x, SACE::Abstract

			xs = VC.make_cons x.evaluate(new_env).value, xs

		end

		ASSERT.kind_of xs, VCO::List::Abstract
	end
end


end	# Umu::AbstractSyntax::Core::Expression::Unary::Container

end	# Umu::AbstractSyntax::Core::Expression::Unary


module_function

	def make_list(loc, exprs, opt_last_expr)
		ASSERT.kind_of		loc,			L::Location
		ASSERT.kind_of		exprs,			::Array
		ASSERT.opt_kind_of	opt_last_expr,	SACE::Abstract

		Unary::Container::List.new(loc, exprs.freeze, opt_last_expr).freeze
	end

end	# Umu::AbstractSyntax::Core::Expression

end	# Umu::AbstractSyntax::Core

end	# Umu::AbstractSyntax

end	# Umu
