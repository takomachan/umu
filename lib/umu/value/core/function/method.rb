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
		receiver, arg_values, method_spec,
		loc, env, event, n
	)
		ASSERT.kind_of receiver,	VC::Top
		ASSERT.kind_of arg_values,	::Array
		ASSERT.kind_of method_spec,	ECTS::Method
		ASSERT.kind_of loc,			L::Location
		ASSERT.kind_of env,			E::Entry
		ASSERT.kind_of event,		E::Tracer::Event
		ASSERT.kind_of n,			::Integer

		param_specs	= method_spec.param_class_specs
		param_num	= param_specs.size
		arg_num		= arg_values.size

		result_value =
			if param_num == arg_num
				__validate_type_of_args__(
					param_num, arg_values, param_specs, env
				)

				value = receiver.invoke(
					method_spec, loc, env.enter(event), event,
					*arg_values
				)
				ASSERT.assert env.ty_kind_of?(
										value, method_spec.ret_class_spec
									)
				ASSERT.kind_of value, VC::Top
			elsif param_num < arg_num
				__validate_type_of_args__(
					param_num, arg_values, param_specs, env
				)

				value = receiver.invoke(
					method_spec, loc, env.enter(event), event,
					*(arg_values[0 .. param_num - 1])
				)
				ASSERT.assert env.ty_kind_of?(
										value, method_spec.ret_class_spec
									)
				ASSERT.kind_of value, VC::Top

				hd_arg_value, *tl_arg_values = arg_values[param_num .. -1]

				value.apply hd_arg_value, tl_arg_values, loc, env
			elsif param_num > arg_num
=begin
				p({
					param_num: param_num,
					arg_num: arg_num,
					arg_values: arg_values
				})
=end
				free_idents, bound_idents = (0 .. param_num - 1).inject(
							 [[],     []]
						) { |(fr_ids, bo_ids), i|
					if i < arg_num
						[
							fr_ids + [
								SACE.make_identifier(
									loc,
									format("%%x_%d", i + 1).to_sym
								)
							],
							bo_ids
						]
					else
						[
							fr_ids,
							bo_ids + [
								SACE.make_identifier(
									loc,
									format("%%x_%d", i + 1).to_sym
								)
							]
						]
					end
				}
=begin
				p({
					free_idents: free_idents,
					bound_idents: bound_idents
				})
=end
				new_env = free_idents.zip(
						arg_values
					).inject(
						env.va_extend_value :'%r', receiver
					) { |e, (id, va)|
					ASSERT.kind_of e,	E::Entry
					ASSERT.kind_of id,	SACE::Unary::Identifier::Short
					ASSERT.kind_of va,	VC::Top

					e.va_extend_value(id.sym, va)
				}

				VC.make_closure(
					SACE.make_lambda(
						loc,
						bound_idents,
						SACE.make_send(
							loc,
							SACE.make_identifier(loc, :'%r'),
							SACE.make_method(
								loc,
								method_spec.symbol,
								free_idents + bound_idents
							)
						)
					),
					new_env.va_context
				)
			else
				ASSERT.abort 'No case'
			end

		ASSERT.kind_of result_value, VC::Top
	end


	def __validate_type_of_args__(num, arg_values, param_specs, env)
		ASSERT.kind_of num,			::Integer
		ASSERT.kind_of arg_values,	::Array
		ASSERT.kind_of param_specs,	::Array
		ASSERT.kind_of env,			E::Entry

		(0 .. num - 1).each do |i|
			arg_value	= arg_values[i]
			param_spec	= param_specs[i]
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
	end
end



class ClassUnary < Abstract
	def self.type_sym
		:ClassUnaryMethod
	end


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
		value = if arg_tail_values.empty?
					invoked_value
				else
					hd_value, *tl_values = arg_tail_values

					invoked_value.apply hd_value, tl_values, loc, env
				end

		ASSERT.kind_of value, VC::Top
	end
end



class ClassNary < Abstract
	def self.type_sym
		:ClassNaryMethod
	end


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
					[arg_head_value] + arg_tail_values,
					method_spec,
					loc, env, event, 0
				)

		ASSERT.kind_of value, VC::Top
	end
end



class Instance < Abstract
	def self.type_sym
		:InstanceMethod
	end


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
		meth_args	= arg_tail_values

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

		value = __nary_invoke__(
					receiver, meth_args, method_spec, loc, env, event, 1
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


	def make_nary_class_method(class_spec, method_sym)
		ASSERT.kind_of class_spec,	ECTSC::Base
		ASSERT.kind_of method_sym,	::Symbol

		VCF::Method::ClassNary.new(class_spec, method_sym) .freeze
	end


	def make_instance_method(class_spec, method_sym)
		ASSERT.kind_of class_spec,	ECTSC::Base
		ASSERT.kind_of method_sym,	::Symbol

		VCF::Method::Instance.new(class_spec, method_sym) .freeze
	end

end	# Umu::Value::Core

end	# Umu::Value

end	# Umu
