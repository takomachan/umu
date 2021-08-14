require 'umu/common'
require 'umu/lexical/position'


module Umu

module ConcreteSyntax

module Core

module Expression

module Binary

class Infix < Abstract
	alias		lhs_opnd lhs_expr
	attr_reader :opr_sym
	alias		rhs_opnd rhs


	def initialize(pos, lhs_opnd, opr_sym, rhs_opnd)
		ASSERT.kind_of lhs_opnd,	SCCE::Abstract
		ASSERT.kind_of opr_sym,		::Symbol
		ASSERT.kind_of rhs_opnd,	SCCE::Abstract

		super(pos, lhs_opnd, rhs_opnd)

		@opr_sym = opr_sym
	end


	def to_s
		format("(%s %s %s)",
			self.lhs_opnd.to_s,
			self.opr_sym.to_s,
			self.rhs_opnd.to_s
		)
	end


	REDEFINABLE_OPR_SYMS = [
		# Number
		:'+',	:'-',	:'*',	:'/',	:mod,	:pow,

		# String
		:'^',

		# Relational
		:'==',	:'\\=',	:'<',	:'>',	:'<=',	:'>=',

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
		pos			= self.pos

		expr = if REDEFINABLE_OPR_SYMS[opr_sym]
				SACE.make_apply(
					pos,
					SACE.make_identifier(pos, opr_sym),
					[lhs_opnd, rhs_opnd]
				)
			else
				case opr_sym
				# Typing
				when :AKO?
					unless rhs_opnd.kind_of?(
										SACE::Unary::Identifier::Abstract
									)
						raise X::SyntaxError.new(
							rhs_opnd.pos,
							"RHS of 'ako?' operator " +
								"require a identifier, but: %s",
							rhs_opnd.to_s
						)
					end

					SACE.make_kind_of pos, lhs_opnd, rhs_opnd.sym

				# Conditional
				when :ANDALSO
					SACE.make_if(
						pos,
						[
							SACE.make_rule(
								pos,
								lhs_opnd,
								rhs_opnd
							)
						],
						SACE.make_bool(pos, false)
					)
				when :ORELSE
					SACE.make_if(
						pos,
						[
							SACE.make_rule(
								pos,
								lhs_opnd,
								SACE.make_bool(pos, true)
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

	def make_infix(pos, lhs_opnd, opr_sym, rhs_opnd)
		ASSERT.kind_of pos,			L::Position
		ASSERT.kind_of lhs_opnd,	SCCE::Abstract
		ASSERT.kind_of opr_sym,		::Symbol
		ASSERT.kind_of rhs_opnd,	SCCE::Abstract

		Binary::Infix.new(pos, lhs_opnd, opr_sym, rhs_opnd).freeze
	end

end	# Umu::ConcreteSyntax::Core::Expression

end	# Umu::ConcreteSyntax::Core

end	# Umu::ConcreteSyntax

end	# Umu
