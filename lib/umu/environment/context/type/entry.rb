# coding: utf-8
# frozen_string_literal: true



module Umu

module Environment

module Context

module Type

ROOT_CLASS = VC::Top
META_CLASS = VC::Class


CLASSES = ::ObjectSpace.each_object(::Class).select {
    |klass|

    klass <= ROOT_CLASS
}.sort { |a, b|
    a.to_s <=> b.to_s
}.each_with_index.sort { |(a, ord_a), (b, ord_b)|
    result = a <=> b

    if result
        result * -1
    else
        ord_a <=> ord_b
    end
}.map { |a, _ord|
    ASSERT.subclass_of a, VC::Top
}.freeze


def update_method_info_of_mess_sym(info_of_symbol, infos, klass)
    ASSERT.kind_of      info_of_symbol, ::Hash
    ASSERT.kind_of      infos,          ::Array
    ASSERT.subclass_of  klass,          VC::Top

    info_of_symbol.merge(
        infos.inject({}) { |hash, info|
            ASSERT.kind_of info, ECTSM::Info

            hash.merge(info.mess_sym => info) {
                ASSERT.abort(
                    "In class: %s, " +
                    "duplicated a message symbol: %s",
                    klass.type_sym, info.mess_sym
                )
            }
        }
    ) { |mess_sym, sub_info, sup_info|
        ASSERT.assert(sub_info.meth_sym == sup_info.meth_sym)

        ASSERT.assert(
            sub_info.param_classes.size == sup_info.param_classes.size
        )

        sub_info.param_classes.zip(sup_info.param_classes).each do
            |sub_param_class, sup_param_class|
            ASSERT.subclass_of sub_param_class, VC::Top
            ASSERT.subclass_of sup_param_class, VC::Top

            ASSERT.assert(
                sub_param_class <= sup_param_class
            )
        end

        ASSERT.assert(
            sub_info.ret_class <= sup_info.ret_class,

            [
                format("Class: %s", klass.inspect),
                format("  Message: %s", mess_sym),
                format("  Super:"),
                format("    Return: %s", sup_info.ret_class),
                format("    Param: [%s]",
                        sup_info.param_classes.map(
                            &:inspect
                        ).join(', ')
                    ),
                format("  Sub:"),
                format("    Return: %s", sub_info.ret_class),
                format("    Param: [%s]",
                        sub_info.param_classes.map(
                            &:inspect
                        ).join(', ')
                    ),
            ].join("\n")
        )

        sub_info
    }
end

module_function :update_method_info_of_mess_sym


CLASS_SIGNATS = CLASSES.map { |klass|
    ASSERT.subclass_of  klass, VC::Top

    class_method_info_of_mess_sym,
    instance_method_info_of_mess_sym = if klass <= META_CLASS
        [{}, {}]
    else
        loop.inject(
             [{},                   {},                 klass]
        ) {
            |(cmeth_info_of_sym,    imeth_info_of_sym,  k), _|

            unless k <= ROOT_CLASS
                break [cmeth_info_of_sym, imeth_info_of_sym]
            end

            [
                update_method_info_of_mess_sym(
                    cmeth_info_of_sym, k.class_method_infos, k
                ),

                update_method_info_of_mess_sym(
                    imeth_info_of_sym, k.instance_method_infos, k
                ),

                k.superclass
            ]
        }
    end

    ECTS.make_class(
        klass,
        klass.type_sym,
        class_method_info_of_mess_sym,
        instance_method_info_of_mess_sym
    )
}
CLASS_SIGNATS.freeze


=begin
CLASS_SIGNATS.each do |signat|
    printf "==== %s : %s ====\n", signat.symbol, signat.klass
    p signat
    puts
end
exit
=end

SIGNAT_OF_CLASS, SIGNAT_OF_CLASS_SYM = CLASS_SIGNATS.inject(
     [{},               {}]
    ) {
    |(signat_of_class,  signat_of_class_sym), signat|
    ASSERT.kind_of signat_of_class,     ::Hash
    ASSERT.kind_of signat_of_class_sym, ::Hash
    ASSERT.kind_of signat,              ECTSC::Base

    [
        signat_of_class.merge(signat.klass => signat) {
            ASSERT.abort "Duplicated a class: %s", signat.klass.to_s
        },

        signat_of_class_sym.merge(signat.symbol => signat) {
            ASSERT.abort "Duplicated a symbol: %s", signat.symbol.to_s
        }
    ]
}
SIGNAT_OF_CLASS.freeze
SIGNAT_OF_CLASS_SYM.freeze


SUPERCLASS_OF_SUBCLASS, SUBCLASSES_OF_SUPERCLASS = CLASSES.inject(
     [{},                       {}]
) {
    |(supsignat_of_subsignat,   subsignats_of_supsignat), subclass|
    ASSERT.kind_of      supsignat_of_subsignat,     ::Hash
    ASSERT.kind_of      subsignats_of_supsignat,    ::Hash
    ASSERT.subclass_of  subclass,                   VC::Top

    if subclass < ROOT_CLASS
        subsignat = SIGNAT_OF_CLASS[subclass]
        supsignat = SIGNAT_OF_CLASS[subclass.superclass]
        ASSERT.kind_of subsignat, ECTSC::Base
        ASSERT.kind_of supsignat, ECTSC::Base

        [
            supsignat_of_subsignat.merge(subsignat => supsignat) {
                |signat, _, _|

                ASSERT.abort(
                    "Duplicated a class signature: %s", signat.inspect
                )
            },
            
            subsignats_of_supsignat.merge(
                supsignat => ECTS.make_set([subsignat])
            ) {
                |_, old_set_of_signat, new_set_of_signat|

                old_set_of_signat.union new_set_of_signat
            }
        ]
    else
        [
            supsignat_of_subsignat,

            subsignats_of_supsignat
        ]
    end
}.freeze
SUPERCLASS_OF_SUBCLASS.freeze
SUBCLASSES_OF_SUPERCLASS.freeze


