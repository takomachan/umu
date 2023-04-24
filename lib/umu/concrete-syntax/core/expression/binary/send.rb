require 'umu/common'
require 'umu/lexical/location'


module Umu

module ConcreteSyntax

module Core

module Expression

module Binary

module Send

module Message

class Abstract < Expression::Abstract; end



class Selector < Abstract
	attr_reader :sel_num


	def initialize(loc, sel_num)
		ASSERT.kind_of sel_num, ::Integer

		super(loc)

		@sel_num = sel_num
	end


	def to_s
		self.sel_num.to_s
	end


private

	def __desugar__(_env, _event)
		SACE.make_number_selector self.loc, self.sel_num
	end
end



class Method < Abstract
	attr_reader :sym, :param_exprs, :opnd_exprs


	def initialize(loc, sym, param_exprs, opnd_exprs)
		ASSERT.kind_of sym,			::Symbol
		ASSERT.kind_of param_exprs,	::Array
		ASSERT.kind_of opnd_exprs,	::Array

		super(loc)

		@sym			= sym
		@param_exprs	= param_exprs
		@opnd_exprs		= opnd_exprs
	end


	def to_s
		opnd_str = if self.opnd_exprs.empty?
						''
					else
						' ' + self.opnd_exprs.map(&:to_s).join(' ')
					end

		if self.param_exprs.empty?
			self.sym.to_s + opnd_str
		else
			format("(%s %s)%s",
				self.sym.to_s,
				self.param_exprs.map(&:to_s).join(', '),
				opnd_str
			)
		end
	end


private

	def __desugar__(env, event)
		new_env = env.enter event

		SACE.make_method(
			self.loc,
			self.sym,
			self.param_exprs.map { |expr| expr.desugar(new_env) },
			self.opnd_exprs.map  { |expr| expr.desugar(new_env) }
		)
	end
end

end	# Umu::ConcreteSyntax::Core::Expression::Binary::Send::Message



class Entry < Binary::Abstract
	alias		rhs_head_message rhs
	attr_reader	:rhs_tail_messages


	def initialize(loc, lhs_expr, rhs_head_message, rhs_tail_messages)
		ASSERT.kind_of lhs_expr,			SCCE::Abstract
		ASSERT.kind_of rhs_head_message,	Message::Abstract
		ASSERT.kind_of rhs_tail_messages,	::Array

		super(loc, lhs_expr, rhs_head_message)

		@rhs_tail_messages = rhs_tail_messages
	end


	def to_s
		format("(%s).%s",
				self.lhs_expr.to_s,
				self.rhs_messages.map(&:to_s).join('.')
		)
	end


	def rhs_messages
		[self.rhs_head_message] + self.rhs_tail_messages
	end


private

	def __desugar__(env, event)
		new_env = env.enter event

		SACE.make_send(
			self.loc,
			self.lhs_expr.desugar(new_env),
			self.rhs_head_message.desugar(new_env),
			self.rhs_tail_messages.map { |mess|
				ASSERT.kind_of mess, Message::Abstract

				mess.desugar(new_env)
			}
		)
	end
end

end	# Umu::ConcreteSyntax::Core::Expression::Binary::Send

end	# Umu::ConcreteSyntax::Core::Expression::Binary


module_function

	def make_selector(loc, sel_num)
		ASSERT.kind_of loc,		L::Location
		ASSERT.kind_of sel_num,	::Integer

		Binary::Send::Message::Selector.new(loc, sel_num).freeze
	end


	def make_method(loc, sym, param_exprs = [], opnd_exprs = [])
		ASSERT.kind_of loc,			L::Location
		ASSERT.kind_of sym,			::Symbol
		ASSERT.kind_of param_exprs,	::Array
		ASSERT.kind_of opnd_exprs,	::Array

		Binary::Send::Message::Method.new(
			loc, sym, param_exprs.freeze, opnd_exprs
		).freeze
	end


	def make_send(loc, lhs_expr, rhs_head_message, rhs_tail_messages = [])
		ASSERT.kind_of loc,					L::Location
		ASSERT.kind_of lhs_expr,			SCCE::Abstract
		ASSERT.kind_of rhs_head_message,	Binary::Send::Message::Abstract
		ASSERT.kind_of rhs_tail_messages,	::Array

		Binary::Send::Entry.new(
			loc, lhs_expr, rhs_head_message, rhs_tail_messages.freeze
		).freeze
	end

end	# Umu::ConcreteSyntax::Core::Expression

end	# Umu::ConcreteSyntax::Core

end	# Umu::ConcreteSyntax

end	# Umu
