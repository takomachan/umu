require 'umu/common'
require 'umu/lexical/position'


module Umu

module ConcreteSyntax

module Core

module Expression

module Unary

module Identifier

class Abstract < Unary::Abstract; end



class Short < Abstract
	alias sym obj


	def initialize(pos, sym)
		ASSERT.kind_of sym, ::Symbol

		super
	end


	def to_s
		self.sym.to_s
	end


private

	def __desugar__(_env, _event)
		SACE.make_identifier self.pos, self.sym
	end
end



class Long < Abstract
	alias		head_id obj
	attr_reader	:tail_ids


	def initialize(pos, head_id, tail_ids)
		ASSERT.kind_of head_id,		Short
		ASSERT.kind_of tail_ids,	::Array

		super(pos, head_id)

		@tail_ids = tail_ids
	end


	def to_s
		if tail_ids.empty?
			self.head_id.to_s
		else
			format("%s::%s",
				self.head_id.to_s,
				self.tail_ids.map(&:to_s).join('::')
			)
		end
	end


private

	def __desugar__(env, event)
		new_env = env.enter event

		if tail_ids.empty?
			self.head_id.desugar(new_env)
		else
			SACE.make_long_identifier(
				pos,
				self.head_id.desugar(new_env),
				self.tail_ids.map { |id| id.desugar(new_env) }
			)
		end
	end
end

end	# Umu::ConcreteSyntax::Core::Expression::Unary::Identifier

end	# Umu::ConcreteSyntax::Core::Expression::Unary


module_function

	def make_identifier(pos, sym)
		ASSERT.kind_of pos,	L::Position
		ASSERT.kind_of sym, ::Symbol

		Unary::Identifier::Short.new(pos, sym).freeze
	end


	def make_long_identifier(pos, head_id, tail_ids)
		ASSERT.kind_of head_id,		Unary::Identifier::Short
		ASSERT.kind_of tail_ids,	::Array

		Unary::Identifier::Long.new(pos, head_id, tail_ids.freeze).freeze
	end

end	# Umu::ConcreteSyntax::Core::Expression

end	# Umu::ConcreteSyntax::Core

end	# Umu::ConcreteSyntax

end	# Umu
