require 'umu/common/assertion'



module Umu

module Exception

module Abstraction

class Abstract < ::StandardError; end



class Expected < Abstract
	attr_reader :msg


	def initialize(msg, *args)
		ASSERT.kind_of msg, ::String

		@msg = format msg, *args
	end


	def to_s
		format "[%s] %s", __category__, self.msg
	end


private

	def __category__
		self.class.to_s.split(/::/)[2]
	end
end



class ExecutionError < Expected
	attr_reader :pos


	def initialize(pos, msg, *args)
		ASSERT.kind_of pos,	L::Position

		super(msg, *args)

		@pos = pos
	end


	def to_s
		super.to_s +
		format(" -- #%d in %s", self.pos.line_num, self.pos.file_name)
	end
end



class RuntimeError < ExecutionError
	attr_reader :env


	def initialize(pos, env, msg, *args)
		ASSERT.kind_of env, E::Entry

		super(pos, msg, *args)

		@env = env
	end


	def print_backtrace
		self.env.print_backtrace
	end
end



class Unexpected < Abstract; end

end # Umu::Exception::Abstraction



class CommandError < Abstraction::Expected; end

class SyntaxErrorWithoutPosition < Abstraction::Expected

private

	def __category__
		'SyntaxError'
	end
end



class LexicalError			< Abstraction::ExecutionError; end
class SyntaxError			< Abstraction::ExecutionError; end
class NotImplemented		< Abstraction::ExecutionError; end



class NameError				< Abstraction::RuntimeError; end
class TypeError				< Abstraction::RuntimeError; end
class ArgumentError			< Abstraction::RuntimeError; end
class ApplicationError		< Abstraction::RuntimeError; end
class SelectionError		< Abstraction::RuntimeError; end
class UserError				< Abstraction::RuntimeError; end
class EqualityError			< Abstraction::RuntimeError; end
class OrderError			< Abstraction::RuntimeError; end
class NoMethodError			< Abstraction::RuntimeError; end
class ZeroDivisionError		< Abstraction::RuntimeError; end
class EmptyError			< Abstraction::RuntimeError; end



class SubclassResponsibility < Abstraction::Unexpected; end

end	# Umu::Exception

end	# Umu
