# coding: utf-8
# frozen_string_literal: true



module Umu

module ConcreteSyntax

module Core

module Pattern

module Container

module Product

class Abstract < Container::Abstract
    alias pats array


    def to_s
        format "(%s)", self.map(&:to_s).join(', ')
    end


    def exported_vars
        self.reject(&:wildcard?).inject([]) { |array, pat|
            ASSERT.kind_of array,  ::Array
            ASSERT.kind_of pat,    Pattern::Abstract

            array + pat.exported_vars
        }.freeze
    end


private

    def __desugar_value__(expr, env, _event)
        ASSERT.kind_of expr, ASCE::Abstract

        ASCD.make_seq_of_declaration(
            self.loc,
            [
                ASCD.make_value(self.loc, :'%t', expr, __type_sym__)
            ] + (
                __desugar_pattern__(:'%t')
            )
        )
    end


    def __desugar_lambda__(seq_num, env, _event)
        ASSERT.kind_of seq_num, ::Integer

        var_sym = __gen_sym__ seq_num

        CSCP.make_result(
            ASCE.make_identifier(self.loc, var_sym),
            __desugar_pattern__(var_sym),
            __type_sym__
        )
    end


    def __desugar_pattern__(var_sym)
        ASSERT.kind_of var_sym, ::Symbol

        self.each_with_index.reject { |pat, _index|
            ASSERT.kind_of pat, Pattern::Abstract

            pat.wildcard? && pat.opt_type_sym.nil?
        }.map { |pat, index|
            ASSERT.kind_of pat,    Pattern::Abstract
            ASSERT.kind_of index,  ::Integer

            expr = ASCE.make_send(
                        pat.loc,
                        ASCE.make_identifier(pat.loc, var_sym),
                        __make_selector__(pat.loc, index, pat)
                    )

            ASCD.make_value pat.loc, pat.var_sym, expr, pat.opt_type_sym
        }
    end


    def __type_sym__
        raise X::InternalSubclassResponsibility
    end


    def __make_selector__(loc, index, pat)
        raise X::InternalSubclassResponsibility
    end
end



class Tuple < Abstract
    def initialize(loc, pats)
        ASSERT.kind_of  pats, ::Array
        ASSERT.assert   pats.size >= 2

        pats.reject(&:wildcard?).inject({}) do |hash, vpat|
            ASSERT.kind_of hash,    ::Hash
            ASSERT.kind_of vpat,    ElementOfContainer::Variable

            hash.merge(vpat.var_sym => true) { |key, _, _|
                raise X::SyntaxError.new(
                    loc,
                    "Duplicated pattern variable: '%s'", key.to_s
                )
            }
        end

        super
    end


    def each
        self.pats.each do |vpat|
            ASSERT.kind_of vpat, ElementOfContainer::Variable

            yield vpat
        end
    end


private

    def __type_sym__
        :Product
    end


    def __make_selector__(loc, index, _pat)
        ASCE.make_number_selector loc, index + 1
    end
end



module Named

class Field < Pattern::Abstract
    attr_reader :label, :vpat


    def initialize(loc, label, vpat)
        ASSERT.kind_of label, CSCE::Unary::Container::Named::Label
        ASSERT.kind_of vpat,  CSCP::ElementOfContainer::Variable

        super(loc)

        @label = label
        @vpat  = vpat
    end


    def var_sym
        self.vpat.var_sym
    end


    def opt_type_sym
        self.vpat.opt_type_sym
    end


    def to_s
        format "%s %s", self.label.to_s, self.vpat.to_s
    end


    def wildcard?
        self.vpat.wildcard?
    end


    def exported_vars
        self.vpat.exported_vars
    end
end



class Entry < Abstract
    attr_reader :index_by_label


    def initialize(loc, fields)
        ASSERT.kind_of  fields, ::Array
        ASSERT.assert   fields.size >= 1

        @index_by_label, vpat_hash, _index =
         fields
        .inject(
             [{},     {},     0    ]
        ) { |(l_hash, v_hash, index), (label, vpat)|
            ASSERT.kind_of l_hash, ::Hash
            ASSERT.kind_of v_hash, ::Hash
            ASSERT.kind_of label,  CSCE::Unary::Container::Named::Label
            ASSERT.kind_of vpat,   ElementOfContainer::Variable

            if vpat.wildcard?
                [
                    l_hash,
                    v_hash,
                    index + 1
                ]
            else
                [
                    l_hash.merge(label => index) { |key, _, _|
                        raise X::SyntaxError.new(
                            loc,
                            "Duplicated pattern label: '%s'", key.to_s
                        )
                    },

                    v_hash.merge(vpat => true) { |key, _, _|
                        raise X::SyntaxError.new(
                            loc,
                            "Duplicated pattern variable: '%s'", key.to_s
                        )
                    },

                    index + 1
                ]
            end
        }

        super(loc, vpat_hash.keys)
    end


    def each
        self.index_by_label.each do |label, index|
            ASSERT.kind_of label, CSCE::Unary::Container::Named::Label
            ASSERT.kind_of index, ::Integer

            yield CSCP.make_named_tuple_field(
                           self.loc,
                           label,
                           self.pats[index]
                       )
        end
    end


private

    def __type_sym__
        :Named
    end


    def __make_selector__(loc, _index, fpat)
        ASSERT.kind_of fpat, Field

        ASCE.make_label_selector loc, fpat.label.sym
    end
end

end # Umu::ConcreteSyntax::Core::Pattern::Container::Product::Named

end # Umu::ConcreteSyntax::Core::Pattern::Container::Product

end # Umu::ConcreteSyntax::Core::Pattern::Container


module_function

    def make_tuple(loc, vpats)
        ASSERT.kind_of loc,     LOC::Entry
        ASSERT.kind_of vpats,   ::Array

        Container::Product::Tuple.new(loc, vpats.freeze).freeze
    end


    def make_named_tuple(loc, fields)
        ASSERT.kind_of loc,     LOC::Entry
        ASSERT.kind_of fields,   ::Array

        Container::Product::Named::Entry.new(loc, fields.freeze).freeze
    end


    def make_named_tuple_field(loc, label, vpat)
        ASSERT.kind_of loc,     LOC::Entry
        ASSERT.kind_of label,   CSCE::Unary::Container::Named::Label
        ASSERT.kind_of vpat,    ElementOfContainer::Variable

        Container::Product::Named::Field.new(loc, label, vpat).freeze
    end

end # Umu::ConcreteSyntax::Core::Pattern

end # Umu::ConcreteSyntax::Core

end # Umu::ConcreteSyntax

end # Umu
