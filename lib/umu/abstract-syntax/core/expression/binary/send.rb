# vim: set nu ai sw=4 ts=4 :
# coding: utf-8
# frozen_string_literal: true

require 'umu/common'
require 'umu/environment/tracer/tracer'


module Umu

module AbstractSyntax

module Core

module Expression

module Binary

module Send

module Message

module Abstraction

class Abstract < Umu::Abstraction::Model
	def evaluate_for(value, env, event)
		raise X::SubclassResponsibility
	end
end



class Selector < Abstract
	attr_reader :sel


	def initialize(loc, sel)
		ASSERT.kind_of sel, ::Object		# Polymopic

		super(loc)

		@sel = sel
	end


	def to_s
		self.sel.to_s
	end
end

end	# Umu::AbstractSyntax::Core::Expression::Binary::Send::Message::Abstraction



class ByNumber < Abstraction::Selector
	alias sel_num sel


	def initialize(loc, sel_num)
		ASSERT.kind_of sel_num,	::Integer

		super
	end


	def evaluate_for(tup_value, env, _event)
		ASSERT.kind_of tup_value,	VC::Top
		ASSERT.kind_of env,			E::Entry

		unless tup_value.kind_of? VCBLP::Tuple
			raise X::TypeError.new(
				self.loc,
				env,
				"Selection operator '.' require a Tuple, but %s : %s",
					tup_value.to_s,
					tup_value.type_sym.to_s
			)
		end

		value = tup_value.select self.sel_num, self.loc, env
		ASSERT.kind_of value, VC::Top
	end
end



class ByLabel < Abstraction::Selector
	alias sel_sym sel

	def initialize(loc, sel_sym)
		ASSERT.kind_of sel_sym,	::Symbol

		super
	end


	def evaluate_for(rec_value, env, _event)
		ASSERT.kind_of rec_value,	VC::Top
		ASSERT.kind_of env,			E::Entry

		unless rec_value.kind_of? VC::Struct::Entry
			raise X::TypeError.new(
				self.loc,
				env,
				"Selection operator '.' require a Struct, but %s : %s",
					rec_value.to_s,
					rec_value.type_sym.to_s
			)
		end

		value = rec_value.select self.sel_sym, self.loc, env
		ASSERT.kind_of value, VC::Top
	end
end



