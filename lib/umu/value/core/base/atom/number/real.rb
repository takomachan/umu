require 'umu/common'


module Umu

module Value

module Core

module Base

module Atom

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
		[:meth_absolute,		self,
			:abs],
		[:meth_negate,			self,
			:negate],
		[:meth_less_than,		VCBA::Bool,
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
		[:meth_nan?,			VCBA::Bool,
			:nan?],
		[:meth_infinite?,		VCBA::Bool,
			:infinite?],
		[:meth_finite?,			VCBA::Bool,
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
		[:meth_truncate,		self,
			:truncate,			VCBAN::Int],
		[:meth_ceil,			self,
			:ceil,				VCBAN::Int],
		[:meth_floor,			self,
			:floor,				VCBAN::Int],
		[:meth_ldexp,			self,
			:ldexp,				VCBAN::Int],
		[:meth_frexp,			VCBLP::Tuple,
			:frexp],
		[:meth_divmod,			VCBLP::Tuple,
			:divmod,			self],

		# I/O
		[:meth_random,		self,
			:'random']
	]


	def initialize(val)
		ASSERT.kind_of val, ::Float

		super
	end


	def to_s
		if self.val.nan?
			'NAN'
		elsif self.val.infinite?
			format("%sINFINITY",
					if self.val < 0
						'-'
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


	def self.meth_make_nan(_loc, _env, _event)
		VC.make_nan
	end


	def self.meth_make_infinity(_loc, _env, _event)
		VC.make_infinity
	end


	def self.meth_make_pi(_loc, _env, _event)
		VC.make_real Math::PI
	end


	def self.meth_make_e(_loc, _env, _event)
		VC.make_real Math::E
	end


	def meth_nan?(_loc, _env, _event)
		VC.make_bool self.val.nan?
	end


	def meth_infinite?(_loc, _env, _event)
		VC.make_bool self.val.infinite?.kind_of?(::Integer)
	end


	def meth_finite?(_loc, _env, _event)
		VC.make_bool self.val.finite?
	end


	def meth_sin(_loc, _env, _event)
		VC.make_real Math.sin(self.val)
	end


	def meth_cos(_loc, _env, _event)
		VC.make_real Math.cos(self.val)
	end


	def meth_tan(_loc, _env, _event)
		VC.make_real Math.tan(self.val)
	end


	def meth_asin(_loc, _env, _event)
		VC.make_real Math.asin(self.val)
	end


	def meth_acos(_loc, _env, _event)
		VC.make_real Math.acos(self.val)
	end


	def meth_atan(_loc, _env, _event)
		VC.make_real Math.atan(self.val)
	end


	def meth_atan2(_loc, _env, _event, other)
		ASSERT.kind_of other, Real

		VC.make_real Math.atan2(other.val, self.val)
	end


	def meth_sinh(_loc, _env, _event)
		VC.make_real Math.sinh(self.val)
	end


	def meth_cosh(_loc, _env, _event)
		VC.make_real Math.cosh(self.val)
	end


	def meth_tanh(_loc, _env, _event)
		VC.make_real Math.tanh(self.val)
	end


	def meth_exp(_loc, _env, _event)
		VC.make_real Math.exp(self.val)
	end


	def meth_log(_loc, _env, _event)
		VC.make_real Math.log(self.val)
	end


	def meth_log10(_loc, _env, _event)
		VC.make_real Math.log10(self.val)
	end


	def meth_sqrt(_loc, _env, _event)
		VC.make_real Math.sqrt(self.val)
	end


	def meth_truncate(loc, env, _event, ndigits)
		ASSERT.kind_of ndigits, VCBAN::Int

		unless ndigits.val >= 0
			raise X::ArgumentError.new(
				loc,
				env,
				"truncate: expected zero or positive for digits number: %d",
				ndigits.val.to_i
			)
		end

		VC.make_real self.val.truncate(ndigits.val).to_f
	end


	def meth_ceil(loc, env, _event, ndigits)
		ASSERT.kind_of ndigits, VCBAN::Int

		unless ndigits.val >= 0
			raise X::ArgumentError.new(
				loc,
				env,
				"ceil: expected zero or positive for digits number: %d",
				ndigits.val.to_i
			)
		end

		VC.make_real self.val.ceil(ndigits.val).to_f
	end


	def meth_floor(loc, env, _event, ndigits)
		ASSERT.kind_of ndigits, VCBAN::Int

		unless ndigits.val >= 0
			raise X::ArgumentError.new(
				loc,
				env,
				"floor: expected zero or positive for digits number: %d",
				ndigits.val.to_i
			)
		end

		VC.make_real self.val.floor(ndigits.val).to_f
	end


	def meth_ldexp(_loc, _env, _event, other)
		ASSERT.kind_of other, VCBAN::Int

		VC.make_real Math.ldexp(self.val, other.val)
	end


	def meth_frexp(_loc, _env, _event)
		fract, expon = Math.frexp self.val

		VC.make_tuple(
			[
				VC.make_real(fract.to_f),
				VC.make_integer(expon.to_i)
			]
		)
	end


	def meth_divmod(_loc, _env, _event, other)
		ASSERT.kind_of other, VCBAN::Real

		fract, integ = self.val.divmod other.val

		VC.make_tuple(
			[
				VC.make_real(fract.to_f),
				VC.make_real(integ.to_f)
			]
		)
	end


	def meth_to_real(_loc, _env, _event)
		self
	end
end

NAN			= Atom::Number::Real.new(::Float::NAN).freeze
INFINITY	= Atom::Number::Real.new(::Float::INFINITY).freeze

end # Umu::Value::Core::Atom::Base::Number

end # Umu::Value::Core::Atom::Base

end # Umu::Value::Core::Atom


module_function

	def make_real(val)
		ASSERT.kind_of val, ::Float

		Base::Atom::Number::Real.new(val).freeze
	end


	def make_nan
		Base::Atom::Number::NAN
	end


	def make_infinity
		Base::Atom::Number::INFINITY
	end

end	# Umu::Value::Core

end	# Umu::Value

end	# Umu
