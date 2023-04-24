require 'umu/common'
require 'umu/lexical/location'


module Umu

module Value

module Core

module Function

class Abstract < Top
	def apply(head_value, tail_values, loc, env)
		ASSERT.kind_of head_value,	VC::Top
		ASSERT.kind_of tail_values,	::Array
		ASSERT.kind_of loc,			L::Location
		ASSERT.kind_of env,			E::Entry

		result_value = E::Tracer.trace(
							env.pref,
							env.trace_stack.count,
							'Apply',
							self.class,
							loc,
							format("(%s %s)",
								self.to_s,
								(
									[head_value] + tail_values
								).map(&:to_s).join(' ')
							)
						) { |event|
							__apply__(
								head_value, tail_values, loc, env, event
							)
						}
		ASSERT.kind_of result_value, VC::Top
	end


private

	def __apply__(_head_value, _tail_values, _loc, _env, _event)
		raise X::SubclassResponsibility
	end
end

end	# Umu::Value::Core::Function

end	# Umu::Value::Core

end	# Umu::Value

end	# Umu