class Method < Abstraction::Abstract
	attr_reader	:sym, :exprs


	def initialize(loc, sym, exprs)
		ASSERT.kind_of sym,		::Symbol
		ASSERT.kind_of exprs,	::Array

		super(loc)

		@sym	= sym
		@exprs	= exprs
	end


	def to_s
		self.sym.to_s + (
			if self.exprs.empty?
				''
			else
				' ' + self.exprs.map(&:to_s).join(' ')
			end
		)
	end


	def evaluate_for(receiver, env, event)
		ASSERT.kind_of receiver,	VC::Top
		ASSERT.kind_of env,			E::Entry
		ASSERT.kind_of event,		E::Tracer::Event

		method_sym	= self.sym
		arg_values	= self.exprs.map { |expr|
			result = expr.evaluate env
			ASSERT.kind_of result, ASR::Value

			result.value
		}
		arg_num		= arg_values.size

		receiver_spec	= env.ty_class_spec_of receiver
		ASSERT.kind_of receiver_spec, ECTSC::Abstract
		method_spec		= receiver_spec.lookup_instance_method(
										method_sym, self.loc, env
									)
		ASSERT.kind_of method_spec, ECTS::Method

		param_specs	= method_spec.param_class_specs
		param_num	= method_spec.param_class_specs.size

		result_value =
			if param_num == arg_num
				__validate_type_of_args__(
					param_num, arg_values, param_specs, loc, env
				)

				next_receiver = receiver.invoke(
					method_spec, self.loc, env, event, *arg_values
				)
				ASSERT.assert env.ty_kind_of?(
					next_receiver, method_spec.ret_class_spec
				)
				ASSERT.kind_of next_receiver, VC::Top
			elsif param_num < arg_num
				__validate_type_of_args__(
					param_num, arg_values, param_specs, loc, env
				)

				invoked_values = if param_num == 0
										[]
									else
										arg_values[0 .. param_num - 1]
									end

				value = receiver.invoke(
					method_spec, loc, env.enter(event), event,
					*invoked_values
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
							 [[],        []]
						) { |(fr_idents, bo_idents), i|
					ident = ASCE.make_identifier(
								loc, format("%%x_%d", i + 1).to_sym
							)

					if i < arg_num
						[fr_idents + [ident],	bo_idents]
					else
						[fr_idents,				bo_idents + [ident]]
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
					) { |e, (ident, v)|
					ASSERT.kind_of e,		E::Entry
					ASSERT.kind_of ident,	ASCEU::Identifier::Short
					ASSERT.kind_of v,		VC::Top

					e.va_extend_value ident.sym, v
				}

				lamb_params = bound_idents.map { |ident|
					ASSERT.kind_of ident, ASCEU::Identifier::Short

					ASCE.make_parameter ident.loc, ident
				}

				VC.make_function(
					ASCE.make_lambda(
						loc,
						lamb_params,
						ASCE.make_send(
							loc,
							ASCE.make_identifier(loc, :'%r'),
							ASCE.make_method(
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


private

	def __validate_type_of_args__(num, arg_values, param_specs, loc, env)
		ASSERT.kind_of num,			::Integer
		ASSERT.kind_of arg_values,	::Array
		ASSERT.kind_of param_specs,	::Array
		ASSERT.kind_of loc,			L::Location
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
						self.sym.to_s,
						i + 1,
						param_spec.symbol,
						arg_value.to_s,
						arg_value.type_sym
				)
			end
		end
	end
end

end	# Umu::AbstractSyntax::Core::Expression::Binary::Send::Message



class Entry < Binary::Abstract
	alias		rhs_head_message rhs
	attr_reader	:rhs_tail_messages
	attr_reader	:opt_receiver_type_sym


	def initialize(
		loc, lhs_expr,
		rhs_head_message, rhs_tail_messages,
		opt_receiver_type_sym
	)
		ASSERT.kind_of		lhs_expr,				ASCE::Abstract
		ASSERT.kind_of		rhs_head_message,
								Binary::Send::Message::Abstraction::Abstract
		ASSERT.kind_of		rhs_tail_messages,		::Array
		ASSERT.opt_kind_of	opt_receiver_type_sym,	::Symbol

		super(loc, lhs_expr, rhs_head_message)

		@rhs_tail_messages		= rhs_tail_messages
		@opt_receiver_type_sym	= opt_receiver_type_sym
	end


	def to_s
		format("(%s%s).%s",
			self.lhs_expr.to_s,

			if self.opt_receiver_type_sym
				format " : %s", self.opt_receiver_type_sym.to_s
			else
				''
			end,

			self.rhs_messages.map(&:to_s).join('.')
		)
	end


	def rhs_messages
		[self.rhs_head_message] + self.rhs_tail_messages
	end


	def __evaluate__(env, event)
		ASSERT.kind_of env,		E::Entry
		ASSERT.kind_of event,	E::Tracer::Event

		new_env = env.enter event

		lhs_result = self.lhs_expr.evaluate new_env
		ASSERT.kind_of lhs_result, ASR::Value
		init_receiver = lhs_result.value

		if self.opt_receiver_type_sym
			receiver_type_sym = opt_receiver_type_sym

			receiver_spec = new_env.ty_lookup receiver_type_sym, self.loc
			ASSERT.kind_of receiver_spec, ECTSC::Base
			unless env.ty_kind_of?(init_receiver, receiver_spec)
				raise X::TypeError.new(
					self.loc,
					env,
					"Expected a %s, but %s : %s",
					receiver_type_sym,
					init_receiver,
					init_receiver.type_sym
				)
			end
		end

		final_receiver = self.rhs_messages.inject(init_receiver) {
			|receiver, message|
			ASSERT.kind_of receiver,	VC::Top
			ASSERT.kind_of message,		Message::Abstraction::Abstract

			message.evaluate_for receiver, new_env, event
		}
		ASSERT.kind_of final_receiver, VC::Top
	end
end

end	# Umu::AbstractSyntax::Core::Expression::Binary::Send

end	# Umu::AbstractSyntax::Core::Expression::Binary


module_function
	def make_number_selector(loc, sel_num)
		ASSERT.kind_of loc,		L::Location
		ASSERT.kind_of sel_num,	::Integer

		Binary::Send::Message::ByNumber.new(loc, sel_num).freeze
	end


	def make_label_selector(loc, sel_sym)
		ASSERT.kind_of loc,		L::Location
		ASSERT.kind_of sel_sym,	::Symbol

		Binary::Send::Message::ByLabel.new(loc, sel_sym).freeze
	end



	def make_method(loc, sym, exprs = [])
		ASSERT.kind_of loc,		L::Location
		ASSERT.kind_of sym,		::Symbol
		ASSERT.kind_of exprs,	::Array

		Binary::Send::Message::Method.new(loc, sym, exprs.freeze).freeze
	end


	def make_send(
		loc, lhs_expr,
		rhs_head_message, rhs_tail_messages = [],
		opt_receiver_type_sym = nil
	)
		ASSERT.kind_of		loc,					L::Location
		ASSERT.kind_of		lhs_expr,				ASCE::Abstract
		ASSERT.kind_of		rhs_head_message,
								Binary::Send::Message::Abstraction::Abstract
		ASSERT.kind_of		rhs_tail_messages,		::Array
		ASSERT.opt_kind_of	opt_receiver_type_sym,	::Symbol

		Binary::Send::Entry.new(
			loc, lhs_expr, rhs_head_message, rhs_tail_messages.freeze,
			opt_receiver_type_sym
		).freeze
	end

end	# Umu::AbstractSyntax::Core::Expression

end	# Umu::AbstractSyntax::Core

end	# Umu::AbstractSyntax

end	# Umu
