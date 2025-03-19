# coding: utf-8
# frozen_string_literal: true



module Umu

module ConcreteSyntax

module Core

module Pattern

module Container

module Morph

class Abstract < Container::Abstract
    alias       pats array
    attr_reader :opt_last_pat

    def initialize(loc, pats, opt_last_pat)
        ASSERT.kind_of      pats,           ::Array
        ASSERT.opt_kind_of  opt_last_pat,   ElementOfContainer::Variable
        ASSERT.assert (if pats.empty? then opt_last_pat.nil? else true end)

        init_hash = if self.opt_last_pat
                        {self.opt_last_pat.var_sym => true}
                    else
                        {}
                    end

        pats.reject(&:wildcard?).inject(init_hash) do |hash, vpat|
            ASSERT.kind_of vpat,    ElementOfContainer::Variable
            ASSERT.kind_of hash,    ::Hash

            hash.merge(vpat.var_sym => true) {
                raise X::SyntaxError.new(
                    vpat.loc,
                    "Duplicated pattern variable: '%s'", vpat.to_s
                )
            }
        end

        super(loc, pats)

        @opt_last_pat = opt_last_pat
    end


    def to_s
        [
            __bb__,

            self.map(&:to_s).join(', '),

            if self.opt_last_pat
                '|' + self.opt_last_pat.to_s
            else
                ''
            end,

            __eb__
        ].join
    end


    def pretty_print(q)
        if self.opt_last_pat
            last_pat = self.opt_last_pat

            PRT.group_for_enum q, self, bb:__bb__, join:', '

            PRT.group q, bb:'|', eb:__eb__ do
                q.pp last_pat
            end
        else
            PRT.group_for_enum q, self, bb:__bb__, eb:__eb__, join:', '
        end
    end


    def exported_vars
        (self.pats + [self.opt_last_pat]).reject(&:wildcard?).inject([]) {
            |array, vpat|
            ASSERT.kind_of array,   ::Array
            ASSERT.kind_of vpat,    ElementOfContainer::Variable

            array + vpat.exported_vars
        }.freeze
    end


