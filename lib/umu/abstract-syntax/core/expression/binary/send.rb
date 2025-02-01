# coding: utf-8
# frozen_string_literal: true



module Umu

module AbstractSyntax

module Core

module Expression

module Binary

module Send

class Message < Umu::Abstraction::Model
    attr_reader :sym, :exprs


    def initialize(loc, sym, exprs)
        ASSERT.kind_of sym,     ::Symbol
        ASSERT.kind_of exprs,   ::Array

        super(loc)

        @sym    = sym
        @exprs  = exprs
    end


    def to_s
        format(".%s",
            if self.exprs.empty?
                self.sym.to_s
            else
                format "(%s %s)",
                        self.sym.to_s,
                        self.exprs.map(&:to_s).join(' ')
            end
        )
    end


    def pretty_print(q)
        PRT.group_for_enum(
            q,

            self.exprs,

            bb: format(self.exprs.empty? ? ".%s" : ".(%s ", self.sym.to_s),

            eb: self.exprs.empty? ? '' : ')',

            join: ' '
        )
    end
end



class Entry < Binary::Abstract
    alias       rhs_head_message rhs
    attr_reader :rhs_tail_messages
    attr_reader :opt_receiver_type_sym


    def initialize(
        loc, lhs_expr,
        rhs_head_message, rhs_tail_messages,
        opt_receiver_type_sym
    )
        ASSERT.kind_of      lhs_expr,               ASCE::Abstract
        ASSERT.kind_of      rhs_head_message,       Message
        ASSERT.kind_of      rhs_tail_messages,      ::Array
        ASSERT.opt_kind_of  opt_receiver_type_sym,  ::Symbol

        super(loc, lhs_expr, rhs_head_message)

        @rhs_tail_messages      = rhs_tail_messages
        @opt_receiver_type_sym  = opt_receiver_type_sym
    end


    def rhs_messages
        [self.rhs_head_message] + self.rhs_tail_messages
    end


    def to_s
        format("(%s%s)%s",
            self.lhs_expr.to_s,

            if self.opt_receiver_type_sym
                format " : %s", self.opt_receiver_type_sym.to_s
            else
                ''
            end,

            self.rhs_messages.map(&:to_s).join
        )
    end


    def pretty_print(q)
        PRT.group q, bb:'(', eb:')' do
            q.pp lhs_expr
            if self.opt_receiver_type_sym
                q.text format(" : %s", self.opt_receiver_type_sym.to_s)
            end
        end

        PRT.group_for_enum q, self.rhs_messages
    end


private

    def __evaluate__(env, event)
        ASSERT.kind_of env,     E::Entry
        ASSERT.kind_of event,   E::Tracer::Event

        new_env = env.enter event

        lhs_result = self.lhs_expr.evaluate new_env
        ASSERT.kind_of lhs_result, ASR::Value
        init_receiver = lhs_result.value

        if self.opt_receiver_type_sym
            receiver_type_sym = opt_receiver_type_sym

            receiver_signat = new_env.ty_lookup receiver_type_sym, self.loc
            ASSERT.kind_of receiver_signat, ECTSC::Base
            unless env.ty_kind_of?(init_receiver, receiver_signat)
                raise X::TypeError.new(
                    self.loc,
                    env,
                    "Expected a %s, but %s : %s",
                    receiver_type_sym,
                    init_receiver,
                    init_receiver.type_sym
                )
            end
        end

        final_receiver = self.rhs_messages.inject(init_receiver) {
            |receiver, message|
            ASSERT.kind_of receiver,    VC::Top
            ASSERT.kind_of message,     Message

            __send_message__ receiver, message, new_env, event
        }
        ASSERT.kind_of final_receiver, VC::Top
    end


    def __send_message__(receiver, message, env, event)
        ASSERT.kind_of receiver,    VC::Top
        ASSERT.kind_of message,     Message
        ASSERT.kind_of env,         E::Entry
        ASSERT.kind_of event,       E::Tracer::Event

        message_sym  = message.sym
        arg_values   = message.exprs.map { |expr|
            result = expr.evaluate env
            ASSERT.kind_of result, ASR::Value

            result.value
        }
        arg_num     = arg_values.size

        receiver_signat = env.ty_class_signat_of receiver
        ASSERT.kind_of receiver_signat, ECTSC::Abstract
        method_signat   = receiver_signat.lookup_instance_method(
                                        message_sym, message.loc, env
                                    )
        ASSERT.kind_of method_signat, ECTSM::Entry

        param_signats   = method_signat.param_class_signats
        param_num       = method_signat.param_class_signats.size

        result_value =
            if param_num == arg_num
                __validate_type_of_args__(
                    message_sym,
                    param_num, arg_values, param_signats, loc, env
                )

                next_receiver = receiver.invoke(
                    method_signat, message.loc, env, event, *arg_values
                )
                ASSERT.assert(
                    env.ty_kind_of?(
                        next_receiver, method_signat.ret_class_signat
                    )
                )
                ASSERT.kind_of next_receiver, VC::Top
            elsif param_num < arg_num
                __validate_type_of_args__(
                    message_sym,
                    param_num, arg_values, param_signats, loc, env
                )

                invoked_values = if param_num == 0
                                        []
                                    else
                                        arg_values[0 .. param_num - 1]
                                    end

                value = receiver.invoke(
                    method_signat, loc, env.enter(event), event,
                    *invoked_values
                )
                ASSERT.assert env.ty_kind_of?(
                    value, method_signat.ret_class_signat
                )
                ASSERT.kind_of value, VC::Top

                hd_arg_value, *tl_arg_values = arg_values[param_num .. -1]

                value.apply hd_arg_value, tl_arg_values, loc, env
            elsif param_num > arg_num
