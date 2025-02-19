# coding: utf-8
# frozen_string_literal: true



module Umu

module ConcreteSyntax

module Core

module Expression

module Nary

module Rule

module Abstraction

class Abstract < Umu::Abstraction::Model
    def line_num
        self.loc.line_num
    end


    def desugar_morph_rule(env)
        raise X::InternalSubclassResponsibility
    end
end



class WithHead < Abstract
    attr_reader :head, :body_expr


    def initialize(loc, head, body_expr)
        ASSERT.kind_of head,        Umu::Abstraction::Model
        ASSERT.kind_of body_expr,   CSCE::Abstract

        super(loc)

        @head       = head
        @body_expr  = body_expr
    end


    def to_s
        format "%s -> %s", self.head.to_s, self.body_expr.to_s
    end


    def pretty_print(q)
        q.pp self.head
        q.text ' -> '
        q.pp self.body_expr
    end
end

end # Umu::ConcreteSyntax::Core::Expression::Nary::Rule::Abstraction



class If < Abstraction::WithHead
    alias head_expr head

    def initialize(loc, head_expr, body_expr)
        ASSERT.kind_of head_expr,   CSCE::Abstract
        ASSERT.kind_of body_expr,   CSCE::Abstract

        super
    end


    def to_s
        format "%s %%THEN %s", self.head_expr, self.body_expr
    end


    def pretty_print(q)
        q.pp self.head_expr
        q.text ' %THEN '
        q.pp self.body_expr
    end
end



class Cond < Abstraction::WithHead
    alias head_expr head
end



module Case

module Head

class Abstract < Umu::Abstraction::Model
    attr_reader :obj


    def initialize(loc, obj)
        ASSERT.kind_of obj, ::Object

        super(loc)

        @obj = obj
    end


    def type_sym
        raise X::InternalSubclassResponsibility
    end
end



class Atom < Abstract
    alias atom_value obj


    def initialize(loc, atom_value)
        ASSERT.kind_of atom_value, VCA::Abstract

        super
    end


    def to_s
        self.obj.to_s
    end


    def pretty_print(q)
        self.obj.pretty_print(q)
    end


    def type_sym
        :Atom
    end
end



class Datum < Abstract
    alias       tag_sym obj
    attr_reader :opt_contents_pat


    def initialize(loc, tag_sym, opt_contents_pat)
        ASSERT.kind_of      tag_sym,            ::Symbol
        ASSERT.opt_kind_of  opt_contents_pat,   CSCP::Abstract

        super(loc, tag_sym)

        @opt_contents_pat = opt_contents_pat
    end


    def type_sym
        :Datum
    end


    def to_s
        format("%s%s",
                self.tag_sym.to_s,

                if self.opt_contents_pat
                    ' ' + self.opt_contents_pat.to_s
                else
                    ''
                end
        )
    end


    def pretty_print(q)
        q.text self.tag_sym.to_s

        if self.opt_contents_pat
            q.text ' '
            q.pp self.opt_contents_pat
        end
    end
end



class Class < Abstract
    alias       class_ident obj

    attr_reader :opt_contents_pat
    attr_reader :opt_superclass_ident


    def initialize(loc, class_ident, opt_contents_pat, opt_superclass_ident)
        ASSERT.kind_of      class_ident,          CSCEU::Identifier::Short
        ASSERT.opt_kind_of  opt_contents_pat,     CSCP::Abstract
        ASSERT.opt_kind_of  opt_superclass_ident, CSCEU::Identifier::Short

        super(loc, class_ident)

        @opt_contents_pat     = opt_contents_pat
        @opt_superclass_ident = opt_superclass_ident
    end


    def type_sym
        :Class
    end


    def to_s
        format("&%s%s",
                if self.opt_superclass_ident
                    format("(%s < %s)",
                             self.class_ident.to_s,
                             self.opt_superclass_ident.to_s
                    )
                else
                    self.class_ident.to_s
                end,

                if self.opt_contents_pat
                    ' ' + self.opt_contents_pat.to_s
                else
                    ''
                end
        )
    end


    def pretty_print(q)
        q.text '&'
        if self.opt_superclass_ident
            q.text format("(%s < %s)",
                         self.class_ident.to_s,
                         self.opt_superclass_ident.to_s
                    )
        else
            q.text self.class_ident.to_s
        end

        if self.opt_contents_pat
            q.text ' '
            q.pp self.opt_contents_pat
        end
    end
end



module Morph

class Abstract < Head::Abstract
    alias opt_source_type_sym obj

    def initialize(loc, opt_source_type_sym)
        ASSERT.opt_kind_of opt_source_type_sym, ::Symbol

        super
    end
end



class Nil < Abstract
    def type_sym
        :MorphNil
    end


    def to_s
        format("%%[]%s",
            if self.opt_source_type_sym
                format " : %s", self.opt_source_type_sym
            else
                ''
            end
        )
    end


    def pretty_print(q)
        q.text self.to_s
    end
end



