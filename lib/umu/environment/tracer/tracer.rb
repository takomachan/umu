# coding: utf-8
# frozen_string_literal: true



module Umu

module Environment

module Tracer

class Event
    attr_reader :label
    attr_reader :klass
    attr_reader :loc
    attr_reader :msg


    def initialize(label, klass, loc, msg)
        ASSERT.kind_of label,   ::String
        ASSERT.kind_of klass,   ::Class
        ASSERT.kind_of loc,     LOC::Entry
        ASSERT.kind_of msg,     ::String

        @label  = label
        @klass  = klass
        @loc    = loc
        @msg    = msg
    end


    def to_s
        format("%s:#%d:[%s] %s: %s",
                    self.loc.file_name,
                    self.loc.line_num + 1,
                    label,
                    Tracer.class_to_string(klass),
                    self.msg
        )
    end
end



module_function

    def make_event(label, klass, loc, msg)
        ASSERT.kind_of label,   ::String
        ASSERT.kind_of klass,   ::Class
        ASSERT.kind_of loc,     LOC::Entry
        ASSERT.kind_of msg,     ::String

        Event.new(label.freeze, klass, loc, msg.freeze).freeze
    end


    def trace(pref, eval_depth, label, klass, loc, msg)
        ASSERT.kind_of pref,        E::Preference
        ASSERT.kind_of eval_depth,  ::Integer
        ASSERT.kind_of label,       ::String
        ASSERT.kind_of klass,       ::Class
        ASSERT.kind_of loc,         LOC::Entry
        ASSERT.kind_of msg,         ::String
        ASSERT.assert block_given?

        if pref.trace_mode?
            STDERR.printf "%s[%s] %s: %s\n",
                            '| ' * eval_depth,
                            label,
                            Tracer.class_to_string(klass),
                            msg
        end

        object = yield Tracer.make_event(label, klass, loc, msg)

        if pref.trace_mode?
            STDERR.printf "%s--> %s: %s\n",
                            '| ' * eval_depth,
                            Tracer.class_to_string(object.class),
                            object.to_s
        end

        object
    end


    def trace_single(pref, eval_depth, label, klass, loc, msg)
        ASSERT.kind_of pref,        E::Preference
        ASSERT.kind_of eval_depth,  ::Integer
        ASSERT.kind_of label,       ::String
        ASSERT.kind_of klass,       ::Class
        ASSERT.kind_of loc,         LOC::Entry
        ASSERT.kind_of msg,         ::String

        if pref.trace_mode?
            STDERR.printf "%s[%s] %s: %s",
                            '| ' * eval_depth,
                            label,
                            Tracer.class_to_string(klass),
                            msg
        end

        object = yield Tracer.make_event(label, klass, loc, msg)

        if pref.trace_mode?
            STDERR.printf " --> %s: %s\n",
                                Tracer.class_to_string(object.class),
                                object.to_s
        end

        object
    end


    def class_to_string(klass)
        ASSERT.kind_of klass, ::Class

        class_name, *fully_qualified_module_names = klass.to_s.split(/::/)

        s = if fully_qualified_module_names.empty?
                class_name
            else
                *module_names, fq_class_name = fully_qualified_module_names

                format("%s (%s)",
                        fq_class_name,
                        Tracer.abbreviate(module_names).join('::')
                )
            end

        ASSERT.kind_of s, ::String
    end


    ABBREVIATABLE_MODULE_NAMES = [
        # Lexical
        [['Lexical'],                                           'L'],
        [['Lexical', 'Lexer'],                                  'LL'],

        # ConcreteSyntax
        [['ConcreteSyntax'],                                    'CS'],
        [['ConcreteSyntax', 'Module'],                          'CSM'],
        [['ConcreteSyntax', 'Module',   'Declaration'],         'CSMD'],
        [['ConcreteSyntax', 'Module',   'Expression'],          'CSME'],
        [['ConcreteSyntax', 'Module',   'Pattern'],             'CSMP'],
        [['ConcreteSyntax', 'Core'],                            'CSC'],
        [['ConcreteSyntax', 'Core', 'Declaration'],             'CSCD'],
        [['ConcreteSyntax', 'Core', 'Expression'],              'CSCE'],
        [['ConcreteSyntax', 'Core', 'Expression',   'Unary'],   'CSCEU'],
        [['ConcreteSyntax', 'Core', 'Expression',   'Unary', 'Atom'],
                                                                'CSCEUA'],
        [['ConcreteSyntax', 'Core', 'Expression',   'Binary'],  'CSCEB'],
        [['ConcreteSyntax', 'Core', 'Expression',   'Nary'],    'CSCEN'],
        [['ConcreteSyntax', 'Core', 'Pattern'],                 'CSCP'],

        # AbstractSyntax
        [['AbstractSyntax'],                                    'AS'],
        [['AbstractSyntax', 'Core'],                            'ASC'],
        [['AbstractSyntax', 'Core', 'Declaration'],             'ASCD'],
        [['AbstractSyntax', 'Core', 'Expression'],              'ASCE'],
        [['AbstractSyntax', 'Core', 'Expression',   'Unary'],   'ASCEU'],
        [['AbstractSyntax', 'Core', 'Expression',   'Unary', 'Atom'],
                                                                'ASCEUA'],
        [['AbstractSyntax', 'Core', 'Expression',   'Binary'],  'ASCEB'],
        [['AbstractSyntax', 'Core', 'Expression',   'Nary'],    'ASCEN'],

        # Value
        [['Value'],                                             'V'],
        [['Value',          'Core'],                            'VC'],
        [['Value',          'Core', 'Atom'],                    'VCA'],
        [['Value',          'Core', 'Atom', 'Number'],          'VCAN'],
        [['Value',          'Core', 'Product'],                 'VCP'],
        [['Value',          'Core', 'Union'],                   'VCU'],
        [['Value',          'Core', 'Morph'],                   'VCM'],

        # Environment
        [['Environment'],                                       'E']
    ].sort { |(xs, _), (ys, _)| ys.size <=> xs.size }   # For longest-match

    def abbreviate(names)
        ASSERT.kind_of names, ::Array

        ABBREVIATABLE_MODULE_NAMES.each { |prefix_names, abbreviated_name|
            prefix_length = prefix_names.length

            if names.take(prefix_length) == prefix_names
                break [abbreviated_name] + names.drop(prefix_length)
            else
                names
            end
        }
    end

end # Umu::Environment::Tracer

end # Umu::Environment

end # Umu
