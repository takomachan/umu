require 'umu/common'
require 'umu/lexical/location'


module Umu

module ConcreteSyntax

module Core

module Expression

module Nary

module Rule

module Abstraction

class Abstract < Umu::Abstraction::Model
	attr_reader :head, :body_expr


	def initialize(loc, head, body_expr)
		ASSERT.kind_of head,		Umu::Abstraction::Model
		ASSERT.kind_of body_expr,	SCCE::Abstract

		super(loc)

		@head		= head
		@body_expr	= body_expr
	end
end

class WithDeclaration < Abstract
	attr_reader :decls


	def initialize(loc, head, body_expr, decls)
		ASSERT.kind_of head,		Umu::Abstraction::Model
		ASSERT.kind_of body_expr,	SCCE::Abstract
		ASSERT.kind_of decls,		::Array

		super(loc, head, body_expr)

		@decls = decls
	end


	def to_s
		format("%s -> %s%s",
				self.head.to_s,

				self.body_expr.to_s,

				if self.decls.empty?
					''
				else
					format " %%WHERE %s", self.decls.map(&:to_s).join(' ')
				end
		)
	end
end

end


class If < Abstraction::Abstract
	alias head_expr head

	def initialize(loc, head_expr, body_expr)
		ASSERT.kind_of head_expr, SCCE::Abstract

		super
	end


	def to_s
		format "%s %s", self.head_expr, self.body_expr
	end
end


class Cond < Abstraction::WithDeclaration
	alias head_expr head

	def initialize(loc, head_expr, body_expr, decls)
		ASSERT.kind_of head_expr, SCCE::Abstract

		super
	end
end


module Case

module Head

class Abstract < Umu::Abstraction::Model
	attr_reader :obj


	def initialize(loc, obj)
		ASSERT.kind_of obj, ::Object

		super(loc)

		@obj = obj
	end


	def to_s
		self.obj.to_s
	end


	def type_sym
		raise X::SubclassResponsibility
	end
end


class Atom < Abstract
	alias atom_expr obj


	def initialize(loc, atom_expr)
		ASSERT.kind_of atom_expr, SCCE::Unary::Atom::Abstract

		super
	end


	def type_sym
		:Atom
	end
end


class Datum < Abstract
	alias tag_sym obj


	def initialize(loc, tag_sym)
		ASSERT.kind_of tag_sym, ::Symbol

		super
	end


	def type_sym
		:Datum
	end
end

end	# Umu::ConcreteSyntax::Core::Expression::Nary::Rule::Case::Head


class Entry < Abstraction::WithDeclaration; end

end	# Umu::ConcreteSyntax::Core::Expression::Nary::Rule::Case

end	# Umu::ConcreteSyntax::Core::Expression::Nary::Rule

end	# Umu::ConcreteSyntax::Core::Expression::Nary


module_function

	def make_if_rule(loc, head_expr, body_expr)
		ASSERT.kind_of loc,			L::Location
		ASSERT.kind_of head_expr,	SCCE::Abstract
		ASSERT.kind_of body_expr,	SCCE::Abstract

		Nary::Rule::If.new(
			loc, head_expr, body_expr
		).freeze
	end


	def make_cond_rule(loc, head_expr, body_expr, decls)
		ASSERT.kind_of loc,			L::Location
		ASSERT.kind_of head_expr,	SCCE::Abstract
		ASSERT.kind_of body_expr,	SCCE::Abstract
		ASSERT.kind_of decls,		::Array

		Nary::Rule::Cond.new(
			loc, head_expr, body_expr, decls.freeze
		).freeze
	end


	def make_case_rule(loc, head, body_expr, decls)
		ASSERT.kind_of loc,			L::Location
		ASSERT.kind_of head,		SCCE::Nary::Rule::Case::Head::Abstract
		ASSERT.kind_of body_expr,	SCCE::Abstract
		ASSERT.kind_of decls,		::Array

		Nary::Rule::Case::Entry.new(
			loc, head, body_expr, decls.freeze
		).freeze
	end


	def make_case_rule_atom(loc, atom_expr)
		ASSERT.kind_of loc,			L::Location
		ASSERT.kind_of atom_expr,	SCCE::Unary::Atom::Abstract

		Nary::Rule::Case::Head::Atom.new(loc, atom_expr).freeze
	end


	def make_case_rule_datum(loc, tag_sym)
		ASSERT.kind_of loc,		L::Location
		ASSERT.kind_of tag_sym,	::Symbol

		Nary::Rule::Case::Head::Datum.new(loc, tag_sym).freeze
	end

end	# Umu::ConcreteSyntax::Core::Expression

end	# Umu::ConcreteSyntax::Core

end	# Umu::ConcreteSyntax

end	# Umu
