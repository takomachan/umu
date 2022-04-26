require 'umu/common'


module Umu

module Value

module Core

module Base

module Number

class Real < Abstract
	CLASS_METHOD_INFOS = [
		[:meth_make_nan,		self,
			:'make-nan'],
		[:meth_make_infinity,	self,
			:'make-infinity'],
		[:meth_make_pi,			self,
			:'make-pi'],
		[:meth_make_e,			self,
			:'make-e']
	]


	INSTANCE_METHOD_INFOS = [
		# Number
		[:meth_negate,			self,
			:'~'],
		[:meth_absolute,		self,
			:abs],
		[:meth_less_than,		VCB::Bool,
			:'<',				self],
		[:meth_add,				self,
			:'+',				self],
		[:meth_sub,				self,
			:'-',				self],
		[:meth_multiply,		self,
			:'*',				self],
		[:meth_divide,			self,
			:'/',				self],
		[:meth_modulo,			self,
			:mod,				self],
		[:meth_power,			self,
			:pow,				self],

		# Math
		[:meth_nan?,			VCB::Bool,
			:nan?],
		[:meth_infinite?,		VCB::Bool,
			:infinite?],
		[:meth_finite?,			VCB::Bool,
			:finite?],
		[:meth_sin,				self,
			:sin],
		[:meth_cos,				self,
			:cos],
		[:meth_tan,				self,
			:tan],
		[:meth_asin,			self,
			:asin],
		[:meth_acos,			self,
			:acos],
		[:meth_atan,			self,
			:atan],
		[:meth_atan2,			self,
			:atan2,				self],
		[:meth_sinh,			self,
			:sinh],
		[:meth_cosh,			self,
			:cosh],
		[:meth_tanh,			self,
			:tanh],
		[:meth_exp,				self,
			:exp],
		[:meth_log,				self,
			:log],
		[:meth_log10,			self,
			:log10],
		[:meth_sqrt,			self,
			:sqrt],
		[:meth_ceil,			self,
			:ceil],
		[:meth_floor,			self,
			:floor],
		[:meth_ldexp,			self,
			:ldexp,				VCBN::Int],
		[:meth_frexp,			VCP::Tuple,
			:frexp],
		[:meth_divmod,			VCP::Tuple,
			:divmod,			self],

		# I/O
		[:meth_random,		self,
			:'random']
	]


	def initialize(pos, val)
		ASSERT.kind_of val, ::Float

		super
	end


	def to_s
		if self.val.nan?
			'NAN'
		elsif self.val.infinite?
			format("%sINFINITY",
					if self.val.negative?
						'~'
					else
						''
					end
			)
		elsif val.finite?
			super
		else
			ASSERT.abort
		end
	end


	def self.meth_make_nan(env, _event)
		VC.make_nan L.make_position(__FILE__, __LINE__)
	end


	def self.meth_make_infinity(env, _event)
		VC.make_infinity L.make_position(__FILE__, __LINE__)
	end


	def self.meth_make_pi(env, _event)
		VC.make_real L.make_position(__FILE__, __LINE__), Math::PI
	end


	def self.meth_make_e(env, _event)
		VC.make_real L.make_position(__FILE__, __LINE__), Math::E
	end


	def meth_nan?(env, _event)
		VC.make_bool self.pos, self.val.nan?
	end


	def meth_infinite?(env, _event)
		VC.make_bool self.pos, self.val.infinite?.kind_of?(::Integer)
	end


	def meth_finite?(env, _event)
		VC.make_bool self.pos, self.val.finite?
	end


	def meth_sin(env, _event)
		VC.make_real self.pos, Math.sin(self.val)
	end


	def meth_cos(env, _event)
		VC.make_real self.pos, Math.cos(self.val)
	end


	def meth_tan(env, _event)
		VC.make_real self.pos, Math.tan(self.val)
	end


	def meth_asin(env, _event)
		VC.make_real self.pos, Math.asin(self.val)
	end


	def meth_acos(env, _event)
		VC.make_real self.pos, Math.acos(self.val)
	end


	def meth_atan(env, _event)
		VC.make_real self.pos, Math.atan(self.val)
	end


	def meth_atan2(env, _event, other)
		ASSERT.kind_of other, Real

		VC.make_real self.pos, Math.atan2(other.val, self.val)
	end


	def meth_sinh(env, _event)
		VC.make_real self.pos, Math.sinh(self.val)
	end


	def meth_cosh(env, _event)
		VC.make_real self.pos, Math.cosh(self.val)
	end


	def meth_tanh(env, _event)
		VC.make_real self.pos, Math.tanh(self.val)
	end


	def meth_exp(env, _event)
		VC.make_real self.pos, Math.exp(self.val)
	end


	def meth_log(env, _event)
		VC.make_real self.pos, Math.log(self.val)
	end


	def meth_log10(env, _event)
		VC.make_real self.pos, Math.log10(self.val)
	end


	def meth_sqrt(env, _event)
		VC.make_real self.pos, Math.sqrt(self.val)
	end


	def meth_ceil(env, _event)
		VC.make_real self.pos, self.val.ceil.to_f
	end


	def meth_floor(env, _event)
		VC.make_real self.pos, self.val.floor.to_f
	end


	def meth_ldexp(env, _event, other)
		ASSERT.kind_of other, VCBN::Int

		VC.make_real self.pos, Math.ldexp(self.val, other.val)
	end


	def meth_frexp(env, _event)
		fract, expon = Math.frexp self.val

		VC.make_tuple(
			self.pos,
			[
				VC.make_real(self.pos, fract.to_f),
				VC.make_int( self.pos, expon.to_i)
			]
		)
	end


	def meth_divmod(env, _event, other)
		ASSERT.kind_of other, Real

		fract, integ = self.val.divmod other.val

		VC.make_tuple(
			self.pos,
			[
				VC.make_real(self.pos, fract.to_f),
				VC.make_real(self.pos, integ.to_f)
			]
		)
	end
end

end # Umu::Value::Core::Base::Number

end # Umu::Value::Core::Base


module_function

	def make_real(pos, val)
		ASSERT.kind_of pos,	L::Position
		ASSERT.kind_of val,	::Float

		Base::Number::Real.new(pos, val).freeze
	end


	def make_nan(pos)
		ASSERT.kind_of pos,	L::Position

		make_real pos, ::Float::NAN
	end


	def make_infinity(pos)
		ASSERT.kind_of pos,	L::Position

		make_real pos, ::Float::INFINITY
	end

end	# Umu::Value::Core

end	# Umu::Value

end	# Umu
