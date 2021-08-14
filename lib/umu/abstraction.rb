require 'umu/common'
require 'umu/lexical/position'


module Umu

module Abstraction

class Model
	attr_reader :pos


	def initialize(pos)
		ASSERT.kind_of pos, L::Position

		@pos = pos
	end


	def to_s
		raise X::SubclassResponsibility
	end
end



class LabelValuePair < Model
	attr_reader :label, :value


	def initialize(pos, label, value)
		ASSERT.kind_of label,	::Symbol
		ASSERT.kind_of value,	::Object	# Polymophic

		super(pos)

		@label	= label
		@value	= value
	end


	def <=>(other)
		ASSERT.kind_of other, self.class

		self.label <=> other.label
	end


	def to_s
		format("%s%s",
				self.label.to_s,

				if self.value
					format("%s%s",
							__infix_string__,

							if block_given?
								yield self.value
							else
								self.value.to_s
							end
					)
				else
					''
				end
		)
	end


private

	def __infix_string__
		':'
	end
end



class CartesianProduct; end



class Collection
	include Enumerable
end

end	# Umu::Abstraction

end	# Umu
