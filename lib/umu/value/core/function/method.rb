require 'umu/common'
require 'umu/lexical/location'
require 'umu/abstract-syntax/core/expression'


module Umu

module Value

module Core

module Function

module Method

class Abstract < Core::Function::Abstract
	attr_reader	:formal_receiver_spec
	attr_reader	:method_sym


	def initialize(formal_receiver_spec, method_sym)
		ASSERT.kind_of formal_receiver_spec,	ECTSC::Base
		ASSERT.kind_of method_sym,				::Symbol

		super()

		@formal_receiver_spec	= formal_receiver_spec
		@method_sym				= method_sym
	end


private

	def __to_s__(opr)
		format("&(%s%s%s)",
				self.formal_receiver_spec.symbol,
				opr,
				self.method_sym
		)
	end


	def __nary_invoke__(
		receiver, arg_head_value, arg_tail_values, method_spec,
		loc, env, event, n
	)
		ASSERT.kind_of receiver,		VC::Top
		ASSERT.kind_of arg_head_value,	VC::Top
		ASSERT.kind_of arg_tail_values,	::Array
		ASSERT.kind_of method_spec, 	ECTS::Method
		ASSERT.kind_of loc,				L::Location
		ASSERT.kind_of env,				E::Entry
		ASSERT.kind_of event,			E::Tracer::Event
		ASSERT.kind_of n,				::Integer

		arg_values	= [arg_head_value] + arg_tail_values
		arg_num		= arg_values.size
		param_num	= method_spec.param_class_specs.size
		unless arg_num == param_num
			raise X::ArgumentError.new(
				loc,
				env,
				"In '%s', wrong number of arguments, " +
						"expected %d, but given %d",
					self.method_sym.to_s,
					param_num + n,
					arg_num + n
			)
		end

		arg_values.zip(method_spec.param_class_specs).each_with_index do
			|(arg_value, param_spec), i|
			ASSERT.kind_of arg_value,	VC::Top
			ASSERT.kind_of param_spec,	ECTSC::Base

			unless env.ty_kind_of?(arg_value, param_spec)
				raise X::TypeError.new(
					loc,
					env,
					"For '%s's #%d argument, expected a %s, but %s : %s",
						self.method_sym.to_s,
						i + 1 + n,
						param_spec.symbol,
						arg_value.to_s,
						arg_value.type_sym
				)
			end
		end

		value = receiver.invoke(
					method_spec,
					loc,
					env.enter(event),
					event,
					arg_head_value,
					*arg_tail_values
				)
		ASSERT.assert env.ty_kind_of?(value, method_spec.ret_class_spec)

		ASSERT.kind_of value, VC::Top
	end
end



class ClassUnary < Abstract
	def to_s
		__to_s__('.')
	end

private

	def __apply__(arg_head_value, arg_tail_values, loc, env, event)
		ASSERT.kind_of arg_head_value,	VC::Top
		ASSERT.kind_of arg_tail_values,	::Array
		ASSERT.kind_of loc,				L::Location
		ASSERT.kind_of env,				E::Entry
		ASSERT.kind_of event,			E::Tracer::Event

		unless arg_head_value.kind_of?(VC::Unit)
			raise X::TypeError.new(
				loc,
				env,
				"In class method: '%s', expected a Unit, but %s : %s",
					self.method_sym,
					arg_head_value.to_s,
					arg_head_value.type_sym
			)
		end

		receiver_spec	= self.formal_receiver_spec
		ASSERT.kind_of receiver_spec, ECTSC::Base
		receiver		= VC.make_class receiver_spec
		method_spec		= receiver_spec.lookup_class_method(
											self.method_sym, loc, env
										)
		ASSERT.kind_of method_spec, ECTS::Method

		invoked_value = receiver.invoke(
							method_spec, loc, env.enter(event), event
						)
		ASSERT.assert env.ty_kind_of?(
								invoked_value, method_spec.ret_class_spec
							)
		value = if arg_values.size == 1
					invoked_value
				else
					invoked_value.apply arg_tail_values, loc, env
				end

		ASSERT.kind_of value, VC::Top
	end
end



class ClassBinary < Abstract
	def to_s
		__to_s__('.')
	end

private

	def __apply__(arg_head_value, arg_tail_values, loc, env, event)
		ASSERT.kind_of arg_head_value,	VC::Top
		ASSERT.kind_of arg_tail_values,	::Array
		ASSERT.kind_of loc,				L::Location
		ASSERT.kind_of env,				E::Entry
		ASSERT.kind_of event,			E::Tracer::Event

		receiver_spec	= self.formal_receiver_spec
		ASSERT.kind_of receiver_spec, ECTSC::Base
		receiver		= VC.make_class receiver_spec
		method_spec		= receiver_spec.lookup_class_method(
											self.method_sym, loc, env
										)
		ASSERT.kind_of method_spec, ECTS::Method
		ASSERT.assert method_spec.param_class_specs.size == 1
		param_spec		= method_spec.param_class_specs[0]

		unless env.ty_kind_of?(arg_head_value, param_spec)
			raise X::TypeError.new(
				loc,
				env,
				"For '%s's argument, expected a %s, but %s : %s",
					self.method_sym.to_s,
					param_spec.symbol,
					arg_head_value.to_s,
					arg_head_value.type_sym
			)
		end

		value = receiver.invoke(
					method_spec,
					loc,
					env.enter(event),
					event,
					arg_head_value,
					*arg_tail_values
				)

		ASSERT.assert env.ty_kind_of?(value, method_spec.ret_class_spec)

		ASSERT.kind_of value, VC::Top
	end
