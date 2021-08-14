require 'umu/common'
require 'umu/value'


module Umu

module Environment

module Context

module Value

class Initial < Abstract

private

	def __extend__(sym, target)
		ASSERT.kind_of sym,		::Symbol
		ASSERT.kind_of target,	Bindings::Target::Abstract

		[{sym => target}, self]
	end
end

INITIAL = Initial.new.freeze


module_function

	def make_initial
		INITIAL
	end

end	# Umu::Environment::Context::Value

end	# Umu::Environment::Context

end	# Umu::Environment

end	# Umu
