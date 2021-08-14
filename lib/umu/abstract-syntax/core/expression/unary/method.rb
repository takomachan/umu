require 'umu/common'


module Umu

module AbstractSyntax

module Core

module Expression

module Unary

module Method

class Abstract < Unary::Abstract
	alias		class_sym obj
	attr_reader	:method_sym


	def initialize(pos, class_sym, method_sym)
		ASSERT.kind_of class_sym,	::Symbol
		ASSERT.kind_of method_sym,	::Symbol

		super(pos, class_sym)

		@method_sym = method_sym
	end
end



class Class < Abstract
	def to_s
		format "@(%s.%s)", self.class_sym, self.method_sym
	end


	def __evaluate__(env, _event)
		class_spec = env.ty_lookup self.class_sym, self.pos
		ASSERT.kind_of class_spec, ECTSC::Base

		method_spec = class_spec.lookup_class_method(
										self.method_sym, self.pos, env
									)
		ASSERT.kind_of method_spec, ECTS::Method

		case method_spec.param_class_specs.size
		when 0
			VC.make_unary_class_method(
					self.pos, class_spec, self.method_sym
				)
		when 1
			VC.make_binary_class_method(
					self.pos, class_spec, self.method_sym
				)
		else
			VC.make_nary_class_method(
					self.pos, class_spec, self.method_sym
				)
		end
	end
end



class Instance < Abstract
	def to_s
		format "@(%s$%s)", self.class_sym, self.method_sym
	end


	def __evaluate__(env, _event)
		class_spec = env.ty_lookup self.class_sym, self.pos
		ASSERT.kind_of class_spec, ECTSC::Base

		method_spec = class_spec.lookup_instance_method(
										self.method_sym, self.pos, env
									)
		ASSERT.kind_of method_spec, ECTS::Method

		if method_spec.param_class_specs.empty?
			VC.make_unary_instance_method(
					self.pos, class_spec, self.method_sym
				)
		else
			VC.make_nary_instance_method(
					self.pos, class_spec, self.method_sym
				)
		end
	end
end

end # Umu::AbstractSyntax::Core::Expression::Unary::Method

end # Umu::AbstractSyntax::Core::Expression::Unary


module_function

	def make_class_method(pos, class_sym, method_sym)
		ASSERT.kind_of pos,	L::Position
		ASSERT.kind_of class_sym,	::Symbol
		ASSERT.kind_of method_sym,	::Symbol

		Unary::Method::Class.new(pos, class_sym, method_sym).freeze
	end


	def make_instance_method(pos, class_sym, method_sym)
		ASSERT.kind_of pos,	L::Position
		ASSERT.kind_of class_sym,	::Symbol
		ASSERT.kind_of method_sym,	::Symbol

		Unary::Method::Instance.new(pos, class_sym, method_sym).freeze
	end

end	# Umu::AbstractSyntax::Core::Expression

end	# Umu::AbstractSyntax::Core

end	# Umu::AbstractSyntax

end	# Umu
