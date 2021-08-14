require 'umu/common'


module Umu

module Value

module Core

module Union

class Abstract < Top
	INSTANCE_METHOD_INFOS = [
		[:meth_content,	VC::Top,
			:content]
	]


	attr_reader :content


	def initialize(pos, content)
		ASSERT.kind_of content, VC::Top

		super(pos)

		@content = content
	end


	def meth_content(_env, _event)
		self.content
	end
end

end	# Umu::Core::Union

end	# Umu::Core

end	# Umu::Value

end	# Umu