end



class ClassNary < Abstract
	def to_s
		__to_s__('.')
	end


private

	def __apply__(arg_head_value, arg_tail_values, loc, env, event)
		ASSERT.kind_of arg_head_value,	VC::Top
		ASSERT.kind_of arg_tail_values,	::Array
		ASSERT.kind_of loc,				L::Location
		ASSERT.kind_of env,				E::Entry
		ASSERT.kind_of event,			E::Tracer::Event

		receiver_spec	= self.formal_receiver_spec
		ASSERT.kind_of receiver_spec, ECTSC::Base
		receiver		= VC.make_class receiver_spec
		method_spec = receiver_spec.lookup_class_method(
											self.method_sym, loc, env
										)
		ASSERT.kind_of method_spec, ECTS::Method

		value = __nary_invoke__(
					receiver,
					arg_head_value,
					arg_tail_values,
					method_spec,
					loc, env, event, 0
				)

		ASSERT.kind_of value, VC::Top
	end
end



class InstanceUnary < Abstract
	def to_s
		__to_s__('$')
	end

private

	def __apply__(arg_head_value, arg_tail_values, loc, env, event)
		ASSERT.kind_of arg_head_value,	VC::Top
		ASSERT.kind_of arg_tail_values,	::Array
		ASSERT.kind_of loc,				L::Location
		ASSERT.kind_of env,				E::Entry
		ASSERT.kind_of event,			E::Tracer::Event

		receiver		= arg_head_value
		receiver_spec	= self.formal_receiver_spec
		ASSERT.kind_of receiver_spec, ECTSC::Base
		method_spec		= receiver_spec.lookup_instance_method(
									self.method_sym, loc, env
								)
		ASSERT.kind_of method_spec, ECTS::Method

		unless env.ty_kind_of?(receiver, receiver_spec)
			raise X::TypeError.new(
				loc,
				env,
				"In '%s', expected a %s, but %s : %s",
					self.method_sym,
					receiver_spec.symbol,
					receiver.to_s,
					receiver.type_sym
			)
		end

		invoked_value = receiver.invoke(
								method_spec, loc, env.enter(event), event
							)
		ASSERT.assert env.ty_kind_of?(
								invoked_value, method_spec.ret_class_spec
							)
		value = if arg_tail_values.empty?
					invoked_value
				else
					hd_value, *tl_value = arg_tail_values

					invoked_value.apply hd_value, tl_value, loc, env
				end

		ASSERT.kind_of value, VC::Top
	end
end



class InstanceNary < Abstract
	def to_s
		__to_s__('$')
	end


private

	def __apply__(arg_head_value, arg_tail_values, loc, env, event)
		ASSERT.kind_of arg_head_value,	VC::Top
		ASSERT.kind_of arg_tail_values,	::Array
		ASSERT.kind_of loc,				L::Location
		ASSERT.kind_of env,				E::Entry
		ASSERT.kind_of event,			E::Tracer::Event

		receiver	= arg_head_value
		meth_params	= arg_tail_values
		ASSERT.assert meth_params.size >= 1

		unless env.ty_kind_of?(receiver, self.formal_receiver_spec)
			raise X::TypeError.new(
				loc,
				env,
				"In '%s's 1st argument, expected a %s, but %s : %s",
					self.method_sym,
					self.formal_receiver_spec.symbol,
					receiver.to_s,
					receiver.type_sym
			)
		end

		actual_receiver_spec = env.ty_class_spec_of receiver
		ASSERT.kind_of actual_receiver_spec, ECTSC::Base
		method_spec = actual_receiver_spec.lookup_instance_method(
											self.method_sym, loc, env
										)
		ASSERT.kind_of method_spec, ECTS::Method

		hd_meth_param, *tl_meth_params = meth_params
		value = __nary_invoke__(
					receiver, hd_meth_param, tl_meth_params, method_spec,
					loc, env, event, 1
				)

		ASSERT.kind_of value, VC::Top
	end
end

end	# Umu::Value::Core::Function::Method

end	# Umu::Value::Core::Function


module_function

	def make_unary_class_method(class_spec, method_sym)
		ASSERT.kind_of class_spec,	ECTSC::Base
		ASSERT.kind_of method_sym,	::Symbol

		VCF::Method::ClassUnary.new(class_spec, method_sym).freeze
	end


	def make_binary_class_method(class_spec, method_sym)
		ASSERT.kind_of class_spec,	ECTSC::Base
		ASSERT.kind_of method_sym,	::Symbol

		VCF::Method::ClassBinary.new(class_spec, method_sym).freeze
	end


	def make_nary_class_method(class_spec, method_sym)
		ASSERT.kind_of class_spec,	ECTSC::Base
		ASSERT.kind_of method_sym,	::Symbol

		VCF::Method::ClassNary.new(class_spec, method_sym) .freeze
	end


	def make_unary_instance_method(class_spec, method_sym)
		ASSERT.kind_of class_spec,	ECTSC::Base
		ASSERT.kind_of method_sym,	::Symbol

		VCF::Method::InstanceUnary.new(class_spec, method_sym).freeze
	end


	def make_nary_instance_method(class_spec, method_sym)
		ASSERT.kind_of class_spec,	ECTSC::Base
		ASSERT.kind_of method_sym,	::Symbol

		VCF::Method::InstanceNary.new(class_spec, method_sym) .freeze
	end

end	# Umu::Value::Core

end	# Umu::Value

end	# Umu
