require 'umu/common'
require 'umu/lexical/location'


module Umu

module ConcreteSyntax

module Core

module Expression

module Unary

module Container

module Comprehension

module Qualifier

class Abstract < Umu::Abstraction::Model; end



class Generator < Abstract
	attr_reader :pat, :expr


	def initialize(loc, pat, expr)
		ASSERT.kind_of expr,	SCCE::Abstract
		ASSERT.kind_of pat,		SCCP::Abstract

		super(loc)

		@pat	= pat
		@expr	= expr
	end


	def to_s
		format "%s <- %s", self.pat.to_s, self.expr.to_s
	end
end

end	# Umu::ConcreteSyntax::Core::Expression::Unary::Container::Comprehension::Qualifier



class Entry < Container::Abstract
	alias		qualifiers exprs
	attr_reader	:expr


	def initialize(loc, expr, qualifiers)
		ASSERT.kind_of expr,		SCCE::Abstract
		ASSERT.kind_of qualifiers,	::Array

		super(loc, qualifiers)

		@expr = expr
	end


	def to_s
		format("[|%s|%s]",
			self.expr.to_s,

			if self.qualifiers.empty?
				''
			else
				' ' + self.qualifiers.map(&:to_s).join(', ')
			end
		)
	end


private

	def __desugar__(env, event)
		new_env = env.enter event

		if self.qualifiers.empty?
			SACE.make_list self.loc, [self.expr.desugar(new_env)]
		else
			hd_qualifier, *tl_qualifiers = qualifiers
			ASSERT.kind_of hd_qualifier, Qualifier::Abstract

			case hd_qualifier
			when Qualifier::Generator
				generator = hd_qualifier

				SACE.make_send(
					generator.loc,

					generator.expr.desugar(new_env),

					SACE.make_method(
						generator.loc,

						:'concat-map',

						[
							SCCE.make_lambda(
								generator.loc,

								[generator.pat],

								SCCE.make_comprehension(
									generator.loc,
									self.expr,
									tl_qualifiers
								)
							).desugar(new_env)
						]
					),

					[],

					:List
				)
			else
				ASSERT.abort hd_qualifier.inspect
			end
		end
	end
end

end	# Umu::ConcreteSyntax::Core::Expression::Unary::Container::Comprehension

end	# Umu::ConcreteSyntax::Core::Expression::Unary::Container

end	# Umu::ConcreteSyntax::Core::Expression::Unary


module_function

	def make_generator(loc, pat, expr)
		ASSERT.kind_of loc,		L::Location
		ASSERT.kind_of expr,	SCCE::Abstract
		ASSERT.kind_of pat,		SCCP::Abstract

		Unary::Container::Comprehension::Qualifier::Generator.new(
			loc, pat, expr
		).freeze
	end


	def make_comprehension(loc, expr, qualifiers)
		ASSERT.kind_of loc,			L::Location
		ASSERT.kind_of expr,		SCCE::Abstract
		ASSERT.kind_of qualifiers,	::Array

		Unary::Container::Comprehension::Entry.new(
			loc, expr, qualifiers.freeze
		).freeze
	end

end	# Umu::ConcreteSyntax::Core::Expression

end	# Umu::ConcreteSyntax::Core

end	# Umu::ConcreteSyntax

end	# Umu
