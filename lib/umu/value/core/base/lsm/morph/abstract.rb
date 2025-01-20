# coding: utf-8
# frozen_string_literal: true



module Umu

module Value

module Core

module Base

module LSM

module Morph

class Abstract < Object
=begin
    Inheriting subclasses must implement the following methods:
    * .make(xs : ::Array) -> Morph::Abstract
    * .meth_make_empty(loc, env, event) -> Morph::Abstract
    * #meth_cons(loc, env, event, value : VC::Top) -> Morph::Abstract
    * #meth_is_empty(loc, env, event) -> VCBA::Bool
    * #dest! -> [VC::Top, Morph::Abstract]
=end


    def self.make(xs)
        raise X::InternalSubclassResponsibility
    end


    define_class_method(
        :meth_make_empty,
        :empty, [],
        [], self
    )
    def self.meth_make_empty(_loc, _env, _event)
        raise X::InternalSubclassResponsibility
    end


=begin
    HOW TO USE: unfoldr

    * Same to: [1 .. 5].to-list

        > &List.unfoldr 1 { x -> if x <= 5 then Some (x, x + 1) else NONE }
        val it : Cons = [1, 2, 3, 4, 5]

    * Same to: [1, 2, 3].map to-s

        > &List.unfoldr [1, 2, 3] { xs ->
        *     case xs of {
        *       [x|xs'] -> Some (x.to-s, xs')
        *       else    -> NONE
        *     }
        * }
        val it : Cons = ["1", "2", "3"]

    * Same to: STDIN.each-line.to-list

        > &List.unfoldr STDIN { io ->
        *     case io.gets of {
        *       &Some s -> Some (s, io)
        *       else    -> NONE
        *     }
        * }
        a
        b
        c
        [Ctrl]+[D]
        val it : Cons = ["a", "b", "c"]
