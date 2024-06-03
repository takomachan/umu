# vim: set nu ai sw=4 ts=4 :
# coding: utf-8
# frozen_string_literal: true

require 'umu/common'


module Umu

module Environment

module Context

module Type

module Specification

class SetOfClass < Abstraction::Collection
	attr_reader :hash


	def initialize(specs)
		ASSERT.kind_of specs, ::Array

		@hash = specs.inject({}) { |hash, spec|
			ASSERT.kind_of spec, ECTSC::Base

			hash.merge(spec => true) {
				ASSERT.abort(
					"Duplicated a class specification: %s", spec.inspect
				)
			}
		}.freeze
	end

	def empty?
		self.hash.empty?
	end


	def member?(spec)
		ASSERT.kind_of spec, ECTSC::Base

		self.hash.has_key? spec
	end


	def each
		self.hash.each_key do |spec|
			yield spec
		end
	end


	def union(other)
		ASSERT.kind_of other, SetOfClass

		SetOfClass.new(
			self.hash.merge(other.hash) { |spec, _, _|
				ASSERT.abort(
					"Duplicated a class specification: %s", spec.inspect
				)
			}.keys.freeze
		).freeze
	end
end



module_function

	def make_set(specs)
		ASSERT.kind_of specs, ::Array

		SetOfClass.new(specs.freeze).freeze
	end

EMPTY_SET = make_set([])

end	# Umu::Environment::Context::Type::Specification

end	# Umu::Environment::Context::Type

end	# Umu::Environment::Context

end	# Umu::Environment

end	# Umu
