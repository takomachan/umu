# coding: utf-8
# frozen_string_literal: true



module Umu

module Value

module Core

module Morph

module Stream

module Entry

class Abstract < Morph::Abstract
    TYPE_SYM = :Stream


    define_class_method(
        :meth_make_empty,
        :empty, [],
        [], self
    )
    def self.meth_make_empty(_loc, env, _event)
        # Cell stream is default stream
        VC.make_cell_stream_nil(env.va_context)
    end


    attr_reader :obj, :va_context

    def initialize(obj, va_context)
        ASSERT.kind_of obj,         ::Object
        ASSERT.kind_of va_context,  ECV::Abstract

        super()

        @obj        = obj
        @va_context = va_context
    end


    def to_s
        format "#%s<%s>", self.type_sym.to_s, self.obj.to_s
    end


    def pretty_print(q)
        bb = format "#%s<", self.type_sym.to_s

        PRT.group q, bb:bb, eb:'>' do
            q.pp self.obj
        end
    end


    def meth_susp(loc, env, event)
        self
    end


    def meth_dest(loc, env, event)
        self.meth_force loc, env, event
    end


    def meth_is_empty(loc, env, event)
        val_of_opt = self.meth_force loc, env, event
        ASSERT.kind_of val_of_opt, VCU::Option::Abstract

        result = val_of_opt.meth_is_none loc, env, event

        ASSERT.kind_of result, VCA::Bool
    end


    def meth_dest!(loc, env, event)
        val_of_opt = self.meth_force loc, env, event
        ASSERT.kind_of val_of_opt, VCU::Option::Abstract

        unless val_of_opt.some?
            raise X::EmptyError.new(
                        loc,
                        env,
                        "dest!: Empty morph cannot be destruct"
                    )
        end
        result = val_of_opt.contents

        ASSERT.kind_of result, VCP::Tuple
    end


    def meth_cons(loc, env, _event, value)
        ASSERT.kind_of value, VC::Top

        sym_x   = :'%x'
        new_env = env.va_extend_value sym_x, value

        VC.make_cell_stream_cons(
            ASCE.make_identifier(loc, sym_x),
            self,
            new_env.va_context
        )
    end


    define_instance_method(
        :meth_force,
        :force, [],
        [], VCU::Option::Abstract
    )
    def meth_force(loc, env, event)
        new_env = env.update_va_context(self.va_context)
                     .enter(event)

        value = E::Tracer.trace(
                            new_env.pref,
                            new_env.trace_stack.count,
                            'Force',
                            self.class,
                            loc,
                            self.to_s,
        ) { |new_event|
            __meth_force__ loc, new_env, new_event
        }
        ASSERT.kind_of value, VCU::Option::Abstract
    end


    define_instance_method(
        :meth_map,
        :map, [],
        [VC::Fun], self
    )
    def meth_map(loc, env, _event, func)
        ASSERT.kind_of func, VC::Fun

        sym_f    = :'%f'
        sym_self = :self

        new_env = env.va_extend_values(
            sym_f    => func,
            sym_self => self
        )

        expr = ASCE.make_send(
                loc,

                ASCE.make_identifier(loc, sym_self),

                ASCE.make_message(
                    loc,
                    :'%map',
                    [ASCE.make_identifier(loc, sym_f)]
                )
            )

        VC.make_suspended_stream(expr, new_env.va_context)
    end


    define_instance_method(
        :meth_map_,
        :'%map', [],
        [VC::Fun], self
    )
    def meth_map_(loc, env, event, func)
        ASSERT.kind_of func, VC::Fun

        val_opt = self.meth_force loc, env, event

        VC.validate_option val_opt, 'map', loc, env

        result = (
            if val_opt.none?
                VC.make_cell_stream_nil env.va_context
            else
                sym_x   = :'%x'
                sym_xs  = :'%xs'
                sym_f   = :'%f'

                x, xs = VC.validate_pair val_opt.contents, "map", loc, env

                VC.validate_stream xs, 'map', loc, env
                new_env = env.va_extend_values(
                                    sym_x   => x,
                                    sym_xs  => xs,
                                    sym_f   => func
                                )

                head_expr = ASCE.make_apply(
                        loc,
                        ASCE.make_identifier(loc, sym_f),
                        ASCE.make_identifier(loc, sym_x)
                    )

                tail_stream = VC.make_expr_stream_entry(
                         ASCE.make_send(
                            loc,

                            ASCE.make_identifier(loc, sym_xs),

                            ASCE.make_message(
                                loc,
                                :map,
                                [ASCE.make_identifier(loc, sym_f)]
                            )
                        ),

                        new_env.va_context
                    )

                VC.make_cell_stream_cons(
                    head_expr, tail_stream, new_env.va_context
                )
            end
        )

        ASSERT.kind_of result, VCM::Stream::Entry::Abstract
    end


    define_instance_method(
        :meth_select,
        :select, [],
        [VC::Fun], self
    )
    def meth_select(loc, env, _event, func)
        ASSERT.kind_of func, VC::Fun

        sym_f    = :'%f'
        sym_self = :'self'

        new_env = env.va_extend_values(
            sym_f    => func,
            sym_self => self
        )

        expr = ASCE.make_send(
                loc,

                ASCE.make_identifier(loc, sym_self),

                ASCE.make_message(
                    loc,
                    :'%select',
                    [ASCE.make_identifier(loc, sym_f)]
                )
            )


        VC.make_suspended_stream(expr, new_env.va_context)
    end


    define_instance_method(
        :meth_select_,
        :'%select', [],
        [VC::Fun], self
    )
    def meth_select_(loc, env, event, func)
        ASSERT.kind_of func, VC::Fun

        val_opt = self.meth_force loc, env, event

        VC.validate_option val_opt, 'select', loc, env

        result = (
            if val_opt.none?
                VC.make_cell_stream_nil env.va_context
            else
                sym_x   = :'%x'
                sym_xs  = :'%xs'
                sym_f   = :'%f'

                x, xs = VC.validate_pair(
                            val_opt.contents, "select", loc, env
                        )

                VC.validate_stream xs, 'select', loc, env

                val_bool = func.apply x, [], loc, env.enter(event)
                ASSERT.kind_of val_bool, VC::Top

                VC.validate_bool val_bool, 'select', loc, env
                if val_bool.true?
                    send_expr = ASCE.make_send(
                            loc,

                            ASCE.make_identifier(loc, sym_xs),

                            ASCE.make_message(
                                loc,
                                :select,
                                [ASCE.make_identifier(loc, sym_f)]
                            )
                        )

                    new_env = env.va_extend_values(
                                        sym_x   => x,
                                        sym_xs  => xs,
                                        sym_f   => func
                                    )

                    VC.make_cell_stream_cons(
                        ASCE.make_identifier(loc, sym_x),

                        VC.make_expr_stream_entry(
                            send_expr,
                            new_env.va_context
                        ),

                        new_env.va_context
                    )
                else
                    xs.meth_select loc, env, event, func
                end
            end
        )

        ASSERT.kind_of result, VCM::Stream::Entry::Abstract
    end


    define_instance_method(
        :meth_append,
        :'++', [],
        [self], self
    )
    def meth_append(loc, env, event, ys)
        ASSERT.kind_of ys, VCM::Stream::Entry::Abstract

        sym_ys   = :'%ys'
        sym_self = :'self'

        new_env = env.va_extend_values(
            sym_ys   => ys,
            sym_self => self
        )

        expr = ASCE.make_send(
                loc,

                ASCE.make_identifier(loc, sym_self),

                ASCE.make_message(
                    loc,
                    :'%++',
                    [ASCE.make_identifier(loc, sym_ys)]
                )
            )


        VC.make_suspended_stream(expr, new_env.va_context)
    end


    define_instance_method(
        :meth_append_,
        :'%++', [],
        [self], self
    )
    def meth_append_(loc, env, event, ys)
        ASSERT.kind_of ys, VCM::Stream::Entry::Abstract

        val_opt = self.meth_force loc, env, event

        VC.validate_option val_opt, '++', loc, env

        result = (
            if val_opt.none?
                ys
            else
                sym_x   = :'%x'
                sym_xs  = :'%xs'
                sym_ys  = :'%ys'

                x, xs = VC.validate_pair(
                            val_opt.contents, "++", loc, env
                        )

                VC.validate_stream xs, '++', loc, env
                new_env = env.va_extend_values(
                                    sym_x   => x,
                                    sym_xs  => xs,
                                    sym_ys  => ys
                                )

                tail_stream = VC.make_expr_stream_entry(
                         ASCE.make_send(
                            loc,

                            ASCE.make_identifier(loc, sym_xs),

                            ASCE.make_message(
                                loc,
                                :'++',
                                [ASCE.make_identifier(loc, sym_ys)]
                            )
                        ),

                        new_env.va_context
                    )

                VC.make_cell_stream_cons(
                    ASCE.make_identifier(loc, sym_x),
                    tail_stream,
                    new_env.va_context
                )
            end
        )

        ASSERT.kind_of result, VCM::Stream::Entry::Abstract
    end


    define_instance_method(
        :meth_concat_map,
        :'concat-map', [],
        [VC::Fun], self
    )
    def meth_concat_map(loc, env, _event, func)
        ASSERT.kind_of func, VC::Fun

        sym_f    = :'%f'
        sym_self = :'self'

        new_env = env.va_extend_values(
            sym_f    => func,
            sym_self => self
        )

        expr = ASCE.make_send(
                loc,

                ASCE.make_identifier(loc, sym_self),

                ASCE.make_message(
                    loc,
                    :'%concat-map',
                    [ASCE.make_identifier(loc, sym_f)]
                )
            )


        VC.make_suspended_stream(expr, new_env.va_context)
    end


    define_instance_method(
        :meth_concat_map_,
        :'%concat-map', [],
        [VC::Fun], self
    )
    def meth_concat_map_(loc, env, event, func)
        ASSERT.kind_of func, VC::Fun

        val_opt = self.meth_force loc, env, event

        VC.validate_option val_opt, 'concat-map', loc, env

        result = (
            if val_opt.none?
                VC.make_cell_stream_nil env.va_context
            else
                x, xs = VC.validate_pair(
                            val_opt.contents, 'concat-map', loc, env
                        )
                VC.validate_stream xs, 'concat-map', loc, env

                ys = func.apply x, [], loc, env.enter(event)
                VC.validate_stream ys, 'concat-map', loc, env

                xs1 = xs.meth_concat_map loc, env, event, func

                ys.meth_append loc, env, event, xs1
            end
        )

        ASSERT.kind_of result, VCM::Stream::Entry::Abstract
    end


    define_instance_method(
        :meth_take_to_list,
        :'take-to-list', [],
        [VCAN::Int], VCM::List::Abstract
    )
    def meth_take_to_list(loc, env, event, value)
        ASSERT.kind_of value, VCAN::Int

        zs = loop.inject(
             [VC.make_nil, self, value.val]
        ) { |(ys,          xs,   n), _|
            if n <= 0
                break ys
            end

            val_of_opt = xs.meth_force(loc, env, event)
            case val_of_opt
            when VCU::Option::None
                break ys
            when VCU::Option::Some
                pair = val_of_opt.contents
                ASSERT.kind_of pair, VCP::Tuple
                x, xs1 = pair.values

                [
                    ys.meth_cons(loc, env, event, x),
                    xs1,
                    n - 1
                ]
            else
                ASSERT.abort "No case: ", val_of_opt.inspect
            end
        }

        result = zs.meth_reverse(loc, env, event)

        ASSERT.kind_of result, VCM::List::Abstract
    end


