require 'umu/common'
require 'umu/lexical/position'


module Umu

module ConcreteSyntax

module Core

module Expression

module Nary

module Lambda

class Abstract < Expression::Abstract
	attr_reader :pats, :expr, :decls


	def initialize(pos, pats, expr, decls)
		ASSERT.kind_of pats,	::Array
		ASSERT.kind_of expr,	SCCE::Abstract
		ASSERT.kind_of decls,	::Array

		super(pos)

		@pats	= pats
		@expr	= expr
		@decls	= decls
	end


	def to_s
		format "%s -> %s", self.pats.map(&:to_s).join(' '), self.expr.to_s
	end


private

	def __name_sym__
		raise X::SubclassResponsibility
	end


	def __desugar__(env, event)
		new_env = env.enter event

		init_decls = self.decls.map { |decl| decl.desugar new_env }

		lamb_idents, final_decls = self.pats.each_with_index.inject(
			 [[],		init_decls]
		) {
			|(idents,	decls),			(pat, index)|
			ASSERT.kind_of idents,	::Array
			ASSERT.kind_of decls,	::Array
			ASSERT.kind_of pat,		SCCP::Abstract
			ASSERT.kind_of index,	::Integer

			result = pat.desugar_lambda index + 1, new_env
			ASSERT.kind_of result, SCCP::Result

			[idents + [result.ident], decls + result.decls]
		}

		final_expr = self.expr.desugar new_env
		lamb_expr = if final_decls.empty?
						final_expr
					else
						SACE.make_let self.pos, final_decls, final_expr
					end

		SACE.make_lambda self.pos, lamb_idents, lamb_expr, __name_sym__
	end
end



class Named < Abstract
	attr_reader :sym


	def initialize(pos, pats, expr, decls, sym)
		ASSERT.kind_of pats,	::Array
		ASSERT.kind_of expr,	SCCE::Abstract
		ASSERT.kind_of decls,	::Array
		ASSERT.kind_of sym,	::Symbol

		super(pos, pats, expr, decls)

		@sym = sym
	end


	def to_s
		format("%s = %s%s",
				self.sym.to_s,

				super,

				if self.decls.empty?
					''
				else
					format(" where {%s}", self.decls.map(&:to_s).join(' '))
				end
		)
	end


private

	def __name_sym__
		self.sym
	end
end



class Anonymous < Abstract

	def to_s
		format("{%s%s}",
				super,

				if self.decls.empty?
					''
				else
					format(" where %s", self.decls.map(&:to_s).join(' '))
				end
		)
	end

private

	def __name_sym__
		nil
	end
end

end	# Umu::ConcreteSyntax::Core::Expression::Nary::Lambda

end	# Umu::ConcreteSyntax::Core::Expression::Nary


module_function

	def make_lambda(pos, pats, expr, decls)
		ASSERT.kind_of pos,		L::Position
		ASSERT.kind_of pats,	::Array
		ASSERT.kind_of expr,	SCCE::Abstract
		ASSERT.kind_of decls,	::Array

		Nary::Lambda::Anonymous.new(pos, pats, expr, decls.freeze).freeze
	end


	def make_named_lambda(pos, pats, expr, decls, sym)
		ASSERT.kind_of pos,		L::Position
		ASSERT.kind_of pats,	::Array
		ASSERT.kind_of expr,	SCCE::Abstract
		ASSERT.kind_of decls,	::Array
		ASSERT.kind_of sym,		::Symbol

		Nary::Lambda::Named.new(pos, pats, expr, decls.freeze, sym).freeze
	end

end	# Umu::ConcreteSyntax::Core::Expression

end	# Umu::ConcreteSyntax::Core

end	# Umu::ConcreteSyntax

end	# Umu
