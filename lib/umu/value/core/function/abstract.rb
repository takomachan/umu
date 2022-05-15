require 'umu/common'
require 'umu/lexical/position'


module Umu

module Value

module Core

module Function

class Abstract < Core::Top
	def apply(app_values, pos, env)
		ASSERT.kind_of app_values,	::Array
		ASSERT.kind_of pos,			L::Position
		ASSERT.kind_of env,			E::Entry

		value = E::Tracer.trace(
							env.pref,
							env.trace_stack.count,
							'Apply',
							self.class,
							pos,
							format("(%s %s)",
								self.to_s,
								app_values.map(&:to_s).join(' ')
							)
						) { |event|
							__apply__ app_values, pos, env, event
						}
		ASSERT.kind_of value, VC::Top
	end


private

	def __apply__(_app_value, _pos, _env, _event)
		raise X::SubclassResponsibility
	end
end

end	# Umu::Value::Core::Function

end	# Umu::Value::Core

end	# Umu::Value

end	# Umu