private

    def __meth_force__(loc, env, event)
        raise X::InternalSubclassResponsibility
    end
end



class Cell < Abstract
    TYPE_SYM = :CellStream


    define_class_method(
        :meth_make_empty,
        :empty, [],
        [], self
    )
    def self.meth_make_empty(_loc, env, _event)
        VC.make_cell_stream_nil env.va_context
    end


    alias cell obj

    def initialize(cell, va_context)
        ASSERT.kind_of cell,        Stream::Cell::Abstract
        ASSERT.kind_of va_context,  ECV::Abstract

        super
    end


    def step(env)
        new_env = env.update_va_context(self.va_context)

        self.cell.step new_env
    end


private

    def __meth_force__(loc, env, event)
        self.cell.force loc, env, event
    end
end



class Expression < Abstract
    TYPE_SYM = :ExprStream


    alias expr obj

    def initialize(expr, va_context)
        ASSERT.kind_of expr,        ASCE::Abstract
        ASSERT.kind_of va_context,  ECV::Abstract

        super
    end


    def step(env)
        self.expr.evaluate(env).value
    end


private

    def __meth_force__(loc, env, event)
        new_env = env.enter event

        self.expr.evaluate(new_env).value
    end
end



class Memorization < Abstract
    TYPE_SYM = :MemoStream


    define_class_method(
        :meth_make_empty,
        :empty, [],
        [], self
    )
    def self.meth_make_empty(_loc, env, _event)
        VC.make_memo_stream_nil env.va_context
    end


    alias       stream_expr obj
    attr_reader :memorized_value

    def initialize(stream_expr, va_context)
        ASSERT.kind_of stream_expr, ASCE::MemoStream::Abstract
        ASSERT.kind_of va_context,  ECV::Abstract

        super

        @memorized_value = nil
    end


    def step(env)
        # @memorized_value ||= self.stream_expr.evaluate(env).value

        ASSERT.abort "No case"
    end


