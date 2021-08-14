require 'umu/common'
require 'umu/environment/tracer/tracer'


module Umu

module AbstractSyntax

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

	def __evaluate__(env, _event)
		ASSERT.kind_of env, E::Entry

		value = env.va_lookup self.sym, self.pos
		ASSERT.kind_of value, VC::Top
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

	def __evaluate__(env, _event)
		ASSERT.kind_of env, E::Entry

		init_value = env.va_lookup self.head_id.sym, self.head_id.pos
		ASSERT.kind_of init_value, VCP::Record::Entry

		final_value = self.tail_ids.inject(init_value) { |value, id|
			ASSERT.kind_of value,	VCP::Record::Entry
			ASSERT.kind_of id,		Short

			value.select id.sym, id.pos, env
		}
		ASSERT.kind_of final_value, VC::Top
	end
end

class Short < Abstract


end

end	# Umu::AbstractSyntax::Core::Expression::Unary::Identifier

end	# Umu::AbstractSyntax::Core::Expression::Unary


module_function

	def make_identifier(pos, sym)
		ASSERT.kind_of pos,	L::Position
		ASSERT.kind_of sym,	::Symbol

		Unary::Identifier::Short.new(pos, sym).freeze
	end


	def make_long_identifier(pos, head_id, tail_ids)
		ASSERT.kind_of head_id,		Unary::Identifier::Short
		ASSERT.kind_of tail_ids,	::Array

		Unary::Identifier::Long.new(pos, head_id, tail_ids.freeze).freeze
	end

end	# Umu::AbstractSyntax::Core::Expression

end	# Umu::AbstractSyntax::Core

end	# Umu::AbstractSyntax

end	# Umu
