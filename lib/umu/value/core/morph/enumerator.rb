# coding: utf-8
# frozen_string_literal: true



module Umu

module Value

module Core

module Morph

module Enum

class Abstract < Morph::Abstract
    def self.make(xs)
        ASSERT.kind_of xs, ::Array

        VC.make_list xs
    end


    define_class_method(
        :meth_make_empty,
        :empty, [],
        [], VCM::List::Abstract
    )
    def self.meth_make_empty(loc, env, _event)
        VC.make_nil
    end


    attr_reader :source

    def initialize(source)
        ASSERT.kind_of source,  VC::Top

        @source = source
    end


    def to_s
        format "#Enum<%s>", self.source.to_s
    end


    define_instance_method(
        :meth_cons,
        :cons, [],
        [VC::Top], VCM::List::Abstract
    )
    def meth_cons(loc, env, _event, value)
        ASSERT.kind_of value, VC::Top

        raise X::NotImplemented.new(
                    loc,
                    env,
                    "cons: Emnumerator morph is not be constructible"
                )
    end
end
Abstract.freeze



class Provider < Abstract
    TYPE_SYM = :ProviderEnum


    attr_reader :dest

    def initialize(source, dest)
        ASSERT.kind_of source,  VC::Top
        ASSERT.kind_of dest,    ::Proc

        super(source)

        @dest = dest
    end


    def meth_dest(_loc, _env, _event)
        val_opt = self.dest.call self.source
        ASSERT.kind_of  val_opt,            VCU::Option::Abstract
        ASSERT.kind_of  val_opt.contents,   VC::Top

        val_opt
    end
end
Provider.freeze


=begin
HOW TO USE UserEnum

    * Same to: [1 ..5].to-list

        > fun rec fn-dest = x -> (
        *     if x <= 5 then Some (x, &UserEnum.make (x + 1) fn-dest)
        *               else NONE
        * )
        > &UserEnum.make 1 fn-dest.to-list
        val it : Cons = [1, 2, 3, 4, 5]

    * Same to: [1 ..5].map to-s

        > &UserEnum.make 1 fn-dest.map to-s
        val it : Cons = ["1", "2", "3", "4", "5"]

    * Same to: [1 ..5].select odd?

        > &UserEnum.make 1 fn-dest.select odd?
        val it : Cons = [1, 3, 5]

    * Same to: [|to-s x| val x <- [1 ..5] if odd? x]

        > [|to-s x| val x <- &UserEnum.make 1 fn-dest if odd? x]
        val it : Cons = ["1", "3", "5"]

    * Same to: STDIN.each-line.for-each { s -> print <| "- " ^ s }

        > fun rec fn-dest' = io -> case io.gets of {
        *   | &None   -> NONE
        *   | &Some s -> Some (s, &UserEnum.make io fn-dest')
        * }
        > &UserEnum.make STDIN fn-dest'.for-each { s -> print <| "- " ^ s }
        aaa [Enter]
        - aaa
        bbb [Enter]
        - bbb
        [Ctrl]+[d]
        >
=end
class User < Abstract
    TYPE_SYM = :UserEnum


    define_class_method(
        :meth_make,
        :make, [],
        [VC::Top, VC::Fun], self
    )
    def self.meth_make(loc, env, event, source, fn_dest)
        ASSERT.kind_of source,  VC::Top
        ASSERT.kind_of fn_dest, VC::Fun

        VC.make_user_enumerator source, fn_dest
    end


    attr_reader :fn_dest

    def initialize(source, fn_dest)
        ASSERT.kind_of source,  VC::Top
        ASSERT.kind_of fn_dest, VC::Fun

        super(source)

        @fn_dest = fn_dest
    end


    def meth_dest(loc, env, event)
        val_opt = self.fn_dest.apply self.source, [], loc, env.enter(event)
        VC.validate_option val_opt, 'dest', loc, env

        ASSERT.kind_of val_opt, VCU::Option::Abstract
    end
end
Provider.freeze

end # Umu::Value::Core::Morph::Enum

end # Umu::Value::Core::Morph



module_function

    def make_enumerator(source, dest)
        ASSERT.kind_of source,  VC::Top
        ASSERT.kind_of dest,    ::Proc

        Morph::Enum::Provider.new(source, dest).freeze
    end


    def make_user_enumerator(source, fn_dest)
        ASSERT.kind_of source,  VC::Top
        ASSERT.kind_of fn_dest, VC::Fun

        Morph::Enum::User.new(source, fn_dest).freeze
    end

end # Umu::Value::Core

end # Umu::Value

end # Umu
