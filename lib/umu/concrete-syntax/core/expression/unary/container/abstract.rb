require 'umu/common'
require 'umu/lexical/location'


module Umu

module ConcreteSyntax

module Core

module Expression

module Unary

module Container

class Abstract < Unary::Abstract
	include Enumerable

	alias array obj


	def initialize(loc, array)
		ASSERT.kind_of array, ::Array

		super
	end


	def each
		self.array.each do |x|
			yield x
		end
	end


	def empty?
		self.count == 0
	end
end

end	# Umu::ConcreteSyntax::Core::Expression::Unary::Container

end	# Umu::ConcreteSyntax::Core::Expression::Unary

end	# Umu::ConcreteSyntax::Core::Expression

end	# Umu::ConcreteSyntax::Core

end	# Umu::ConcreteSyntax

end	# Umu