private

    def __meth_force__(loc, env, event)
        new_env = env.update_va_context(self.va_context)
                     .enter(event)

        @memorized_value ||= (
            case self.stream_expr
            when ASCE::MemoStream::Nil
                VC.make_none
            when ASCE::MemoStream::Cons
                # Evaluate head expression
                head_expr  = self.stream_expr.head_expr
                head_value = head_expr.evaluate(new_env).value

                # Evaluate tail expression
                tail_expr   = self.stream_expr.tail_expr
                tail_stream = tail_expr.evaluate(new_env).value
                unless tail_stream.kind_of? Stream::Entry::Abstract
                    raise X::TypeError.new(
                        loc,
                        new_env,
                        "force: Expected a Stream, but %s : %s",
                        tail_stream.to_s,
                        tail_stream.type_sym.to_s
                    )
                end

                # Make the result of forcing stream
                VC.make_some VC.make_tuple(head_value, tail_stream)
            else
                ASSERT.abort 'No case'
            end
        )

        ASSERT.kind_of @memorized_value, VCU::Option::Abstract
    end
end



class Suspended < Abstract
    TYPE_SYM = :SuspStream


    alias expr obj

    def initialize(expr, va_context)
        ASSERT.kind_of expr,        ASCE::Abstract
        ASSERT.kind_of va_context,  ECV::Abstract

        super
    end


    def step(env)
        ASSERT.abort "No case"
    end


