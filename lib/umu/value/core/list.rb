require 'umu/common'
require 'umu/lexical/position'


module Umu

module Value

module Core

module List

class Abstract < Top
	CLASS_METHOD_INFOS = [
		[:meth_make_nil,	self,
			:'make-nil'],
		[:meth_make_cons,	self,
			:'make-cons',	VC::Top, self]
	]


	INSTANCE_METHOD_INFOS = [
		[ :meth_nil?,	VCB::Bool,
			:nil?],
		[ :meth_cons?,	VCB::Bool,
			:cons?],
		[ :meth_cons,	self,
			:cons,		VC::Top],
		[ :meth_des,	VCP::Tuple,
			:des]
	]


	include Enumerable


	def self.meth_make_nil(env, event)
		VC.make_nil L.make_position(__FILE__, __LINE__)
	end


	def self.meth_make_cons(env, event, x, xs)
		ASSERT.kind_of x,	VC::Top
		ASSERT.kind_of xs,	List::Abstract

		VC.make_cons x.pos, x, xs
	end


	def each
		return self.to_enum unless block_given?

		xs = self
		until xs.nil?
			begin
				yield xs.head
			rescue StopIteration
				break
			end

			xs = xs.tail
		end

		nil
	end


	def to_s
		format "[%s]", self.map(&:to_s).join(', ')
	end


	def nil?
		raise X::SubclassResponsibility
	end


	def meth_to_string(env, event)
		VC.make_string(
			self.pos,

			format("[%s]",
				self.map { |elem|
					elem.meth_to_string(env, event).val
				}.join(', ')
			)
		)
	end


	def meth_nil?(_env, _event)
		raise X::SubclassResponsibility
	end


	def meth_cons?(_env, _event)
		raise X::SubclassResponsibility
	end


	def meth_cons(_env, _event, value)
		ASSERT.kind_of value, VC::Top

		VC.make_cons self.pos, value, self
	end


	def meth_des(_env, _event)
		raise X::SubclassResponsibility
	end
end



class Nil < Abstract
	def nil?
		true
	end


	def meth_nil?(_env, _event)
		VC.make_true self.pos
	end


	def meth_cons?(_env, _event)
		VC.make_false self.pos
	end


	def meth_des(env, _event)
		raise X::EmptyError.new(
				self.pos,
				env,
				"Empty error on des(truct) operation"
			)
	end
end



class Cons < Abstract
	attr_reader :head, :tail


	def initialize(pos, head, tail)
		ASSERT.kind_of head,	VC::Top
		ASSERT.kind_of tail,	List::Abstract

		super(pos)

		@head	= head
		@tail	= tail
	end


	def nil?
		false
	end


	def meth_nil?(_env, _event)
		VC.make_false self.pos
	end


	def meth_cons?(_env, _event)
		VC.make_true self.pos
	end


	def meth_des(_env, _event)
		VC.make_tuple(self.pos, [self.head, self.tail])
	end
end

end	# Umu::Value::Core::List


module_function

	def make_nil(pos)
		ASSERT.kind_of pos, L::Position

		List::Nil.new(pos).freeze
	end


	def make_cons(pos, head, tail)
		ASSERT.kind_of pos,		L::Position
		ASSERT.kind_of head,	VC::Top
		ASSERT.kind_of tail,	List::Abstract

		List::Cons.new(pos, head, tail).freeze
	end

end	# Umu::Value::Core

end	# Umu::Value

end	# Umu