class Cons < Abstract
    attr_reader :head_pat, :tail_pat

    def initialize(loc, head_pat, tail_pat, opt_source_type_sym)
        ASSERT.kind_of     head_pat,            CSCP::Abstract
        ASSERT.kind_of     tail_pat,            CSCP::Abstract
        ASSERT.opt_kind_of opt_source_type_sym, ::Symbol

        super(loc, opt_source_type_sym)
        @head_pat = head_pat
        @tail_pat = tail_pat
    end


    def type_sym
        :MorphCons
    end


    def to_s
        format("%%[%s%s]",
                self.head_pat.to_s,

                format(" | %s", self.tail_pat.to_s)
        )
    end


    def pretty_print(q)
        PRT.group q, bb:'%[', eb:']' do
            q.pp self.head_pat

            if self.tail_pat
                q.breakable

                q.text '|'

                q.breakable

                q.pp self.tail_pat
            end
        end
    end
end

end # Umu::ConcreteSyntax::Core::Expression::Nary::Rule::Case::Head::Morph

end # Umu::ConcreteSyntax::Core::Expression::Nary::Rule::Case::Head


class Otherwise < Abstraction::Abstract
    attr_reader :expr

    def initialize(loc, expr)
        ASSERT.kind_of expr, CSCE::Abstract

        super(loc)

        @expr = expr
    end


    def desugar_morph_rule(env)
        self.expr.desugar env
    end
end



class Unmatch < Abstraction::Abstract
    def desugar_morph_rule(_env)
        ASCE.make_raise(
            self.loc,
            X::UnmatchError,
            ASCE.make_string(self.loc, "No rules matched")
        )
    end
end



class Entry < Abstraction::WithHead
    def desugar_morph_rule(env)
        self.body_expr.desugar env
    end
end

end # Umu::ConcreteSyntax::Core::Expression::Nary::Rule::Case

end # Umu::ConcreteSyntax::Core::Expression::Nary::Rule

end # Umu::ConcreteSyntax::Core::Expression::Nary


module_function

    def make_if_rule(loc, head_expr, body_expr)
        ASSERT.kind_of loc,         LOC::Entry
        ASSERT.kind_of head_expr,   CSCE::Abstract
        ASSERT.kind_of body_expr,   CSCE::Abstract

        Nary::Rule::If.new(
            loc, head_expr, body_expr 
        ).freeze
    end


    def make_cond_rule(loc, head_expr, body_expr)
        ASSERT.kind_of loc,         LOC::Entry
        ASSERT.kind_of head_expr,   CSCE::Abstract
        ASSERT.kind_of body_expr,   CSCE::Abstract

        Nary::Rule::Cond.new(loc, head_expr, body_expr).freeze
    end


    def make_case_rule(loc, head, body_expr)
        ASSERT.kind_of loc,         LOC::Entry
        ASSERT.kind_of head,        CSCEN::Rule::Case::Head::Abstract
        ASSERT.kind_of body_expr,   CSCE::Abstract

        Nary::Rule::Case::Entry.new(loc, head, body_expr).freeze
    end


    def make_case_rule_otherwise(loc, expr)
        ASSERT.kind_of loc,     LOC::Entry
        ASSERT.kind_of expr,    CSCE::Abstract

        Nary::Rule::Case::Otherwise.new(loc, expr).freeze
    end


    def make_case_rule_unmatch(loc)
        ASSERT.kind_of loc, LOC::Entry

        Nary::Rule::Case::Unmatch.new(loc).freeze
    end


    def make_case_rule_head_atom(loc, atom_value)
        ASSERT.kind_of loc,         LOC::Entry
        ASSERT.kind_of atom_value,  VCA::Abstract

        Nary::Rule::Case::Head::Atom.new(
            loc, atom_value
        ).freeze
    end


    def make_case_rule_head_datum(loc, tag_sym, opt_contents_pat)
        ASSERT.kind_of      loc,                LOC::Entry
        ASSERT.kind_of      tag_sym,            ::Symbol
        ASSERT.opt_kind_of  opt_contents_pat,   CSCP::Abstract

        Nary::Rule::Case::Head::Datum.new(
            loc, tag_sym, opt_contents_pat
        ).freeze
    end


    def make_case_rule_head_class(
        loc, class_ident, opt_contents_pat, opt_superclass_ident = nil
    )
        ASSERT.kind_of      loc,                  LOC::Entry
        ASSERT.kind_of      class_ident,          CSCEU::Identifier::Short
        ASSERT.opt_kind_of  opt_contents_pat,     CSCP::Abstract
        ASSERT.opt_kind_of  opt_superclass_ident, CSCEU::Identifier::Short

        Nary::Rule::Case::Head::Class.new(
            loc, class_ident, opt_contents_pat, opt_superclass_ident
        ).freeze
    end


    def make_case_rule_head_morph_nil(loc, opt_source_type_sym = nil)
        ASSERT.kind_of     loc,                 LOC::Entry
        ASSERT.opt_kind_of opt_source_type_sym, ::Symbol

        Nary::Rule::Case::Head::Morph::Nil.new(
            loc, opt_source_type_sym, 
        ).freeze
    end


    def make_case_rule_head_morph_cons(
        loc, head_pat, tail_pat, opt_source_type_sym = nil
    )
        ASSERT.kind_of loc,         LOC::Entry
        ASSERT.kind_of head_pat,    CSCP::Abstract
        ASSERT.kind_of tail_pat,    CSCP::Abstract
        ASSERT.opt_kind_of opt_source_type_sym, ::Symbol

        Nary::Rule::Case::Head::Morph::Cons.new(
            loc, head_pat, tail_pat, opt_source_type_sym
        ).freeze
    end

end # Umu::ConcreteSyntax::Core::Expression

end # Umu::ConcreteSyntax::Core

end # Umu::ConcreteSyntax

end # Umu
