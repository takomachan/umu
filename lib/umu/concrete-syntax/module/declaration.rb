require 'umu/common'
require 'umu/lexical/position'

require 'umu/concrete-syntax/module/abstract'



module Umu

module ConcreteSyntax

module Module

module Declaration

class Abstract < Module::Abstract
	def exported_vars
		raise X::SubclassResponsibility
	end
end



class Module < Abstract
	attr_reader :pat, :expr


	def initialize(pos, pat, expr)
		ASSERT.kind_of pat,		SCMP::Abstract
		ASSERT.kind_of expr,	SCME::Abstract

		super(pos)

		@pat	= pat
		@expr	= expr
	end


	def to_s
		format "module %s = %s", self.pat.to_s, self.expr.to_s
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


	def initialize(pos, core_decl)
		ASSERT.kind_of core_decl, SCCD::Abstract

		super(pos)

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

	def make_module(pos, pat, expr)
		ASSERT.kind_of pat,		SCMP::Abstract
		ASSERT.kind_of expr,	SCME::Abstract

		Module.new(pos, pat, expr).freeze
	end


	def make_core(pos, core_decl)
		ASSERT.kind_of core_decl, SCCD::Abstract

		Core.new(pos, core_decl).freeze
	end

end	# Umu::ConcreteSyntax::Module::Declaration

end	# Umu::ConcreteSyntax::Module

end	# Umu::ConcreteSyntax

end	# Umu