ANCESTORS_OF_DESCENDANT, DESCENDANTS_OF_ANCESTOR = CLASS_SIGNATS.inject(
     [{},                       {}]
) {
    |(ancestors_of_descendant,  descendants_of_ancestor), descendant|
    ASSERT.kind_of ancestors_of_descendant, ::Hash
    ASSERT.kind_of descendants_of_ancestor, ::Hash
    ASSERT.kind_of descendant,              ECTSC::Base

    ancestors, _ = loop.inject([[], descendant]) { |(signats, signat), _|
        ASSERT.kind_of signats, ::Array
        ASSERT.kind_of signat,  ECTSC::Base

        opt_supsignat = SUPERCLASS_OF_SUBCLASS[signat]
        ASSERT.opt_kind_of opt_supsignat, ECTSC::Base

        if opt_supsignat
            [signats + [opt_supsignat], opt_supsignat]
        else
            break [signats, nil]
        end
    }

    [
        ancestors_of_descendant.merge(
            descendant => ECTS.make_set(ancestors)
        ) { |signat, _, _|

            ASSERT.abort(
                "Duplicated a class signature: %s", signat.inspect
            )
        },

        descendants_of_ancestor.merge(
            ancestors.inject({}) { |hash, ancestor|
                hash.merge(ancestor => ECTS.make_set([descendant])) {
                    |signat, _, _|

                    ASSERT.abort("Duplicated a class signature: %s",
                                    signat.inspect
                    )
                }
            }
        ) { |_, old_set_of_signat, new_set_of_signat|
            old_set_of_signat.union new_set_of_signat
        }
    ]
}.freeze
ANCESTORS_OF_DESCENDANT.freeze
DESCENDANTS_OF_ANCESTOR.freeze



class Entry
    def classes
        CLASSES
    end


    def class_signats
        CLASS_SIGNATS
    end


    def class_signat_of(value)
        ASSERT.kind_of value, VC::Top

        signat = if value.kind_of?(META_CLASS)
                    ECTS.make_metaclass value.class_signat
                else
                    self.signat_of_class value.class
                end

        ASSERT.kind_of signat, ECTSC::Abstract
    end


    def signat_of_class(klass)
        ASSERT.subclass_of klass, VC::Top

        ASSERT.kind_of SIGNAT_OF_CLASS[klass], ECTSC::Base
    end


    def root_class_signat
        ASSERT.kind_of self.signat_of_class(ROOT_CLASS), ECTSC::Base
    end


    def lookup(class_sym, loc, env)
        ASSERT.kind_of class_sym, ::Symbol
        ASSERT.kind_of loc,       LOC::Entry
        ASSERT.kind_of env,       E::Entry

        class_signat = SIGNAT_OF_CLASS_SYM[class_sym]

        unless class_signat
            raise X::NameError.new(
                loc,
                env,
                "Unbound type identifier: '%s'", class_sym.to_s
            )
        end

          ASSERT.kind_of class_signat, ECTSC::Base
    end


    def test_kind_of?(lhs_value, rhs_signat)
        ASSERT.kind_of lhs_value,   VC::Top
        ASSERT.kind_of rhs_signat,  ECTSC::Base

        lhs_signat = self.class_signat_of lhs_value
        ASSERT.kind_of lhs_signat, ECTSC::Abstract

        result = if lhs_signat == rhs_signat
                        true
                    else
                        rhs_signats = self.descendants_of rhs_signat
                        ASSERT.kind_of rhs_signats, ECTS::SetOfClass

                        rhs_signats.member? lhs_signat
                    end
        ASSERT.bool result
    end


    def opt_superclass_of(subclass)
        ASSERT.kind_of subclass, ECTSC::Base

        ASSERT.opt_kind_of subclass.opt_superclass, ECTSC::Base
    end


    def subclasses_of(superclass)
        ASSERT.kind_of superclass, ECTSC::Base

        ASSERT.kind_of superclass.subclasses, ECTS::SetOfClass
    end


    def ancestors_of(descendant)
        ASSERT.kind_of descendant, ECTSC::Base

        ASSERT.kind_of descendant.ancestors, ECTS::SetOfClass
    end


    def descendants_of(ancestor)
        ASSERT.kind_of ancestor, ECTSC::Base

        ASSERT.kind_of ancestor.descendants, ECTS::SetOfClass
    end
end


BUILTIN = Entry.new.freeze

# BUILTIN.root_class_signat.print_class_tree



module_function

    def make
        BUILTIN
    end

end # Umu::Environment::Context::Type

end # Umu::Environment::Context

end # Umu::Environment

end # Umu