private

    def __meth_force__(loc, env, event)
        new_env = env.update_va_context(self.va_context)
                     .enter(event)

        stream_value = self.expr.evaluate(new_env).value
        unless stream_value.kind_of? Stream::Entry::Abstract
            raise X::TypeError.new(
                loc,
                new_env,
                "force: Expected a Stream, but %s : %s",
                stream_value.to_s,
                stream_value.type_sym.to_s
            )
        end

        option_value = stream_value.meth_force loc, new_env, event
        unless option_value.kind_of? VCU::Option::Abstract
            raise X::TypeError.new(
                loc,
                new_env,
                "force: Expected a Option, but %s : %s",
                option_value.to_s,
                option_value.type_sym.to_s
            )
        end

        ASSERT.kind_of option_value, VCU::Option::Abstract
    end
end



class Interval < Abstract
    TYPE_SYM = :IntervalStream


    define_class_method(
        :meth_from,
        :'from', [:'from:'],
        [VCAN::Int], self
    )
    define_class_method(
        :meth_from_to,
        :'from-to', [:'from:to:'],
        [VCAN::Int, VCAN::Int], self
    )
    define_class_method(
        :meth_from_to_by,
        :'from-to-by', [:'from:to:by:'],
        [VCAN::Int, VCAN::Int, VCAN::Int], self
    )
    def self.meth_from_to_by(
        _loc, env, _event,
        current_value,
        opt_stop_value = nil,
        step_value     = VC.make_integer_one
    )
        ASSERT.kind_of     current_value,   VCAN::Int
        ASSERT.opt_kind_of opt_stop_value,  VCAN::Int
        ASSERT.kind_of     step_value,      VCAN::Int

        VC.make_interval_stream(
            current_value, opt_stop_value, step_value, env.va_context
        )
    end


    define_class_method(
        :meth_from_by,
        :'from-by', [:'from:by:'],
        [VCAN::Int, VCAN::Int], self
    )
    def self.meth_from_by(
        _loc, env, _event, current_value, step_value
    )
        ASSERT.kind_of current_value,   VCAN::Int
        ASSERT.kind_of step_value,      VCAN::Int

        VC.make_interval_stream(
            current_value, nil, step_value, env.va_context
        )
    end


    alias       current_value obj
    attr_reader :opt_stop_value, :step_value

    def initialize(current_value, opt_stop_value, step_value, va_context)
        ASSERT.kind_of     current_value,   VCAN::Int
        ASSERT.opt_kind_of opt_stop_value,  VCAN::Int
        ASSERT.kind_of     step_value,      VCAN::Int
        ASSERT.kind_of     va_context,      ECV::Abstract

        super(current_value, va_context)

        @opt_stop_value = opt_stop_value
        @step_value     = step_value
    end


    def to_s
        format("&[%s ..%s (%s%s)]",
                self.current_value.to_s,

                if self.opt_stop_value
                    format " %s", self.opt_stop_value.to_s
                else
                    ''
                end,

                self.step_value.val.positive? ? '+' : '',

                self.step_value.to_s
        )
    end


    def pretty_print(q)
        PRT.group q, bb:'&[', eb:']' do
            q.pp self.current_value

            q.text ' ..'

            if self.opt_stop_value
                q.text format(" %s", self.opt_stop_value.to_s)
            end

            q.text format(" (%s%s)",
                            self.step_value.val.positive? ? '+' : '',
                            self.step_value.to_s
                    )
        end
    end


    def step(env)
        self
    end


