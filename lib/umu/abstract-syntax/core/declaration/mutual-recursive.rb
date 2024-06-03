# vim: set nu ai sw=4 ts=4 :
# coding: utf-8
# frozen_string_literal: true

require 'umu/common'
require 'umu/abstract-syntax/result'


module Umu

module AbstractSyntax

module Core

module Declaration

class MutualRecursive < Abstract
	attr_reader :bindings


	def initialize(loc, bindings)
		ASSERT.kind_of loc,			L::Location
		ASSERT.kind_of bindings,	::Hash

		super(loc)

		@bindings = bindings
	end


	def to_s
		format(
			"%%VAL %%REC %s",
			self.bindings.map { |sym, binding|
				format "%s = %s", sym.to_s, binding.lam_expr.to_s
			}.join(' and ')
		)
	end


private

	def __evaluate__(env)
		ASSERT.kind_of env, E::Entry

		env.va_extend_mutual_recursive self.bindings
	end
end



module_function

	def make_mutual_recursive(loc, bindings)
		ASSERT.kind_of loc,			L::Location
		ASSERT.kind_of bindings,	::Hash

		MutualRecursive.new(loc, bindings.freeze).freeze
	end

end	# Umu::AbstractSyntax::Core::Declaration

end	# Umu::AbstractSyntax::Core

end	# Umu::AbstractSyntax

end	# Umu
