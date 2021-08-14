require 'umu/common'


module Umu

module ConcreteSyntax

module Core

module Pattern

class Result
	attr_reader :ident, :decls


	def initialize(ident, decls)
		ASSERT.kind_of ident,	SACE::Unary::Identifier::Short
		ASSERT.kind_of decls,	::Array
		ASSERT.assert decls.all? { |decl|
			decl.kind_of? SACD::Simple::Value
		}

		@ident	= ident
		@decls	= decls
	end


	def to_s
		format("{ident = %s, decls = [%s]}",
			self.ident.to_s,
			self.decls.map(&:to_s).join(', ')
		)
	end
end


module_function

	def make_result(ident, decls)
		ASSERT.kind_of ident,	SACE::Unary::Identifier::Short
		ASSERT.kind_of decls,	::Array

		Result.new(ident, decls.freeze).freeze
	end

end	# Umu::ConcreteSyntax::Core::Pattern

end	# Umu::ConcreteSyntax::Core

end	# Umu::ConcreteSyntax

end	# Umu
