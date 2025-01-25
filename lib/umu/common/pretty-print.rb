# coding: utf-8
# frozen_string_literal: true

module Umu

module PrettyPrint

=begin
Option Parameter
* bb:   Begining symbol of grouping (Begin Braket)
* eb:   Stopping symbol of grouping (End Braket)
* sep:  Separator symbol between all elements
* join: Join symbol between repeated elements

How to Print
* N==0: <bb> <sep> <eb>
* N==1: <bb> <sep> elem <sep> <eb>
* N>=2: <bb> <sep> elem { <join> <sep> elem } <sep> <eb>
* where N is number of elements
=end

module_function

    def __parse_opt_params__(opts)
        ASSERT.kind_of opts, ::Hash

        bb   = nil
        eb   = nil
        sep  = nil
        join = nil

        opts.each do |key, val|
            case key
            when :bb
                ASSERT.kind_of val, ::String

                bb = val
            when :eb
                ASSERT.kind_of val, ::String

                eb = val
            when :sep
                ASSERT.kind_of val, ::String

                sep = val
            when :join
                ASSERT.kind_of val, ::String

                join = val
            else
                ASSERT.abort format("Unknown option: %s", key.to_s)
            end
        end

        [bb, eb, sep, sep ? sep : '', join]
    end


    def group(q, opts = {}, &_block)
        ASSERT.kind_of q,      ::PrettyPrint
        ASSERT.kind_of opts,   ::Hash

        bb, eb, _sep, sep_str, _join = __parse_opt_params__ opts

        q.text bb if bb

        q.group(PP_INDENT_WIDTH) do
            q.breakable sep_str

            yield
        end

        q.breakable sep_str

        q.text eb if eb
    end


    def group_for_enum(q, elems, opts = {}, &_block)
        ASSERT.kind_of q,      ::PrettyPrint
        ASSERT.assert elems.respond_to? :each
        ASSERT.kind_of opts,   ::Hash

        bb, eb, sep, sep_str, join = __parse_opt_params__ opts

        q.text bb if bb

        if elems.count == 0
            q.text sep_str if sep
            q.text eb if eb
        else
            q.group(PP_INDENT_WIDTH) do
                q.breakable sep_str

                if block_given?
                    yield elems.first
                else
                    q.pp elems.first
                end

                elems.drop(1).each do |elem|
                    q.text join if join

                    q.breakable sep_str

                    if block_given?
                        yield elem
                    else
                        q.pp elem
                    end
                end
            end

            if eb
                q.breakable sep_str

                q.text eb
            end
        end
    end
end # Umu::PrettyPrint

end # Umu
