require 'umu/common'


module Umu

module ConcreteSyntax

module Core

module Pattern

module Container

class Tuple < Abstraction::Abstract
	alias pats array


	def initialize(pos, pats)
		ASSERT.kind_of	pats, ::Array
		ASSERT.assert	pats.size >= 2

		pats.reject(&:wildcard?).inject({}) do |hash, vpat|
			ASSERT.kind_of vpat,	Variable
			ASSERT.kind_of hash,	::Hash

			hash.merge(vpat.var_sym => true) { |key, _, _|
				raise X::SyntaxError.new(
					pos,
					"Duplicated pattern variable: '%s'", key.to_s
				)
			}
		end

		super
	end


	def to_s
		format "(%s)", self.map(&:to_s).join(', ')
	end


	def exported_vars
		self.reject(&:wildcard).inject([]) { |array, vpat|
			ASSERT.kind_of array,	::Array
			ASSERT.kind_of vpat,	Variable

			array + vpat.exported_vars
		}.freeze
	end


private

	def __desugar_value__(expr, env, _event)
		ASSERT.kind_of expr, SACE::Abstract

		SACD.make_declarations(
			self.pos,
			[
				SACD.make_value(self.pos, :'%t', expr)
			] + (
				__desugar__(:'%t', env)
			)
		)
	end


	def __desugar_lambda__(seq_num, env, _event)
		ASSERT.kind_of seq_num, ::Integer

		var_sym = __gen_sym__ seq_num

		SCCP.make_result(
			SACE.make_identifier(self.pos, var_sym),
			__desugar__(var_sym, env)
		)
	end


	def __desugar__(var_sym, _env)
		self.each_with_index.reject { |vpat, _index|
			ASSERT.kind_of vpat, Variable

			vpat.wildcard?
		}.map { |vpat, index|
			ASSERT.kind_of vpat,	Variable
			ASSERT.kind_of index,	::Integer

			expr = SACE.make_send(
						vpat.pos,
						SACE.make_identifier(vpat.pos, var_sym),
						[SACE.make_number_selector(vpat.pos, index + 1)]
					)

			SACD.make_value vpat.pos, vpat.var_sym, expr
		}
	end
end

end	# Umu::ConcreteSyntax::Core::Pattern::Container


module_function

	def make_tuple(pos, pats)
		ASSERT.kind_of pos,		L::Position
		ASSERT.kind_of pats,	::Array

		Container::Tuple.new(pos, pats.freeze).freeze
	end

end	# Umu::ConcreteSyntax::Core::Pattern

end	# Umu::ConcreteSyntax::Core

end	# Umu::ConcreteSyntax

end	# Umu