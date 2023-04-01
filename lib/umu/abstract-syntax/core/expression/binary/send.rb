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

		unless tup_value.kind_of? VCP::Tuple
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

		unless rec_value.kind_of? VCP::Struct::Entry
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
		if self.exprs.empty?
			self.sym.to_s
		else
			format("(%s %s)",
				self.sym.to_s,
				self.exprs.map(&:to_s).join(', ')
			)
		end
	end


	def evaluate_for(receiver, env, event)
		ASSERT.kind_of receiver,	VC::Top
		ASSERT.kind_of env,			E::Entry
		ASSERT.kind_of event,		E::Tracer::Event

		method_sym	= self.sym
		arg_values	= self.exprs.map { |expr|
			result = expr.evaluate env
			ASSERT.kind_of result, SAR::Value

			result.value
		}
		arg_num		= arg_values.size

		receiver_spec	= env.ty_class_spec_of receiver
		ASSERT.kind_of receiver_spec, ECTSC::Abstract
		method_spec		= receiver_spec.lookup_instance_method(
										method_sym, self.loc, env
									)
		ASSERT.kind_of method_spec, ECTS::Method
		param_num		= method_spec.param_class_specs.size

		unless arg_num == param_num
			raise X::ArgumentError.new(
				self.loc,
				env,
				"Wrong number of arguments, " +
					"expected: %d, but given: %d",
				param_num, arg_num
			)
		end

		arg_values.zip(
			method_spec.param_class_specs
		).each_with_index do
			|(arg_value, param_class_spec), i|
			ASSERT.kind_of arg_value,			VC::Top
			ASSERT.kind_of param_class_spec,	ECTSC::Base

			unless env.ty_kind_of?(arg_value, param_class_spec)
				raise X::TypeError.new(
					self.loc,
					env,
					"Type error at #%d argument, " +
							"expected a %s, but %s : %s",
						i + 1,
						param_class_spec.symbol,
						arg_value,
						arg_value.type_sym.to_s
				)
			end
		end

		next_receiver = receiver.invoke(
							method_spec,
							self.loc,
							env,
							event,
							*arg_values
						)
		ASSERT.assert env.ty_kind_of?(
							next_receiver, method_spec.ret_class_spec
						)

		ASSERT.kind_of next_receiver, VC::Top
	end
end

end	# Umu::AbstractSyntax::Core::Expression::Binary::Send::Message



class Entry < Binary::Abstract
	alias rhs_messages rhs


	def initialize(loc, lhs_expr, rhs_messages)
		ASSERT.kind_of lhs_expr,	SACE::Abstract
		ASSERT.kind_of rhs_messages,	::Array
		ASSERT.assert rhs_messages.size >= 1

		super
	end


	def to_s
		format("(%s).%s",
			self.lhs_expr.to_s,
			self.rhs_messages.map(&:to_s).join('.')
		)
	end


	def __evaluate__(env, event)
		ASSERT.kind_of env,		E::Entry
		ASSERT.kind_of event,	E::Tracer::Event

		new_env = env.enter event

		lhs_result = self.lhs_expr.evaluate new_env
		ASSERT.kind_of lhs_result, SAR::Value
		init_receiver = lhs_result.value

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


	def make_send(loc, lhs_expr, rhs_exprs)
		ASSERT.kind_of loc,			L::Location
		ASSERT.kind_of lhs_expr,	SACE::Abstract
		ASSERT.kind_of rhs_exprs,	::Array

		Binary::Send::Entry.new(loc, lhs_expr, rhs_exprs.freeze).freeze
	end

end	# Umu::AbstractSyntax::Core::Expression

end	# Umu::AbstractSyntax::Core

end	# Umu::AbstractSyntax

end	# Umu
