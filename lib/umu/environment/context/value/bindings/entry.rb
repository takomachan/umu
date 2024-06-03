# vim: set nu ai sw=4 ts=4 :
# coding: utf-8
# frozen_string_literal: true

require 'umu/common'
require 'umu/value'


module Umu

module Environment

module Context

module Value

module Bindings

class Entry < Abstract
	attr_reader	:bindings
	attr_reader	:old_context


	def initialize(bindings, old_context)
		ASSERT.kind_of bindings,	::Hash
		ASSERT.kind_of old_context,	ECV::Abstract

		@bindings		= bindings
		@old_context	= old_context
	end


private

	def __extend__(sym, target)
		ASSERT.kind_of sym,		::Symbol
		ASSERT.kind_of target,	Bindings::Target::Abstract

		if self.bindings.has_key? sym
			[{sym => target},						self]
		else
			[self.bindings.merge(sym => target),	self.old_context]
		end
	end
end

end # Umu::Environment::Context::Value::Bindings



module_function

	def make_bindings(bindings, old_context)
		ASSERT.kind_of bindings,	::Hash
		ASSERT.kind_of old_context,	ECV::Abstract

		Bindings::Entry.new(bindings.freeze, old_context).freeze
	end

end	# Umu::Environment::Context::Value

end	# Umu::Environment::Context

end	# Umu::Environment

end	# Umu
