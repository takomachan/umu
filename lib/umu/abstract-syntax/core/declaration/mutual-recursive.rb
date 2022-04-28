require 'umu/common'
require 'umu/abstract-syntax/result'


module Umu

module AbstractSyntax

module Core

module Declaration

class MutualRecursive < Abstract
	attr_reader :bindings


	def initialize(pos, bindings)
		ASSERT.kind_of pos,			L::Position
		ASSERT.kind_of bindings,	::Hash

		super(pos)

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

	def make_mutual_recursive(pos, bindings)
		ASSERT.kind_of pos,			L::Position
		ASSERT.kind_of bindings,	::Hash

		MutualRecursive.new(pos, bindings.freeze).freeze
	end

end	# Umu::AbstractSyntax::Core::Declaration

end	# Umu::AbstractSyntax::Core

end	# Umu::AbstractSyntax

end	# Umu
