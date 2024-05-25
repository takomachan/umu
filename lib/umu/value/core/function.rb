require 'umu/common'
require 'umu/lexical/location'


module Umu

module Value

module Core

class Function < Top
	attr_reader	:lam, :va_context


	def initialize(lam, va_context)
		ASSERT.kind_of lam,			ASCEN::Lambda::Entry
		ASSERT.kind_of va_context,	ECV::Abstract

		super()

		@lam		= lam
		@va_context	= va_context
	end


	def to_s
		lam = self.lam

		format("#<%s%s>",
			if lam.opt_name
				format "%s: ", lam.opt_name
			else
				''
			end,

			self.lam.to_s
		)
	end


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

	def __apply__(init_head_value, init_tail_values, loc, env, event)
		ASSERT.kind_of init_head_value,		VC::Top
		ASSERT.kind_of init_tail_values,	::Array
		ASSERT.kind_of loc,					L::Location
		ASSERT.kind_of env,					E::Entry
		ASSERT.kind_of event,				E::Tracer::Event

		init_values	= [init_head_value] + init_tail_values
		lam			= self.lam

		init_params		= lam.params
		init_params_num	= init_params.size
		init_values_num	= init_values.size
		ASSERT.assert init_params_num >= 1
		ASSERT.assert init_values_num >= 1
		init_env		= env.update_va_context self.va_context

		result_value = 
			if init_params_num == init_values_num
				final_params, final_values, final_env = __bind__(
					init_params_num, init_params, init_values, init_env
				)
				ASSERT.assert final_params.empty?
				ASSERT.assert final_values.empty?

				new_env	= final_env.enter event
				result	= self.lam.expr.evaluate new_env
				ASSERT.kind_of result, ASR::Value

				result.value
			elsif init_params_num < init_values_num
				final_params, final_values, final_env = __bind__(
					init_params_num, init_params, init_values, init_env
				)
				ASSERT.assert final_params.empty?
				ASSERT.assert (not final_values.empty?)
				final_head_value, *final_tail_values = final_values

				new_env	= final_env.enter event
				result	= self.lam.expr.evaluate new_env
				ASSERT.kind_of result, ASR::Value

				result.value.apply(
					final_head_value, final_tail_values, loc, new_env
				)
			elsif init_params_num > init_values_num
				final_params, final_values, final_env = __bind__(
					init_values_num, init_params, init_values, init_env
				)
				ASSERT.assert (not final_params.empty?)
				ASSERT.assert final_values.empty?

				VC.make_function(
					ASCE.make_lambda(
						loc, final_params, lam.expr, lam.opt_name
					),
					final_env.va_context
				)
			else
				ASSERT.abort 'No case'
			end

		ASSERT.kind_of result_value, VC::Top
	end


	def __bind__(init_num, init_params, init_values, init_env)
		tuple = loop.inject(
			 [init_num,	init_params,	init_values,	init_env]
		) {
			|(num,		params,			values,			env),		_|
			ASSERT.kind_of num,		::Integer
			ASSERT.kind_of params,	::Array
			ASSERT.kind_of values,	::Array
			ASSERT.kind_of env,		E::Entry

			if num <= 0
				break [params, values, env]
			end

			head_param, *tail_params	= params
			head_value, *tail_values	= values
			ASSERT.kind_of head_param,	ASCEN::Lambda::Parameter
			ASSERT.kind_of tail_params,	::Array
			ASSERT.kind_of head_value,	VC::Top
			ASSERT.kind_of tail_values,	::Array

			if head_param.opt_type_sym
				type_sym = head_param.opt_type_sym

				spec = env.ty_lookup type_sym, head_param.loc
				ASSERT.kind_of spec, ECTSC::Base
				unless env.ty_kind_of?(head_value, spec)
					raise X::TypeError.new(
						head_param.loc,
						env,
						"Expected a %s, but %s : %s",
						type_sym,
						head_value,
						head_value.type_sym
					)
				end
			end

			[
				num - 1,

				tail_params,

				tail_values,

				env.va_extend_value(head_param.ident.sym, head_value)
			]
		}

		ASSERT.tuple_of tuple, [::Array, ::Array, E::Entry]
	end
end


module_function

	def make_function(lam, va_context)
		ASSERT.kind_of lam,			ASCEN::Lambda::Entry
		ASSERT.kind_of va_context,	ECV::Abstract

		Function.new(lam, va_context).freeze
	end

end	# Umu::Value::Core

end	# Umu::Value

end	# Umu
