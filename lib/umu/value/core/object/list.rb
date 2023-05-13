require 'umu/common'
require 'umu/lexical/location'


module Umu

module Value

module Core

module Object

module List

class Abstract < Object::Abstract
	INSTANCE_METHOD_INFOS = [
		[ :meth_nil?,		VCA::Bool,
			:nil?],
		[ :meth_cons?,		VCA::Bool,
			:cons?],
		[ :meth_cons,		self,
			:cons,			VC::Top],
		[ :meth_foldr,		VC::Top,
			:foldr,			VC::Top, VC::Function],
		[ :meth_foldl,		VC::Top,
			:foldl,			VC::Top, VC::Function],
		[ :meth_map,		self,
			:map,			VC::Function],
		[ :meth_filter,		self,
			:filter,		VC::Function],
		[ :meth_append,		self,
			:append,		self],
		[ :meth_concat,		self,
			:concat],
		[ :meth_zip,		self,
			:zip,			self],
		[ :meth_unzip,		VCP::Tuple,
			:unzip],
		[ :meth_partition,	VCP::Tuple,
			:partition,		VC::Function],
		[ :meth_sort,		self,
			:sort]
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


	def meth_foldr(loc, env, event, init, func)
		ASSERT.kind_of init,	VC::Top
		ASSERT.kind_of func,	VC::Function

		new_env = env.enter event

		result_value = self.reverse_each.inject(init) { |acc, x|
			func.apply x, [acc], loc, new_env
		}

		ASSERT.kind_of result_value, VC::Top
	end


	def meth_foldl(loc, env, event, init, func)
		ASSERT.kind_of init,	VC::Top
		ASSERT.kind_of func,	VC::Function

		new_env = env.enter event

		result_value = self.inject(init) { |acc, x|
			func.apply x, [acc], loc, new_env
		}

		ASSERT.kind_of result_value, VC::Top
	end


	def meth_map(loc, env, event, func)
		ASSERT.kind_of func, VC::Function

		new_env = env.enter event

		ys = self.map { |x| func.apply x, [], loc, new_env }

		VC.make_list ys
	end


	def meth_filter(loc, env, event, func)
		ASSERT.kind_of func, VC::Function

		new_env = env.enter event

		ys = self.select { |x|
			value = func.apply x, [], loc, new_env
			ASSERT.kind_of value, VC::Top

			unless value.kind_of? VCA::Bool
				raise X::TypeError.new(
					loc,
					env,
					"filter: expected a Bool, but %s : %s",
					value.to_s,
					value.type_sym.to_s
				)
			end

			value.true?
		}

		VC.make_list ys
	end


	def meth_append(_loc, _env, _event, ys)
		ASSERT.kind_of ys, List::Abstract

		result_value = self.reverse_each.inject(ys) { |zs, x|
			VC.make_cons x, zs
		}

		ASSERT.kind_of result_value, List::Abstract
	end


	def meth_concat(loc, env, event)
		result_value = self.inject(VC.make_nil) { |xss, xs|
			ASSERT.kind_of xs, VC::Top

			unless xs.kind_of? List::Abstract
				raise X::TypeError.new(
					loc,
					env,
					"concat: expected a List, but %s : %s",
					xs.to_s,
					xs.type_sym.to_s
				)
			end

			xss.meth_append loc, env, event, xs
		}

		ASSERT.kind_of result_value, List::Abstract
	end


	def meth_zip(loc, env, event, ys)
		ASSERT.kind_of ys, List::Abstract

		result_value = self.zip(ys).reverse_each.inject(VC.make_nil) {
			|zs, (x, y)|

			if x.kind_of?(VC::Top) && y.kind_of?(VC::Top)
				VC.make_cons VC.make_tuple([x, y]), zs
			else
				zs
			end
		}
		ASSERT.kind_of result_value, List::Abstract
	end


	def meth_unzip(loc, env, event)
		result_value = self.reverse_each.inject(
			VC.make_tuple([VC.make_nil, VC.make_nil])
		) { |ys_zs, y_z|
			ASSERT.kind_of y_z, VC::Top

			unless y_z.kind_of? VCP::Tuple
				raise X::TypeError.new(
					loc,
					env,
					"unzip: expected a Tuple, but %s : %s",
					pair.to_s,
					pair.type_sym.to_s
				)
			end

			VC.make_tuple(
				[
					VC.make_cons(
						y_z.select(  1, loc, env),
						ys_zs.select(1, loc, env)
					),

					VC.make_cons(
						y_z.select(  2, loc, env),
						ys_zs.select(2, loc, env)
					)
				]
			)
		}

		ASSERT.kind_of result_value, VCP::Tuple
	end


	def meth_partition(loc, env, event, func)
		ASSERT.kind_of func, VC::Function

		new_env = env.enter event

		xs, ys = self.partition { |x|
			value = func.apply(x, [], loc, new_env)
			ASSERT.kind_of value, VC::Top

			unless value.kind_of? VCA::Bool
				raise X::TypeError.new(
					loc,
					env,
					"partition: expected a Bool, but %s : %s",
					value.to_s,
					value.type_sym.to_s
				)
			end

			value.true?
		}
		
		VC.make_tuple [VC.make_list(xs), VC.make_list(ts)]
	end


	def meth_sort(loc, env, event)
		xs = self.sort { |a, b|
			if a.meth_equal(loc, env, event, b).true?
				0
			elsif a.meth_less_than(loc, env, event, b).true?
				-1
			else
				1
			end
		}

		VC.make_list xs
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
end

NIL = Nil.new.freeze



class Cons < Abstract
	CLASS_METHOD_INFOS = [
		[:meth_make,		self,
			:'make',		VC::Top, List::Abstract]
	]

	INSTANCE_METHOD_INFOS = [
		[:meth_contents,		VCP::Tuple,
			:contents],
		[ :meth_partial_des,	VCP::Tuple,
			:pdes],
		[ :meth_head,			VC::Top,
			:head],
		[ :meth_tail,			List::Abstract,
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


	def meth_partial_des(_loc, _env, _event)
		VC.make_tuple [self.head, self.tail]
	end


	alias meth_contents meth_partial_des


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


	def make_list(xs)
		ASSERT.kind_of xs, ::Array

		xs.reverse_each.inject(VC.make_nil) { |ys, x|
			VC.make_cons x, ys
		}
	end

end	# Umu::Value::Core

end	# Umu::Value

end	# Umu
