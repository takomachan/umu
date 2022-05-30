require 'umu/common'
require 'umu/lexical/location'


module Umu

module Value

module Core

module Function

class Abstract < Core::Top
	def apply(app_values, loc, env)
		ASSERT.kind_of app_values,	::Array
		ASSERT.kind_of loc,			L::Location
		ASSERT.kind_of env,			E::Entry

		value = E::Tracer.trace(
							env.pref,
							env.trace_stack.count,
							'Apply',
							self.class,
							loc,
							format("(%s %s)",
								self.to_s,
								app_values.map(&:to_s).join(' ')
							)
						) { |event|
							__apply__ app_values, loc, env, event
						}
		ASSERT.kind_of value, VC::Top
	end


private

	def __apply__(_app_value, _loc, _env, _event)
		raise X::SubclassResponsibility
	end
end

end	# Umu::Value::Core::Function

end	# Umu::Value::Core

end	# Umu::Value

end	# Umu
