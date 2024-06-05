# vim: set nu ai sw=4 ts=4 :
# coding: utf-8
# frozen_string_literal: true

require 'umu/common'
require 'umu/lexical/location'


module Umu

module ConcreteSyntax

module Core

module Expression

module Unary

module Container

module Named

class Label < Unary::Abstract
	alias sym obj


	def initialize(loc, sym)
		ASSERT.kind_of sym, ::Symbol

		super
	end


	def hash
		self.sym.hash
	end


	def eql?(other)
		self.sym.eql? other.sym
	end


	def to_s
		self.sym.to_s + ':'
	end


private

	def __desugar__(_env, _event)
		ASCE.make_named_tuple_label self.loc, self.sym
	end
end



class Entry < Abstract
    attr_reader :index_by_label


	def initialize(loc, fields)
		ASSERT.kind_of	fields, ::Array
		ASSERT.assert	fields.size >= 2

		index_by_label, exprs = fields.each_with_index.inject([{}, []]) {
			|(hash, array), (pair, index)|
			ASSERT.kind_of	hash,	::Hash
			ASSERT.kind_of	array,	::Array
			ASSERT.tuple_of	pair,[Label, CSCE::Abstract]
			ASSERT.kind_of	index,	::Integer

			[
				hash.merge(pair[0] => index) { |label, _, _|
					raise X::SyntaxError.new(
						label.loc,
						format("Duplicated label in named tuple: '%s'",
								label.sym
						)
					)
				},

				array + [pair[1]]
			]
		}

		@index_by_label = index_by_label.freeze

		super(loc, exprs.freeze)
	end


	def to_s
		format("(%s)",
			self.index_by_label.map { |label, index|
				format "%s %s", label.to_s, self.exprs[index].to_s
			}.join(', ')
		)
	end


private

	def __desugar__(env, event)
		new_env = env.enter event

		ASCE.make_named_tuple(
			self.loc,

			self.map { |expr| expr.desugar(new_env) },

			self.index_by_label.inject({}) { |hash, (label, index)|
				hash.merge(label.desugar(new_env) => index)
			}
		)
	end
end

end	# Umu::ConcreteSyntax::Core::Expression::Unary::Container::Named

end	# Umu::ConcreteSyntax::Core::Expression::Unary::Container

end	# Umu::ConcreteSyntax::Core::Expression::Unary


module_function

	def make_named_tuple_label(loc, sym)
		ASSERT.kind_of loc,		L::Location
		ASSERT.kind_of sym,		::Symbol

		Unary::Container::Named::Label.new(loc, sym).freeze
	end


	def make_named_tuple(loc, fields)
		ASSERT.kind_of loc,		L::Location
		ASSERT.kind_of fields,	::Array

		Unary::Container::Named::Entry.new(loc, fields.freeze).freeze
	end

end	# Umu::ConcreteSyntax::Core::Expression

end	# Umu::ConcreteSyntax::Core

end	# Umu::ConcreteSyntax

end	# Umu
