require 'umu/common'
require 'umu/lexical/location'


module Umu

module ConcreteSyntax

module Core

module Declaration

module Function

class Abstract < Declaration::Abstract
	attr_reader :lam_expr


	def initialize(loc, lam_expr)
		ASSERT.kind_of lam_expr, SCCE::Nary::Lambda::Named

		super(loc)

		@lam_expr = lam_expr
	end


	def to_s
		format "%%FUN %s", self.lam_expr.to_s
	end


	def exported_vars
		[SCCP.make_variable(self.loc, self.lam_expr.sym)].freeze
	end


private

	def __desugar__(env, event)
		SACD.make_value(
			self.loc,
			self.lam_expr.sym,
			self.lam_expr.desugar(env.enter(event))
		)
	end
end



class Simple < Abstract
	def to_s
		format "%%FUN %s", self.lam_expr.to_s
	end
end



class Recursive < Abstract
	def to_s
		self.lam_expr.to_s
	end
end

end	# Umu::ConcreteSyntax::Core::Declaration::Function



module_function

	def make_function(loc, lam_expr)
		ASSERT.kind_of lam_expr, SCCE::Nary::Lambda::Named

		Function::Simple.new(loc, lam_expr).freeze
	end


	def make_recursive_function(loc, lam_expr)
		ASSERT.kind_of lam_expr, SCCE::Nary::Lambda::Named

		Function::Recursive.new(loc, lam_expr).freeze
	end

end	# Umu::ConcreteSyntax::Core::Declaration

end	# Umu::ConcreteSyntax::Core

end	# Umu::ConcreteSyntax

end	# Umu
