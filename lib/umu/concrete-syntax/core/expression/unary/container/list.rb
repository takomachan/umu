require 'umu/common'
require 'umu/lexical/location'


module Umu

module ConcreteSyntax

module Core

module Expression

module Unary

module Container

module List

class Simple < Container::Abstract
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



module Comprehension

module Qualifier

class Abstract < Umu::Abstraction::Model; end



class Generator < Abstract
	attr_reader :ident, :expr


	def initialize(loc, ident, expr)
		ASSERT.kind_of expr,	SCCE::Abstract
		ASSERT.kind_of ident,	SCCEU::Identifier::Short

		super(loc)

		@ident	= ident
		@expr	= expr
	end


	def to_s
		format "%s <- %s", self.ident.to_s, self.expr.to_s
	end
end

end	# Umu::ConcreteSyntax::Core::Expression::Unary::Container::List::Comprehension::Qualifier



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
							SACE.make_lambda(
								generator.loc,
								[
									SACE.make_parameter(
										generator.ident.loc,
										generator.ident.desugar(new_env)
									)
								],
								SCCE.make_list_comprehension(
									generator.loc,
									self.expr,
									tl_qualifiers
								).desugar(new_env)
							)
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

end	# Umu::ConcreteSyntax::Core::Expression::Unary::Container::List::Comprehension

end	# Umu::ConcreteSyntax::Core::Expression::Unary::Container::List

end	# Umu::ConcreteSyntax::Core::Expression::Unary::Container

end	# Umu::ConcreteSyntax::Core::Expression::Unary


module_function

	def make_list(loc, exprs, opt_last_expr)
		ASSERT.kind_of		loc,			L::Location
		ASSERT.kind_of		exprs,			::Array
		ASSERT.opt_kind_of	opt_last_expr,	SCCE::Abstract

		Unary::Container::List::Simple.new(
			loc, exprs.freeze, opt_last_expr
		).freeze
	end


	def make_generator(loc, ident, expr)
		ASSERT.kind_of loc,		L::Location
		ASSERT.kind_of expr,	SCCE::Abstract
		ASSERT.kind_of ident,	SCCEU::Identifier::Short

		Unary::Container::List::Comprehension::Qualifier::Generator.new(
			loc, ident, expr
		).freeze
	end


	def make_list_comprehension(loc, expr, qualifiers)
		ASSERT.kind_of loc,			L::Location
		ASSERT.kind_of expr,		SCCE::Abstract
		ASSERT.kind_of qualifiers,	::Array

		Unary::Container::List::Comprehension::Entry.new(
			loc, expr, qualifiers.freeze
		).freeze
	end

end	# Umu::ConcreteSyntax::Core::Expression

end	# Umu::ConcreteSyntax::Core

end	# Umu::ConcreteSyntax

end	# Umu
