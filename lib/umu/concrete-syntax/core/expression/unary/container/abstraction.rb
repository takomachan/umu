require 'umu/common'
require 'umu/lexical/location'


module Umu

module ConcreteSyntax

module Core

module Expression

module Unary

module Container

module Abstraction

class LabelValuePair < Umu::Abstraction::LabelValuePair
	alias opt_expr	value


	def initialize(loc, label, opt_expr)
		ASSERT.opt_kind_of opt_expr, SCCE::Abstract

		super
	end


	def expr
		opt_expr = self.opt_expr

		if opt_expr
			opt_expr
		else
			SCCE.make_identifier self.loc, self.label
		end
	end
end



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

end	# Umu::ConcreteSyntax::Core::Expression::Unary::Container::Abstraction

end	# Umu::ConcreteSyntax::Core::Expression::Unary::Container

end	# Umu::ConcreteSyntax::Core::Expression::Unary

end	# Umu::ConcreteSyntax::Core::Expression

end	# Umu::ConcreteSyntax::Core

end	# Umu::ConcreteSyntax

end	# Umu
