# vim: set nu ai sw=4 ts=4 :
# coding: utf-8
# frozen_string_literal: true

require 'umu/common'
require 'umu/lexical/location'

require_relative 'abstract'



module Umu

module ConcreteSyntax

module Module

module Expression

module Identifier

class Abstract < Expression::Abstract
	def cons(id)
		ASSERT.kind_of id, Abstract

		CSME.make_long_identifier(
				id.loc,
				id.head,
				id.tail + [self.head] + self.tail
			)
	end


	def enque(id)
		ASSERT.kind_of id, Abstract

		CSME.make_long_identifier(
				self.loc,
				self.head,
				self.tail + [id.head] + id.tail
			)
	end


	def head
		raise X::SubclassResponsibility
	end


	def tail
		raise X::SubclassResponsibility
	end
end



class Short < Abstract
	attr_reader :sym


	def initialize(loc, sym)
		ASSERT.kind_of sym, ::Symbol

		super(loc)

		@sym = sym
	end


	def to_s
		self.sym.to_s
	end


	def head
		self
	end


	def tail
		[].freeze
	end


private

	def __desugar__(_env, _event)
		ASCE.make_identifier self.loc, self.sym
	end
end



class Long < Abstract
	attr_reader :head, :tail


	def initialize(loc, head, tail)
		ASSERT.kind_of head, Short
		ASSERT.kind_of tail, ::Array

		super(loc)

		@head = head
		@tail = tail
	end


	def to_s
		if tail.empty?
			self.head.to_s
		else
			format("%s::%s",
				self.head.to_s,
				self.tail.map(&:to_s).join('::')
			)
		end
	end


private

	def __desugar__(env, event)
		new_env = env.enter event

		ASCE.make_long_identifier(
			loc,
			self.head.desugar(new_env),
			self.tail.map { |id| id.desugar new_env }
		)
	end
end

end	# Umu::ConcreteSyntax::Core::Expression::Identifier


module_function

	def make_identifier(loc, sym)
		ASSERT.kind_of loc,	L::Location
		ASSERT.kind_of sym, ::Symbol

		Identifier::Short.new(loc, sym).freeze
	end


	def make_long_identifier(loc, head, tail)
		ASSERT.kind_of head, Identifier::Short
		ASSERT.kind_of tail, ::Array

		Identifier::Long.new(loc, head, tail.freeze).freeze
	end

end	# Umu::ConcreteSyntax::Module::Expression

end	# Umu::ConcreteSyntax::Module

end	# Umu::ConcreteSyntax

end	# Umu
