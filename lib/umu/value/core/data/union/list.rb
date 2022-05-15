require 'umu/common'
require 'umu/lexical/position'


module Umu

module Value

module Core

module Data

module Union

module List

class Abstract < Union::Abstract
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


	def self.meth_make_nil(_pos, _env, _event)
		VC.make_nil
	end


	def self.meth_make_cons(_pos, _env, _event, x, xs)
		ASSERT.kind_of x,	VC::Top
		ASSERT.kind_of xs,	List::Abstract

		VC.make_cons x, xs
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


	def meth_to_string(pos, env, event)
		VC.make_string(
			format("[%s]",
				self.map { |elem|
					elem.meth_to_string(pos, env, event).val
				}.join(', ')
			)
		)
	end


	def meth_nil?(_pos, _env, _event)
		VC.make_false
	end


	def meth_cons?(_pos, _env, _event)
		VC.make_false
	end


	def meth_cons(_pos, _env, _event, value)
		ASSERT.kind_of value, VC::Top

		VC.make_cons value, self
	end


	def meth_des(_pos, _env, _event)
		raise X::SubclassResponsibility
	end
end



class Nil < Abstract
	INSTANCE_METHOD_INFOS = [
		[:meth_contents,	VC::Unit,
			:contents]
	]


	def nil?
		true
	end


	def meth_nil?(_pos, _env, _event)
		VC.make_true
	end


	def meth_des(pos, env, _event)
		raise X::EmptyError.new(
				pos,
				env,
				"Empty error on des(truct) operation"
			)
	end
end



class Cons < Abstract
	INSTANCE_METHOD_INFOS = [
		[:meth_contents,	VCP::Tuple,
			:contents]
	]


	attr_reader :head, :tail


	def initialize(head, tail)
		ASSERT.kind_of head,	VC::Top
		ASSERT.kind_of tail,	List::Abstract

		super()

		@head	= head
		@tail	= tail
	end


	def nil?
		false
	end


	def meth_cons?(_pos, _env, _event)
		VC.make_true
	end


	def meth_des(_pos, _env, _event)
		VC.make_tuple [self.head, self.tail]
	end


	alias meth_contents meth_des
end

end	# Umu::Value::Core::Data::Union::List

end	# Umu::Value::Core::Data::Union

end	# Umu::Value::Core::Data


module_function

	def make_nil
		Data::Union::List::Nil.new.freeze
	end


	def make_cons(head, tail)
		ASSERT.kind_of head,	VC::Top
		ASSERT.kind_of tail,	Data::Union::List::Abstract

		Data::Union::List::Cons.new(head, tail).freeze
	end

end	# Umu::Value::Core

end	# Umu::Value

end	# Umu
