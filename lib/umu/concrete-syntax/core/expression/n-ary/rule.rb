require 'umu/common'
require 'umu/lexical/location'


module Umu

module ConcreteSyntax

module Core

module Expression

module Nary

module Rule

class Abstract < Abstraction::Model
	attr_reader :test_expr, :then_expr


	def initialize(loc, test_expr, then_expr)
		ASSERT.kind_of test_expr,	SCCE::Abstract
		ASSERT.kind_of then_expr,	SCCE::Abstract

		super(loc)

		@test_expr	= test_expr
		@then_expr	= then_expr
	end
end


class If < Abstract
	def to_s
		format "%s %s", self.test_expr, self.then_expr
	end
end


class Cond < Abstract
	attr_reader :decls


	def initialize(loc, test_expr, then_expr, decls)
		ASSERT.kind_of test_expr,	SCCE::Abstract
		ASSERT.kind_of then_expr,	SCCE::Abstract
		ASSERT.kind_of decls,		::Array

		super(loc, test_expr, then_expr)

		@decls = decls
	end


	def to_s
		format("%s -> %s%s",
				self.test_expr,

				self.then_expr,

				if self.decls.empty?
					''
				else
					format " %%WHERE %s", self.decls.map(&:to_s).join(' ')
				end
		)
	end
end

end	# Umu::ConcreteSyntax::Core::Expression::Nary::Rule

end	# Umu::ConcreteSyntax::Core::Expression::Nary


module_function

	def make_if_rule(loc, test_expr, then_expr)
		ASSERT.kind_of loc,			L::Location
		ASSERT.kind_of test_expr,	SCCE::Abstract
		ASSERT.kind_of then_expr,	SCCE::Abstract

		Nary::Rule::If.new(loc, test_expr, then_expr).freeze
	end


	def make_cond_rule(loc, test_expr, then_expr, decls)
		ASSERT.kind_of loc,			L::Location
		ASSERT.kind_of test_expr,	SCCE::Abstract
		ASSERT.kind_of then_expr,	SCCE::Abstract
		ASSERT.kind_of decls,		::Array

		Nary::Rule::Cond.new(loc, test_expr, then_expr, decls.freeze).freeze
	end

end	# Umu::ConcreteSyntax::Core::Expression

end	# Umu::ConcreteSyntax::Core

end	# Umu::ConcreteSyntax

end	# Umu
