# coding: utf-8
# frozen_string_literal: true



module Umu

module ConcreteSyntax

module Core

module Expression

module Nary

module Branch

module Rule

module Case

module_function

    def make_rule_mono_nil(loc, type_sym)
        ASSERT.kind_of loc,         LOC::Entry
        ASSERT.kind_of type_sym,    ::Symbol

        CSCE.make_case_rule_poly_nil(loc, type_sym)
    end


    def make_rule_mono_cons(loc, head_pat, tail_pat, type_sym)
        ASSERT.kind_of loc,         LOC::Entry
        ASSERT.kind_of head_pat,    CSCP::ElementOfContainer::Variable
        ASSERT.kind_of tail_pat,    CSCP::ElementOfContainer::Variable
        ASSERT.kind_of type_sym,    ::Symbol

        if tail_pat.opt_type_sym
            raise X::SyntaxError.new(
                loc,
                format("case: Can not specify type assertion for " +
                                                "tail pattern: '%s'",
                    tail_pat
                )
            )
        end

        CSCE.make_case_rule_poly_cons(
            loc,
            head_pat,
            CSCP.make_variable(tail_pat.loc, tail_pat.var_sym, type_sym),
            type_sym
        )
    end

end # Umu::ConcreteSyntax::Core::Expression::Nary::Branch::Rule::Case

end # Umu::ConcreteSyntax::Core::Expression::Nary::Branch::Rule

end # Umu::ConcreteSyntax::Core::Expression::Nary::Branch

end # Umu::ConcreteSyntax::Core::Expression::Nary

module_function

    # 1. For list

    def make_case_rule_list_nil(loc)
        ASSERT.kind_of loc, LOC::Entry

        Nary::Branch::Rule::Case.make_rule_mono_nil(loc, :List)
    end


    def make_case_rule_list_cons(loc, head_pat, tail_pat)
        ASSERT.kind_of loc,         LOC::Entry
        ASSERT.kind_of head_pat,    CSCP::ElementOfContainer::Variable
        ASSERT.kind_of tail_pat,    CSCP::ElementOfContainer::Variable

        Nary::Branch::Rule::Case.make_rule_mono_cons(
            loc, head_pat, tail_pat, :List
        )
    end


    # 2. For cell stream

    def make_case_rule_cell_stream_nil(loc)
        ASSERT.kind_of loc, LOC::Entry

        Nary::Branch::Rule::Case.make_rule_mono_nil(loc, :CellStream)
    end


    def make_case_rule_cell_stream_cons(loc, head_pat, tail_pat)
        ASSERT.kind_of loc,         LOC::Entry
        ASSERT.kind_of head_pat,    CSCP::ElementOfContainer::Variable
        ASSERT.kind_of tail_pat,    CSCP::ElementOfContainer::Variable

        Nary::Branch::Rule::Case.make_rule_mono_cons(
            loc, head_pat, tail_pat, :CellStream
        )
    end


    # 3. For memorized stream

    def make_case_rule_memo_stream_nil(loc)
        ASSERT.kind_of loc, LOC::Entry

        Nary::Branch::Rule::Case.make_rule_mono_nil(loc, :MemoStream)
    end


    def make_case_rule_memo_stream_cons(loc, head_pat, tail_pat)
        ASSERT.kind_of loc,         LOC::Entry
        ASSERT.kind_of head_pat,    CSCP::ElementOfContainer::Variable
        ASSERT.kind_of tail_pat,    CSCP::ElementOfContainer::Variable

        Nary::Branch::Rule::Case.make_rule_mono_cons(
            loc, head_pat, tail_pat, :MemoStream
        )
    end

end # Umu::ConcreteSyntax::Core::Expression

end # Umu::ConcreteSyntax::Core

end # Umu::ConcreteSyntax

end # Umu
