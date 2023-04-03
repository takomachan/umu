require 'umu/common'
require 'umu/lexical/location'
require 'umu/abstract-syntax/core/expression'


module Umu

module Value

module Core

module Function

class Closure < Abstract
	attr_reader	:lam, :va_context


	def initialize(lam, va_context)
		ASSERT.kind_of lam,			SACE::Nary::Lambda
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


private

	def __apply__(init_head_value, init_tail_values, loc, env, event)
		ASSERT.kind_of init_head_value,		VC::Top
		ASSERT.kind_of init_tail_values,	::Array
		ASSERT.kind_of loc,					L::Location
		ASSERT.kind_of env,					E::Entry
		ASSERT.kind_of event,				E::Tracer::Event

		init_values	= [init_head_value] + init_tail_values
		lam			= self.lam

		init_idents		= lam.idents
		init_idents_num	= init_idents.size
		init_values_num	= init_values.size
		ASSERT.assert init_idents_num >= 1
		ASSERT.assert init_values_num >= 1
		init_env		= env.update_va_context self.va_context

		result_value = 
			if init_idents_num == init_values_num
				final_idents, final_values, final_env = __bind__(
					init_idents_num, init_idents, init_values, init_env
				)
				ASSERT.assert final_idents.empty?
				ASSERT.assert final_values.empty?

				new_env	= final_env.enter event
				result	= self.lam.expr.evaluate new_env
				ASSERT.kind_of result, SAR::Value

				result.value
			elsif init_idents_num < init_values_num
				final_idents, final_values, final_env = __bind__(
					init_idents_num, init_idents, init_values, init_env
				)
				ASSERT.assert final_idents.empty?
				ASSERT.assert (not final_values.empty?)
				final_head_value, *final_tail_values = final_values

				new_env	= final_env.enter event
				result	= self.lam.expr.evaluate new_env
				ASSERT.kind_of result, SAR::Value

				result.value.apply(
					final_head_value, final_tail_values, loc, new_env
				)
			elsif init_idents_num > init_values_num
				final_idents, final_values, final_env = __bind__(
					init_values_num, init_idents, init_values, init_env
				)
				ASSERT.assert (not final_idents.empty?)
				ASSERT.assert final_values.empty?

				VC.make_closure(
					SACE.make_lambda(
						loc, final_idents, lam.expr, lam.opt_name
					),
					final_env.va_context
				)
			else
				ASSERT.abort 'No case'
			end

		ASSERT.kind_of result_value, VC::Top
	end


	def __bind__(init_num, init_idents, init_values, init_env)
		tuple = loop.inject(
			 [init_num,	init_idents,	init_values,	init_env]
		) {
			|(num,		idents,			values,			env),		_|
			ASSERT.kind_of num,		::Integer
			ASSERT.kind_of idents,	::Array
			ASSERT.kind_of values,	::Array
			ASSERT.kind_of env,		E::Entry

			if num <= 0
				break [idents, values, env]
			end

			head_ident, *tail_idents	= idents
			head_value, *tail_values	= values
			ASSERT.kind_of head_ident,	SACE::Unary::Identifier::Short
			ASSERT.kind_of tail_idents,	::Array
			ASSERT.kind_of head_value,	VC::Top
			ASSERT.kind_of tail_values,	::Array

			[
				num - 1,

				tail_idents,

				tail_values,

				env.va_extend_value(head_ident.sym, head_value)
			]
		}

		ASSERT.tuple_of tuple, [::Array, ::Array, E::Entry]
	end
end

end	# Umu::Value::Core::Function


module_function

	def make_closure(lam, va_context)
		ASSERT.kind_of lam,			SACE::Nary::Lambda
		ASSERT.kind_of va_context,	ECV::Abstract

		Function::Closure.new(lam, va_context).freeze
	end

end	# Umu::Value::Core

end	# Umu::Value

end	# Umu
