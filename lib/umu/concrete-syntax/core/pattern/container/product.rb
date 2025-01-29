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


    def exported_vars
        self.reject(&:wildcard?).inject([]) { |array, epat|
            ASSERT.kind_of array,  ::Array
            ASSERT.kind_of epat,   Pattern::Abstract

            array + epat.exported_vars
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

        self.each_with_index.reject { |epat, _index|
            ASSERT.kind_of epat, ElementOfContainer::Abstract

            epat.wildcard? && epat.opt_type_sym.nil?
        }.map { |epat, index|
            ASSERT.kind_of epat,   ElementOfContainer::Abstract
            ASSERT.kind_of index,  ::Integer

            expr = ASCE.make_product(
                        epat.loc,
                        ASCE.make_identifier(epat.loc, var_sym),
                        __make_selector__(epat.loc, index, epat)
                    )

            ASCD.make_value(
                epat.loc,
                epat.var_pat.var_sym,
                expr,
                epat.var_pat.opt_type_sym
            )
        }
    end


    def __type_sym__
        raise X::InternalSubclassResponsibility
    end


    def __make_selector__(loc, index, epat)
        raise X::InternalSubclassResponsibility
    end
end



class Tuple < Abstract
    def initialize(loc, vpats)
        ASSERT.kind_of  vpats, ::Array
        ASSERT.assert   vpats.size >= 2

        vpats.reject(&:wildcard?).inject({}) do |hash, vpat|
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


    def to_s
        format "(%s)", self.map(&:to_s).join(', ')
    end


    def pretty_print(q)
        PRT.group_for_enum q, self, bb:'(', eb:')', join:', '
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

class Label < Abstraction::Model
    attr_reader :sym


    def initialize(loc, sym)
        ASSERT.kind_of sym, ::Symbol

        super(loc)

        @sym = sym
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
            ASSERT.kind_of label,  Label
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
            ASSERT.kind_of label, Label
            ASSERT.kind_of index, ::Integer

            yield CSCP.make_named_tuple_field(
                           self.loc,
                           label,
                           self.pats[index]
                       )
        end
    end


    def to_s
        format "(%s)", self.map(&:to_s).join(' ')
    end


    def pretty_print(q)
        PRT.group_for_enum q, self, bb:'(', eb:')', join:' '
    end


private

    def __type_sym__
        :Named
    end


    def __make_selector__(loc, _index, fpat)
        ASSERT.kind_of fpat, ElementOfContainer::Field

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
        ASSERT.kind_of fields,  ::Array

        Container::Product::Named::Entry.new(loc, fields.freeze).freeze
    end

    def make_named_tuple_label(loc, sym)
        ASSERT.kind_of loc,     LOC::Entry
        ASSERT.kind_of sym,     ::Symbol

        Container::Product::Named::Label.new(loc, sym).freeze
    end


end # Umu::ConcreteSyntax::Core::Pattern

end # Umu::ConcreteSyntax::Core

end # Umu::ConcreteSyntax

end # Umu
