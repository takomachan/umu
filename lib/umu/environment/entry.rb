require 'umu/common'
require 'umu/lexical/position'
require 'umu/environment/preference'
require 'umu/environment/tracer/stack'
require 'umu/environment/context'
require 'umu/abstract-syntax/core/expression'


module Umu

module Environment

class Entry < Abstraction::CartesianProduct
	attr_reader :ty_context
	attr_reader :va_context
	attr_reader :pref
	attr_reader :trace_stack
	attr_reader :sources


	def initialize(ty_context, va_context, pref, trace_stack, sources)
		ASSERT.kind_of ty_context,	ECT::Entry
		ASSERT.kind_of va_context,	ECV::Abstract
		ASSERT.kind_of pref,		Preference
		ASSERT.kind_of trace_stack,	Tracer::Stack::Abstract
		ASSERT.kind_of sources,		::Hash

		@ty_context		= ty_context
		@va_context		= va_context
		@pref			= pref
		@trace_stack	= trace_stack
		@sources		= sources
	end


	def to_s
		'#<env>'
	end


	def ty_class_spec_of(value)
		ASSERT.kind_of value, VC::Top

		ASSERT.kind_of self.ty_context.class_spec_of(value), ECTSC::Abstract
	end


	def ty_spec_of_class(klass)
		ASSERT.subclass_of klass, VC::Top

		ASSERT.kind_of self.ty_context.spec_of_class(klass), ECTSC::Base
	end


	def ty_lookup(sym, pos)
		ASSERT.kind_of sym, ::Symbol
		ASSERT.kind_of pos,	L::Position

		ASSERT.kind_of self.ty_context.lookup(sym, pos, self), ECTSC::Base
	end


	def ty_kind_of?(lhs_value, rhs_spec)
		ASSERT.kind_of lhs_value,	VC::Top
		ASSERT.kind_of rhs_spec,	ECTSC::Base

		ASSERT.bool self.ty_context.test_kind_of?(lhs_value, rhs_spec)
	end


	def va_lookup(sym, pos)
		ASSERT.kind_of sym, ::Symbol
		ASSERT.kind_of pos,	L::Position

		self.va_context.lookup sym, pos, self
	end


	def va_extend_value(sym, value)
		ASSERT.kind_of sym,		::Symbol
		ASSERT.kind_of value,	VC::Top


		self.update_va_context(
			self.va_context.extend(sym, ECV::Bindings.make_value(value))
		)
	end


	def va_extend_recursive(sym, lam_expr)
		ASSERT.kind_of sym,			::Symbol
		ASSERT.kind_of lam_expr,	SACE::Nary::Lambda


		self.update_va_context(
			self.va_context.extend(
				sym,
				ECV::Bindings.make_recursive(lam_expr)
			)
		)
	end


	def va_extend_mutual_recursive(bindings)
		ASSERT.kind_of bindings, ::Hash


		self.update_va_context(
			self.va_context.extend_mutual(bindings)
		)
	end


	def update_va_context(va_context)
		ASSERT.kind_of va_context, ECV::Abstract

		Environment.make_entry(
			self.ty_context,
			va_context,
			self.pref,
			self.trace_stack,
			self.sources
		)
	end


	def update_trace_mode(bool)
		ASSERT.bool bool

		self.update_preference self.pref.update_trace_mode(bool)
	end


	def update_preference(pref)
		ASSERT.kind_of pref, Preference

		Environment.make_entry(
			self.ty_context,
			self.va_context,
			pref,
			self.trace_stack,
			self.sources
		)
	end


	def enter(event)
		ASSERT.kind_of event, Tracer::Event

		__update_trace_stack__ self.trace_stack.push(event)
	end


	def leave
		__update_trace_stack__ self.trace_stack.pop
	end


	def update_line(file_name, line_num, line)

		source = self.sources[file_name] || {}

		__update_sources__(
			self.sources.merge(
				file_name => source.merge(line_num => line.freeze)
			).freeze
		)
	end


	def update_source(file_name, text)
		ASSERT.kind_of file_name,	::String
		ASSERT.kind_of text,		::String

		source, _ = text.each_line.inject([{}, 1]) {
			|(sources, line_num), line|

			[
				sources.merge(line_num => line.chomp.freeze),
				line_num + 1
			]
		}

		__update_sources__(
			self.sources.merge(file_name => source.freeze).freeze
		)
	end


	def print_backtrace
		self.trace_stack.inject(L.make_initial_position) do
			|last_pos, event|

			current_pos = event.pos
			if current_pos != last_pos
				opt_line = __lookup_line_at__ current_pos
				if opt_line
					STDERR.printf("\n%s:#%d>%s\n",
									current_pos.file_name,
									current_pos.line_num,
									opt_line
								)
				end
			end

			STDERR.puts event.to_s

			current_pos
		end
	end


private

	def __update_trace_stack__(stack)
		ASSERT.kind_of stack, Tracer::Stack::Abstract

		Environment.make_entry(
			self.ty_context,
			self.va_context,
			self.pref,
			stack,
			self.sources
		)
	end


	def __update_sources__(sources)
		ASSERT.kind_of sources,		::Hash

		Environment.make_entry(
			self.ty_context,
			self.va_context,
			self.pref,
			self.trace_stack,
			sources
		)
	end


	def __lookup_line_at__(pos)
		ASSERT.kind_of pos,	L::Position

		opt_source = self.sources[pos.file_name]
		if opt_source
			opt_source[pos.line_num]
		else
			nil
		end
	end
end



module_function

	def setup(pref)
		ASSERT.kind_of pref, Preference

		make_entry(
			ECT.make,
			ECV.make_initial,
			pref,
			Tracer::Stack.empty,
			{}.freeze
		)
	end


	def make_entry(ty_context, va_context, pref, trace_stack, sources)
		ASSERT.kind_of ty_context,	ECT::Entry
		ASSERT.kind_of va_context,	ECV::Abstract
		ASSERT.kind_of pref,		Preference
		ASSERT.kind_of trace_stack,	Tracer::Stack::Abstract
		ASSERT.kind_of sources,		::Hash

		Entry.new(ty_context, va_context, pref, trace_stack, sources).freeze
	end
end	# Umu::Environment

end	# Umu
