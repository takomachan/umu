# coding: utf-8
# frozen_string_literal: true



module Umu

module ConcreteSyntax

module Core

module Expression

module Nary

module Lambda

class Abstract < Expression::Abstract
    attr_reader :pats, :expr, :decls


    def initialize(loc, pats, expr, decls)
        ASSERT.kind_of pats,    ::Array
        ASSERT.kind_of expr,    CSCE::Abstract
        ASSERT.kind_of decls,   ::Array

        super(loc)

        @pats   = pats
        @expr   = expr
        @decls  = decls
    end


    def to_s
        format "%s -> %s", self.pats.map(&:to_s).join(' '), self.expr.to_s
    end


private

    def __name_sym__
        raise X::InternalSubclassResponsibility
    end


    def __desugar__(env, event)
        new_env = env.enter event

        lamb_params, lamb_decls = self.pats.each_with_index.inject(
             [[],       []]
        ) {
            |(params,   decls),         (pat, index)|
            ASSERT.kind_of params,  ::Array
            ASSERT.kind_of decls,   ::Array
            ASSERT.kind_of pat,     CSCP::Abstract
            ASSERT.kind_of index,   ::Integer

            result = pat.desugar_lambda index + 1, new_env
            ASSERT.kind_of result, CSCP::Result
            param = ASCE.make_parameter(
                        result.ident.loc, result.ident, result.opt_type_sym
                    )

            [params + [param], decls + result.decls]
        }

        local_decls = lamb_decls + self.decls.map { |decl|
                            decl.desugar new_env
                        }
        body_expr  = self.expr.desugar new_env
        lamb_expr = if local_decls.empty?
                        body_expr
                    else
                        ASCE.make_let(
                            self.loc,

                            ASCD.make_seq_of_declaration(
                                self.loc,
                                local_decls
                            ),

                            body_expr
                        )
                    end

        ASCE.make_lambda self.loc, lamb_params, lamb_expr, __name_sym__
    end
end



class Named < Abstract
    attr_reader :sym


    def initialize(loc, pats, expr, decls, sym)
        ASSERT.kind_of pats,    ::Array
        ASSERT.kind_of expr,    CSCE::Abstract
        ASSERT.kind_of decls,   ::Array
        ASSERT.kind_of sym,     ::Symbol

        super(loc, pats, expr, decls)

        @sym = sym
    end


    def to_s
        format("%s = %s%s",
                self.sym.to_s,

                super,

                if self.decls.empty?
                    ''
                else
                    format(" %%WHERE {%s}", self.decls.map(&:to_s).join(' '))
                end
        )
    end


    def pretty_print(q)
        q.group(
            PP_INDENT_WIDTH,
            format("%s =", self.sym.to_s),
            ''
        ) do
            self.pats.each do |pat|
                q.breakable

                q.pp pat
            end
        end

        q.breakable

        q.group(PP_INDENT_WIDTH, '-> ', '') do
            q.pp self.expr
        end

        unless self.decls.empty?
            q.breakable

            q.group(PP_INDENT_WIDTH, '%WHERE {', '') do
                self.decls.each do |decl|
                    q.breakable

                    q.pp decl
                end
            end

            q.breakable

            q.text '}'
        end
    end


private

    def __name_sym__
        self.sym
    end
end



class Anonymous < Abstract

    def to_s
        format("{%s%s}",
                super,

                if self.decls.empty?
                    ''
                else
                    format(" %%WHERE %s", self.decls.map(&:to_s).join(' '))
                end
        )
    end


    def pretty_print(q)
        q.group(PP_INDENT_WIDTH, '{', '') do
            self.pats.each do |pat|
                q.breakable

                q.pp pat
            end
        end

        q.breakable

        q.group(PP_INDENT_WIDTH, '-> ', '') do
            q.pp self.expr
        end

        q.breakable

        unless self.decls.empty?
            q.group(PP_INDENT_WIDTH, '%WHERE', '') do
                self.decls.each do |decl|
                    q.breakable

                    q.pp decl
                end
            end
        end

        q.text '}'
    end

private

    def __name_sym__
        nil
    end
end

end # Umu::ConcreteSyntax::Core::Expression::Nary::Lambda

end # Umu::ConcreteSyntax::Core::Expression::Nary


module_function

    def make_lambda(loc, pats, expr, decls = [])
        ASSERT.kind_of loc,     LOC::Entry
        ASSERT.kind_of pats,    ::Array
        ASSERT.kind_of expr,    CSCE::Abstract
        ASSERT.kind_of decls,   ::Array

        Nary::Lambda::Anonymous.new(loc, pats, expr, decls.freeze).freeze
    end


    def make_named_lambda(loc, pats, expr, decls, sym)
        ASSERT.kind_of loc,     LOC::Entry
        ASSERT.kind_of pats,    ::Array
        ASSERT.kind_of expr,    CSCE::Abstract
        ASSERT.kind_of decls,   ::Array
        ASSERT.kind_of sym,     ::Symbol

        Nary::Lambda::Named.new(loc, pats, expr, decls.freeze, sym).freeze
    end

end # Umu::ConcreteSyntax::Core::Expression

end # Umu::ConcreteSyntax::Core

end # Umu::ConcreteSyntax

end # Umu
