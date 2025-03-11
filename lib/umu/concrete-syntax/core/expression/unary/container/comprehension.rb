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


    def desugar_qualifier(
        env, elem_expr, tail_qualifiers, type_coercion_sym,
        make_comprehension, _make_morph
    )
        ASSERT.kind_of env,                 E::Entry
        ASSERT.kind_of elem_expr,           CSCE::Abstract
        ASSERT.kind_of tail_qualifiers,     ::Array
        ASSERT.kind_of type_coercion_sym,   ::Symbol
        ASSERT.kind_of make_comprehension,  ::Proc
        ASSERT.kind_of _make_morph,         ::Proc

        body_expr = make_comprehension.call(
                         self.loc, elem_expr, tail_qualifiers
                    )

        ASCE.make_send(
            self.loc,

            self.expr.desugar(env),

            ASCE.make_message(self.loc, type_coercion_sym),

            [
                ASCE.make_message(
                    self.loc,

                    :'concat-map',

                    [
                        CSCE.make_lambda(
                            self.loc, [self.pat], body_expr
                        ).desugar(env)
                    ]
                )
            ]
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


    def desugar_qualifier(
        env, elem_expr, tail_qualifiers, _type_coercion_sym,
        make_comprehension, make_morph
    )
        ASSERT.kind_of env,                 E::Entry
        ASSERT.kind_of elem_expr,           CSCE::Abstract
        ASSERT.kind_of tail_qualifiers,     ::Array
        ASSERT.kind_of _type_coercion_sym,  ::Symbol
        ASSERT.kind_of make_comprehension,  ::Proc
        ASSERT.kind_of make_morph,         ::Proc

        then_expr = make_comprehension.call(
                         self.loc, elem_expr, tail_qualifiers
                    )

        ASCE.make_if(
            self.loc,

            [
                ASCE.make_rule(
                    elem_expr.loc,
                    self.expr.desugar(env),
                    then_expr.desugar(env)
                )
            ],

            make_morph.call(self.loc, [])
        )
    end
end

end # Umu::ConcreteSyntax::Core::Expression::Unary::Container::Comprehension::Qualifier



module Entry

class Abstract < Container::Abstract
    alias       qualifiers exprs
    attr_reader :expr


    def initialize(loc, expr, qualifiers)
        ASSERT.kind_of expr,        CSCE::Abstract
        ASSERT.kind_of qualifiers,  ::Array

        super(loc, qualifiers)

        @expr = expr
    end


    def to_s
        format("%s%s|%s]",
            __bb__,

            self.expr.to_s,

            if self.qualifiers.empty?
                ''
            else
                ' ' + self.qualifiers.map(&:to_s).join(' ')
            end
        )
    end


    def pretty_print(q)
        PRT.group q, bb:__bb__, eb:'|' do
            q.pp self.expr
        end

        PRT.group_for_enum q, self.qualifiers, eb:']', sep:' ', join:' '
    end


private

    def __desugar__(env, event)
        new_env = env.enter event

        if self.qualifiers.empty?
            __make_morph__ self.loc, [self.expr.desugar(new_env)]
        else
            hd_qualifier, *tl_qualifiers = qualifiers
            ASSERT.kind_of hd_qualifier, Qualifier::Abstract

            hd_qualifier.desugar_qualifier(
                new_env, self.expr, tl_qualifiers, __type_coercion_sym__,

                lambda { |loc, expr, qualifiers|
                    __make_comprehension__ loc, expr, qualifiers
                },

                lambda { |loc, exprs|
                    __make_morph__ loc, exprs
                }
            )
        end
    end
end



class List < Abstract

private

    def __bb__
        '[|'
    end


    def __type_coercion_sym__
        :'to-list'
    end


    def __make_comprehension__(loc, expr, qualifiers)
        CSCE.make_list_comprehension loc, expr, qualifiers
    end


    def __make_morph__(loc, exprs)
        ASCE.make_list loc, exprs
    end
end



class Stream < Abstract

private

    def __bb__
        '&[|'
    end


    def __type_coercion_sym__
        :'susp'
    end


    def __make_comprehension__(loc, expr, qualifiers)
        CSCE.make_stream_comprehension loc, expr, qualifiers
    end


    def __make_morph__(loc, exprs)
        ASCE.make_stream loc, exprs
    end
end

end # Umu::ConcreteSyntax::Core::Expression::Unary::Container::Comprehension::Entry

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


    def make_list_comprehension(loc, expr, qualifiers)
        ASSERT.kind_of loc,         LOC::Entry
        ASSERT.kind_of expr,        CSCE::Abstract
        ASSERT.kind_of qualifiers,  ::Array

        Unary::Container::Comprehension::Entry::List.new(
            loc, expr, qualifiers.freeze
        ).freeze
    end


    def make_stream_comprehension(loc, expr, qualifiers)
        ASSERT.kind_of loc,         LOC::Entry
        ASSERT.kind_of expr,        CSCE::Abstract
        ASSERT.kind_of qualifiers,  ::Array

        Unary::Container::Comprehension::Entry::Stream.new(
            loc, expr, qualifiers.freeze
        ).freeze
    end

end # Umu::ConcreteSyntax::Core::Expression

end # Umu::ConcreteSyntax::Core

end # Umu::ConcreteSyntax

end # Umu
