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
	attr_reader :sym, :exprs


	def initialize(loc, sym, exprs)
		ASSERT.kind_of sym,		::Symbol
		ASSERT.kind_of exprs,	::Array
		ASSERT.assert exprs.all? { |e| e.kind_of? SCCE::Abstract }

		super(loc)

		@exprs	= exprs
		@sym	= sym
	end


	def to_s
		if self.exprs.empty?
			self.sym.to_s
		else
			format("(%s %s)",
				self.sym.to_s,
				self.exprs.map(&:to_s).join(', ')
			)
		end
	end


private

	def __desugar__(env, event)
		new_env = env.enter event

		SACE.make_method(
			self.loc,
			self.sym,
			self.exprs.map { |expr| expr.desugar(new_env) }
		)
	end
end

end	# Umu::ConcreteSyntax::Core::Expression::Binary::Send::Message



class Entry < Binary::Abstract
	alias rhs_messages rhs


	def initialize(loc, lhs_expr, rhs_messages)
		ASSERT.kind_of lhs_expr,	SCCE::Abstract
		ASSERT.kind_of rhs_messages,	::Array

		super(loc, lhs_expr, rhs_messages)
	end


	def to_s
		format("(%s).%s",
				self.lhs_expr.to_s,
				self.rhs_messages.map(&:to_s).join('.')
		)
	end


private

	def __desugar__(env, event)
		new_env = env.enter event

		SACE.make_send(
			self.loc,
			self.lhs_expr.desugar(new_env),
			self.rhs_messages.map { |mess| mess.desugar(new_env) }
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


	def make_method(loc, sym, exprs)
		ASSERT.kind_of loc,		L::Location
		ASSERT.kind_of sym,		::Symbol
		ASSERT.kind_of exprs,	::Array

		Binary::Send::Message::Method.new(loc, sym, exprs.freeze).freeze
	end


	def make_send(loc, lhs_expr, rhs_messages)
		ASSERT.kind_of loc,			L::Location
		ASSERT.kind_of lhs_expr,	SCCE::Abstract
		ASSERT.kind_of rhs_messages,	::Array

		Binary::Send::Entry.new(loc, lhs_expr, rhs_messages.freeze).freeze
	end

end	# Umu::ConcreteSyntax::Core::Expression

end	# Umu::ConcreteSyntax::Core

end	# Umu::ConcreteSyntax

end	# Umu
