# coding: utf-8
# frozen_string_literal: true

module Umu

module PrettyPrint

module_function

    def seplist(q, enum, bb = nil, eb = nil, sep = nil, &_block)
        q.text bb if bb

        case enum.count
        when 0
            q.text eb if eb
        when 1
            q.pp enum.first
            q.text eb if eb
        else
            q.group(PP_INDENT_WIDTH) do
                q.breakable ''

                if block_given?
                    yield enum.first
                else
                    q.pp enum.first
                end
                enum.drop(1).each do |elem|
                    q.text sep if sep

                    q.breakable ''

                    if block_given?
                        yield elem
                    else
                        q.pp elem
                    end
                end
            end

            if eb
                q.breakable ''

                q.text eb
            end
        end
    end

(# FIXME: About method PrettyPrint#breakable
    Expected: [1, 2, 3]
    Actual:   [ 1, 2, 3 ]
#)

end # Umu::PrettyPrint

end # Umu
