# vim: set nu ai sw=4 ts=4 :
# coding: utf-8
# frozen_string_literal: true

require 'umu/common'


module Umu

module Value

module Core

module Base

module Atom

class Unit < Abstract
	def to_s
		'()'
	end


	def meth_equal(_loc, _env, _event, other)
		ASSERT.kind_of other, VC::Top

		VC.make_bool other.kind_of?(self.class)
	end
end

UNIT = Unit.new(nil).freeze

end	# Umu::Core::Base::Atom

end	# Umu::Core::Base


module_function

	def make_unit
		Base::Atom::UNIT
	end

end	# Umu::Core

end	# Umu::Value

end	# Umu
