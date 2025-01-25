# coding: utf-8
# frozen_string_literal: true



module Umu

module ConcreteSyntax

module Module

module Declaration

class Abstract < Module::Abstract
    def exported_vars
        raise X::InternalSubclassResponsibility
    end
end



class Structure < Abstract
    attr_reader :pat, :expr, :local_decls


    def initialize(loc, pat, expr, local_decls)
        ASSERT.kind_of pat,         CSMP::Abstract
        ASSERT.kind_of expr,        CSME::Abstract
        ASSERT.kind_of local_decls, ::Array

        super(loc)

        @pat         = pat
        @expr        = expr
        @local_decls = local_decls
    end


    def to_s
        format("%%STRUCTURE %s = %s%s",
                 self.pat.to_s,

                 self.expr.to_s,

                if self.local_decls.empty?
                    ''
                else
                    format(" %%WHERE {%s}",
                            self.local_decls.map(&:to_s).join(' ')
                    )
                end
        )
    end


    def pretty_print(q)
        PRT.group q, bb: format("%%STRUCTURE %s = ", self.pat.to_s) do
            q.pp self.expr
        end

        unless self.local_decls.empty?
            q.breakable

            PRT.group_for_enum(
                 q, self.local_decls, bb: '%WHERE {', eb: '}', sep: ' '
            )
        end
    end


    def exported_vars
        self.pat.exported_vars
    end


private

    def __desugar__(env, event)
        new_env = env.enter event

        expr = if self.local_decls.empty?
                self.expr.desugar new_env
            else
                ASCE.make_let(
                    self.loc,

                    ASCD.make_seq_of_declaration(
                        self.loc,
                        self.local_decls.map { |decl| decl.desugar new_env }
                    ),

                    self.expr.desugar(new_env)
                )
            end

        self.pat.desugar_value expr, new_env
    end
end



module Import

module Fields

class Abstract < Abstraction::Model
    attr_reader :fields


    def initialize(loc, fields)
        ASSERT.kind_of  fields, ::Array

        super(loc)

        @fields = fields
    end


    def to_s
        self.fields.map { |target_id, opt_type_sym, opt_source_id|
            ASSERT.kind_of     target_id,       CSME::Identifier::Short
            ASSERT.opt_kind_of opt_type_sym,    ::Symbol
            ASSERT.opt_kind_of opt_source_id,   CSME::Identifier::Abstract

            __format_field__ target_id, opt_type_sym, opt_source_id
        }.join(' ')
    end


    def pretty_print(q)
        return if self.fields.empty?

        fst_field, *not_fst_fields = self.fields
        q.text __format_field__(*fst_field)

        not_fst_fields.each do |field|
            q.breakable

            q.text __format_field__(*field)
        end
    end


    def desugar_field(env, souce_dir_id)
        ASSERT.kind_of souce_dir_id, CSME::Identifier::Abstract

        self.fields.map { |target_id, opt_type_sym, opt_source_id|
            ASSERT.kind_of     target_id,       CSME::Identifier::Short
            ASSERT.opt_kind_of opt_type_sym,    ::Symbol
            ASSERT.opt_kind_of opt_source_id,   CSME::Identifier::Abstract

            expr = ASCE.make_long_identifier(
                souce_dir_id.loc,

                souce_dir_id.head.desugar(env),

                (
                    souce_dir_id.tail + (
                        opt_source_id ? opt_source_id : target_id
                    ).to_a
                ).map { |id| id.desugar env }
            )

            ASCD.make_value(
                target_id.loc,
                target_id.sym,
                expr,
                __opt_type_sym__(opt_type_sym)
            )
        }
    end


private

    def __reserved_word__
        raise X::InternalSubclassResponsibility
    end


    def __opt_type_sym__
        raise X::InternalSubclassResponsibility
    end


    def __format_field__(target_id, opt_type_sym, opt_source_id)
        format("%%%s %s%s%s",
                __reserved_word__,

                target_id.to_s,

                if opt_type_sym
                    format " : %s", opt_type_sym.to_s
                else
                    ''
                end,

                if opt_source_id
                    format " = %s", opt_source_id.to_s
                else
                    ''
                end
        )
    end
