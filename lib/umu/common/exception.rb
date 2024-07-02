# coding: utf-8
# frozen_string_literal: true

require_relative 'assertion'



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
    attr_reader :loc


    def initialize(loc, msg, *args)
        ASSERT.kind_of loc, LOC::Entry

        super(msg, *args)

        @loc = loc
    end


    def to_s
        format "%s -- %s", super.to_s, self.loc.to_s
    end
end



class RuntimeError < ExecutionError
    attr_reader :env


    def initialize(loc, env, msg, *args)
        ASSERT.kind_of env, E::Entry

        super(loc, msg, *args)

        @env = env
    end


    def print_backtrace
        self.env.print_backtrace
    end
end



class SubclassResponsibility < RuntimeError; end

end # Umu::Exception::Abstraction



class CommandError < Abstraction::Expected; end

class SyntaxErrorWithoutLocation < Abstraction::Expected

private

    def __category__
        'SyntaxError'
    end
end



class LexicalError          < Abstraction::ExecutionError; end
class SyntaxError           < Abstraction::ExecutionError; end



class NameError             < Abstraction::RuntimeError; end
class TypeError             < Abstraction::RuntimeError; end
class ArgumentError         < Abstraction::RuntimeError; end
class ApplicationError      < Abstraction::RuntimeError; end
class SelectionError        < Abstraction::RuntimeError; end
class NoMethodError         < Abstraction::RuntimeError; end
class UnmatchError          < Abstraction::RuntimeError; end
class ZeroDivisionError     < Abstraction::RuntimeError; end
class EmptyError            < Abstraction::RuntimeError; end
class Panic                 < Abstraction::RuntimeError; end



class EqualityError         < Abstraction::SubclassResponsibility; end
class OrderError            < Abstraction::SubclassResponsibility; end
class NotImplemented        < Abstraction::SubclassResponsibility; end



class InternalSubclassResponsibility < Abstraction::Abstract; end

end # Umu::Exception

end # Umu
