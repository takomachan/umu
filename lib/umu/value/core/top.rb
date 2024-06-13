# vim: set nu ai sw=4 ts=4 :
# coding: utf-8
# frozen_string_literal: true

require 'umu/common'
require 'umu/abstraction'


module Umu

module Value

module Core

class Top < ::Object
	INSTANCE_METHOD_INFOS = [
		# String
		[:meth_inspect,		VCBA::String,
			:inspect],
		[:meth_to_string,	VCBA::String,
			:'to-s'],

		# Relational
		[:meth_equal,		VCBA::Bool,
			:'==',			self],
		[:meth_less_than,	VCBA::Bool,
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


	def invoke(method_signat, loc, env, _event, *arg_values)
		ASSERT.kind_of method_signat,	ECTS::Method
		ASSERT.kind_of loc,				L::Location
		ASSERT.kind_of env,				E::Entry
		ASSERT.kind_of arg_values,		::Array
		ASSERT.assert arg_values.all? { |v| v.kind_of? VC::Top }

		msg = format("(%s).%s%s -> %s",
						self.to_s,

						method_signat.meth_sym,

						if arg_values.empty?
							''
						else
							format("(%s)",
								arg_values.zip(
									method_signat.param_class_signats
								).map{ |(value, signat)|
									format "%s : %s", value, signat.to_sym
								}.join(', ')
							)
						end,

						method_signat.ret_class_signat.to_sym
					)

		value = E::Tracer.trace(
							env.pref,
							env.trace_stack.count,
							'Invoke',
							self.class,
							loc,
							msg,
						) { |event|
							__invoke__(
								method_signat.meth_sym,
								loc,
								env,
								event,
								arg_values
							)
						}
		ASSERT.kind_of value, VC::Top
	end


	def apply(_head_value, _tail_values, loc, env)
		ASSERT.kind_of loc,	L::Location
		ASSERT.kind_of env,	E::Entry

		raise X::ApplicationError.new(
			loc,
			env,
			"Application error for %s : %s",
				self.to_s,
				self.type_sym.to_s
		)
	end


	def meth_inspect(_loc, _env, _event)
		VC.make_string self.to_s
	end


	alias meth_to_string meth_inspect


	def meth_equal(loc, env, _event, _other)
		raise X::EqualityError.new(
			loc,
			env,
			"Equality error for %s : %s",
				self.to_s,
				self.type_sym.to_s
		)
	end


	def meth_less_than(loc, env, _event, _other)
		raise X::OrderError.new(
			loc,
			env,
			"Order error for %s : %s",
				self.to_s,
				self.type_sym.to_s
		)
	end


private

	def __invoke__(meth_sym, loc, env, event, arg_values)
		ASSERT.kind_of meth_sym,	::Symbol
		ASSERT.kind_of loc,			L::Location
		ASSERT.kind_of env,			E::Entry
		ASSERT.kind_of event,		E::Tracer::Event
		ASSERT.kind_of arg_values,	::Array

		self.send meth_sym, loc, env, event, *arg_values
	end
end

end	# Umu::Value::Core

end	# Umu::Value

end	# Umu
