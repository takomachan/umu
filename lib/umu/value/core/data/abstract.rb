require 'umu/common'


module Umu

module Value

module Core

module Data

class Abstract < Top
	INSTANCE_METHOD_INFOS = [
		[:meth_contents,	VC::Top,
			:contents]
	]


	attr_reader :contents


	def initialize(pos, contents)
		ASSERT.kind_of contents, VC::Top

		super(pos)

		@contents = contents
	end


	def meth_contents(_env, _event)
		self.contents
	end
end

end	# Umu::Core::Data

end	# Umu::Core

end	# Umu::Value

end	# Umu
