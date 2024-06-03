# vim: set nu ai sw=4 ts=4 :
# coding: utf-8
# frozen_string_literal: true

require 'umu/common'
require 'umu/environment/tracer/tracer'


module Umu

module Environment

module Tracer

module Stack

class Abstract < Abstraction::Collection
	def each
		return self.to_enum unless block_given?

		elem = self

		until elem.kind_of? Empty
			yield elem.event

			elem = elem.old_cons
		end

		nil
	end


	def push(event)
		ASSERT.kind_of event, Tracer::Event

		Cons.new(event, self).freeze
	end


	def pop
		raise X::SubclassResponsibility
	end


	def print
		self.each do |event|
			STDERR.puts event.to_s
		end
	end
end



class Empty < Abstract
	def pop
		ASSERT.abort "Empty Stack"
	end
end

EMPTY = Empty.new.freeze


class Cons < Abstract
	attr_reader :event
	attr_reader :old_cons


	def initialize(event, old_cons)
		ASSERT.kind_of event,		Tracer::Event
		ASSERT.kind_of old_cons,	Abstract

		@event		= event
		@old_cons	= old_cons
	end


	def pop
		self.old_cons
	end
end



module_function

	def empty
		EMPTY
	end
end # Umu::Environment::Tracer::Stack

end # Umu::Environment::Tracer

end # Umu::Environment

end # Umu
