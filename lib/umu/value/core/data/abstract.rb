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

	UNIT = VC.make_unit(L.make_position(__FILE__, __LINE__))


	def meth_contents(_env, _event)
		UNIT
	end
end

end	# Umu::Core::Data

end	# Umu::Core

end	# Umu::Value

end	# Umu
