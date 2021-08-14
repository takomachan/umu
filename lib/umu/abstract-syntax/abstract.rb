require 'umu/common'
require 'umu/abstraction'


module Umu

module AbstractSyntax

class Abstract < Abstraction::Model
	def evaluate(env)
		raise X::SubclassResponsibility
	end
end

end	# Umu::AbstractSyntax

end	# Umu
