require 'umu/common'
require 'umu/abstraction'


module Umu

module Value

module Core

class Top < Abstraction::Model
	INSTANCE_METHOD_INFOS = [
		# String
		[:meth_inspect,		VCA::String,
			:inspect],
		[:meth_to_string,	VCA::String,
			:'to-s'],

		# Relational
		[:meth_equal,		VCA::Bool,
			:'==',			self],
		[:meth_less_than,	VCA::Bool,
			:'<',			self]
	]


	def self.class_method_infos
		begin
			self.const_get :CLASS_METHOD_INFOS, false
		rescue ::NameError
			[]
		end
	end


	def self.instance_method_infos
		begin
			self.const_get :INSTANCE_METHOD_INFOS, false
		rescue ::NameError
			[]
		end
	end


	def self.type_sym
		begin
			self.const_get :TYPE_SYM, false
		rescue ::NameError
			class_path	= self.to_s.split(/::/).map(&:to_sym)
			self_sym	= class_path[-1]

			if self_sym == :Abstract
				class_path[-2]
			else
				self_sym
			end
		end
	end


	def type_sym
		self.class.type_sym
	end


	def invoke(method_spec, env, _event, *arg_values)
		ASSERT.kind_of method_spec,	ECTS::Method
		ASSERT.kind_of env,			E::Entry
		ASSERT.kind_of arg_values,	::Array
		ASSERT.assert arg_values.all? { |v| v.kind_of? VC::Top }

		msg = format("(%s).%s%s -> %s",
						self.to_s,

						method_spec.meth_sym,

						if arg_values.empty?
							''
						else
							format("(%s)",
								arg_values.zip(
									method_spec.param_class_specs
								).map{ |(value, spec)|
									format "%s : %s", value, spec.to_sym
								}.join(', ')
							)
						end,

						method_spec.ret_class_spec.to_sym
					)

		value = E::Tracer.trace(
							env.pref,
							env.trace_stack.count,
							'Invoke',
							self.class,
							self.pos,
							msg,
						) { |event|
							__invoke__(
								method_spec.meth_sym,
								env,
								event,
								arg_values
							)
						}
		ASSERT.kind_of value, VC::Top
	end


	def apply(val, env)
		raise X::ApplicationError.new(
			self.pos,
			env,
			"Application error for %s : %s",
				self.to_s,
				self.type_sym.to_s
		)
	end


	def meth_inspect(env, _event)
		VC.make_string self.pos, self.to_s
	end


	alias meth_to_string meth_inspect


	def meth_equal(env, _event, _other)
		raise X::EqualityError.new(
			self.pos,
			env,
			"Equality error for %s : %s",
				self.to_s,
				self.type_sym.to_s
		)
	end


	def meth_less_than(env, _event, _other)
		raise X::OrderError.new(
			self.pos,
			env,
			"Order error for %s : %s",
				self.to_s,
				self.type_sym.to_s
		)
	end


private

	def __invoke__(meth_sym, env, event, arg_values)
		ASSERT.kind_of meth_sym,	::Symbol
		ASSERT.kind_of env,			E::Entry
		ASSERT.kind_of event,		E::Tracer::Event
		ASSERT.kind_of arg_values,	::Array

		self.send meth_sym, env, event, *arg_values
	end
end

end	# Umu::Value::Core

end	# Umu::Value

end	# Umu
