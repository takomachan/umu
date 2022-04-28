require 'umu/common'
require 'umu/environment/tracer/tracer'


module Umu

module AbstractSyntax

module Core

module Expression

module Nary		# N-ary, where N >= 3

class Let < Expression::Abstract
	attr_reader	:decls, :expr


	def initialize(pos, decls, expr)
		ASSERT.kind_of decls,	::Array
		ASSERT.kind_of expr,	SACE::Abstract

		super(pos)

		@decls	= decls
		@expr	= expr
	end


	def to_s
		format(
			"%%LET { %s %%IN %s }",
			self.decls.map(&:to_s).join(' '),
			self.expr
		)
	end


	def __evaluate__(init_env, event)
		ASSERT.kind_of init_env,	E::Entry
		ASSERT.kind_of event,		E::Tracer::Event

		new_env = self.decls.inject(init_env.enter(event)) { |env, decl|
			ASSERT.kind_of env,		E::Entry
			ASSERT.kind_of decl,	SACD::Abstract

			result = decl.evaluate env
			ASSERT.kind_of result, SAR::Environment

			result.env
		}

		final_result = self.expr.evaluate new_env
		ASSERT.kind_of final_result, SAR::Value

		final_result.value
	end
end

end	# Umu::AbstractSyntax::Core::Expression::Nary


module_function

	def make_let(pos, decls, expr)
		ASSERT.kind_of pos,		L::Position
		ASSERT.kind_of decls,	::Array
		ASSERT.kind_of expr,	SACE::Abstract

		Nary::Let.new(pos, decls.freeze, expr).freeze
	end

end	# Umu::AbstractSyntax::Core::Expression

end	# Umu::AbstractSyntax::Core

end	# Umu::AbstractSyntax

end	# Umu
