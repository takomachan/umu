# coding: utf-8
# frozen_string_literal: true

module Umu

module Commander

module Subcommand

module_function

    def execute(line, line_num, env, setup_env)
        ASSERT.kind_of line,        ::String
        ASSERT.kind_of line_num,    ::Integer
        ASSERT.kind_of env,         E::Entry
        ASSERT.kind_of setup_env,   E::Entry

        name, *args = line.split

        new_env = case name
        when ':trace'
            env.update_trace_mode true
        when ':notrace'
            env.update_trace_mode false
        when ':lextrace'
            env.update_lex_trace_mode true
        when ':nolextrace'
            env.update_lex_trace_mode false
        when ':dump'
            env.update_dump_mode true
        when ':nodump'
            env.update_dump_mode false
        when ':class'
            case args.size
            when 0
                Subcommand.print_class_tree env.ty_context.root_class_signat
            when 1
                class_signat = env.ty_lookup(
                    args[0].to_sym,
                    LOC.make_location(STDIN_FILE_NAME, line_num)
                )

                Subcommand.print_class_signat class_signat, env
            else
                raise X::CommandError.new "Syntax error"
            end

            env
        when ':env'
            setup_bindings = setup_env.va_get_bindings

            Subcommand.get_binding_lines(env){ |sym, value|
                opt_setup_value = setup_bindings[sym]
                if opt_setup_value
                    if opt_setup_value == value
                        false
                    else
                        true
                    end
                else
                    true
                end
            }.each do |_sym, line|
                STDERR.puts line
            end

            env
        when ':envall'
            Subcommand.get_binding_lines(env).sort { |a, b|
                a[0] <=> b[0]
            }.each do |_sym, line|
                STDERR.puts line
            end

            env
        else
            raise X::CommandError.new "Unknown command: '%s'", line
        end

        ASSERT.kind_of new_env, E::Entry
    end


    def print_class_tree(class_signat, nest = 0)
        ASSERT.kind_of class_signat, ECTSC::Abstract
        ASSERT.kind_of nest,         ::Integer

        printf("%s%s%s\n",
                 '    ' * nest,
                class_signat.to_sym.to_s,
                class_signat.abstract_class? ? '/' : ''
        )

        class_signat.subclasses.sort.each do |subclass_signat|
            Subcommand.print_class_tree subclass_signat, nest + 1
        end
    end


    def print_class_signat(class_signat, env, nest = 0)
        ASSERT.kind_of class_signat, ECTSC::Abstract
        ASSERT.kind_of env,          E::Entry
        ASSERT.kind_of nest,         ::Integer

        indent_0 = '    ' * nest
        indent_1 = '    ' * (nest + 1)

        printf("%sABSTRACT CLASS?: %s\n",
                indent_0,

                if class_signat.abstract_class?
                    "Yes"
                else
                    "No, this is a concrete class"
                end
        )

        opt_superclass = class_signat.opt_superclass
        if opt_superclass
            superclass = opt_superclass

            printf "%sSUPERCLASS: %s\n", indent_0, superclass.to_sym
        end

        subclasses = class_signat.subclasses
        unless subclasses.empty?
            printf("%sSUBCLASSES: %s\n",
                indent_0,
                subclasses.map(&:to_sym).join(', ')
            )
        end

        ancestors = class_signat.ancestors
        unless ancestors.empty?
            printf("%sANCESTORS: %s\n",
                indent_0,
                ancestors.map(&:to_sym).join(', ')
            )
        end

        descendants = class_signat.descendants
        unless descendants.empty?
            printf("%sDESCENDANTS: %s\n",
                indent_0,
                descendants.map(&:to_sym).join(', ')
            )
        end

        unless class_signat.num_of_class_messages == 0
            printf "%sCLASS MESSAGES:\n", indent_0

            class_signat.each_class_method(env).sort.each do
                |meth_signat|

                printf("%s&%s.%s\n",
                    indent_1,
                    class_signat.symbol.to_s,
                    meth_signat.to_s
                )
            end
        end

        unless class_signat.num_of_instance_messages == 0
            printf "%sINSTANCE MESSAGES:\n", indent_0

            class_signat.each_instance_method(env).sort.each do
                |meth_signat|

                printf("%s%s#%s\n",
                    indent_1,
                    class_signat.symbol.to_s,
                    meth_signat.to_s
                )
            end
        end
    end


    def get_binding_lines(env, &_block)
        ASSERT.kind_of env, E::Entry

        lines = env.va_context.reverse_each.inject({}) { |lines, context|
                ASSERT.kind_of lines,   ::Hash
                ASSERT.kind_of context, ECV::Entry

                lines.merge(
                    context.get_bindings.select { |sym, value|
                        if /^%/ =~ sym.to_s
                            false
                        else
                            if block_given?
                                yield sym, value
                            else
                                true
                            end
                        end
                    }.inject({}) { |hash, (sym, value)|
                        line = case value
                                when VC::Fun
                                    format "fun %s", sym.to_s
                                when VC::Struct::Entry
                                    format "structure %s", sym.to_s
                                else
                                    format("val %s : %s",
                                                 sym.to_s,
                                                 value.type_sym.to_s
                                            )
                                end

                        hash.merge(sym => line) {
                            ASSERT.abort "No case: %s", sym
                        }
                    }
                ) { |_sym, newer_line, _older_line|
                    newer_line
                }
            }

        ASSERT.kind_of lines, ::Hash
    end

end # Umu::Commander::Subcommand

end # Umu::Commander

end # Umu
