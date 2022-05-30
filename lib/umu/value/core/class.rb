require 'umu/common'


module Umu

module Value

module Core

class Class < Top
	attr_reader :class_spec


	def initialize(class_spec)
		ASSERT.kind_of class_spec, ECTSC::Base

		super()

		@class_spec = class_spec
	end


	def to_s
		format "&%s", self.class_spec.to_sym
	end


private

	def __invoke__(meth_sym, loc, env, event, arg_values)
		ASSERT.kind_of meth_sym,	::Symbol
		ASSERT.kind_of loc,			L::Location
		ASSERT.kind_of env,			E::Entry
		ASSERT.kind_of event,		E::Tracer::Event
		ASSERT.kind_of arg_values,	::Array

		self.class_spec.klass.send meth_sym, loc, env, event, *arg_values
	end
end


module_function

	def make_class(class_spec)
		ASSERT.kind_of class_spec, ECTSC::Base

		Class.new(class_spec).freeze
	end

end	# Umu::Core

end	# Umu::Value

end	# Umu
