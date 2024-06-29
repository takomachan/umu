# coding: utf-8
# frozen_string_literal: true



module Umu

module Environment

class Preference < Abstraction::Record
    attr_reader :interactive_mode
    attr_reader :trace_mode
    attr_reader :lex_trace_mode
    attr_reader :dump_mode
    attr_reader :no_prelude


    def self.deconstruct_keys
        {
            interactive_mode:   ::Object,
            trace_mode:         ::Object,
            lex_trace_mode:     ::Object,
            dump_mode:          ::Object,
            no_prelude:         ::Object
        }.freeze
    end


    def initialize(
            interactive_mode,
            trace_mode,
            lex_trace_mode,
            dump_mode,
            no_prelude
        )
        ASSERT.bool interactive_mode
        ASSERT.bool trace_mode
        ASSERT.bool lex_trace_mode
        ASSERT.bool dump_mode
        ASSERT.bool no_prelude

        @interactive_mode   = interactive_mode
        @trace_mode         = trace_mode
        @lex_trace_mode     = lex_trace_mode
        @dump_mode          = dump_mode
        @no_prelude         = no_prelude
    end


    def interactive_mode?
        self.interactive_mode
    end


    def trace_mode?
        self.trace_mode
    end


    def lex_trace_mode?
        self.lex_trace_mode
    end


    def dump_mode?
        self.dump_mode
    end


    def any_trace?
        [
            self.trace_mode,
            self.lex_trace_mode,
            self.dump_mode
        ].any?
    end


    def no_prelude?
        self.no_prelude
    end


    def update_interactive_mode(bool)
        ASSERT.bool bool

        self.update(interactive_mode: bool)
    end


    def update_trace_mode(bool)
        ASSERT.bool bool

        self.update(trace_mode: bool)
    end


    def update_lex_trace_mode(bool)
        ASSERT.bool bool

        self.update(lex_trace_mode: bool)
    end


    def update_dump_mode(bool)
        ASSERT.bool bool

        self.update(dump_mode: bool)
    end


    def update_no_prelude(bool)
        ASSERT.bool bool

        self.update(no_prelude: bool)
    end
end


module_function

    def make_preference(
        interactive_mode,
        trace_mode,
        lex_trace_mode,
        dump_mode,
        no_prelude
    )
        ASSERT.bool interactive_mode
        ASSERT.bool trace_mode
        ASSERT.bool lex_trace_mode
        ASSERT.bool dump_mode
        ASSERT.bool no_prelude

        Preference.new(
            interactive_mode,
            trace_mode,
            lex_trace_mode,
            dump_mode,
            no_prelude
        ).freeze
    end


INITIAL_PREFERENCE = make_preference(
    false,  # interactive_mode
    false,  # trace_mode
    false,  # lex_trace_mode
    false,  # dump_mode
    false   # no_prelude
)

end # Umu::Environment

end # Umu
