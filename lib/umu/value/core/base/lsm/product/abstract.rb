# vim: set nu ai sw=4 ts=4 :
# coding: utf-8
# frozen_string_literal: true

require 'umu/common'
require 'umu/lexical/location'


module Umu

module Value

module Core

module Base

module LSM

module Product

class Abstract < LSM::Abstract
	include Enumerable

	attr_reader	:objs


	def initialize(objs)
		ASSERT.kind_of objs, ::Object

		super()

		@objs = objs
	end


	def arity
		self.objs.size
	end


	def each
		self.objs.each do |obj|
			yield obj
		end
	end


	def select(sel, loc, env)
		raise X::SubclassResponsibility
	end
end

end	# Umu::Value::Core::Base::LSM::Product

end	# Umu::Value::Core::Base::LSM

end	# Umu::Value::Core::Base

end	# Umu::Value::Core

end	# Umu::Value

end	# Umu
