require 'umu/common'
require 'umu/lexical/location'

require_relative 'abstract'



module Umu

module ConcreteSyntax

module Module

module Expression

module Identifier

class Abstract < Expression::Abstract; end



class Short < Abstract
	attr_reader :sym


	def initialize(loc, sym)
		ASSERT.kind_of sym, ::Symbol

		super(loc)

		@sym = sym
	end


	def to_s
		self.sym.to_s
	end


private

	def __desugar__(_env, _event)
		ASCE.make_identifier self.loc, self.sym
	end
end



class Long < Abstract
	attr_reader :head_id, :tail_ids


	def initialize(loc, head_id, tail_ids)
		ASSERT.kind_of head_id,		Short
		ASSERT.kind_of tail_ids,	::Array

		super(loc)

		@head_id	= head_id
		@tail_ids	= tail_ids
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

		ASCE.make_long_identifier(
			loc,
			self.head_id.desugar(new_env),
			self.tail_ids.map { |id| id.desugar new_env }
		)
	end
end

end	# Umu::ConcreteSyntax::Core::Expression::Identifier


module_function

	def make_identifier(loc, sym)
		ASSERT.kind_of loc,	L::Location
		ASSERT.kind_of sym, ::Symbol

		Identifier::Short.new(loc, sym).freeze
	end


	def make_long_identifier(loc, head_id, tail_ids)
		ASSERT.kind_of head_id,		Identifier::Short
		ASSERT.kind_of tail_ids,	::Array

		Identifier::Long.new(loc, head_id, tail_ids.freeze).freeze
	end

end	# Umu::ConcreteSyntax::Module::Expression

end	# Umu::ConcreteSyntax::Module

end	# Umu::ConcreteSyntax

end	# Umu
