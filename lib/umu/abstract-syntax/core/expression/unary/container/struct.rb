# vim: set nu ai sw=4 ts=4 :
# coding: utf-8
# frozen_string_literal: true

require 'umu/common'


module Umu

module AbstractSyntax

module Core

module Expression

module Unary

module Container

module Struct

class Field < Abstraction::LabelValuePair

private

	def __infix_string__
		' = '
	end
end



class Entry < Abstraction::HashBased
	alias expr_by_label hash


	def initialize(loc, expr_by_label)
		ASSERT.kind_of expr_by_label, ::Hash

		super
	end


	def each
		for (label, expr) in self.expr_by_label do
			ASSERT.kind_of label,	::Symbol
			ASSERT.kind_of expr,	ASCE::Abstract

			yield ASCE.make_struct_field self.loc, label, expr
		end
	end


	def to_s
		format "{%s}", self.map(&:to_s).join(', ')
	end


private

	def __evaluate__(env, event)
		ASSERT.kind_of env,		E::Entry
		ASSERT.kind_of event,	E::Tracer::Event


		new_env = env.enter event

		VC.make_struct(
			self.expr_by_label.inject({}) { |hash, (label, expr)|
				ASSERT.kind_of label,	::Symbol
				ASSERT.kind_of expr,	ASCE::Abstract

				hash.merge(label => expr.evaluate(new_env).value) {
					|lab, _, _|

					ASSERT.abort(lab.to_s)
				}
			}
		)
	end
end

end	# Umu::AbstractSyntax::Core::Expression::Unary::Container::Struct

end	# Umu::AbstractSyntax::Core::Expression::Unary::Container

end	# Umu::AbstractSyntax::Core::Expression::Unary


module_function

	def make_struct_field(loc, label, expr)
		ASSERT.kind_of loc,		L::Location
		ASSERT.kind_of label,	::Symbol
		ASSERT.kind_of expr,	ASCE::Abstract

		Unary::Container::Struct::Field.new(loc, label, expr).freeze
	end


	def make_struct(loc, expr_by_label)
		ASSERT.kind_of loc,				L::Location
		ASSERT.kind_of expr_by_label,	::Hash

		Unary::Container::Struct::Entry.new(
			loc, expr_by_label.freeze
		).freeze
	end

end	# Umu::AbstractSyntax::Core::Expression

end	# Umu::AbstractSyntax::Core

end	# Umu::AbstractSyntax

end	# Umu
