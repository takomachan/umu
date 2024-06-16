# coding: utf-8
# frozen_string_literal: true

require 'umu/common'
require 'umu/lexical/escape'
require 'umu/lexical/location'


module Umu

module ConcreteSyntax

module Core

module Expression

module Unary

module Atom

class Abstract < Unary::Abstract
    def desugar(env)
        E::Tracer.trace_single(
                    env.pref,
                    env.trace_stack.count,
                    'Desu',
                    self.class,
                    self.loc,
                    self.to_s
                ) { |event|
                    __desugar__ env, event
                }
    end
end

end # Umu::ConcreteSyntax::Core::Expression::Unary::Atom

end # Umu::ConcreteSyntax::Core::Expression::Unary

end # Umu::ConcreteSyntax::Core::Expression

end # Umu::ConcreteSyntax::Core

end # Umu::ConcreteSyntax

end # Umu
