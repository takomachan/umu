# vim: set nu ai sw=4 ts=4 :
# coding: utf-8
# frozen_string_literal: true

require 'umu/common'


module Umu

module ConcreteSyntax

module Module

module Pattern

module Struct

class Field < Abstraction::LabelValuePair
	alias opt_var_sym value


	def initialize(loc, label, opt_var_sym)
		ASSERT.opt_kind_of opt_var_sym, ::Symbol

		super
	end


	def pat
		var_sym = if self.opt_var_sym
						self.opt_var_sym
					else
						self.label
					end

		CSCP.make_variable self.loc, var_sym
	end

private

	def __infix_string__
		' = '
	end
end



class Entry < Pattern::Abstract
	include Enumerable

	attr_reader :fields


	def initialize(loc, fields)
		ASSERT.kind_of	fields,	::Array

		@fields = fields

		fields.reject { |field|
			ASSERT.kind_of field, Field

			field.pat.wildcard?
		}.inject([{}, {}]) do |(lab_hash, vpat_hash), field|
			ASSERT.kind_of lab_hash,	::Hash
			ASSERT.kind_of vpat_hash,	::Hash
			ASSERT.kind_of field,		Field

			vpat = field.pat
			ASSERT.kind_of vpat, CSCP::Variable

			[
				lab_hash.merge(field.label => true) { |key, _, _|
					raise X::SyntaxError.new(
						loc,
						"Duplicated pattern label: '%s'", key.to_s
					)
				},

				vpat_hash.merge(vpat.var_sym => true) { |key, _, _|
					raise X::SyntaxError.new(
						loc,
						"Duplicated pattern variable: '%s'", key.to_s
					)
				}
			]
		end

		super(loc)
	end


	def each
		self.fields.each do |x|
			yield x
		end
	end


	def to_s
		flds = case self.fields.size
				when 0
					''
				when 1
					format " %%VAL %s ", self.fields[0].to_s
				else
					format " %%VAL (%s) ", self.map(&:to_s).join(', ')
				end

		format "%%STRUCT {%s}", flds
	end


	def exported_vars
		self.map(&:pat).reject(&:wildcard?).inject([]) { |array, vpat|
			ASSERT.kind_of array,	::Array
			ASSERT.kind_of vpat,	CSCP::Variable

			array + vpat.exported_vars
		}.freeze
	end


private


	def __desugar_value__(expr, env, _event)
		ASSERT.kind_of expr, ASCE::Abstract

		ASCD.make_declarations(
			self.loc,
			[
				ASCD.make_value(self.loc, :'%r', expr)
			] + (
				__desugar__(env)
			)
		)
	end

	def __desugar__(_env)
		self.reject { |field|
			ASSERT.kind_of field, Field

			field.pat.wildcard?
		}.map { |field|
			ASSERT.kind_of field, Field

			vpat = field.pat
			ASSERT.kind_of vpat, CSCP::Variable

			loc = field.loc
			expr = ASCE.make_send(
						loc,
						ASCE.make_identifier(loc, :'%r'),
						ASCE.make_label_selector(loc, field.label)
					)

			ASCD.make_value vpat.loc, vpat.var_sym, expr
		}
	end
end

end	# Umu::ConcreteSyntax::Module::Pattern::Struct


module_function

	def make_struct_field(loc, label, opt_var_sym)
		ASSERT.kind_of		loc,			L::Location
		ASSERT.kind_of		label,			::Symbol
		ASSERT.opt_kind_of	opt_var_sym,	::Symbol

		Struct::Field.new(loc, label, opt_var_sym).freeze
	end


	def make_struct(loc, fields)
		ASSERT.kind_of	loc,	L::Location
		ASSERT.kind_of	fields,	::Array

		Struct::Entry.new(loc, fields.freeze).freeze
	end

end	# Umu::ConcreteSyntax::Module::Pattern

end	# Umu::ConcreteSyntax::Module

end	# Umu::ConcreteSyntax

end	# Umu