private

    def __bb__
        raise X::InternalSubclassResponsibility
    end


    def __eb__
        raise X::InternalSubclassResponsibility
    end


    def __desugar_value__(expr, env, _event)
        ASSERT.kind_of expr, ASCE::Abstract

        decl = if self.pats.empty?
                __desugar_value_nil__(self.loc, expr)
            else
                ASCD.make_seq_of_declaration(
                    self.loc, __desugar__(expr, env)
                )
            end

        ASSERT.kind_of decl, ASCD::Abstract
    end


    def __desugar_lambda__(seq_num, env, _event)
        ASSERT.kind_of seq_num, ::Integer

        var_sym = __gen_sym__ seq_num

        opt_result = (
            if self.pats.empty?
                __desugar_lambda_nil__(self.loc)
            else
                CSCP.make_result(
                    ASCE.make_identifier(self.loc, var_sym),

                    __desugar__(
                        ASCE.make_identifier(self.loc, var_sym),
                        env
                    ),

                    __opt_type_sym_of_cons__
                )
            end
        )

        ASSERT.opt_kind_of opt_result, CSCP::Result
    end


    def __desugar__(expr, _env)
        ASSERT.kind_of expr, ASCE::Abstract

        head_vpat, *tail_pats = self.pats
        ASSERT.kind_of head_vpat, ElementOfContainer::Variable

        init_loc = head_vpat.loc

        init_seq_num = 1

        init_pair_sym = __gen_pair_sym__ init_seq_num

        init_decls = [
            ASCD.make_value(
                init_loc,
                init_pair_sym,
                __make_send_dest__(init_loc, expr)
            ),

            ASCD.make_value(
                init_loc,
                head_vpat.var_sym,
                __make_select_head__(init_loc, init_pair_sym),
                head_vpat.opt_type_sym
            )
        ]

        _final_seq_num, final_pair_sym, final_decls = tail_pats.inject(
             [init_seq_num, init_pair_sym, init_decls]
        ) {
            |(seq_num,      pair_sym,      decls     ), vpat|
            ASSERT.kind_of seq_num,     ::Integer
            ASSERT.kind_of pair_sym,    ::Symbol
            ASSERT.kind_of decls,       ::Array
            ASSERT.kind_of vpat,        ElementOfContainer::Variable

            loc             = vpat.loc
            next_seq_num    = seq_num + 1
            next_pair_sym   = __gen_pair_sym__ next_seq_num
            tail_list_expr  = __make_select_tail__ loc, pair_sym

            next_decls = (
                    decls
                ) + (
                    if vpat.wildcard?
                        [
                            ASCD.make_value(
                                loc,
                                next_pair_sym,
                                ASCE.make_product(
                                    loc,
                                    __make_send_dest__(loc, tail_list_expr),
                                    ASCE.make_number_selector(loc, 2)
                                ),
                                vpat.opt_type_sym
                            )
                        ]
                    else
                        [
                            ASCD.make_value(
                                loc,
                                next_pair_sym,
                                __make_send_dest__(loc, tail_list_expr)
                            ),

                            ASCD.make_value(
                                loc,
                                vpat.var_sym,
                                __make_select_head__(loc, next_pair_sym),
                                vpat.opt_type_sym
                            )

                        ]
                    end
                )

            [next_seq_num, next_pair_sym, next_decls]
        }

        (
            final_decls
        ) + (
            if self.opt_last_pat
                last_pat = self.opt_last_pat

                [
                    ASCD.make_value(
                        last_pat.loc,
                        last_pat.var_sym,
                        __make_select_tail__(last_pat.loc, final_pair_sym),
                        last_pat.opt_type_sym
                    )
                ]
            else
                [
                    __desugar_value_nil__(
                        loc,
                        __make_select_tail__(loc, final_pair_sym)
                    )
                ]
            end
        )
    end


    def __desugar_value_nil__(loc, expr)
        ASCD.make_value(
            loc, WILDCARD, expr, __opt_type_sym_of_nil__
        )
    end


    def __desugar_lambda_nil__(loc)
        CSCP.make_result(
            ASCE.make_identifier(loc, WILDCARD),
            [],
            __opt_type_sym_of_nil__
        )
    end


    def __gen_pair_sym__(num)
        ASSERT.kind_of num, ::Integer

        format("%%p%d", num).to_sym
    end


    def __make_send_dest__(loc, expr)
        ASSERT.kind_of loc,  LOC::Entry
        ASSERT.kind_of expr, ASCE::Abstract

        opt_type_sym = if self.opt_last_pat
                            self.opt_last_pat.opt_type_sym
                        else
                            __opt_type_sym_of_morph__
                        end

        ASCE.make_send(
            loc, expr, ASCE.make_message(loc, :dest!), [], opt_type_sym
        )
    end


    def __make_select_by_number__(loc, var_sym, sel_num)
        ASSERT.kind_of loc,     LOC::Entry
        ASSERT.kind_of var_sym, ::Symbol
        ASSERT.kind_of sel_num, ::Integer

        ASCE.make_product(
            loc,
            ASCE.make_identifier(loc, var_sym),
            ASCE.make_number_selector(loc, sel_num)
        )
    end


    def __make_select_head__(loc, var_sym)
        ASSERT.kind_of loc,     LOC::Entry
        ASSERT.kind_of var_sym, ::Symbol

        __make_select_by_number__ loc, var_sym, 1
    end


    def __make_select_tail__(loc, var_sym)
        ASSERT.kind_of loc,     LOC::Entry
        ASSERT.kind_of var_sym, ::Symbol

        __make_select_by_number__ loc, var_sym, 2
    end


    def __opt_type_sym_of_morph__
        raise X::InternalSubclassResponsibility
    end

    alias __opt_type_sym_of_nil__   __opt_type_sym_of_morph__
    alias __opt_type_sym_of_cons__  __opt_type_sym_of_morph__
end

end # Umu::ConcreteSyntax::Core::Pattern::Container::Morph

end # Umu::ConcreteSyntax::Core::Pattern::Container

end # Umu::ConcreteSyntax::Core::Pattern

end # Umu::ConcreteSyntax::Core

end # Umu::ConcreteSyntax

end # Umu
