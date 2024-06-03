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

module Identifier

class Abstract < Unary::Abstract; end



class Short < Abstract
	alias sym obj


	def initialize(loc, sym)
		ASSERT.kind_of sym, ::Symbol

		super
	end


	def to_s
		self.sym.to_s
	end


private

	def __desugar__(_env, _event)
		ASCE.make_identifier self.loc, self.sym
	end
end



class Long < Abstract
	alias		head_id obj
	attr_reader	:tail_ids


	def initialize(loc, head_id, tail_ids)
		ASSERT.kind_of head_id,		Short
		ASSERT.kind_of tail_ids,	::Array

		super(loc, head_id)

		@tail_ids = tail_ids
	end


	def to_s
		if tail_ids.empty?
			self.head_id.to_s
		else
			format("%s::%s",
				self.head_id.to_s,
				self.tail_ids.map(&:to_s).join('::')
			)
		end
	end


private

	def __desugar__(env, event)
		new_env = env.enter event

		if tail_ids.empty?
			self.head_id.desugar(new_env)
		else
			ASCE.make_long_identifier(
				loc,
				self.head_id.desugar(new_env),
				self.tail_ids.map { |id| id.desugar(new_env) }
			)
		end
	end
end

end	# Umu::ConcreteSyntax::Core::Expression::Unary::Identifier

end	# Umu::ConcreteSyntax::Core::Expression::Unary


module_function

	def make_identifier(loc, sym)
		ASSERT.kind_of loc,	L::Location
		ASSERT.kind_of sym, ::Symbol

		Unary::Identifier::Short.new(loc, sym).freeze
	end


	def make_long_identifier(loc, head_id, tail_ids)
		ASSERT.kind_of head_id,		Unary::Identifier::Short
		ASSERT.kind_of tail_ids,	::Array

		Unary::Identifier::Long.new(loc, head_id, tail_ids.freeze).freeze
	end

end	# Umu::ConcreteSyntax::Core::Expression

end	# Umu::ConcreteSyntax::Core

end	# Umu::ConcreteSyntax

end	# Umu