=begin
                p({
                    param_num: param_num,
                    arg_num: arg_num,
                    arg_values: arg_values
                })
=end
                free_idents, bound_idents = (0 .. param_num - 1).inject(
                             [[],        []]
                        ) { |(fr_idents, bo_idents), i|
                    ident = ASCE.make_identifier(
                                loc, format("%%x_%d", i + 1).to_sym
                            )

                    if i < arg_num
                        [fr_idents + [ident],   bo_idents]
                    else
                        [fr_idents,             bo_idents + [ident]]
                    end
                }
=begin
                p({
                    free_idents: free_idents,
                    bound_idents: bound_idents
                })
=end
                new_env = free_idents.zip(
                        arg_values
                    ).inject(
                        env.va_extend_value :'%r', receiver
                    ) { |e, (ident, v)|
                    ASSERT.kind_of e,       E::Entry
                    ASSERT.kind_of ident,   ASCEU::Identifier::Short
                    ASSERT.kind_of v,       VC::Top

                    e.va_extend_value ident.sym, v
                }

                lamb_params = bound_idents.map { |ident|
                    ASSERT.kind_of ident, ASCEU::Identifier::Short

                    ASCE.make_parameter ident.loc, ident
                }

                VC.make_function(
                    ASCE.make_lambda(
                        loc,
                        lamb_params,
                        ASCE.make_send(
                            loc,
                            ASCE.make_identifier(loc, :'%r'),
                            ASCE.make_message(
                                loc,
                                method_signat.mess_sym,
                                free_idents + bound_idents
                            )
                        )
                    ),
                    new_env.va_context
                )
            else
                ASSERT.abort 'No case'
            end

        ASSERT.kind_of result_value, VC::Top
    end


    def __validate_type_of_args__(
        mess_sym, num, arg_values, param_signats, loc, env
    )
        ASSERT.kind_of mess_sym,        ::Symbol
        ASSERT.kind_of num,             ::Integer
        ASSERT.kind_of arg_values,      ::Array
        ASSERT.kind_of param_signats,   ::Array
        ASSERT.kind_of loc,             LOC::Entry
        ASSERT.kind_of env,             E::Entry

        (0 .. num - 1).each do |i|
            arg_value       = arg_values[i]
            param_signat    = param_signats[i]
            ASSERT.kind_of arg_value,       VC::Top
            ASSERT.kind_of param_signat,    ECTSC::Base

            unless env.ty_kind_of?(arg_value, param_signat)
                raise X::TypeError.new(
                    loc,
                    env,
                    "For '%s's #%d argument, expected a %s, but %s : %s",
                        mess_sym.to_s,
                        i + 1,
                        param_signat.symbol,
                        arg_value.to_s,
                        arg_value.type_sym
                )
            end
        end
    end
end

end # Umu::AbstractSyntax::Core::Expression::Binary::Send

end # Umu::AbstractSyntax::Core::Expression::Binary


module_function

    def make_message(loc, sym, exprs = [])
        ASSERT.kind_of loc,     LOC::Entry
        ASSERT.kind_of sym,     ::Symbol
        ASSERT.kind_of exprs,   ::Array

        Binary::Send::Message.new(loc, sym, exprs.freeze).freeze
    end


    def make_send(
        loc, lhs_expr,
        rhs_head_message, rhs_tail_messages = [],
        opt_receiver_type_sym = nil
    )
        ASSERT.kind_of      loc,                    LOC::Entry
        ASSERT.kind_of      lhs_expr,               ASCE::Abstract
        ASSERT.kind_of      rhs_head_message,       Binary::Send::Message
        ASSERT.kind_of      rhs_tail_messages,      ::Array
        ASSERT.opt_kind_of  opt_receiver_type_sym,  ::Symbol

        Binary::Send::Entry.new(
            loc, lhs_expr, rhs_head_message, rhs_tail_messages.freeze,
            opt_receiver_type_sym
        ).freeze
    end

end # Umu::AbstractSyntax::Core::Expression

end # Umu::AbstractSyntax::Core

end # Umu::AbstractSyntax

end # Umu