private

    def __meth_force__(loc, env, event)
        new_env = env.enter event

        end_of_interval = (
            if self.opt_stop_value
                stop_value = self.opt_stop_value

                if self.step_value.val.positive?
                    self.current_value.val > stop_value.val
                else
                    self.current_value.val < stop_value.val
                end
            else
                false
            end
        )

        if end_of_interval
            VC.make_none
        else
            sym_next = :'%next'
            sym_stop = :'%stop'
            sym_step = :'%step'

            next_value = self.current_value + self.step_value

            new_env, message = (
                if self.opt_stop_value
                    [
                        env.va_extend_values(
                            sym_next => next_value,
                            sym_stop => self.opt_stop_value,
                            sym_step => self.step_value
                        ),

                        ASCE.make_message(
                            loc,
                            :'from-to-by',
                            [
                                ASCE.make_identifier(loc, sym_next),
                                ASCE.make_identifier(loc, sym_stop),
                                ASCE.make_identifier(loc, sym_step)
                            ]
                        )
                    ]
                else
                    [
                        env.va_extend_values(
                            sym_next => next_value,
                            sym_step => self.step_value
                        ),

                        ASCE.make_message(
                            loc,
                            :'from-by',
                            [
                                ASCE.make_identifier(loc, sym_next),
                                ASCE.make_identifier(loc, sym_step)
                            ]
                        )
                    ]
                end
            )

            VC.make_some(
                VC.make_tuple(
                    self.current_value,

                    VC.make_suspended_stream(
                         ASCE.make_send(
                            loc,
                            ASCE.make_class(loc, TYPE_SYM),
                            message
                        ),

                        new_env.va_context
                    )
                )
            )
        end
    end
