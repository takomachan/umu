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
		[:meth_get_string,	VCD::Option::Abstract,
			:'gets'],
		[:meth_put_string,	VC::Unit,
			:'puts',		VCB::String]
	]


	attr_reader	:io


	def initialize(pos, io)
		ASSERT.kind_of io, ::IO

		super(pos)

		@io = io
	end


	def self.meth_make_stdin(env, _event)
		VC.make_io L.make_position(__FILE__, __LINE__), ::STDIN
	end


	def self.meth_make_stdout(env, _event)
		VC.make_io L.make_position(__FILE__, __LINE__), ::STDOUT
	end


	def self.meth_make_stderr(env, _event)
		VC.make_io L.make_position(__FILE__, __LINE__), ::STDERR
	end


	def to_s
		self.io.inspect
	end


	def meth_get_string(env, _event)
		s = self.io.gets

		if s
			VC.make_some self.pos, VC.make_string(self.pos, s.chomp)
		else
			VC.make_none self.pos
		end
	end


	def meth_put_string(env, event, value)
		ASSERT.kind_of value, VCB::String

		self.io.print value.val

		VC.make_unit self.pos
	end
end


module_function

	def make_io(pos, io)
		ASSERT.kind_of pos,	L::Position
		ASSERT.kind_of io,	::IO

		IO.new(pos, io).freeze
	end

end	# Umu::Value::Core

end	# Umu::Value

end	# Umu
