# coding: utf-8
# frozen_string_literal: true



module Umu

module Environment

module Context

module Type

module Signature

module Class

class Abstract
    def lookup_instance_method(sym, loc, env)
        raise X::InternalSubclassResponsibility
    end
end



class Base < Abstract
    attr_reader :klass
    attr_reader :symbol
    attr_reader :class_method_info_of_symbol
    attr_reader :instance_method_info_of_symbol

    alias to_sym symbol


    def initialize(
        klass,
        symbol,
        class_method_info_of_symbol,
        instance_method_info_of_symbol
    )
        ASSERT.subclass_of  klass,                          VC::Top
        ASSERT.kind_of      symbol,                         ::Symbol
        ASSERT.kind_of      class_method_info_of_symbol,    ::Hash
        ASSERT.kind_of      instance_method_info_of_symbol, ::Hash

        @klass                          = klass
        @symbol                         = symbol
        @class_method_info_of_symbol    = class_method_info_of_symbol
        @instance_method_info_of_symbol = instance_method_info_of_symbol
    end


    def ==(other)
        other.kind_of?(Abstract) && self.symbol == other.symbol
    end
    alias eql? ==


    def <=>(other)
        ASSERT.kind_of other, Abstract

        self.symbol <=> other.symbol
    end


    def hash
        self.symbol.hash
    end


    def num_of_class_methods
        self.class_method_info_of_symbol.size
    end


    def each_class_method(env)
        ASSERT.kind_of env, E::Entry

        return enum_for(__method__, env) unless block_given?

        self.class_method_info_of_symbol.each_value do |info|
            yield __make_method__(env, *info)
        end
    end


    def lookup_class_method(sym, loc, env)
        ASSERT.kind_of sym, ::Symbol
        ASSERT.kind_of loc, LOC::Entry
        ASSERT.kind_of env, E::Entry

        info = self.class_method_info_of_symbol[sym]
        unless info
            raise X::NoMethodError.new(
                loc,
                env,
                "For class: %s, unknown class method: '%s'",
                    self.symbol, sym.to_s
            )
        end
        ASSERT.kind_of info, ::Array

        ASSERT.kind_of __make_method__(env, *info), ECTS::Method
    end


    def num_of_instance_methods
        self.instance_method_info_of_symbol.size
    end


    def each_instance_method(env)
        ASSERT.kind_of env, E::Entry

        return enum_for(__method__, env) unless block_given?

        self.instance_method_info_of_symbol.each_value do |info|
            yield __make_method__(env, *info)
        end
    end


    def lookup_instance_method(sym, loc, env)
        ASSERT.kind_of sym, ::Symbol
        ASSERT.kind_of loc, LOC::Entry
        ASSERT.kind_of env, E::Entry

        info = self.instance_method_info_of_symbol[sym]
        unless info
            raise X::NoMethodError.new(
                loc,
                env,
                "For class: %s, unknown method: '%s'", self.symbol, sym.to_s
            )
        end
        ASSERT.kind_of info, ::Array

        ASSERT.kind_of __make_method__(env, *info), ECTS::Method
    end


    def opt_superclass
        ASSERT.opt_kind_of SUPERCLASS_OF_SUBCLASS[self], ECTSC::Base
    end


    def subclasses
        opt_subclasses = SUBCLASSES_OF_SUPERCLASS[self]
        subclasses = if opt_subclasses
                            opt_subclasses
                        else
                            ECTS::EMPTY_SET
                        end

        ASSERT.kind_of subclasses, ECTS::SetOfClass
    end


    def ancestors
        opt_ancestors = ANCESTORS_OF_DESCENDANT[self]
        ancestors = if opt_ancestors
                        opt_ancestors
                    else
                        ECTS::EMPTY_SET
                    end

        ASSERT.kind_of ancestors, ECTS::SetOfClass
    end


    def descendants
        opt_descendants = DESCENDANTS_OF_ANCESTOR[self]
        descendants = if opt_descendants
                            opt_descendants
                        else
                            ECTS::EMPTY_SET
                        end

        ASSERT.kind_of descendants, ECTS::SetOfClass
    end


    def print_class_tree(nest = 0)
        ASSERT.kind_of nest, ::Integer

        printf "%s%s\n", '    ' * nest, self.to_sym

        self.subclasses.sort.each do |subclass_signat|
            subclass_signat.print_class_tree nest + 1
        end
    end


    def print_class(env, nest = 0)
        ASSERT.kind_of env,     E::Entry
        ASSERT.kind_of nest,    ::Integer

        indent_0 = '    ' * nest
        indent_1 = '    ' * (nest + 1)

        opt_superclass = self.opt_superclass
        if opt_superclass
            superclass = opt_superclass

            printf "%sSUPERCLASS: %s\n", indent_0, superclass.to_sym
        end

        subclasses = self.subclasses
        unless subclasses.empty?
            printf("%sSUBCLASSES: %s\n",
                indent_0,
                subclasses.map(&:to_sym).join(', ')
            )
        end

        ancestors = self.ancestors
        unless ancestors.empty?
            printf("%sANCESTORS: %s\n",
                indent_0,
                ancestors.map(&:to_sym).join(', ')
            )
        end

        descendants = self.descendants
        unless descendants.empty?
            printf("%sDESCENDANTS: %s\n",
                indent_0,
                descendants.map(&:to_sym).join(', ')
            )
        end

        unless self.num_of_class_methods == 0
            printf "%sCLASS METHODS:\n", indent_0

            self.each_class_method(env).sort.each do |meth_signat|
                printf("%s&%s.%s : %s\n",
                    indent_1,

                    self.symbol,

                    meth_signat.symbol,

                    (
                        meth_signat.param_class_signats +
                        [meth_signat.ret_class_signat.symbol]
                    ).map(&:to_sym).join(' -> ')
                )
            end
        end

        unless self.num_of_instance_methods == 0
            printf "%sINSTANCE METHODS:\n", indent_0

            self.each_instance_method(env).sort.each do |meth_signat|
                printf("%s%s#%s : %s\n",
                    indent_1,

                    self.symbol,

                    meth_signat.symbol,

                    (
                        meth_signat.param_class_signats +
                        [meth_signat.ret_class_signat.symbol]
                    ).map(&:to_sym).join(' -> ')
                )
            end
        end
    end


