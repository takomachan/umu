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

module Abstraction

class LabelValuePair < Umu::Abstraction::LabelValuePair
	alias expr value


	def initialize(loc, label, expr)
		ASSERT.kind_of expr, ASCE::Abstract

		super
	end
end



class Abstract < Unary::Abstract
	include ::Enumerable


	def each
		self.array.each do |expr|
			ASSERT.kind_of expr, ASCE::Abstract

			yield expr
		end
	end


	def simple?
		false
	end
end



class ArrayBased < Abstract
	alias array obj


	def initialize(loc, array)
		ASSERT.kind_of array, ::Array

		super
	end
end



class HashBased < Abstract
	alias hash obj


	def initialize(loc, hash)
		ASSERT.kind_of hash, ::Hash

		super
	end
end

end	# Umu::AbstractSyntax::Core::Expression::Unary::Container::Abstraction

end	# Umu::AbstractSyntax::Core::Expression::Unary::Container

end	# Umu::AbstractSyntax::Core::Expression::Unary

end	# Umu::AbstractSyntax::Core::Expression

end	# Umu::AbstractSyntax::Core

end	# Umu::AbstractSyntax

end	# Umu
