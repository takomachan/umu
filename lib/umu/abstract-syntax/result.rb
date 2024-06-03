# vim: set nu ai sw=4 ts=4 :
# coding: utf-8
# frozen_string_literal: true

require 'umu/common'


module Umu

module AbstractSyntax

module Result

class Abstract; end


class Value < Abstract
	attr_reader :value


	def initialize(value)
		ASSERT.kind_of value, VC::Top

		@value = value
	end
end


class Environment < Abstract
	attr_reader :env


	def initialize(env)
		ASSERT.kind_of env, E::Entry

		@env = env
	end
end


module_function

	def make_value(value)
		Result::Value.new(value).freeze
	end


	def make_environment(env)
		Result::Environment.new(env).freeze
	end

end	# Umu::AbstractSyntax::Result

end	# Umu::AbstractSyntax

end	# Umu
