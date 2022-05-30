require 'umu/common'
require 'umu/lexical/location'


module Umu

module Value

module Core

module Product

class Abstract < Top
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

end	# Umu::Value::Core::Product

end	# Umu::Value::Core

end	# Umu::Value

end	# Umu
