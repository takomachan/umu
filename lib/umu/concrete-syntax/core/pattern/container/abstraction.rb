require 'umu/common'


module Umu

module ConcreteSyntax

module Core

module Pattern

module Container

module Abstraction

class LabelValuePair < Umu::Abstraction::LabelValuePair
	alias opt_var_sym value


	def initialize(pos, label, opt_var_sym)
		ASSERT.opt_kind_of opt_var_sym, ::Symbol

		super
	end


	def pat
		var_sym = if self.opt_var_sym
						self.opt_var_sym
					else
						self.label
					end

		SCCP.make_variable self.pos, var_sym
	end
end



class Abstract < Pattern::Abstract
	include Enumerable

	attr_reader :array


	def initialize(pos, array)
		ASSERT.kind_of array, ::Array

		super(pos)

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
