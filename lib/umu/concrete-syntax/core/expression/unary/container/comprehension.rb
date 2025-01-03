# coding: utf-8
# frozen_string_literal: true



module Umu

module ConcreteSyntax

module Core

module Expression

module Unary

module Container

module Comprehension

module Qualifier

class Abstract < Umu::Abstraction::Model
    attr_reader :expr


    def initialize(loc, expr)
        ASSERT.kind_of expr, CSCE::Abstract

        super(loc)

        @expr = expr
    end


    def pretty_print(q)
        raise X::InternalSubclassResponsibility
    end
end



class Generator < Abstract
    attr_reader :pat


    def initialize(loc, pat, expr)
        ASSERT.kind_of pat,     CSCP::Abstract
        ASSERT.kind_of expr,    CSCE::Abstract

        super(loc, expr)

        @pat = pat
    end


    def to_s
        format "%%VAL %s <- %s", self.pat.to_s, self.expr.to_s
    end


    def pretty_print(q)
        q.text '%VAL '
        q.pp self.pat
        q.text ' <- '
        q.pp self.expr
    end


    def desugar(elem_expr, tail_qualifiers, env)
        ASSERT.kind_of elem_expr,       CSCE::Abstract
        ASSERT.kind_of tail_qualifiers, ::Array
        ASSERT.kind_of env,             E::Entry

        ASCE.make_send(
            self.loc,

            self.expr.desugar(env),

            ASCE.make_message(
                self.loc,

                :'concat-map',

                [
                    CSCE.make_lambda(
                        self.loc,

                        [self.pat],

                        CSCE.make_comprehension(
                            self.loc,
                            elem_expr,
                            tail_qualifiers
                        )
                    ).desugar(env)
                ]
            ),

            [],

            :Morph
        )
    end
end



class Guard < Abstract
    def to_s
        format "%%IF %s", self.expr.to_s
    end


    def pretty_print(q)
        q.text '%IF '
        q.pp self.expr
    end


    def desugar(elem_expr, tail_qualifiers, env)
        ASSERT.kind_of elem_expr,       CSCE::Abstract
        ASSERT.kind_of tail_qualifiers, ::Array
        ASSERT.kind_of env,             E::Entry

        ASCE.make_if(
            self.loc,

            [
                ASCE.make_rule(
                    elem_expr.loc,
                    self.expr.desugar(env),
                    CSCE.make_comprehension(
                        self.loc,
                        elem_expr,
                        tail_qualifiers
                    ).desugar(env)
                )
            ],

            ASCE.make_list(self.loc, [])
        )
    end
end

end # Umu::ConcreteSyntax::Core::Expression::Unary::Container::Comprehension::Qualifier



class Entry < Container::Abstract
    alias       qualifiers exprs
    attr_reader :expr


    def initialize(loc, expr, qualifiers)
        ASSERT.kind_of expr,        CSCE::Abstract
        ASSERT.kind_of qualifiers,  ::Array

        super(loc, qualifiers)

        @expr = expr
    end


    def to_s
        format("[|%s|%s]",
            self.expr.to_s,

            if self.qualifiers.empty?
                ''
            else
                ' ' + self.qualifiers.map(&:to_s).join(' ')
            end
        )
    end


    def pretty_print(q)
        PRT.group q, bb: '[|', eb: '|' do
            q.pp self.expr
        end

        PRT.group_nary q, self.qualifiers, eb: ']', sep: ' ', join: ' '
    end


private

    def __desugar__(env, event)
        new_env = env.enter event

        if self.qualifiers.empty?
            ASCE.make_list self.loc, [self.expr.desugar(new_env)]
        else
            hd_qualifier, *tl_qualifiers = qualifiers
            ASSERT.kind_of hd_qualifier, Qualifier::Abstract

            hd_qualifier.desugar(self.expr, tl_qualifiers, new_env)
        end
    end
end

end # Umu::ConcreteSyntax::Core::Expression::Unary::Container::Comprehension

end # Umu::ConcreteSyntax::Core::Expression::Unary::Container

end # Umu::ConcreteSyntax::Core::Expression::Unary


module_function

    def make_generator(loc, pat, expr)
        ASSERT.kind_of loc,     LOC::Entry
        ASSERT.kind_of pat,     CSCP::Abstract
        ASSERT.kind_of expr,    CSCE::Abstract

        Unary::Container::Comprehension::Qualifier::Generator.new(
            loc, pat, expr
        ).freeze
    end


    def make_guard(loc, expr)
        ASSERT.kind_of loc,     LOC::Entry
        ASSERT.kind_of expr,    CSCE::Abstract

        Unary::Container::Comprehension::Qualifier::Guard.new(
            loc, expr
        ).freeze
    end


    def make_comprehension(loc, expr, qualifiers)
        ASSERT.kind_of loc,         LOC::Entry
        ASSERT.kind_of expr,        CSCE::Abstract
        ASSERT.kind_of qualifiers,  ::Array

        Unary::Container::Comprehension::Entry.new(
            loc, expr, qualifiers.freeze
        ).freeze
    end

end # Umu::ConcreteSyntax::Core::Expression

end # Umu::ConcreteSyntax::Core

end # Umu::ConcreteSyntax

end # Umu
