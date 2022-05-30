require 'umu/common'
require 'umu/abstract-syntax/result'


module Umu

module AbstractSyntax

module Core

module Declaration

class Declarations < Abstract
	attr_reader :decls


	def initialize(loc, decls)
		ASSERT.kind_of loc,		L::Location
		ASSERT.kind_of decls,	::Array

		super(loc)

		@decls = decls
	end


	def to_s
		format "{ %s }", self.decls.map(&:to_s).join(' ')
	end


private

	def __evaluate__(old_env)
		ASSERT.kind_of old_env, E::Entry

		new_env = self.decls.inject(old_env) { |env, decl|
			ASSERT.kind_of env,		E::Entry
			ASSERT.kind_of decl,	SACD::Abstract

			result = decl.evaluate env
			ASSERT.kind_of result, SAR::Environment

			result.env
		}

		ASSERT.kind_of new_env, E::Entry
	end
end



module_function

	def make_declarations(loc, decls)
		ASSERT.kind_of loc,		L::Location
		ASSERT.kind_of decls,	::Array

		Declarations.new(loc, decls.freeze).freeze
	end

end	# Umu::AbstractSyntax::Core::Declaration

end	# Umu::AbstractSyntax::Core

end	# Umu::AbstractSyntax

end	# Umu
