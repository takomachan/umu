require 'umu/common'
require 'umu/lexical/position'

require 'umu/concrete-syntax/module/expression/abstract'



module Umu

module ConcreteSyntax

module Module

module Expression

class Struct < Expression::Abstract
	attr_reader :body_decls, :local_decls


	def initialize(pos, body_decls, local_decls)
		ASSERT.kind_of body_decls,	::Array
		ASSERT.kind_of local_decls,	::Array

		super(pos)

		@body_decls		= body_decls
		@local_decls	= local_decls
	end


	def to_s
		format("struct {%s}%s",
			if self.body_decls.empty?
				' '
			else
				self.body_decls.map(&:to_s).join(' ')
			end,

			if self.local_decls.empty?
				''
			else
				format " where {%s}", self.local_decls.map(&:to_s).join(' ')
			end
		)
	end


private

	def __desugar__(env, event)
		expr_by_label = (
			self.body_decls.inject([]) {
				|array, decl|
				ASSERT.kind_of array,	::Array
				ASSERT.kind_of decl,	Declaration::Abstract

				array + decl.exported_vars
			}.inject({}) { |hash, vpat|
				ASSERT.kind_of hash,	::Hash
				ASSERT.kind_of vpat,	SCCP::Variable

				label = vpat.var_sym
				expr  = SACE.make_identifier(vpat.pos, vpat.var_sym)

				hash.merge(label => expr) { |_lab, _old_expr, new_expr|
					new_expr
				}
			}
		)

		struct_expr	= SACE.make_struct self.pos, expr_by_label
		decls		= self.local_decls + self.body_decls

		if decls.empty?
			struct_expr
		else
			new_env = env.enter event

			SACE.make_let(
				self.pos,
				decls.map { |decl| decl.desugar new_env },
				struct_expr
			)
		end
	end
end


module_function

	def make_struct(pos, body_decls, local_decls)
		ASSERT.kind_of pos,			L::Position
		ASSERT.kind_of body_decls,	::Array
		ASSERT.kind_of local_decls,	::Array

		Struct.new(
			pos, body_decls.freeze, local_decls.freeze
		).freeze
	end

end	# Umu::ConcreteSyntax::Module::Expression

end	# Umu::ConcreteSyntax::Module

end	# Umu::ConcreteSyntax

end	# Umu
