# coding: utf-8
# frozen_string_literal: true



module Umu

module AbstractSyntax

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


    def pretty_print(q)
        q.text self.to_s
    end
end



class Entry < Abstraction::Expressions
    attr_reader :index_by_label


    def initialize(loc, exprs, index_by_label)
        ASSERT.kind_of exprs,           ::Array
        ASSERT.assert exprs.size >= 2
        ASSERT.kind_of index_by_label,  ::Hash

        @index_by_label = index_by_label.freeze

        super(loc, exprs)
    end


    def each
        self.index_by_label.each do |label, index|
            yield label, self.exprs[index]
        end
    end


    def to_s
        format("(%s)",
            self.map { |label, expr|
                format "%s %s", label.to_s, expr.to_s
            }.join(', ')
        )
    end


    def pretty_print(q)
        P.seplist(q, self, '(', ')', ',') do |(label, expr)|
            q.pp label
            q.text ' '
            q.pp expr
        end
    end


private

    def __evaluate__(env, event)
        ASSERT.kind_of env,     E::Entry
        ASSERT.kind_of event,   E::Tracer::Event

        new_env = env.enter event

        VC.make_named_tuple(
            self.exprs.map { |expr| expr.evaluate(new_env).value },

            self.index_by_label.inject({}) { |hash, (label, index)|
                hash.merge(label.sym => index)
            }
        )
    end
end

end # Umu::AbstractSyntax::Core::Expression::Unary::Container::Named

end # Umu::AbstractSyntax::Core::Expression::Unary::Container

end # Umu::AbstractSyntax::Core::Expression::Unary


module_function

    def make_named_tuple_label(loc, sym)
        ASSERT.kind_of loc,     Umu::Location
        ASSERT.kind_of sym,     ::Symbol

        Unary::Container::Named::Label.new(loc, sym).freeze
    end


    def make_named_tuple(loc, exprs, index_by_label)
        ASSERT.kind_of loc,             Umu::Location
        ASSERT.kind_of exprs,           ::Array
        ASSERT.kind_of index_by_label,  ::Hash

        Unary::Container::Named::Entry.new(
            loc, exprs.freeze, index_by_label.freeze
        ).freeze
    end

end # Umu::AbstractSyntax::Core::Expression

end # Umu::AbstractSyntax::Core

end # Umu::AbstractSyntax

end # Umu
