# coding: utf-8
# frozen_string_literal: true

require 'optparse'

require_relative '../version'


module Umu

module Commander

module_function

    def parse_option(args, init_pref)
        ASSERT.kind_of args,        ::Array
        ASSERT.kind_of init_pref,   E::Preference

        interactive_mode = false
        trace_mode       = false
        dump_mode        = false
        no_prelude       = false

        mut_args = args.dup

        OptionParser.new do |opts|
            opts.on(
                '-i', '--[no-]interactive',
                'Interactive execution (REPL)'
            ) do |answer|
                interactive_mode = true
            end

            opts.on(
                '-t', '--[no-]trace',
                'Enable trace'
            ) do |answer|
                trace_mode = true
            end

            opts.on(
                '-d', '--[no-]dump',
                'Enable dump'
            ) do |answer|
                dump_mode = true
            end

            opts.on(
                '--no-prelude',
                'No loading standard prelude'
            ) do |answer|
                no_prelude = true
            end

            begin
                opts.banner  = 'umu [OPTION ..] SCRIPT_FILE ..'
                opts.version = VERSION
                opts.parse! mut_args
            rescue OptionParser::ParseError => exception
                raise X::CommandError.new exception.to_s
            end
        end

        pref = init_pref
                .update_interactive_mode(interactive_mode)
                .update_trace_mode(      trace_mode)
                .update_dump_mode(       dump_mode)
                .update_no_prelude(      no_prelude)

        pair = [pref, mut_args]
        ASSERT.tuple_of pair, [E::Preference, ::Array]
    end

end # Umu::Commander

end # Umu
