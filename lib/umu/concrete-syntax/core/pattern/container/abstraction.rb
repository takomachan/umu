require 'umu/common'


module Umu

module ConcreteSyntax

module Core

module Pattern

module Container

module Abstraction

class LabelValuePair < Umu::Abstraction::LabelValuePair
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
end



class Abstract < Pattern::Abstract
	include Enumerable

	attr_reader :array


	def initialize(loc, array)
		ASSERT.kind_of array, ::Array

		super(loc)

		@array = array
	end


	def each
		self.array.each do |x|
			yield x
		end
	end


private

	def __gen_sym__(num)
		ASSERT.kind_of num, ::Integer

		format("%%a%d", num).to_sym
	end
end

end	# Umu::ConcreteSyntax::Core::Pattern::Container::Abstraction

end	# Umu::ConcreteSyntax::Core::Pattern::Container

end	# Umu::ConcreteSyntax::Core::Pattern

end	# Umu::ConcreteSyntax::Core

end	# Umu::ConcreteSyntax

end	# Umu