=end
    define_class_method(
        :meth_unfoldr,
        :unfoldr, [],
        [VC::Top, VC::Fun], self
    )
    def self.meth_unfoldr(loc, env, event, x, func)
        ASSERT.kind_of x,    VC::Top
        ASSERT.kind_of func, VC::Fun

        result = self.meth_unfoldl(loc, env, event, x, func)
                     .meth_reverse(loc, env, event)

        ASSERT.kind_of result, VC::Top
    end


    define_class_method(
        :meth_unfoldl,
        :unfoldl, [],
        [VC::Top, VC::Fun], self
    )
    def self.meth_unfoldl(loc, env, event, x, func)
        ASSERT.kind_of x,    VC::Top
        ASSERT.kind_of func, VC::Fun

        new_env = env.enter event

        _, result = loop.inject(
            [x, self.meth_make_empty(loc, new_env, event)]
        ) { |(x1, ys), _|
            value = func.apply x1, [], loc, new_env
            ASSERT.kind_of value, VC::Top

            unless value.kind_of? VCBLU::Option::Abstract
                raise X::TypeError.new(
                    new_loc,
                    new_env,
                    "unfoldl: Expected a Option, but %s : %s",
                    value.to_s,
                    value.type_sym.to_s
                )
            end

            case value
            when VCBLU::Option::None
                break [x1, ys]
            when VCBLU::Option::Some
                tuple = value.contents
                ASSERT.kind_of tuple, VC::Top

                unless tuple.kind_of? VCBLP::Tuple
                    raise X::TypeError.new(
                        new_loc,
                        new_env,
                        "Unfoldl: Expected a Tuple, but %s : %s",
                        tuple.to_s,
                        tuple.type_sym.to_s
                    )
                end

                tup_vals = tuple.values
                unless tup_vals.size == 2
                    raise X::TypeError.new(
                        new_loc,
                        new_env,
                        "Unfoldl: Expected arity of the tuple is 2, " +
                                                                "but %s",
                        tuple.to_s
                    )
                end

                x2, next_x = tup_vals

                [next_x, ys.meth_cons(loc, new_env, event, x2)]
            else
                ASSERT.abort "No case"
            end
        }

        ASSERT.kind_of result, VC::Top
    end


    include Enumerable


    def each
        return self.to_enum unless block_given?

        xs = self
        loop do
            t = xs.dest!
            ASSERT.kind_of t, VCBLP::Tuple
            x, xs1 = t.values

            yield x

            xs = xs1
        end

        nil
    end


    define_instance_method(
        :meth_cons,
        :cons, [],
        [VC::Top], self
    )
    def meth_cons(_loc, _env, _event, value)
        ASSERT.kind_of value, VC::Top

        raise X::InternalSubclassResponsibility
    end


    define_instance_method(
        :meth_is_empty,
        :empty?, [],
        [], VCBA::Bool
    )
    def meth_is_empty(_loc, _env, _event)
        raise X::InternalSubclassResponsibility
    end


    def dest!
        raise X::InternalSubclassResponsibility
    end


    define_instance_method(
        :meth_dest!,
        :dest!, [],
        [], VCBLP::Tuple
    )
    def meth_dest!(loc, env, _event)
        begin
            self.dest!
        rescue ::StopIteration
            raise X::EmptyError.new(
                        loc,
                        env,
                        "dest!: Empty morph cannot be destructible"
                    )
        end
    end


    define_instance_method(
        :meth_dest,
        :dest, [],
        [], VCBLU::Option::Abstract
    )
    def meth_dest(loc, env, event)
        if self.meth_is_empty(loc, env, event).true?
            VC.make_none
        else
            VC.make_some self.dest!
        end
    end


    define_instance_method(
        :meth_head,
        :head, [],
        [], VC::Top
    )
    def meth_head(loc, env, event)
        self.meth_dest!(loc, env, event).select_by_number(1, loc, env)
    end


    define_instance_method(
        :meth_tail,
        :tail, [],
        [], self
    )
    def meth_tail(loc, env, event)
        self.meth_dest!(loc, env, event).select_by_number(2, loc, env)
    end


    define_instance_method(
        :meth_to_list,
        :'to-list', [],
        [], VCBLM::List::Abstract
    )
    def meth_to_list(loc, env, event)
        result = self.foldr(
             loc,     env,     event, VC.make_nil
        ) { |new_loc, new_env, x ,    xs|

             xs.meth_cons new_loc, new_env, event, x
        }

        ASSERT.kind_of result, VC::Top
    end


    def foldr(loc, env, event, init, &block)
        ASSERT.kind_of init,  VC::Top
        ASSERT.kind_of block, ::Proc

        result = self.foldl(
             loc,     env,     event, VC.make_nil
        ) { |new_loc, new_env, x,     xs|

             xs.meth_cons new_loc, new_env, event, x
        }.foldl(
            loc, env, event, init, &block
        )

        ASSERT.kind_of result, VC::Top
    end


    define_instance_method(
        :meth_foldr,
        :foldr, [],
        [VC::Top, VC::Fun], VC::Top
    )
    def meth_foldr(loc, env, event, init, func)
        ASSERT.kind_of init,    VC::Top
        ASSERT.kind_of func,    VC::Fun

        result = self.foldr(
             loc,     env,     event, init
        ) { |new_loc, new_env, x,     y|

            func.apply x, [y], new_loc, new_env
        }

        ASSERT.kind_of result, VC::Top
    end


    def foldl(loc, env, event, init, &block)
        ASSERT.kind_of init,  VC::Top
        ASSERT.kind_of block, ::Proc

        new_env = env.enter event

        mut_y  = init.dup
        mut_xs = self.dup
        result = loop {
            if mut_xs.meth_is_empty(loc, new_env, event).true?
                break mut_y
            end

            pair = mut_xs.meth_dest!(loc, new_env, event)
            ASSERT.kind_of pair, VCBLP::Tuple

            x, mut_xs = pair.values
            mut_y = yield loc, new_env, x, mut_y
        }

        ASSERT.kind_of mut_y.freeze, VC::Top
    end


    define_instance_method(
        :meth_foldl,
        :foldl, [],
        [VC::Top, VC::Fun], VC::Top
    )
    def meth_foldl(loc, env, event, init, func)
        ASSERT.kind_of init,    VC::Top
        ASSERT.kind_of func,    VC::Fun

        result = self.foldl(
             loc,     env,     event, init
        ) { |new_loc, new_env, x,     y|

            func.apply x, [y], new_loc, new_env
        }

        ASSERT.kind_of result, VC::Top
    end


    define_instance_method(
        :meth_reverse,
        :reverse, [],
        [], self
    )
    def meth_reverse(loc, env, event)
        result = self.foldl(
             loc,     env,     event, VC.make_nil
        ) { |new_loc, new_env, x,     xs|

             xs.meth_cons new_loc, new_env, event, x
        }

        ASSERT.kind_of result, VC::Top
    end


    define_instance_method(
        :meth_count,
        :count, [],
        [], VCBAN::Int
    )
    def meth_count(loc, env, event)
        result = self.foldl(
             loc,     env,     event, VC.make_integer_zero
        ) { |new_loc, new_env, _,     n|

             n.meth_succ new_loc, new_env, event
        }

        ASSERT.kind_of result, VCBAN::Int
    end


    define_instance_method(
        :meth_sum,
        :sum, [],
        [], VCBAN::Abstract
    )
    def meth_sum(loc, env, event)
        if self.meth_is_empty(loc, env, event).true?
            raise X::EmptyError.new loc, env, "sum: Empty morph"
        end

        head = self.meth_head loc, env, event
        unless head.kind_of? VCBAN::Abstract
            raise X::TypeError.new(
                loc,
                env,
                "sum: Expected a Number, but %s : %s",
                head.to_s,
                head.type_sym.to_s
            )
        end
        zero = head.meth_zero loc, env, event
        zero_class_signat = env.ty_class_signat_of zero

        result = self.foldl(
             loc,     env,     event, zero
        ) { |new_loc, new_env, x,     sum|

            unless env.ty_kind_of?(x, zero_class_signat)
                raise X::TypeError.new(
                    new_loc,
                    new_env,
                    "sum: Expected a %s, but %s : %s",
                    zero_class_signat.symbol.to_s,
                    x.to_s,
                    x.type_sym.to_s
                )
            end

            sum.meth_add new_loc, new_env, event, x
        }

        ASSERT.kind_of result, VCBAN::Abstract
    end


    define_instance_method(
        :meth_avg,
        :avg, [],
        [], VCBAN::Abstract
    )
    def meth_avg(loc, env, event)
        if self.meth_is_empty(loc, env, event).true?
            raise X::EmptyError.new loc, env, "avg: Empty morph"
        end

        head = self.meth_head loc, env, event
        unless head.kind_of? VCBAN::Abstract
            raise X::TypeError.new(
                loc,
                env,
                "avg: Expected a Number, but %s : %s",
                head.to_s,
                head.type_sym.to_s
            )
        end
        zero = head.meth_zero loc, env, event
        zero_class_signat = env.ty_class_signat_of zero

        result_opaque = self.foldl(
             loc,     env,     event, VC.make_opaque([zero, zero])
        ) { |new_loc, new_env, x,     opaque|

            unless env.ty_kind_of?(x, zero_class_signat)
                raise X::TypeError.new(
                    new_loc,
                    new_env,
                    "avg: Expected a %s, but %s : %s",
                    zero_class_signat.symbol.to_s,
                    x.to_s,
                    x.type_sym.to_s
                )
            end

            va_sum, va_count = opaque.obj

            VC.make_opaque(
                [
                    va_sum.meth_add(loc, env, event, x),
                    va_count.meth_succ(loc, env, event)
                ]
            )
        }

        res_sum, res_count = result_opaque.obj

        res_sum.meth_divide(loc, env, event, res_count)
    end


    define_instance_method(
        :meth_max,
        :max, [],
        [], VCBAN::Abstract
    )
    def meth_max(loc, env, event)
        if self.meth_is_empty(loc, env, event).true?
            raise X::EmptyError.new loc, env, "max: Empty morph"
        end

        head = self.meth_head loc, env, event
        unless head.kind_of? VCBAN::Abstract
            raise X::TypeError.new(
                loc,
                env,
                "max: Expected a Number, but %s : %s",
                head.to_s,
                head.type_sym.to_s
            )
        end
        head_class_signat = env.ty_class_signat_of head

        self.meth_tail(loc, env, event).foldl(
             loc,     env,       event, head
        ) { |new_loc, new_event, x,     y|

            unless env.ty_kind_of?(y, head_class_signat)
                raise X::TypeError.new(
                    new_loc,
                    new_env,
                    "max: Expected a %s, but %s : %s",
                    head_class_signat.symbol.to_s,
                    y.to_s,
                    y.type_sym.to_s
                )
            end

            if y.meth_less_than(loc, env, event, x).true?
                x
            else
                y
            end
        }
    end


    define_instance_method(
        :meth_min,
        :min, [],
        [], VCBAN::Abstract
    )
    def meth_min(loc, env, event)
        if self.meth_is_empty(loc, env, event).true?
            raise X::EmptyError.new loc, env, "min: Empty morph"
        end

        head = self.meth_head loc, env, event
        unless head.kind_of? VCBAN::Abstract
            raise X::TypeError.new(
                loc,
                env,
                "min: Expected a Number, but %s : %s",
                head.to_s,
                head.type_sym.to_s
            )
        end
        head_class_signat = env.ty_class_signat_of head

        self.meth_tail(loc, env, event).foldl(
             loc,     env,       event, head
        ) { |new_loc, new_event, x,     y|

            unless env.ty_kind_of?(y, head_class_signat)
                raise X::TypeError.new(
                    new_loc,
                    new_env,
                    "min: Expected a %s, but %s : %s",
                    head_class_signat.symbol.to_s,
                    y.to_s,
                    y.type_sym.to_s
                )
            end

            if x.meth_less_than(loc, env, event, y).true?
                x
            else
                y
            end
        }
    end


    define_instance_method(
        :meth_is_all,
        :all?, [],
        [VC::Fun], VCBA::Bool
    )
    def meth_is_all(loc, env, event, func)
        ASSERT.kind_of func, VC::Fun

        result = self.foldl(
             loc,     env,     event, VC.make_true
        ) { |new_loc, new_env, x,     bool|

            value = func.apply x, [], new_loc, new_env
            unless value.kind_of? VCBA::Bool
                raise X::TypeError.new(
                    new_loc,
                    new_env,
                    "all?:Expected a Bool, but %s : %s",
                    value.to_s,
                    value.type_sym.to_s
                )
            end

            break VC.make_false if value.false?

            bool
        }

        ASSERT.kind_of result, VCBA::Bool
    end


    define_instance_method(
        :meth_is_any,
        :any?, [],
        [VC::Fun], VCBA::Bool
    )
    def meth_is_any(loc, env, event, func)
        ASSERT.kind_of func, VC::Fun

        result = self.foldl(
             loc,     env,     event, VC.make_false
        ) { |new_loc, new_env, x,     bool|

            value = func.apply x, [], new_loc, new_env
            unless value.kind_of? VCBA::Bool
                raise X::TypeError.new(
                    new_loc,
                    new_env,
                    "any?: Expected a Bool, but %s : %s",
                    value.to_s,
                    value.type_sym.to_s
                )
            end

            break VC.make_true if value.true?

            bool
        }

        ASSERT.kind_of result, VCBA::Bool
    end


    define_instance_method(
        :meth_is_include,
        :include?, [],
        [VC::Top], VCBA::Bool
    )
    def meth_is_include(loc, env, event, member)
        ASSERT.kind_of member, VC::Top

        result = self.foldl(
             loc,     env,     event, VC.make_false
        ) { |new_loc, new_env, x,     bool|

            value = x.meth_equal loc, new_env, event, member
            unless value.kind_of? VCBA::Bool
                raise X::TypeError.new(
                    new_loc,
                    new_env,
                    "include?: Expected a Bool, but %s : %s",
                    value.to_s,
                    value.type_sym.to_s
                )
            end

            break VC.make_true if value.true?

            bool
        }

        ASSERT.kind_of result, VCBA::Bool
    end


    define_instance_method(
        :meth_for_each,
        :'for-each', [],
        [VC::Fun], VC::Unit
    )
    def meth_for_each(loc, env, event, func)
        ASSERT.kind_of func, VC::Fun

        self.foldl(
              loc,     env,     event, VC.make_unit
        ) do |new_loc, new_env, x,     _|

             func.apply x, [], loc, new_env
        end

        VC.make_unit
    end


    define_instance_method(
        :meth_map,
        :map, [],
        [VC::Fun], self
    )
    def meth_map(loc, env, event, func)
        ASSERT.kind_of func, VC::Fun

        result = self.foldr(
             loc,     env,     event, VC.make_nil
        ) { |new_loc, new_env, x,     ys|

            ys.meth_cons(
                new_loc, new_env, event, 
                func.apply(x, [], new_loc, new_env)
            )
        }

        ASSERT.kind_of result, VCBLM::List::Abstract
    end


    define_instance_method(
        :meth_select,
        :select, [],
        [VC::Fun], self
    )
    def meth_select(loc, env, event, func)
        ASSERT.kind_of func, VC::Fun

        result = self.foldr(
             loc,     env,     event, VC.make_nil
        ) { |new_loc, new_env, x,     ys|

            value = func.apply x, [], new_loc, new_env
            unless value.kind_of? VCBA::Bool
                raise X::TypeError.new(
                    new_loc,
                    new_env,
                    "select: Expected a Bool, but %s : %s",
                    value.to_s,
                    value.type_sym.to_s
                )
            end

            if value.true?
                ys.meth_cons new_loc, new_env, event, x
            else
                ys
            end
        }

        ASSERT.kind_of result, VCBLM::List::Abstract
    end


    define_instance_method(
        :meth_reject,
        :reject, [],
        [VC::Fun], self
    )
    def meth_reject(loc, env, event, func)
        ASSERT.kind_of func, VC::Fun

        result = self.foldr(
             loc,     env,     event, VC.make_nil
        ) { |new_loc, new_env, x,     ys|

            value = func.apply x, [], new_loc, new_env
            unless value.kind_of? VCBA::Bool
                raise X::TypeError.new(
                    new_loc,
                    new_env,
                    "reject: Expected a Bool, but %s : %s",
                    value.to_s,
                    value.type_sym.to_s
                )
            end

            if value.false?
                ys.meth_cons new_loc, new_env, event, x
            else
                ys
            end
        }

        ASSERT.kind_of result, VCBLM::List::Abstract
    end


    define_instance_method(
        :meth_append,
        :'++', [],
        [self], self
    )
    def meth_append(loc, env, event, ys)
        ASSERT.kind_of ys, Abstract

        result = if ys.meth_is_empty(loc, env, event).true?
                        self
                    else
                        self.foldr(
                             loc,     env,     event, ys
                        ) { |new_loc, new_env, x,     ys1|

                            ys1.meth_cons new_loc, new_env, event, x
                        }
                    end

        ASSERT.kind_of result, VCBLM::List::Abstract
    end


    define_instance_method(
        :meth_concat,
        :concat, [],
        [], self
    )
    def meth_concat(loc, env, event)
        result = self.foldl(
             loc,     env,     event, VC.make_nil
        ) { |new_loc, new_env, xs,    xss|

            xss.meth_append new_loc, new_env, event, xs
        }

        ASSERT.kind_of result, VCBLM::List::Abstract
    end


    define_instance_method(
        :meth_concat_map,
        :'concat-map', [],
        [VC::Fun], self
    )
    def meth_concat_map(loc, env, event, func)
        ASSERT.kind_of func, VC::Fun

        result = self.foldl(
             loc,     env,     event, VC.make_nil
        ) { |new_loc, new_env, x,     yss|

            xs = func.apply x, [], loc, new_env
            unless xs.kind_of? Abstract
                raise X::TypeError.new(
                    new_loc,
                    new_env,
                    "concat-map: Expected a Morph, but %s : %s",
                    xs.to_s,
                    xs.type_sym.to_s
                )
            end

            yss.meth_append new_loc, new_env, event, xs
        }

        ASSERT.kind_of result, VCBLM::List::Abstract
    end


    define_instance_method(
        :meth_join,
        :join, [],
        [], VCBA::String
    )
    define_instance_method(
        :meth_join,
        :'join:', [],
        [VCBA::String], VCBA::String
    )
    def meth_join(loc, env, event, sep_value = nil)
        ASSERT.opt_kind_of sep_value, VCBA::String

        result = self.foldl(
             loc,     env,     event, VC.make_opaque(["", true])
        ) { |new_loc, new_env, x,     opaque|

            unless x.kind_of? VCBA::String
                raise X::TypeError.new(
                    new_loc,
                    new_env,
                    "join: Expected a String, but %s : %s",
                    x.to_s,
                    x.type_sym.to_s
                )
            end

            s, is_first = opaque.obj

            VC.make_opaque(
                [
                    s + (
                        if sep_value && ! is_first
                            sep_value.val
                        else
                            ""
                        end
                    ) + x.val,

                    false
                ]
            )
        }

        VC.make_string (result.obj)[0]
    end


    define_instance_method(
        :meth_zip,
        :zip, [],
        [self], self
    )
    def meth_zip(loc, env, event, ys)
        ASSERT.kind_of ys, Abstract

        _, _, zs = loop.inject(
             [self, ys,  VC.make_nil]
        ) { |(xs1,  ys1, zs1        ), _|

            if (
                xs1.meth_is_empty(loc, env, event).true? ||
                ys1.meth_is_empty(loc, env, event).true?
            )
                break [xs1, ys1, zs1]
            else
                xs_pair = xs1.meth_dest! loc, env, event
                unless xs_pair.kind_of? VCBLP::Tuple
                    raise X::TypeError.new(
                        new_loc,
                        new_env,
                        "zip (Lhs): Expected a Tuple, but %s : %s",
                        xs_pair.to_s,
                        xs_pair.type_sym.to_s
                    )
                end

                xs_arity = xs_pair.arity
                unless xs_arity == 2
                    raise X::TypeError.new(
                        new_loc,
                        new_env,
                        "zip (Lhs): Expected a pair, " +
                            "but arity of the tuple is %d",
                        xs_arity
                    )
                end
                x, xs2 = xs_pair.values

                ys_pair = ys1.meth_dest! loc, env, event
                unless ys_pair.kind_of? VCBLP::Tuple
                    raise X::TypeError.new(
                        new_loc,
                        new_env,
                        "zip (Rhs): Expected a Tuple, but %s : %s",
                        ys_pair.to_s,
                        ys_pair.type_sym.to_s
                    )
                end

                ys_arity = ys_pair.arity
                unless ys_arity == 2
                    raise X::TypeError.new(
                        new_loc,
                        new_env,
                        "zip (Rhs): Expected a pair, " +
                            "but arity of the tuple is %d",
                        ys_arity
                    )
                end
                y, ys2 = ys_pair.values

                [
                    xs2,
                    ys2,
                    zs1.meth_cons(loc, env, event,
                        VC.make_tuple(x, y)
                    )
                ]
            end
        }

        result = zs.meth_reverse loc, env, event

        ASSERT.kind_of result, VCBLM::List::Abstract
    end


    define_instance_method(
        :meth_unzip,
        :unzip, [],
        [], VCBLP::Tuple
    )
    def meth_unzip(loc, env, event)
        result = self.foldr(
             loc,     env,     event,
            VC.make_tuple(VC.make_nil, VC.make_nil)
        ) { |new_loc, new_env, y_z,     ys_zs|

            unless y_z.kind_of? VCBLP::Tuple
                raise X::TypeError.new(
                    new_loc,
                    new_env,
                    "unzip: Expected a Tuple, but %s : %s",
                    y_z.to_s,
                    y_z.type_sym.to_s
                )
            end

            y_z_arity = y_z.arity
            unless y_z_arity == 2
                raise X::TypeError.new(
                    new_loc,
                    new_env,
                    "unzip: Expected a pair, " +
                        "but arity of the tuple is %d",
                    y_z_arity
                )
            end
            y, z = y_z.values

            ys, zs = ys_zs.values

            VC.make_tuple(
                ys.meth_cons(loc, env, event, y),
                zs.meth_cons(loc, env, event, z)
            )
        }

        ASSERT.kind_of result, VCBLP::Tuple
    end


    define_instance_method(
        :meth_uniq,
        :uniq, [],
        [], self
    )
    def meth_uniq(loc, env, event)
        if self.meth_is_empty(loc, env, event).true?
            self
        else
            pair = self.dest!

            unless pair.kind_of? VCBLP::Tuple
                raise X::TypeError.new(
                    new_loc,
                    new_env,
                    "uniq: Expected a Tuple, but %s : %s",
                    pair.to_s,
                    pair.type_sym.to_s
                )
            end

            pair_arity = pair.arity
            unless pair_arity == 2
                raise X::TypeError.new(
                    new_loc,
                    new_env,
                    "uniq: Expected a pair, " +
                        "but arity of the tuple is %d",
                    pair_arity
                )
            end
            x, xs = pair.values

            if xs.meth_is_empty(loc, env, event).true?
                self
            else

                result_opaque = xs.foldl(
                     loc,     env,     event,
                     VC.make_opaque([x, VC.make_list([x])])
                ) { |new_loc, new_env, x1,    opaque|

                    before, ys = opaque.obj

                    pp({x1: x1, before: before, ys: ys})

                    VC.make_opaque(
                        [
                            x1,

                            if x1.meth_equal(
                                loc, env, event, before
                            ).true? 
                                ys
                            else
                                ys.meth_cons loc, env, event, x1
                            end
                        ]
                    )
                }

                (result_opaque.obj)[1].meth_reverse loc, env, event
            end
        end
    end


    define_instance_method(
        :meth_partition,
        :partition, [],
        [VC::Fun], VCBLP::Tuple
    )
    def meth_partition(loc, env, event, func)
        ASSERT.kind_of func, VC::Fun

        init_opaque = VC.make_opaque [VC.make_nil, VC.make_nil]

        result_opaque = self.foldr(
             loc,     env,     event, init_opaque
        ) { |new_loc, new_env, x,     opaque|

            value = func.apply(x, [], loc, new_env)
            ASSERT.kind_of value, VC::Top

            unless value.kind_of? VCBA::Bool
                raise X::TypeError.new(
                    new_loc,
                    new_env,
                    "partition: Expected a Bool, but %s : %s",
                    value.to_s,
                    value.type_sym.to_s
                )
            end

            ys, zs = opaque.obj

            if value.true?
                VC.make_opaque([
                    ys.meth_cons(loc, env, event, x),
                    zs
                ])
            else
                VC.make_opaque([
                    ys,
                    zs.meth_cons(loc, env, event, x)
                ])
            end
        }

        VC.make_tuple *(result_opaque.obj)
    end


    define_instance_method(
        :meth_sort,
        :sort, [],
        [], self
    )
    define_instance_method(
        :meth_sort,
        :'sort-with', [],
        [VC::Fun], self
    )
    def meth_sort(loc, env, event, opt_func = nil)
        ASSERT.opt_kind_of opt_func, VC::Fun

        if self.meth_is_empty(loc, env, event).true?
            return self
        end

        pair = self.meth_dest!(loc, env, event)

        unless pair.kind_of? VCBLP::Tuple
            raise X::TypeError.new(
                new_loc,
                new_env,
                "sort: Expected a Tuple, but %s : %s",
                pair.to_s,
                pair.type_sym.to_s
            )
        end

        pair_arity = pair.arity
        unless pair_arity == 2
            raise X::TypeError.new(
                new_loc,
                new_env,
                "sort: Expected a pair, " +
                    "but arity of the tuple is %d",
                pair_arity
            )
        end
        pivot, xs = pair.values

        init_opaque = VC.make_opaque [VC.make_nil, VC.make_nil]

        result_opaque = xs.foldr(
             loc,     env,     event, init_opaque
        ) { |new_loc, new_env, x,     opaque|

            compare_result = if opt_func
                    func = opt_func

                    value = func.apply x, [pivot], new_loc, new_env
                    ASSERT.kind_of value, VC::Top

                    unless value.kind_of? VCBAN::Int
                        raise X::TypeError.new(
                            new_loc,
                            new_env,
                            "sort: Expected a Int, but %s : %s",
                            value.to_s,
                            value.type_sym.to_s
                        )
                    end

                    value.val
                else
                    if x.meth_less_than(
                        new_loc, new_env, event, pivot
                    ).true?
                        -1
                    else
                        1
                    end
                end

            ys, zs = opaque.obj

            if compare_result < 0
                VC.make_opaque([
                    ys.meth_cons(loc, env, event, x),
                    zs
                ])
            else
                VC.make_opaque([
                    ys,
                    zs.meth_cons(loc, env, event, x)
                ])
            end
        }
        littles, bigs = result_opaque.obj

        littles1 = littles.meth_sort loc, env, event, opt_func
        bigs1    = bigs   .meth_sort loc, env, event, opt_func

        result = littles1.meth_append(loc, env, event,
                                bigs1.meth_cons(loc, env, event, pivot)
                            )

        ASSERT.kind_of result, VCBLM::List::Abstract
    end
end
Abstract.freeze

end # Umu::Value::Core::LSM::Base::Morph

end # Umu::Value::Core::LSM::Base

end # Umu::Value::Core::LSM

end # Umu::Value::Core

end # Umu::Value

end # Umu
