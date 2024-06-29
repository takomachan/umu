# coding: utf-8
# frozen_string_literal: true



module Umu

module ConcreteSyntax

module Core

module Expression

module Unary

module Container

module Named

class Label < Unary::Abstract
    alias sym obj


    def initialize(loc, sym)
        ASSERT.kind_of sym, ::Symbol

        super
    end


    def hash
        self.sym.hash
    end


    def eql?(other)
        self.sym.eql? other.sym
    end


    def to_s
        self.sym.to_s + ':'
    end


private

    def __desugar__(_env, _event)
        ASCE.make_named_tuple_label self.loc, self.sym
    end
end



class Entry < Abstract
    attr_reader :index_by_label


    def initialize(loc, fields)
        ASSERT.kind_of  fields, ::Array
        ASSERT.assert   fields.size >= 2

        index_by_label, exprs = fields.each_with_index.inject([{}, []]) {
            |(hash, array), (pair, index)|
            ASSERT.kind_of  hash,   ::Hash
            ASSERT.kind_of  array,  ::Array
            ASSERT.kind_of  pair,   ::Array
            ASSERT.kind_of  index,  ::Integer

            label, opt_expr = pair
            ASSERT.kind_of     label,    Label
            ASSERT.opt_kind_of opt_expr, CSCE::Abstract

            [
                hash.merge(label => index) { |label, _, _|
                    raise X::SyntaxError.new(
                        label.loc,
                        format("Duplicated label in named tuple: '%s'",
                                label.sym
                        )
                    )
                },

                array + [opt_expr]
            ]
        }

        @index_by_label = index_by_label.freeze

        super(loc, exprs.freeze)
    end


    def to_s
        format("(%s)",
            self.index_by_label.map { |label, index|
                opt_expr = self.exprs[index]

                format("%s%s",
                        label.to_s,
                        opt_expr ? (' ' + opt_expr.to_s) : ''
                )
            }.join(', ')
        )
    end


private

    def __desugar__(env, event)
        new_env = env.enter event

        exprs = self.index_by_label.inject([]) { |array, (label, index)|
            opt_expr = self.exprs[index]

            array + [
                if opt_expr
                    opt_expr.desugar(new_env)
                else
                    ASCE.make_identifier label.loc, label.sym
                end
            ]
        }

        index_by_label = self.index_by_label.inject({}) {
            |hash, (label, index)|

            hash.merge(label.desugar(new_env) => index)
        }

        ASCE.make_named_tuple self.loc, exprs, index_by_label
    end
end

end # Umu::ConcreteSyntax::Core::Expression::Unary::Container::Named

end # Umu::ConcreteSyntax::Core::Expression::Unary::Container

end # Umu::ConcreteSyntax::Core::Expression::Unary


module_function

    def make_named_tuple_label(loc, sym)
        ASSERT.kind_of loc,     LOC::Entry
        ASSERT.kind_of sym,     ::Symbol

        Unary::Container::Named::Label.new(loc, sym).freeze
    end


    def make_named_tuple(loc, fields)
        ASSERT.kind_of loc,     LOC::Entry
        ASSERT.kind_of fields,  ::Array

        Unary::Container::Named::Entry.new(loc, fields.freeze).freeze
    end

end # Umu::ConcreteSyntax::Core::Expression

end # Umu::ConcreteSyntax::Core

end # Umu::ConcreteSyntax

end # Umu
