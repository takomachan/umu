require 'umu/common'
require 'umu/lexical/location'


module Umu

module ConcreteSyntax

module Core

module Declaration

class Recursive < Declaration::Abstract
	attr_reader :functions


	def initialize(loc, functions)
		ASSERT.kind_of functions, ::Array

		super(loc)

		@functions = functions
	end


	def to_s
		format("%%FUN rec %s",
			self.functions.map(&:to_s).join(' %%AND ')
		)
	end


	def exported_vars
		self.functions.inject([]) { |array, function|
			ASSERT.kind_of array,		::Array
			ASSERT.kind_of function,	Function::Abstract

			array + function.exported_vars
		}.freeze
	end


private

	def __desugar__(env, event)
		new_env = env.enter event

		case self.functions.size
		when 0
			ASSERT.abort self.inspect
		when 1
			function = self.functions[0]
			ASSERT.kind_of function, Function::Abstract

			SACD.make_recursive(
				function.loc,
				function.lam_expr.sym,
				function.lam_expr.desugar(new_env)
			)
		else
			functions = self.functions.inject({}) {
				|hash, function|
				ASSERT.kind_of hash,		::Hash
				ASSERT.kind_of function,	Function::Abstract

				hash.merge(
					function.lam_expr.sym => ECV::Bindings.make_recursive(
						function.lam_expr.desugar(new_env)
					)
				) {
					raise X::SyntaxError.new(
						function.loc,
						"In mutual recursion, duplicated variable: '%s'",
												function.lam_expr.sym.to_s
					)
				}
			}

			SACD.make_mutual_recursive self.loc, functions
		end
	end
end



module_function

	def make_recursive(loc, functions)
		ASSERT.kind_of loc,			L::Location
		ASSERT.kind_of functions,	::Array

		Recursive.new(loc, functions.freeze).freeze
	end

end	# Umu::ConcreteSyntax::Core::Declaration

end	# Umu::ConcreteSyntax::Core

end	# Umu::ConcreteSyntax

end	# Umu
