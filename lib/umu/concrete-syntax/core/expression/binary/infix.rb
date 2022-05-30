require 'umu/common'
require 'umu/lexical/location'


module Umu

module ConcreteSyntax

module Core

module Expression

module Binary

class Infix < Abstract
	alias		lhs_opnd lhs_expr
	attr_reader :opr_sym
	alias		rhs_opnd rhs


	def initialize(loc, lhs_opnd, opr_sym, rhs_opnd)
		ASSERT.kind_of lhs_opnd,	SCCE::Abstract
		ASSERT.kind_of opr_sym,		::Symbol
		ASSERT.kind_of rhs_opnd,	SCCE::Abstract

		super(loc, lhs_opnd, rhs_opnd)

		@opr_sym = opr_sym
	end


	def to_s
		_opr = self.opr_sym.to_s
		opr = if /^[a-zA-Z]+\??$/ =~ _opr
					'%' + _opr.upcase
				else
					_opr
				end

		format "(%s %s %s)", self.lhs_opnd.to_s, opr, self.rhs_opnd.to_s
	end


	REDEFINABLE_OPR_SYMS = [
		# Number
		:'+',	:'-',	:'*',	:'/',	:mod,	:pow,

		# String
		:'^',

		# Relational
		:'==',	:'<>',	:'<',	:'>',	:'<=',	:'>=',

		# List
		:'++',

		# Function application
		:'<|', :'|>',

		# Function composition
		:'<<', :'>>'
	].inject({}) { |hash, sym| hash.merge(sym => true) }


private

	def __desugar__(env, event)
		new_env = env.enter event

		lhs_opnd	= self.lhs_opnd.desugar(new_env)
		opr_sym		= self.opr_sym
		rhs_opnd	= self.rhs_opnd.desugar(new_env)
		loc			= self.loc

		expr = if REDEFINABLE_OPR_SYMS[opr_sym]
				SACE.make_apply(
					loc,
					SACE.make_identifier(loc, opr_sym),
					[lhs_opnd, rhs_opnd]
				)
			else
				case opr_sym
				# Typing
				when :ISA?
					unless rhs_opnd.kind_of?(
										SACE::Unary::Identifier::Abstract
									)
						raise X::SyntaxError.new(
							rhs_opnd.loc,
							"RHS of 'isa?' operator " +
								"require a identifier, but: %s",
							rhs_opnd.to_s
						)
					end

					SACE.make_kind_of loc, lhs_opnd, rhs_opnd.sym

				# Conditional
				when :ANDALSO
					SACE.make_if(
						loc,
						[
							SACE.make_rule(
								loc,
								lhs_opnd,
								rhs_opnd
							)
						],
						SACE.make_bool(loc, false)
					)
				when :ORELSE
					SACE.make_if(
						loc,
						[
							SACE.make_rule(
								loc,
								lhs_opnd,
								SACE.make_bool(loc, true)
							)
						],
						rhs_opnd
					)

				else
					ASSERT.abort self.opr_sym.inspect
				end
			end

		ASSERT.kind_of expr, SACE::Abstract
	end
end

end	# Umu::ConcreteSyntax::Core::Expression::Binary


module_function

	def make_infix(loc, lhs_opnd, opr_sym, rhs_opnd)
		ASSERT.kind_of loc,			L::Location
		ASSERT.kind_of lhs_opnd,	SCCE::Abstract
		ASSERT.kind_of opr_sym,		::Symbol
		ASSERT.kind_of rhs_opnd,	SCCE::Abstract

		Binary::Infix.new(loc, lhs_opnd, opr_sym, rhs_opnd).freeze
	end

end	# Umu::ConcreteSyntax::Core::Expression

end	# Umu::ConcreteSyntax::Core

end	# Umu::ConcreteSyntax

end	# Umu
