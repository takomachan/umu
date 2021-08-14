require 'umu/common'


module Umu

module Value

module Core

class Unit < Top
	def to_s
		'()'
	end


	def meth_equal(env, _event, other)
		ASSERT.kind_of other, VC::Top

		VC.make_bool self.pos, other.kind_of?(self.class)
	end
end


module_function

	def make_unit(pos)
		ASSERT.kind_of pos, L::Position

		Unit.new(pos).freeze
	end

end	# Umu::Core

end	# Umu::Value

end	# Umu