private

    def __make_method__(
        env,
        meth_sym, ret_class, method_sym, *param_classes
    )
        ASSERT.kind_of      env,            E::Entry
        ASSERT.kind_of      meth_sym,       ::Symbol
        ASSERT.subclass_of  ret_class,      VC::Top
        ASSERT.kind_of      method_sym,     ::Symbol
        ASSERT.kind_of      param_classes,  ::Array

        ret_signat      = env.ty_signat_of_class ret_class
        param_signats   = param_classes.map { |klass|
            ASSERT.subclass_of klass, VC::Top

            env.ty_signat_of_class klass
        }

        ECTS.make_method meth_sym, ret_signat, method_sym, param_signats
    end
end



class Meta < Abstract
    attr_reader :base_class_signat


    def initialize(base_class_signat)
        ASSERT.kind_of base_class_signat, Base

        @base_class_signat = base_class_signat
    end


    def lookup_instance_method(sym, loc, env)
        ASSERT.kind_of sym, ::Symbol
        ASSERT.kind_of loc, LOC::Entry
        ASSERT.kind_of env, E::Entry

        method = self.base_class_signat.lookup_class_method(sym, loc, env)

        ASSERT.kind_of method, ECTS::Method
    end
end

end # Umu::Environment::Context::Type::Signature::Class



module_function

    def make_class(
        klass,
        symbol,
        class_method_info_of_symbol,
        instance_method_info_of_symbol
    )
        ASSERT.subclass_of  klass,                          VC::Top
        ASSERT.kind_of      symbol,                         ::Symbol
        ASSERT.kind_of      class_method_info_of_symbol,    ::Hash
        ASSERT.kind_of      instance_method_info_of_symbol, ::Hash

        Class::Base.new(
            klass,
            symbol,
            class_method_info_of_symbol.freeze,
            instance_method_info_of_symbol.freeze
        ).freeze
    end


    def make_metaclass(base_class_signat)
        ASSERT.kind_of base_class_signat, Class::Base

        Class::Meta.new(base_class_signat).freeze
    end

end # Umu::Environment::Context::Type::Signature

end # Umu::Environment::Context::Type

end # Umu::Environment::Context

end # Umu::Environment

end # Umu