end

end # Umu::Value::Core::Morph::Stream::Entry

end # Umu::Value::Core::Morph::Stream

end # Umu::Value::Core::Morph



module_function

    # For Cell Stream

    def make_cell_stream_nil(va_context)
        ASSERT.kind_of va_context,  ECV::Abstract

        VC.make_cell_stream_entry(
            Morph::Stream::Cell.make_nil,
            va_context
        )
    end


    def make_cell_stream_cons(head_expr, tail_stream, va_context)
        ASSERT.kind_of head_expr,   ASCE::Abstract
        ASSERT.kind_of tail_stream, Morph::Stream::Entry::Abstract
        ASSERT.kind_of va_context,  ECV::Abstract

        VC.make_cell_stream_entry(
            Morph::Stream::Cell.make_cons(head_expr, tail_stream),
            va_context
        )
    end


    def make_cell_stream_entry(cell, va_context)
        ASSERT.kind_of cell,        Morph::Stream::Cell::Abstract
        ASSERT.kind_of va_context,  ECV::Abstract

        Morph::Stream::Entry::Cell.new(cell, va_context).freeze
    end


    def make_expr_stream_entry(expr, va_context)
        ASSERT.kind_of expr,        ASCE::Abstract
        ASSERT.kind_of va_context,  ECV::Abstract

        Morph::Stream::Entry::Expression.new(expr, va_context).freeze
    end


    # For Memo Stream

    def make_memo_stream_nil(va_context)
        ASSERT.kind_of va_context,  ECV::Abstract

        VC.make_memo_stream_entry(
            ASCE.make_memo_stream_nil(
                LOC.make_location(__FILE__, __LINE__)
            ),
            va_context
        )
    end

    def make_memo_stream_entry(stream_expr, va_context)
        ASSERT.kind_of stream_expr, ASCE::MemoStream::Abstract
        ASSERT.kind_of va_context,  ECV::Abstract
                                                    # Does NOT freeze!!
        Morph::Stream::Entry::Memorization.new(stream_expr, va_context)
    end


    # For Suspended Stream

    def make_suspended_stream(expr, va_context)
        ASSERT.kind_of expr,        ASCE::Abstract
        ASSERT.kind_of va_context,  ECV::Abstract

        Morph::Stream::Entry::Suspended.new(expr, va_context)
    end


    # For Interval Stream

    def make_interval_stream(
        current_value, opt_stop_value, step_value, va_context
    )
        ASSERT.kind_of     current_value,   VCAN::Int
        ASSERT.opt_kind_of opt_stop_value,  VCAN::Int
        ASSERT.kind_of     step_value,      VCAN::Int
        ASSERT.kind_of     va_context,      ECV::Abstract

        Morph::Stream::Entry::Interval.new(
            current_value, opt_stop_value, step_value, va_context
        ).freeze
    end

end # Umu::Value::Core

end # Umu::Value

end # Umu
