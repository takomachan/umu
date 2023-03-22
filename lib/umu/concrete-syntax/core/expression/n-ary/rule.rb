require 'umu/common'
require 'umu/lexical/location'


module Umu

module ConcreteSyntax

module Core

module Expression

module Nary

module Rule

module Abstraction

class Abstract < Umu::Abstraction::Model
	attr_reader :head_expr, :body_expr


	def initialize(loc, head_expr, body_expr)
		ASSERT.kind_of head_expr,	SCCE::Abstract
		ASSERT.kind_of body_expr,	SCCE::Abstract

		super(loc)

		@head_expr	= head_expr
		@body_expr	= body_expr
	end
end

class WithDeclaration < Abstract
	attr_reader :decls


	def initialize(loc, head_expr, body_expr, decls)
		ASSERT.kind_of head_expr,	SCCE::Abstract
		ASSERT.kind_of body_expr,	SCCE::Abstract
		ASSERT.kind_of decls,		::Array

		super(loc, head_expr, body_expr)

		@decls = decls
	end


	def to_s
		format("%s -> %s%s",
				self.head_expr,

				self.body_expr,

				if self.decls.empty?
					''
				else
					format " %%WHERE %s", self.decls.map(&:to_s).join(' ')
				end
		)
	end
end

end


class If < Abstraction::Abstract
	def to_s
		format "%s %s", self.head_expr, self.body_expr
	end
end


class Cond < Abstraction::WithDeclaration
end


class Case < Abstraction::WithDeclaration
end

end	# Umu::ConcreteSyntax::Core::Expression::Nary::Rule

end	# Umu::ConcreteSyntax::Core::Expression::Nary


module_function

	def make_if_rule(loc, head_expr, body_expr)
		ASSERT.kind_of loc,			L::Location
		ASSERT.kind_of head_expr,	SCCE::Abstract
		ASSERT.kind_of body_expr,	SCCE::Abstract

		Nary::Rule::If.new(loc, head_expr, body_expr).freeze
	end


	def make_cond_rule(loc, head_expr, body_expr, decls)
		ASSERT.kind_of loc,			L::Location
		ASSERT.kind_of head_expr,	SCCE::Abstract
		ASSERT.kind_of body_expr,	SCCE::Abstract
		ASSERT.kind_of decls,		::Array

		Nary::Rule::Cond.new(loc, head_expr, body_expr, decls.freeze).freeze
	end


	def make_case_rule(loc, head_expr, body_expr, decls)
		ASSERT.kind_of loc,			L::Location
		ASSERT.kind_of head_expr,	SCCE::Abstract
		ASSERT.kind_of body_expr,	SCCE::Abstract
		ASSERT.kind_of decls,		::Array

		Nary::Rule::Case.new(loc, head_expr, body_expr, decls.freeze).freeze
	end

end	# Umu::ConcreteSyntax::Core::Expression

end	# Umu::ConcreteSyntax::Core

end	# Umu::ConcreteSyntax

end	# Umu
