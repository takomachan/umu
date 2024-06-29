# coding: utf-8
# frozen_string_literal: true



module Umu

module AbstractSyntax

module Core

module Expression

module Binary

class KindOf < Binary::Abstract
    alias       expr        lhs_expr
    alias       class_id    rhs
    attr_reader :opt_type_sym


    def initialize(loc, expr, class_id, opt_type_sym)
        ASSERT.kind_of      expr,           ASCE::Abstract
        ASSERT.kind_of      class_id,       ASCEU::Identifier::Short
        ASSERT.opt_kind_of  opt_type_sym,   ::Symbol

        super(loc, expr, class_id)

        @opt_type_sym = opt_type_sym
    end


    def to_s
        format("(%s%s %%KIND-OF? %s)",
            self.expr.to_s,

            if self.opt_type_sym
                format " : %s", self.opt_type_sym
            else
                ''
            end,

            self.class_id.to_s
        )
    end


    def __evaluate__(env, event)
        ASSERT.kind_of env,     E::Entry
        ASSERT.kind_of event,   E::Tracer::Event

        rhs_signat = env.ty_lookup self.class_id.sym, self.loc
        ASSERT.kind_of rhs_signat, ECTSC::Base

        lhs_value = self.expr.evaluate(env.enter event).value
        ASSERT.kind_of lhs_value, VC::Top

        if self.opt_type_sym
            type_signat = env.ty_lookup self.opt_type_sym, self.loc
            ASSERT.kind_of type_signat, ECTSC::Base

            unless env.ty_kind_of?(lhs_value, type_signat)
                raise X::TypeError.new(
                    self.loc,
                    env,
                    "Type error in case-expression, " +
                        "expected a %s, but %s : %s",
                    self.opt_type_sym,
                    lhs_value,
                    lhs_value.type_sym
                )
            end
        end

        VC.make_bool env.ty_kind_of?(lhs_value, rhs_signat)
    end
end

end # Umu::AbstractSyntax::Core::Expression::Binary


module_function

    def make_test_kind_of(loc, expr, class_id, opt_type_sym = nil)
        ASSERT.kind_of      loc,            L::Location
        ASSERT.kind_of      expr,           ASCE::Abstract
        ASSERT.kind_of      class_id,       ASCEU::Identifier::Short
        ASSERT.opt_kind_of  opt_type_sym,   ::Symbol

        Binary::KindOf.new(loc, expr, class_id, opt_type_sym).freeze
    end

end # Umu::AbstractSyntax::Core::Expression

end # Umu::AbstractSyntax::Core

end # Umu::AbstractSyntax

end # Umu
