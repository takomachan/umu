require 'umu/common'


module Umu

module Value

module Core

module Atom

module Number

class Abstract < Atom::Abstract
	INSTANCE_METHOD_INFOS = [
		# Number
		[:meth_positive?,	VCA::Bool,
			:positive?],
		[:meth_negative?,	VCA::Bool,
			:negative?],
		[:meth_negate,		self,
			:'~'],
		[:meth_absolute,	self,
			:abs],
		[:meth_to_int,		VCAN::Int,
			:'to-i'],
		[:meth_to_real,		VCAN::Real,
			:'to-r'],
		[:meth_add,			self,
			:'+',			self],
		[:meth_sub,			self,
			:'-',			self],
		[:meth_multiply,	self,
			:'*',			self],
		[:meth_divide,		self,
			:'/',			self],
		[:meth_modulo,		self,
			:mod,			self],
		[:meth_power,		self,
			:pow,			self],

		# I/O
		[:meth_random,		self,
			:'random']
	]


	def initialize(pos, val)
		ASSERT.kind_of val, ::Numeric

		super
	end


	def to_s
		val = self.val

		if val.negative?
			format "~%s", val.abs.inspect
		else
			val.inspect
		end
	end


	def meth_positive?(env, _event)
		VC.make_bool self.pos, self.val.positive?
	end


	def meth_negative?(env, _event)
		VC.make_bool self.pos, self.val.negative?
	end


	def meth_negate(env, _event)
		VC.make_number self.pos, self.class, - self.val
	end


	def meth_absolute(env, _event)
		VC.make_number self.pos, self.class, self.val.abs
	end


	def meth_to_int(env, _event)
		begin
			VC.make_int self.pos, self.val.to_i
		rescue ::FloatDomainError
			raise X::ArgumentError.new(
				self.pos,
				env,
				"Domain error on real number %s : %s",
						self.to_s,
						self.type_sym.to_s
			)
		end
	end


	def meth_to_real(env, _event)
		VC.make_real self.pos, self.val.to_f
	end


	def meth_add(env, _event, other)
		ASSERT.kind_of other, Number::Abstract

		VC.make_number self.pos, self.class, self.val + other.val
	end


	def meth_sub(env, _event, other)
		ASSERT.kind_of other, Number::Abstract

		VC.make_number self.pos, self.class, self.val - other.val
	end


	def meth_multiply(env, _event, other)
		ASSERT.kind_of other, Number::Abstract

		VC.make_number self.pos, self.class, self.val * other.val
	end


	def meth_divide(env, _event, other)
		ASSERT.kind_of other, Number::Abstract

		begin
			VC.make_number self.pos, self.class, self.val / other.val
		rescue ::ZeroDivisionError
			raise X::ZeroDivisionError.new(
				self.pos,
				env,
				"Zero devision error"
			)
		end
	end


	def meth_modulo(env, _event, other)
		ASSERT.kind_of other, Number::Abstract

		begin
			VC.make_number self.pos, self.class, self.val % other.val
		rescue ::ZeroDivisionError
			raise X::ZeroDivisionError.new(
				self.pos,
				env,
				"Zero devision error"
			)
		end
	end


	def meth_power(env, _event, other)
		ASSERT.kind_of other, Number::Abstract

		begin
			VC.make_number self.pos, self.class, self.val ** other.val
		rescue ::ZeroDivisionError
			raise X::ZeroDivisionError.new(
				self.pos,
				env,
				"Zero devision error"
			)
		end
	end


	def meth_random(env, _event)
		value = if self.val.positive?
				begin
					VC.make_number(
							self.pos, self.class, ::Random.rand(self.val)
						)
				rescue Errno::EDOM
					raise X::ArgumentError.new(
						self.pos,
						env,
						"Domain error on real number %s : %s",
								self.to_s,
								self.type_sym.to_s
					)
				end
			elsif self.val.negative?
				raise X::ArgumentError.new(
					self.pos,
					env,
					"Invalid argument %s : %s",
							self.to_s,
							self.type_sym.to_s
				)
			else
				self
			end

		ASSERT.kind_of value, Number::Abstract
	end
end

end # Umu::Value::Core::Atom::Number

end # Umu::Value::Core::Atom


module_function

	def make_number(pos, klass, val)
		ASSERT.kind_of		pos,	L::Position
		ASSERT.subclass_of	klass,	VCAN::Abstract
		ASSERT.kind_of		val,	::Numeric

		klass.new(pos, val).freeze
	end

end # Umu::Value::Core

end	# Umu::Value

end	# Umu
