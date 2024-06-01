require 'umu/common'
require 'umu/lexical/location'

require_relative 'abstract'



module Umu

module ConcreteSyntax

module Module

module Declaration

class Abstract < Module::Abstract
	def exported_vars
		raise X::SubclassResponsibility
	end
end



class Structure < Abstract
	attr_reader :pat, :expr


	def initialize(loc, pat, expr)
		ASSERT.kind_of pat,		CSMP::Abstract
		ASSERT.kind_of expr,	CSME::Abstract

		super(loc)

		@pat	= pat
		@expr	= expr
	end


	def to_s
		format "%%STRUCTURE %s = %s", self.pat.to_s, self.expr.to_s
	end


	def exported_vars
		self.pat.exported_vars
	end


private

	def __desugar__(env, event)
		new_env = env.enter event

		self.pat.desugar_value self.expr.desugar(new_env), new_env
	end
end



class Core < Abstract
	attr_reader :core_decl


	def initialize(loc, core_decl)
		ASSERT.kind_of core_decl, CSCD::Abstract

		super(loc)

		@core_decl = core_decl
	end


	def to_s
		self.core_decl.to_s
	end


	def exported_vars
		self.core_decl.exported_vars
	end


private

	def __desugar__(env, event)
		self.core_decl.desugar env.enter(event)
	end
end



module_function

	def make_structure(loc, pat, expr)
		ASSERT.kind_of pat,		CSMP::Abstract
		ASSERT.kind_of expr,	CSME::Abstract

		Structure.new(loc, pat, expr).freeze
	end


	def make_core(loc, core_decl)
		ASSERT.kind_of core_decl, CSCD::Abstract

		Core.new(loc, core_decl).freeze
	end

end	# Umu::ConcreteSyntax::Module::Declaration

end	# Umu::ConcreteSyntax::Module

end	# Umu::ConcreteSyntax

end	# Umu
