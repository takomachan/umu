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

	def __evaluate__(_env, _event)
		ASSERT.kind_of env,		E::Entry
		ASSERT.kind_of event,	E::Tracer::Event


		new_env = env.enter event

		VC.make_named_tuple(
			self.map { |expr| expr.evaluate(new_env).value },
			self.index_by_label
		)
	end
end



class Entry < Abstraction::ArrayBased
	alias exprs array
    attr_reader :index_by_label


	def initialize(loc, exprs, index_by_label)
		ASSERT.kind_of exprs,			::Array
		ASSERT.assert exprs.size >= 2
		ASSERT.kind_of index_by_label,	::Hash

		@index_by_label = index_by_label.freeze

		super(loc, exprs)
	end


	def to_s
		format("(%s)",
			self.index_by_label.map { |label, index|
				format "%s %s", label.to_s, self.exprs[index].to_s
			}.join(', ')
		)
	end


private

	def __evaluate__(env, event)
		ASSERT.kind_of env,		E::Entry
		ASSERT.kind_of event,	E::Tracer::Event

		new_env = env.enter event

		VC.make_named_tuple(
			self.map { |expr| expr.evaluate(new_env).value },

			self.index_by_label.inject({}) { |hash, (label, index)|
				hash.merge(label.sym => index)
			}
		)
	end
end

end	# Umu::AbstractSyntax::Core::Expression::Unary::Container::Named

end	# Umu::AbstractSyntax::Core::Expression::Unary::Container

end	# Umu::AbstractSyntax::Core::Expression::Unary


module_function

	def make_named_tuple_label(loc, sym)
		ASSERT.kind_of loc,		L::Location
		ASSERT.kind_of sym,		::Symbol

		Unary::Container::Named::Label.new(loc, sym).freeze
	end


	def make_named_tuple(loc, exprs, index_by_label)
		ASSERT.kind_of loc,				L::Location
		ASSERT.kind_of exprs,			::Array
		ASSERT.kind_of index_by_label,	::Hash

		Unary::Container::Named::Entry.new(
			loc, exprs.freeze, index_by_label.freeze
		).freeze
	end

end	# Umu::AbstractSyntax::Core::Expression

end	# Umu::AbstractSyntax::Core

end	# Umu::AbstractSyntax

end	# Umu
