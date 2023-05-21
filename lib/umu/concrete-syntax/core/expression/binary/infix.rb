require 'umu/common'
require 'umu/lexical/location'


module Umu

module ConcreteSyntax

module Core

module Expression

module Binary

module Infix

module Abstraction

class Abstract < Binary::Abstract
	alias		lhs_opnd lhs
	attr_reader	:opr_sym
	alias		rhs_opnd rhs


	def initialize(loc, lhs_opnd, opr_sym, rhs_opnd)
		ASSERT.kind_of lhs_opnd,	Umu::Abstraction::Model
		ASSERT.kind_of opr_sym,		::Symbol
		ASSERT.kind_of rhs_opnd,	Umu::Abstraction::Model

		super(loc, lhs_opnd, rhs_opnd)

		@opr_sym = opr_sym
	end


	def to_s
		_opr = self.opr_sym.to_s
		opr = if /^[a-zA-Z\-]+\??$/ =~ _opr
					'%' + _opr.upcase
				else
					_opr
				end

		format "(%s %s %s)", self.lhs_opnd.to_s, opr, self.rhs_opnd.to_s
	end
end



class Simple < Abstract
	def initialize(loc, lhs_opnd, opr_sym, rhs_opnd)
		ASSERT.kind_of lhs_opnd,	SCCE::Abstract
		ASSERT.kind_of opr_sym,		::Symbol
		ASSERT.kind_of rhs_opnd,	SCCE::Abstract

		super
	end
end

end	# Umu::ConcreteSyntax::Core::Expression::Binary::Infix::Abstraction



class Redefinable < Abstraction::Simple

private

	def __desugar__(env, event)
		new_env = env.enter event

		SACE.make_apply(
			self.loc,
			SACE.make_identifier(loc, self.opr_sym),
			self.lhs_opnd.desugar(new_env),
			[self.rhs_opnd.desugar(new_env)]
		)
	end
end



class KindOf < Abstraction::Abstract
	alias rhs_ident rhs_opnd

	def initialize(loc, lhs_opnd, opr_sym, rhs_ident)
		ASSERT.kind_of lhs_opnd,	SCCE::Abstract
		ASSERT.kind_of opr_sym,		::Symbol
		ASSERT.kind_of rhs_ident,	SCCEU::Identifier::Short

		super
	end


private

	def __desugar__(env, event)
		new_env = env.enter event

		SACE.make_test_kind_of(
			self.loc,
			self.lhs_opnd.desugar(new_env),
			self.rhs_ident.desugar(new_env)
		)
	end
end



class AndAlso < Abstraction::Simple

private

	def __desugar__(env, event)
		new_env = env.enter event

		SACE.make_if(
			self.loc,
			[
				SACE.make_rule(
					self.loc,
					self.lhs_opnd.desugar(new_env),
					self.rhs_opnd.desugar(new_env)
				)
			],
			SACE.make_bool(self.loc, false)
		)
	end
end



class OrElse < Abstraction::Simple

private

	def __desugar__(env, event)
		new_env = env.enter event

		SACE.make_if(
			self.loc,
			loc,
			[
				SACE.make_rule(
					self.loc,
					self.lhs_opnd.desugar(new_env),
					SACE.make_bool(loc, true)
				)
			],
			self.rhs_opnd.desugar(new_env)
		)
	end
end

end	# Umu::ConcreteSyntax::Core::Expression::Binary::Infix

end	# Umu::ConcreteSyntax::Core::Expression::Binary


module_function

	def make_infix(loc, lhs_opnd, opr_sym, rhs_opnd)
		ASSERT.kind_of loc,			L::Location
		ASSERT.kind_of lhs_opnd,	SCCE::Abstract
		ASSERT.kind_of opr_sym,		::Symbol
		ASSERT.kind_of rhs_opnd,	SCCE::Abstract

		Binary::Infix::Redefinable.new(
			loc, lhs_opnd, opr_sym, rhs_opnd
		).freeze
	end


	def make_kindof(loc, lhs_opnd, opr_sym, rhs_ident)
		ASSERT.kind_of loc,			L::Location
		ASSERT.kind_of lhs_opnd,	SCCE::Abstract
		ASSERT.kind_of opr_sym,		::Symbol
		ASSERT.kind_of rhs_ident,	SCCEU::Identifier::Short

		Binary::Infix::KindOf.new(
			loc, lhs_opnd, opr_sym, rhs_ident
		).freeze
	end


	def make_andalso(loc, lhs_opnd, opr_sym, rhs_opnd)
		ASSERT.kind_of loc,			L::Location
		ASSERT.kind_of lhs_opnd,	SCCE::Abstract
		ASSERT.kind_of opr_sym,		::Symbol
		ASSERT.kind_of rhs_opnd,	SCCE::Abstract

		Binary::Infix::AndAlso.new(
			loc, lhs_opnd, opr_sym, rhs_opnd
		).freeze
	end


	def make_orelse(loc, lhs_opnd, opr_sym, rhs_opnd)
		ASSERT.kind_of loc,			L::Location
		ASSERT.kind_of lhs_opnd,	SCCE::Abstract
		ASSERT.kind_of opr_sym,		::Symbol
		ASSERT.kind_of rhs_opnd,	SCCE::Abstract

		Binary::Infix::OrElse.new(
			loc, lhs_opnd, opr_sym, rhs_opnd
		).freeze
	end

end	# Umu::ConcreteSyntax::Core::Expression

end	# Umu::ConcreteSyntax::Core

end	# Umu::ConcreteSyntax

end	# Umu
