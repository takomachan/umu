require 'umu/common'
require 'umu/lexical/location'


module Umu

module Value

module Core

class IO < Top
	CLASS_METHOD_INFOS = [
		[:meth_make_stdin,		self,
			:'make-stdin'],
		[:meth_make_stdout,		self,
			:'make-stdout'],
		[:meth_make_stderr,		self,
			:'make-stderr']
	]


	INSTANCE_METHOD_INFOS = [
		[:meth_get_string,	VCBLU::Option::Abstract,
			:'gets'],
		[:meth_put_string,	VCBA::Unit,
			:'puts',		VCBA::String]
	]


	attr_reader	:io


	def initialize(io)
		ASSERT.kind_of io, ::IO

		super()

		@io = io
	end


	def self.meth_make_stdin(_loc, _env, _event)
		VC.make_stdin
	end


	def self.meth_make_stdout(_loc, _env, _event)
		VC.make_stdout
	end


	def self.meth_make_stderr(_loc, _env, _event)
		VC.make_stderr
	end


	def to_s
		self.io.inspect
	end


	def meth_get_string(_loc, _env, _event)
		s = self.io.gets

		if s
			VC.make_some VC.make_string(s.chomp)
		else
			VC.make_none
		end
	end


	def meth_put_string(_loc, _env, event, value)
		ASSERT.kind_of value, VCBA::String

		self.io.print value.val

		VC.make_unit
	end
end

STDIN	= IO.new(::STDIN).freeze
STDOUT	= IO.new(::STDOUT).freeze
STDERR	= IO.new(::STDERR).freeze


module_function

	def make_stdin
		STDIN
	end


	def make_stdout
		STDOUT
	end


	def make_stderr
		STDERR
	end

end	# Umu::Value::Core

end	# Umu::Value

end	# Umu
