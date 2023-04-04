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


	def initialize(loc, class_sym, method_sym)
		ASSERT.kind_of class_sym,	::Symbol
		ASSERT.kind_of method_sym,	::Symbol

		super(loc, class_sym)

		@method_sym = method_sym
	end
end



class Class < Abstract
	def to_s
		format "&(%s.%s)", self.class_sym, self.method_sym
	end


	def __evaluate__(env, _event)
		class_spec = env.ty_lookup self.class_sym, self.loc
		ASSERT.kind_of class_spec, ECTSC::Base

		method_spec = class_spec.lookup_class_method(
										self.method_sym, self.loc, env
									)
		ASSERT.kind_of method_spec, ECTS::Method

		if method_spec.param_class_specs.empty?
			VC.make_unary_class_method	class_spec, self.method_sym
		else
			VC.make_nary_class_method	class_spec, self.method_sym
		end
	end
end



class Instance < Abstract
	def to_s
		format "&(%s$%s)", self.class_sym, self.method_sym
	end


	def __evaluate__(env, _event)
		class_spec = env.ty_lookup self.class_sym, self.loc
		ASSERT.kind_of class_spec, ECTSC::Base

		method_spec = class_spec.lookup_instance_method(
										self.method_sym, self.loc, env
									)
		ASSERT.kind_of method_spec, ECTS::Method

		VC.make_instance_method class_spec, self.method_sym
	end
end

end # Umu::AbstractSyntax::Core::Expression::Unary::Method

end # Umu::AbstractSyntax::Core::Expression::Unary


module_function

	def make_class_method(loc, class_sym, method_sym)
		ASSERT.kind_of loc,	L::Location
		ASSERT.kind_of class_sym,	::Symbol
		ASSERT.kind_of method_sym,	::Symbol

		Unary::Method::Class.new(loc, class_sym, method_sym).freeze
	end


	def make_instance_method(loc, class_sym, method_sym)
		ASSERT.kind_of loc,	L::Location
		ASSERT.kind_of class_sym,	::Symbol
		ASSERT.kind_of method_sym,	::Symbol

		Unary::Method::Instance.new(loc, class_sym, method_sym).freeze
	end

end	# Umu::AbstractSyntax::Core::Expression

end	# Umu::AbstractSyntax::Core

end	# Umu::AbstractSyntax

end	# Umu
