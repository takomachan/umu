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
                        "Empty morph cannot be destructible"
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
        self.reverse_each.inject(VC.make_nil) { |xs, x|
             xs.meth_cons loc, env, event, x
        }
    end


    define_instance_method(
        :meth_foldr,
        :foldr, [],
        [VC::Top, VC::Fun], VC::Top
    )
    def meth_foldr(loc, env, event, init, func)
        ASSERT.kind_of init,    VC::Top
        ASSERT.kind_of func,    VC::Fun

        new_env = env.enter event

        result_value = self.reverse_each.inject(init) { |acc, x|
            func.apply x, [acc], loc, new_env
        }

        ASSERT.kind_of result_value, VC::Top
    end


    define_instance_method(
        :meth_foldl,
        :foldl, [],
        [VC::Top, VC::Fun], VC::Top
    )
    def meth_foldl(loc, env, event, init, func)
        ASSERT.kind_of init,    VC::Top
        ASSERT.kind_of func,    VC::Fun

        new_env = env.enter event

        result_value = self.inject(init) { |acc, x|
            func.apply x, [acc], loc, new_env
        }

        ASSERT.kind_of result_value, VC::Top
    end


    define_instance_method(
        :meth_count,
        :count, [],
        [], VCBAN::Int
    )
    def meth_count(loc, env, event)
        VC.make_integer self.count
    end


    define_instance_method(
        :meth_max,
        :max, [],
        [], VCBAN::Int
    )
    def meth_max(loc, env, event)
        if self.meth_is_empty(loc, env, event).true?
            raise X::EmptyError.new loc, env, "max: Empty morph"
        end

        self.meth_tail(loc, env, event).inject(
            self.meth_head(loc, env, event)
        ) { |x, y|
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
        [], VCBAN::Int
    )
    def meth_min(loc, env, event)
        if self.meth_is_empty(loc, env, event).true?
            raise X::EmptyError.new loc, env, "min: Empty morph"
        end

        self.meth_tail(loc, env, event).inject(
            self.meth_head(loc, env, event)
        ) { |x, y|
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

        new_env = env.enter event

        VC.make_bool self.all? { |x|
             func.apply(x, [], loc, new_env).true?
        }
    end


    define_instance_method(
        :meth_is_any,
        :any?, [],
        [VC::Fun], VCBA::Bool
    )
    def meth_is_any(loc, env, event, func)
        ASSERT.kind_of func, VC::Fun

        new_env = env.enter event

        VC.make_bool self.any? { |x|
             func.apply(x, [], loc, new_env).true?
        }
    end


    define_instance_method(
        :meth_is_include,
        :include?, [],
        [VC::Top], VCBA::Bool
    )
    def meth_is_include(loc, env, event, value)
        ASSERT.kind_of value, VC::Top

        new_env = env.enter event

        VC.make_bool self.any? { |x|
            x.meth_equal(loc, new_env, event, value).true?
        }
    end


    define_instance_method(
        :meth_for_each,
        :'for-each', [],
        [VC::Fun], VC::Unit
    )
    def meth_for_each(loc, env, event, func)
        ASSERT.kind_of func, VC::Fun

        new_env = env.enter event

        self.each do |x|
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

        new_env = env.enter event

        ys = self.map { |x| func.apply x, [], loc, new_env }

        self.class.make ys
    end


    define_instance_method(
        :meth_select,
        :select, [],
        [VC::Fun], self
    )
    def meth_select(loc, env, event, func)
        ASSERT.kind_of func, VC::Fun

        new_env = env.enter event

        ys = self.select { |x|
            value = func.apply x, [], loc, new_env
            ASSERT.kind_of value, VC::Top

            unless value.kind_of? VCBA::Bool
                raise X::TypeError.new(
                    loc,
                    env,
                    "Expected a Bool, but %s : %s",
                    value.to_s,
                    value.type_sym.to_s
                )
            end

            value.true?
        }

        self.class.make ys
    end


    define_instance_method(
        :meth_reject,
        :reject, [],
        [VC::Fun], self
    )
    def meth_reject(loc, env, event, func)
        ASSERT.kind_of func, VC::Fun

        new_env = env.enter event

        ys = self.reject { |x|
            value = func.apply x, [], loc, new_env
            ASSERT.kind_of value, VC::Top

            unless value.kind_of? VCBA::Bool
                raise X::TypeError.new(
                    loc,
                    env,
                    "Expected a Bool, but %s : %s",
                    value.to_s,
                    value.type_sym.to_s
                )
            end

            value.true?
        }

        self.class.make ys
    end


    define_instance_method(
        :meth_append,
        :'++', [],
        [self], self
    )
    def meth_append(loc, env, event, ys)
        ASSERT.kind_of ys, Abstract

        self.class.make(self.to_a + ys.to_a)
    end


    define_instance_method(
        :meth_concat,
        :concat, [],
        [], self
    )
    def meth_concat(loc, env, event)
        mut_ys = []
        self.each do |xs|
            ASSERT.kind_of xs, VC::Top

            unless xs.kind_of? Abstract
                raise X::TypeError.new(
                    loc,
                    env,
                    "concat: expected a Morph, but %s : %s",
                    xs.to_s,
                    xs.type_sym.to_s
                )
            end

            mut_ys.concat xs.to_a
        end

        self.class.make mut_ys
    end


    define_instance_method(
        :meth_concat_map,
        :'concat-map', [],
        [VC::Fun], self
    )
    def meth_concat_map(loc, env, event, func)
        ASSERT.kind_of func, VC::Fun

        new_env = env.enter event

        mut_ys = []
        self.each do |x|
            ASSERT.kind_of x, VC::Top

            xs = func.apply x, [], loc, new_env
            unless xs.kind_of? Abstract
                raise X::TypeError.new(
                    loc,
                    env,
                    "concat: expected a Morph, but %s : %s",
                    xs.to_s,
                    xs.type_sym.to_s
                )
            end

            mut_ys.concat xs.to_a
        end

        self.class.make mut_ys
    end


    define_instance_method(
        :meth_join,
        :join, [],
        [], self
    )
    define_instance_method(
        :meth_join,
        :'join:', [],
        [VCBA::String], self
    )
    def meth_join(loc, env, event, sep_value = nil)
        ASSERT.opt_kind_of sep_value, VCBA::String

        str, _ = self.inject(["", true]) { |(s, is_first), x|
                    unless x.kind_of? VCBA::String
                        raise X::TypeError.new(
                            loc,
                            env,
                            "join: expected a String, but %s : %s",
                            x.to_s,
                            x.type_sym.to_s
                        )
                    end

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
                }

        VC.make_string str
    end


    define_instance_method(
        :meth_zip,
        :zip, [],
        [self], self
    )
    def meth_zip(loc, env, event, ys)
        ASSERT.kind_of ys, Abstract

        result_value = self.zip(ys).reverse_each.inject(
            self.class.make([])
        ) { |zs, (x, y)|

            if x.kind_of?(VC::Top) && y.kind_of?(VC::Top)
                zs.meth_cons loc, env, event, VC.make_tuple([x, y])
            else
                zs
            end
        }
        ASSERT.kind_of result_value, Abstract
    end


    define_instance_method(
        :meth_unzip,
        :unzip, [],
        [], VCBLP::Tuple
    )
    def meth_unzip(loc, env, event)
        result_value = self.reverse_each.inject(
            VC.make_tuple([
                self.class.make([]), self.class.make([])
            ])
        ) { |ys_zs, y_z|
            ASSERT.kind_of ys_zs, VCBLP::Tuple
            ASSERT.kind_of y_z,   VC::Top

            unless y_z.kind_of? VCBLP::Tuple
                raise X::TypeError.new(
                    loc,
                    env,
                    "unzip: expected a Tuple, but %s : %s",
                    pair.to_s,
                    pair.type_sym.to_s
                )
            end

            VC.make_tuple(
                [
                    ys_zs.select_by_number(1, loc, env).meth_cons(
                        loc, env, event,
                        y_z.select_by_number(1, loc, env),
                    ),

                    ys_zs.select_by_number(2, loc, env).meth_cons(
                        loc, env, event,
                        y_z.select_by_number(2, loc, env)
                    )
                ]
            )
        }

        ASSERT.kind_of result_value, VCBLP::Tuple
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
            x  = pair.select_by_number 1, loc, env
            xs = pair.select_by_number 2, loc, env

            if xs.meth_is_empty(loc, env, event).true?
                self
            else
                _, zs = xs.inject([x, [x]]) { |(before, ys), x1|
                    [
                        x1,

                        if x1.meth_equal(loc, env, event, before).true? 
                            ys
                        else
                            ys + [x1]
                        end
                    ]
                }

                self.class.make zs
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

        new_env = env.enter event

        xs, ys = self.partition { |x|
            value = func.apply(x, [], loc, new_env)
            ASSERT.kind_of value, VC::Top

            unless value.kind_of? VCBA::Bool
                raise X::TypeError.new(
                    loc,
                    env,
                    "partition: expected a Bool, but %s : %s",
                    value.to_s,
                    value.type_sym.to_s
                )
            end

            value.true?
        }
        
        VC.make_tuple [self.class.make(xs), self.class.make(ys)]
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

        xs = if opt_func
                    func = opt_func
                    new_env = env.enter event

                    xs = self.sort { |a, b|
                        ASSERT.kind_of a, VC::Top
                        ASSERT.kind_of b, VC::Top

                        value = func.apply a, [b], loc, new_env
                        ASSERT.kind_of value, VC::Top

                        unless value.kind_of? VCBAN::Int
                            raise X::TypeError.new(
                                loc,
                                env,
                                "sort-with: expected a Int, but %s : %s",
                                value.to_s,
                                value.type_sym.to_s
                            )
                        end

                        value.val
                    }
                else
                    xs = self.sort { |a, b|
                        ASSERT.kind_of a, VC::Top
                        ASSERT.kind_of b, VC::Top

                        if a.meth_less_than(loc, env, event, b).true?
                            -1
                        elsif a.meth_equal(loc, env, event, b).true?
                            0
                        else
                            1
                        end
                    }
                end

        self.class.make xs
    end
end
Abstract.freeze

end # Umu::Value::Core::LSM::Base::Morph

end # Umu::Value::Core::LSM::Base

end # Umu::Value::Core::LSM

end # Umu::Value::Core

end # Umu::Value

end # Umu
