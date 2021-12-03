require 'umu/common'



module Umu

module Environment

class Preference < Abstraction::Record
	attr_reader :interactive_mode
	attr_reader :trace_mode
	attr_reader :lex_trace_mode


	def initialize(
			interactive_mode,
			trace_mode,
			lex_trace_mode
		)
		ASSERT.bool	interactive_mode
		ASSERT.bool	trace_mode

		@interactive_mode	= interactive_mode
		@trace_mode			= trace_mode
		@lex_trace_mode		= lex_trace_mode
	end


	def interactive_mode?
		self.interactive_mode
	end


	def trace_mode?
		self.trace_mode
	end


	def lex_trace_mode?
		self.trace_mode && self.lex_trace_mode
	end


	def update_interactive_mode(bool)
		ASSERT.bool bool

		Environment.make_preference(
			bool, self.trace_mode, self.lex_trace_mode
		)
	end


	def update_trace_mode(bool)
		ASSERT.bool bool

		Environment.make_preference(
			self.interactive_mode, bool, self.lex_trace_mode
		)
	end


	def update_lex_trace_mode(bool)
		ASSERT.bool bool

		Environment.make_preference(
			self.interactive_mode, self.trace_mode, bool
		)
	end
end


module_function

	def make_preference(
		interactive_mode,
		trace_mode,
		lex_trace_mode
	)
		ASSERT.bool	interactive_mode
		ASSERT.bool	trace_mode
		ASSERT.bool lex_trace_mode

		Preference.new(
			interactive_mode,
			trace_mode,
			lex_trace_mode
		).freeze
	end


INITIAL_PREFERENCE = make_preference(
	false,	# interactive_mode
	false,	# trace_mode
	false	# lex_trace_mode
)

end # Umu::Environment

end # Umu
