require 'umu/common'


module Umu

module ConcreteSyntax

module Core

module Pattern

class Result
	attr_reader :ident, :decls, :opt_type_sym


	def initialize(ident, decls, opt_type_sym)
		ASSERT.kind_of		ident,			SACEU::Identifier::Short
		ASSERT.kind_of		decls,			::Array
		ASSERT.opt_kind_of	opt_type_sym,	::Symbol
		ASSERT.assert decls.all? { |decl|
			decl.kind_of? SACD::Simple::Value
		}

		@ident			= ident
		@decls			= decls
		@opt_type_sym	= opt_type_sym
	end


	def to_s
		format("{ident = %s%s, decls = [%s]}",
			self.ident.to_s,

			if self.opt_type_sym
				format " : %s", self.opt_type_sym
			else
				''
			end,

			self.decls.map(&:to_s).join(', ')
		)
	end
end


module_function

	def make_result(ident, decls, opt_type_sym = nil)
		ASSERT.kind_of		ident,			SACEU::Identifier::Short
		ASSERT.kind_of		decls,			::Array
		ASSERT.opt_kind_of	opt_type_sym,	::Symbol

		Result.new(ident, decls.freeze, opt_type_sym).freeze
	end

end	# Umu::ConcreteSyntax::Core::Pattern

end	# Umu::ConcreteSyntax::Core

end	# Umu::ConcreteSyntax

end	# Umu
