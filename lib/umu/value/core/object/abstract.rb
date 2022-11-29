require 'umu/common'


module Umu

module Value

module Core

module Object

class Abstract < Top
	INSTANCE_METHOD_INFOS = [
		[:meth_contents,	VC::Top,
			:contents]
	]


	def meth_contents(_loc, _env, _event)
		VC.make_unit
	end
end

end	# Umu::Core::Object

end	# Umu::Core

end	# Umu::Value

end	# Umu
