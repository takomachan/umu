require 'umu/common'
require 'umu/lexical/position'


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
		[:meth_get_string,	VCDU::Option::Abstract,
			:'gets'],
		[:meth_put_string,	VC::Unit,
			:'puts',		VCB::String]
	]


	attr_reader	:io


	def initialize(io)
		ASSERT.kind_of io, ::IO

		super()

		@io = io
	end


	def self.meth_make_stdin(_pos, _env, _event)
		VC.make_io ::STDIN
	end


	def self.meth_make_stdout(_pos, _env, _event)
		VC.make_io ::STDOUT
	end


	def self.meth_make_stderr(_pos, _env, _event)
		VC.make_io ::STDERR
	end


	def to_s
		self.io.inspect
	end


	def meth_get_string(_pos, _env, _event)
		s = self.io.gets

		if s
			VC.make_some VC.make_string(s.chomp)
		else
			VC.make_none
		end
	end


	def meth_put_string(_pos, _env, event, value)
		ASSERT.kind_of value, VCB::String

		self.io.print value.val

		VC.make_unit
	end
end


module_function

	def make_io(io)
		ASSERT.kind_of io, ::IO

		IO.new(io).freeze
	end

end	# Umu::Value::Core

end	# Umu::Value

end	# Umu
