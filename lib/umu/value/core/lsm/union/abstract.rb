require 'umu/common'


module Umu

module Value

module Core

module LSM

module Union

class Abstract < LSM::Abstract
	INSTANCE_METHOD_INFOS = [
		[:meth_contents,	VC::Top,
			:contents]
	]


	def to_s
		format("&%s %s", self.type_sym, self.contents.to_s)
	end


	def contents
		VC.make_unit
	end


	def meth_to_string(loc, env, event)
		VC.make_string(
			format("&%s %s",
					self.type_sym,
					self.meth_contents(
						loc, env, event
					).meth_to_string(
						loc, env, event
					).val
			)
		)
	end


	def meth_contents(_loc, _env, _event)
		self.contents
	end
end

end	# Umu::Value::Core::LSM::Union

end	# Umu::Value::Core::LSM

end	# Umu::Core

end	# Umu::Value

end	# Umu