require 'umu/common'
require 'umu/lexical/location'


module Umu

module Value

module Core

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

end	# Umu::Value::Core::LSM::Product

end	# Umu::Value::Core::LSM

end	# Umu::Value::Core

end	# Umu::Value

end	# Umu
