# coding: utf-8
# frozen_string_literal: true



module Umu

module Value

module Core

module Stream

module Entry

class Abstract < Object
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


    define_instance_method(
        :meth_force,
        :force, [:dest],
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
        :meth_is_empty,
        :empty?, [],
        [], VCA::Bool
    )
    def meth_is_empty(loc, env, event)
        val_of_opt = self.meth_force loc, env, event
        ASSERT.kind_of val_of_opt, VCU::Option::Abstract

        result = val_of_opt.meth_is_none loc, env, event

        ASSERT.kind_of result, VCA::Bool
    end


    define_instance_method(
        :meth_dest!,
        :dest!, [],
        [], VCP::Tuple
    )
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


    define_instance_method(
        :meth_cons,
        :cons, [],
        [VC::Top], self
    )
    def meth_cons(loc, env, _event, value)
        ASSERT.kind_of value, VC::Top

        raise X::NotImplemented.new(
                    loc,
                    env,
                    "cons: Stream morph is not be constructible"
                )
    end


    define_instance_method(
        :meth_take,
        :take, [],
        [VCAN::Int], VCM::List::Abstract
    )
    def meth_take(loc, env, event, value)
        ASSERT.kind_of value, VCAN::Int

        zs, _, _ = loop.inject(
             [VC.make_nil, self, value.val]
        ) { |(ys,          xs,   n), _|
            if n <= 0
                break [ys, xs, n]
            end

            val_of_opt = xs.meth_force(loc, env, event)
            case val_of_opt
            when VCU::Option::None
                break [ys, xs, n]
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
        self.cell.step env
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
        self.expr.evaluate(env).value
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

end # Umu::Value::Core::Stream::Entry

end # Umu::Value::Core::Stream



module_function

    # For Cell Stream

    def make_cell_stream_nil(va_context)
        ASSERT.kind_of va_context,  ECV::Abstract

        VC.make_cell_stream_entry(
            Stream::Cell.make_nil,
            va_context
        )
    end


    def make_cell_stream_cons(head_expr, tail_stream, va_context)
        ASSERT.kind_of head_expr,   ASCE::Abstract
        ASSERT.kind_of tail_stream, Stream::Entry::Abstract
        ASSERT.kind_of va_context,  ECV::Abstract

        VC.make_cell_stream_entry(
            Stream::Cell.make_cons(head_expr, tail_stream),
            va_context
        )
    end


    def make_cell_stream_entry(cell, va_context)
        ASSERT.kind_of cell,        Stream::Cell::Abstract
        ASSERT.kind_of va_context,  ECV::Abstract

        Stream::Entry::Cell.new(cell, va_context).freeze
    end


    def make_expr_stream_entry(expr, va_context)
        ASSERT.kind_of expr,        ASCE::Abstract
        ASSERT.kind_of va_context,  ECV::Abstract

        Stream::Entry::Expression.new(expr, va_context).freeze
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
        Stream::Entry::Memorization.new(stream_expr, va_context)
    end


    # For Look Ahead Stream

    def make_suspended_stream(expr, va_context)
        ASSERT.kind_of expr,        ASCE::Abstract
        ASSERT.kind_of va_context,  ECV::Abstract

        Stream::Entry::Suspended.new(expr, va_context)
    end

end # Umu::Value::Core

end # Umu::Value

end # Umu
