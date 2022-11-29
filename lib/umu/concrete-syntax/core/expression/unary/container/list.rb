require 'umu/common'
require 'umu/lexical/location'


module Umu

module ConcreteSyntax

module Core

module Expression

module Unary

module Container

class List < Abstract
	attr_reader	:opt_last_expr


	def initialize(loc, exprs, opt_last_expr)
		ASSERT.kind_of		exprs,			::Array
		ASSERT.opt_kind_of	opt_last_expr,	SCCE::Abstract
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

	def __desugar__(env, event)
		new_env = env.enter event

		SACE.make_list(
			self.loc,

			self.map { |elem| elem.desugar(new_env) },

			if self.opt_last_expr
				self.opt_last_expr.desugar(new_env)
			else
				nil
			end
		)
	end
end

end	# Umu::ConcreteSyntax::Core::Expression::Unary::Container

end	# Umu::ConcreteSyntax::Core::Expression::Unary


module_function

	def make_list(loc, exprs, opt_last_expr)
		ASSERT.kind_of		loc,			L::Location
		ASSERT.kind_of		exprs,			::Array
		ASSERT.opt_kind_of	opt_last_expr,	SCCE::Abstract

		Unary::Container::List.new(loc, exprs.freeze, opt_last_expr).freeze
	end

end	# Umu::ConcreteSyntax::Core::Expression

end	# Umu::ConcreteSyntax::Core

end	# Umu::ConcreteSyntax

end	# Umu
