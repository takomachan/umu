# vim: set nu ai sw=4 ts=4 :
# coding: utf-8
# frozen_string_literal: true

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



class Import < Abstract
	attr_reader :id, :fields


	def initialize(loc, id, fields)
		ASSERT.kind_of id,		CSME::Identifier::Abstract
		ASSERT.kind_of fields,	::Array

		super(loc)

		@id		= id
		@fields	= fields
	end


	def to_s
		format("%%IMPORT %s { %s }",
				self.id.to_s,
				self.fields.map(&:map)
		)
	end


	def exported_vars
		[CSCP.make_variable(self.loc, self.id.sym)].freeze
	end


private

	def __desugar__(env, event)
		new_env = env.enter event

		ASCD.make_declarations(
			self.loc,

			self.fields.map { |decl_id, opt_member_id|
				ASSERT.kind_of     decl_id,	CSME::Identifier::Abstract
				ASSERT.opt_kind_of opt_member_id, CSME::Identifier::Abstract

				expr = ASCE.make_long_identifier(
					self.loc,

					self.id.head.desugar(env),

					(
						self.id.tail + [
							opt_member_id ? opt_member_id : decl_id
						]
					).map { |id| id.desugar(env) }
				)

				ASCD.make_value self.loc, decl_id.sym, expr
			}
		)
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


	def make_import(loc, id, fields)
		ASSERT.kind_of id,		CSME::Identifier::Abstract
		ASSERT.kind_of fields,	::Array

		Import.new(loc, id, fields).freeze
	end


	def make_core(loc, core_decl)
		ASSERT.kind_of core_decl, CSCD::Abstract

		Core.new(loc, core_decl).freeze
	end

end	# Umu::ConcreteSyntax::Module::Declaration

end	# Umu::ConcreteSyntax::Module

end	# Umu::ConcreteSyntax

end	# Umu