end



class Value < Abstract

private

    def __reserved_word__
        'VAL'
    end

    def __opt_type_sym__(opt_type_sym)
        opt_type_sym
    end
end



class Function < Abstract

private

    def __reserved_word__
        'FUN'
    end

    def __opt_type_sym__(opt_type_sym)
        opt_type_sym || :Fun
    end
end



class Structure < Abstract

private

    def __reserved_word__
        'STRUCTURE'
    end

    def __opt_type_sym__(opt_type_sym)
        opt_type_sym || :Struct
    end
end

end # Umu::ConcreteSyntax::Module::Declaration::Import::Fields

class Entry < Declaration::Abstract
    attr_reader :id, :opt_fields


    def initialize(loc, id, opt_fields)
        ASSERT.kind_of      id,         CSME::Identifier::Abstract
        ASSERT.opt_kind_of  opt_fields, ::Array

        super(loc)

        @id         = id
        @opt_fields = opt_fields
    end


    def to_s
        body = if self.opt_fields
                    fields = self.opt_fields

                    format " { %s }", fields.map(&:to_s).join(' ')
                else
                    ''
                end

        format "%%IMPORT %s%s", self.id.to_s, body
    end


    def pretty_print(q)
        q.text '%IMPORT '
        q.text self.id.to_s

        if self.opt_fields
            PRT.group_for_enum(
                q, self.opt_fields, bb: ' {', eb: '}', sep: ' '
           ) do |field| q.pp field end
        end
    end


    def exported_vars
        [].freeze
    end


private

    def __desugar__(env, event)
        new_env = env.enter event

        result = if self.opt_fields
            fields = self.opt_fields

            decls = fields.inject([]) { |array, field|
                ASSERT.kind_of field, Fields::Abstract

                array + field.desugar_field(new_env, self.id)
            }

            ASCD.make_seq_of_declaration self.loc, decls
        else
            ASCD.make_import self.loc, self.id.desugar(new_env)
        end

        ASSERT.kind_of result, ASCD::Abstract
    end
end

end # Umu::ConcreteSyntax::Module::Declaration::Import



class Core < Abstract
    attr_reader :core_decl


    def initialize(loc, core_decl)
        ASSERT.kind_of core_decl, CSCD::Abstract

        super(loc)

        @core_decl = core_decl
    end


    def to_s
        self.core_decl.to_s
    end


    def pretty_print(q)
        q.pp self.core_decl
    end


    def exported_vars
        self.core_decl.exported_vars
    end


private

    def __desugar__(env, event)
        self.core_decl.desugar env.enter(event)
    end
end



module_function

    def make_structure(loc, pat, expr, local_decls)
        ASSERT.kind_of pat,         CSMP::Abstract
        ASSERT.kind_of expr,        CSME::Abstract
        ASSERT.kind_of local_decls, ::Array

        Structure.new(loc, pat, expr, local_decls.freeze).freeze
    end


    def make_import(loc, id, opt_fields)
        ASSERT.kind_of      id,         CSME::Identifier::Abstract
        ASSERT.opt_kind_of  opt_fields, ::Array

        Import::Entry.new(loc, id, opt_fields.freeze).freeze
    end


    def make_value_fields_of_import(loc, atomic_fields)
        ASSERT.kind_of atomic_fields, ::Array

        Import::Fields::Value.new(loc, atomic_fields.freeze).freeze
    end


    def make_function_fields_of_import(loc, atomic_fields)
        ASSERT.kind_of atomic_fields, ::Array

        Import::Fields::Function.new(loc, atomic_fields.freeze).freeze
    end


    def make_structure_fields_of_import(loc, atomic_fields)
        ASSERT.kind_of atomic_fields, ::Array

        Import::Fields::Structure.new(loc, atomic_fields.freeze).freeze
    end


    def make_core(loc, core_decl)
        ASSERT.kind_of core_decl, CSCD::Abstract

        Core.new(loc, core_decl).freeze
    end

end # Umu::ConcreteSyntax::Module::Declaration

end # Umu::ConcreteSyntax::Module

end # Umu::ConcreteSyntax

end # Umu
