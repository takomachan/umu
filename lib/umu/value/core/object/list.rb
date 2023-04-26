require 'umu/common'
require 'umu/lexical/location'


module Umu

module Value

module Core

module Object

module List

class Abstract < Object::Abstract
	INSTANCE_METHOD_INFOS = [
		[ :meth_nil?,	VCA::Bool,
			:nil?],
		[ :meth_cons?,	VCA::Bool,
			:cons?],
		[ :meth_cons,	self,
			:cons,		VC::Top],
		[ :meth_des,	VCP::Tuple,
			:des],
		[ :meth_map,	self,
			:map,		VC::Function]
	]


	include Enumerable


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


	def meth_to_string(loc, env, event)
		VC.make_string(
			format("[%s]",
				self.map { |elem|
					elem.meth_to_string(loc, env, event).val
				}.join(', ')
			)
		)
	end


	def meth_nil?(_loc, _env, _event)
		VC.make_false
	end


	def meth_cons?(_loc, _env, _event)
		VC.make_false
	end


	def meth_cons(_loc, _env, _event, value)
		ASSERT.kind_of value, VC::Top

		VC.make_cons value, self
	end


	def meth_des(_loc, _env, _event)
		raise X::SubclassResponsibility
	end


	def meth_map(loc, env, event, func)
		ASSERT.kind_of func, VC::Function

		new_env = env.enter event
		ys = []
		self.each do |x|
			ASSERT.kind_of x, VC::Top

			ys.unshift func.apply(x, [], loc, new_env)
		end

		result_value = ys.inject(VC.make_nil) { |zs, y| VC.make_cons y, zs }
		ASSERT.kind_of result_value, List::Abstract
	end
end



class Nil < Abstract
	CLASS_METHOD_INFOS = [
		[:meth_make,		self,
			:'make'],
	]

	INSTANCE_METHOD_INFOS = [
		[:meth_contents,	VC::Unit,
			:contents]
	]


	def self.meth_make(_loc, _env, _event)
		VC.make_nil
	end


	def nil?
		true
	end


	def meth_nil?(_loc, _env, _event)
		VC.make_true
	end


	def meth_des(loc, env, _event)
		raise X::EmptyError.new(
				loc,
				env,
				"Empty error on des(truct) operation"
			)
	end
end

NIL = Nil.new.freeze



class Cons < Abstract
	CLASS_METHOD_INFOS = [
		[:meth_make,		self,
			:'make',		VC::Top, List::Abstract]
	]

	INSTANCE_METHOD_INFOS = [
		[:meth_contents,	VCP::Tuple,
			:contents],
		[ :meth_head,		VC::Top,
			:head],
		[ :meth_tail,		List::Abstract,
			:tail]
	]


	def self.meth_make(_loc, _env, _event, x, xs)
		ASSERT.kind_of x,	VC::Top
		ASSERT.kind_of xs,	List::Abstract

		VC.make_cons x, xs
	end


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


	def meth_cons?(_loc, _env, _event)
		VC.make_true
	end


	def meth_des(_loc, _env, _event)
		VC.make_tuple [self.head, self.tail]
	end


	alias meth_contents meth_des


	def meth_head(_loc, _env, _event)
		self.head
	end


	def meth_tail(_loc, _env, _event)
		self.tail
	end
end

end	# Umu::Value::Core::Object::List

end	# Umu::Value::Core::Object


module_function

	def make_nil
		Object::List::NIL
	end


	def make_cons(head, tail)
		ASSERT.kind_of head,	VC::Top
		ASSERT.kind_of tail,	Object::List::Abstract

		Object::List::Cons.new(head, tail).freeze
	end

end	# Umu::Value::Core

end	# Umu::Value

end	# Umu
