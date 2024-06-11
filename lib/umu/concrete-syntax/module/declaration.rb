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
	attr_reader :id, :opt_fields


	def initialize(loc, id, opt_fields)
		ASSERT.kind_of		id,			CSME::Identifier::Abstract
		ASSERT.opt_kind_of	opt_fields,	::Array

		super(loc)

		@id			= id
		@opt_fields	= opt_fields
	end


	def to_s
		body = if self.opt_fields
			fields = self.opt_fields

			format(" { %s }",
				fields.map { |target_id, opt_source_id|
					ASSERT.kind_of     target_id,
										CSME::Identifier::Short
					ASSERT.opt_kind_of opt_source_id,
										CSME::Identifier::Abstract

					format("%%VAL %s%s",
							target_id.to_s,

							if opt_source_id
								format " = %s", opt_source_id
							else
								''
							end
					)
				}.join(' ')
			)
		else
			''
		end

		format "%%IMPORT %s%s", self.id.to_s, body
	end


	def exported_vars
		[CSCP.make_variable(self.loc, self.id.sym)].freeze
	end


private

	def __desugar__(env, event)
		new_env = env.enter event

		result = if self.opt_fields
			fields = self.opt_fields

			decls = fields.map { |target_id, opt_source_id|
				ASSERT.kind_of     target_id,     CSME::Identifier::Short
				ASSERT.opt_kind_of opt_source_id, CSME::Identifier::Abstract

				expr = ASCE.make_long_identifier(
					self.loc,

					self.id.head.desugar(new_env),

					(
						self.id.tail + (
							opt_source_id ? opt_source_id : target_id
						).to_a
					).map { |id| id.desugar(new_env) }
				)

				ASCD.make_value self.loc, target_id.sym, expr
			}

			ASCD.make_declarations self.loc, decls
		else
			ASCD.make_import self.loc, self.id.desugar(new_env)
		end

		ASSERT.kind_of result, ASCD::Abstract
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


	def make_import(loc, id, opt_fields)
		ASSERT.kind_of		id,			CSME::Identifier::Abstract
		ASSERT.opt_kind_of	opt_fields,	::Array

		Import.new(loc, id, opt_fields.freeze).freeze
	end


	def make_core(loc, core_decl)
		ASSERT.kind_of core_decl, CSCD::Abstract

		Core.new(loc, core_decl).freeze
	end

end	# Umu::ConcreteSyntax::Module::Declaration

end	# Umu::ConcreteSyntax::Module

end	# Umu::ConcreteSyntax

end	# Umu
