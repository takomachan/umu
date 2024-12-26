# coding: utf-8
# frozen_string_literal: true

module Umu

module Commander

module Prelude

FILE_NAME = format "<%s>", __FILE__

START_LINE_NUM = __LINE__ + 2

SOURCE_TEXT  = <<'___EOS___'
######################################
######## Umu Standard Library ########
######################################

structure Umu = struct {
    ######## Bool ########

    # TRUE : Bool
    val TRUE = &Bool.true

    # FALSE : Bool
    val FALSE = &Bool.false



    ######## Option ########

    structure Option = struct {
        #### Constructor ####

        # Some : 'a -> Some 'a
        val Some = &Some.make

        # NONE : None
        val NONE = &None.make


        #### Classifier ####

        # Some? : Option 'a -> Bool
        val Some? = &(Option.some?)

        # None? : Option 'a -> Bool
        val None? = &(Option.none?)
    }



    #### Math ####

    structure Math = struct {
        # NAN           : Real
        val NAN = &Real.nan

        # INFINITY      : Real
        val INFINITY = &Real.infinity

        # PI            : Real
        val PI = &Real.pi

        # E             : Real
        val E = &Real.e

        # nan?          : Real -> Bool
        val nan? = &(Real.nan?)

        # infinite?     : Real -> Bool
        val infinite? = &(Real.infinite?)

        # equal?        : Real -> Real -> Int -> Bool
        fun equal? = (x : Real) (y : Real) (n : Int) ->
            x.truncate n.== (y.truncate n)

        # finite?       : Real -> Bool
        val finite? = &(Real.finite?)

        # sin           : Real -> Real
        val sin = &(Real.sin)

        # cos           : Real -> Real
        val cos = &(Real.cos)

        # tan           : Real -> Real
        val tan = &(Real.tan)

        # asin          : Real -> Real
        val asin = &(loat.asin)

        # acos          : Real -> Real
        val acos = &(Real.acos)

        # atan          : Real -> Real
        val atan = &(Real.atan)

        # atan2         : Real -> Real -> Real
        val atan2 = &(Real.atan2)

        # sinh          : Real -> Real
        val sinh = &(Real.sinh)

        # cosh          : Real -> Real
        val cosh = &(Real.cosh)

        # tanh          : Real -> Real
        val tanh = &(Real.tanh)

        # exp           : Real -> Real
        val exp = &(Real.exp)

        # log           : Real -> Real
        val log = &(Real.log)

        # log10         : Real -> Real
        val log10 = &(Real.log10)

        # sqrt          : Real -> Real
        val sqrt = &(Real.sqrt)

        # truncate      : Real -> Int -> Real
        fun truncate = (x : Real) (n : Int) -> x.truncate n

        # ceil          : Real -> Int -> Real
        fun ceil = (x : Real) (n : Int) -> x.ceil n

        # floor         : Real -> Int -> Real
        fun floor = (x : Real) (n : Int) -> x.floor n

        # ldexp         : Real -> Int -> Real
        fun ldexp = (x : Real) (y : Int) -> x.ldexp y

        # frexp         : Real -> (Real, Real)
        fun frexp = (x : Real) (y : Int) -> x.frexp y

        # divmod        : Real -> Real -> (Real, Real)
        fun divmod = (x : Real) (y : Int) -> x.divmod y
    }



    #### I/O ####

    structure IO = struct {
        val STDIN  = &IO.stdin
        val STDOUT = &IO.stdout
        val STDERR = &IO.stderr

        # gets : () -> Option String 
        fun gets = () -> STDIN.gets

        # puts : String -> ()
        fun puts = x -> STDOUT.puts x

        # display : 'a -> ()
        fun display = x -> STDOUT.puts (x.to-s)

        # tab : Int -> ()
        fun rec tab = n ->
            if (0.< n) (
                STDOUT.puts " " ;
                tab (n.- 1)
            ) else
                ()

        # nl : () -> ()
        fun nl = () -> STDOUT.puts "\n"

        # print : 'a -> ()
        fun print = x -> STDOUT.puts (x.to-s.^ "\n")

        # p : 'a -> ()
        fun p = x -> STDOUT.puts (x.inspect.^ "\n")

        # pp : 'a -> ()
        fun pp = x -> STDOUT.pp x

        # msgout : 'a -> ()
        fun msgout = x -> STDERR.puts (x.to-s.^ "\n")

        # random : 'a -> 'a where { 'a <- Number }
        fun random = x : Number -> x.random
    }



    ######## Morph ########

    structure Morph = struct {
        # cons : 'a -> %['a] -> %['a]
        fun cons = x (xs : Morph) -> xs.cons x


        # empty? : %['a] -> Bool
        val empty? = &(Morph.empty?)


        # des : %['a] -> Option ('a, %['a])
        val des = &(Morph.des)


        # head : %['a] -> 'a
        fun head = xs : Morph -> xs.des!$1


        # tail : %['a] -> %['a]
        fun tail = xs : Morph -> xs.des!$2


        # to-list : %['a] -> ['a]
        fun to-list = xs : Morph -> xs.to-list


        # equal-with? : ('a -> 'b -> Bool) -> %['a] -> %['b] -> Bool
        fun rec equal-with? = eq? xs ys ->
            if (xs kind-of? Morph)
                if (ys kind-of? Morph)
                    case xs {
                      []      -> empty? ys
                    | [x|xs'] -> case ys {
                          []      -> FALSE
                        | [y|ys'] -> equal-with? eq? x   y &&
                                     equal-with? eq? xs' ys'
                        }
                    }
                else
                    FALSE
            else
                if (ys kind-of? Morph)
                    FALSE
                else
                    eq? xs ys


        # equal? : %['a] -> %['b] -> Bool
        val equal? = equal-with? { x y -> x.== y }


        # foldr : 'b -> ('a -> 'b -> 'b) -> %['a] -> 'b
        (#
        fun rec foldr = a f xs -> case xs {
          []      -> a
        | [x|xs'] -> f x (foldr a f xs')
        }
        #)
        fun foldr = a (f : Fun) (xs : Morph) -> xs.foldr a f


        # foldr1 : ('a -> 'a -> 'a) -> %['a] -> 'a
        (#
        fun foldr1 = f xs -> foldr x f xs'
                            where { val [x|xs'] = xs }
        #)
        fun foldr1 = (f : Fun) (xs : Cons) -> xs'.foldr x f
                            where { val [x|xs'] = xs }


        # foldl : 'b -> ('a -> 'b -> 'b) -> %['a] -> 'b
        (#
        fun rec foldl = a f xs -> case xs {
          []      -> a
        | [x|xs'] -> foldl (f x a) f xs'
        }
        #)
        fun foldl = a (f : Fun) (xs : Morph) -> xs.foldl a f


        # foldl1 : ('a -> 'a -> 'a) -> %['a] -> 'a
        (#
        fun foldl1 = (f : Fun) (xs : Cons) -> foldl x f xs'
                            where { val [x|xs'] = xs }
        #)
        fun foldl1 = (f : Fun) (xs : Cons) -> xs'.foldl x f
                            where { val [x|xs'] = xs }


        # length : %['a] -> Int
        # val length = foldl 0 { _ len -> len.+ 1 }
        fun length = xs : Morph -> xs.foldl 0 { _ len -> len.+ 1 }


        # reverse : %['a] -> %['a]
        # val reverse = foldl [] cons
        fun reverse = xs : Morph -> xs.foldl [] cons


        # max : %['a] -> 'a
        val max = foldl1 { x y -> if (y.< x) x else y }


        # min : %['a] -> 'a
        val min = foldl1 { x y -> if (x.< y) x else y }


        # for-each : ('a -> 'b) -> %['a] -> ()
        fun for-each = (f : Fun) (xs : Morph) -> xs.for-each f


        # map : ('a -> 'b) -> %['a] -> %['b]
        # fun map = f -> foldr [] { x xs -> [f x | xs] }
        fun map = (f : Fun) (xs : Morph) -> xs.map f


        # select : ('a -> Bool) -> %['a] -> %['a]
        # fun select = f -> foldr [] { x xs -> if (f x) [x|xs] else xs }
        fun select = (f : Fun) (xs : Morph) -> xs.select f


        # concat : %[%['a]] -> %['a]
        # val concat = foldl [] { xs xss -> xss ++ xs }
        val concat = &(Morph.concat)


        # concat-map : ('a -> %['b]) -> %['a] -> %['b]
        fun concat-map = (f : Fun) (xs : Morph) -> xs.concat-map f


        # zip-with : ('a -> 'b -> 'c) -> %['a] -> %['b] -> %['c]
        fun zip-with = f -> foldr e g
        where {
            fun e = _ -> []

            fun g = x h ys -> case ys {
              []      -> []
            | [y|ys'] -> [f x y | h ys']
            }
        }


        # zip : %['a] -> %['b] -> %[('a, 'b)]
        # val zip = zip-with { x y -> (x, y) }
        fun zip = (xs : Morph) (ys : Morph) -> xs.zip ys


        # unzip : %[('a, 'b)] -> (%['a], %['b])
        # val unzip = foldr ([], []) { (y, z) (ys, zs) -> ([y|ys], [z|zs]) }
        val unzip = &(Morph.unzip)


        # partition : ('a -> Bool) -> %['a] -> (%['a], %['a])
        (#
        fun partition = (f : Fun) (xs : Morph) -> foldr ([], []) {
            x (ys, zs)
        ->
            if (f x)
                ([x|ys],    zs)
            else
                (   ys,  [x|zs])
        } xs
        #)
        fun partition = (f : Fun) (xs : Morph) -> xs.partition f


        # sort : %['a] -> %['a]
        (#
        fun rec sort = xs -> case xs {
          []          -> []
        | [pivot|xs'] ->
                concat [sort littles, [pivot], sort bigs]
            where val (littles, bigs) = partition (< pivot) xs'
        }
        #)
        val sort = &(Morph.sort)


        # sort-with : ('a -> Int) -> %['a] -> %['a]
        fun sort-with = (f : Fun) (xs : Morph) -> xs.sort-with f
    }



    ######## String ########

    structure String = struct {
        # panic : String -> ()
        val panic = &(String.panic)


        # join : String -> [String] -> String
        fun join = j xs -> case xs {
          []      -> ""
        | [x|xs'] -> case xs' {
              []   -> x
              else -> x.^ (xs'.foldl "" { x' s -> s.^ j.^ x' })
            }
        }


        # concat : [String] -> String
        val concat = join ""
    }



    ######## Prelude ########

    structure Prelude = struct {
        #### Top ####

        # inspect   : 'a -> String
        val inspect = &(inspect)

        # to-s      : 'a -> String
        val to-s = &(to-s)

        # (==)      : 'a -> 'b -> Bool
        fun (==) = x y -> x.== y

        # (<>)      : 'a -> 'b -> Bool
        fun (<>) = x y -> x.== y.not

        # (<)       : 'a -> 'a -> Bool
        fun (<) = x y -> x.< y

        # (>)       : 'a -> 'a -> Bool
        fun (>) = x y -> y.< x

        # (<=)      : 'a -> 'a -> Bool
        fun (<=) = x y -> y.< x.not

        # (>=)      : 'a -> 'a -> Bool
        fun (>=) = x y -> x.< y.not

        # (<=>)     : 'a -> 'a -> Int
        fun (<=>) = x y -> if (x.< y)
                                -1
                            elsif (x.== y)
                                0
                            else
                                1


        #### Bool ####

        # TRUE      : Bool
        val TRUE = TRUE

        # FALSE     : Bool
        val FALSE = FALSE

        # not       : Bool -> Bool
        val not = &(Bool.not)


        #### Number ####

        #   positive?   : Number -> Bool
        val positive? = &(Number.positive?)

        #   negative?   : Number -> Bool
        val negative? = &(Number.negative?)

        #   zero?       : Number -> Bool
        val zero? = &(Number.zero?)

        #   odd?        : Int -> Bool
        val odd? = &(Int.odd?)

        #   even?       : Int -> Bool
        val even? = &(Int.even?)

        # abs           : 'a -> 'a  where { 'a <- Number }
        val abs = &(Number.abs)

        # negate        : 'a -> 'a  where { 'a <- Number }
        val negate = &(Number.negate)

        # to-i          : Number -> Int
        val to-i = &(Number.to-i)

        # to-r          : Number -> Real
        val to-r = &(Number.to-r)

        # (+)           : 'a -> 'a -> 'a        where { 'a <- Number }
        fun (+) = (x : Number) (y : Number) -> x.+ y

        # (-)           : 'a -> 'a -> 'a        where { 'a <- Number }
        fun (-) = (x : Number) (y : Number) -> x.- y

        # (*)           : 'a -> 'a -> 'a        where { 'a <- Number }
        fun (*) = (x : Number) (y : Number) -> x.* y

        # (/)           : 'a -> 'a -> 'a        where { 'a <- Number }
        fun (/) = (x : Number) (y : Number) -> x./ y

        # (mod)         : 'a -> 'a -> 'a        where { 'a <- Number }
        fun (mod) = (x : Number) (y : Number) -> x.mod y

        # (pow)         : 'a -> 'a -> 'a        where { 'a <- Number }
        fun (pow) = (x : Number) (y : Number) -> x.pow y


        #### Math ####

        # NAN       : Real
        val NAN = Math::NAN

        # INFINITY  : Real
        val INFINITY = Math::INFINITY

        # nan?      : Real -> Bool
        val nan? = Math::nan?

        # infinite? : Real -> Bool
        val infinite? = Math::infinite?

        # finite?   : Real -> Bool
        val finite? = Math::finite?


        #### String ####

        # panic     : String -> ()
        val panic = String::panic

        # (^)       : String -> String -> String
        fun (^) = (x : String) (y : String) -> x.^ y

        # join      : String -> [String] -> String
        val join = String::join


        #### I/O ####

        val STDIN  = IO::STDIN
        val STDOUT = IO::STDOUT
        val STDERR = IO::STDERR

        # gets      : () -> Option String 
        val gets = IO::gets

        # puts      : 'a -> ()
        val puts = IO::puts

        # display   : 'a -> ()
        val display = IO::display

        # tab       : Int -> ()
        val tab = IO::tab

        # nl        : () -> ()
        val nl = IO::nl

        # print     : 'a -> ()
        val print = IO::print

        # p         : 'a -> ()
        val p = IO::p

        # pp        : 'a -> ()
        val pp = IO::pp


        #### Tuple ####

        # (,)   : 'a -> 'b -> ('a, 'b)
        fun (,) = x y -> (x, y)

        # fst   : ('a, 'b) -> 'a
        fun fst = (f, _) -> f

        # snd   : ('a, 'b) -> 'b
        fun snd = (_, s) -> s


        #### Union ####

        # val-of : Union 'a -> Top
        fun val-of = x : Union -> x.contents


        #### Datum ####
        # See SICP(Wizard Book), 2.4.2 Tagged data

        # Datum : Symbol -> 'a -> Datum 'a
        fun Datum = (t : Symbol) x -> &Datum.make t x

        # tag-of : Datum 'a -> Symbol
        val tag-of = &(Datum.tag)


        #### Option ####

        # Some  : 'a -> Option 'a
        val Some = Option::Some

        # NONE  : Option 'a
        val NONE = Option::NONE

        # Some? : Option 'a -> Bool
        val Some? = Option::Some?

        # None? : Option 'a -> Bool
        val None? = Option::None?


        #### Morph ####

        # (|)       : 'a -> %['a] -> %['a]
        val (|) = Morph::cons

        # (++)      : %['a] -> %['a] -> %['a]
        fun (++) = (xs : Morph) (ys : Morph) -> xs.++ ys

        # cons : 'a -> %['a] -> %['a]
        val cons = Morph::cons

        # empty?    : %['a] -> Bool
        val empty? = Morph::empty?

        # head      : %['a] -> 'a
        val head = Morph::head

        # tail      : %['a] -> ['a]
        val tail = Morph::tail

        # to-list : %['a] -> ['a]
        val to-list = Morph::to-list

        # equal?    : 'a -> 'b -> Bool
        val equal? = Morph::equal?

        # foldr     : 'b -> ('a -> 'b -> 'b) -> %['a] -> 'b
        val foldr = Morph::foldr

        # foldr1    : ('a -> 'a -> 'a) -> %['a] -> 'a
        val foldr1 = Morph::foldr1

        # foldl     : 'b -> ('a -> 'b -> 'b) -> %['a] -> 'b
        val foldl = Morph::foldl

        # foldl1    : ('a -> 'a -> 'a) -> %['a] -> 'a
        val foldl1 = Morph::foldl1

        # length    : %['a] -> Int
        val length = Morph::length

        # reverse   : %['a] -> ['a]
        val reverse = Morph::reverse

        # max       : %['a] -> 'a
        val max = Morph::max

        # min       : %['a] -> 'a
        val min = Morph::min

        # map       : ('a -> 'b) -> %['a] -> %['b]
        val map = Morph::map

        # select    : ('a -> Bool) -> %['a] -> %['a]
        val select = Morph::select

        # concat    : %[%['a]] -> %['a]
        val concat = Morph::concat

        # concat-map : ('a -> %['b]) -> %['a] -> %['b]
        val concat-map = Morph::concat-map

        # zip       : %['a] -> %['b] -> (%['a, 'b])
        val zip = Morph::zip

        # unzip     : %[('a, 'b)] -> (%['a], %['b])
        val unzip = Morph::unzip

        # partition : ('a -> Bool) -> %['a] -> (%['a], %['a])
        val partition = Morph::partition

        # sort      : %['a] -> %['a]
        val sort = Morph::sort

        # sort-with : ('a -> Int) -> %['a] -> %['a]
        val sort-with = Morph::sort-with


        #### High order Function ####

        ## id       : 'a -> 'a
        fun id = x -> x

        ## const    : 'a -> 'b -> 'a
        fun const = x _ -> x

        ## tee      : ('a -> 'b) -> 'a -> 'a
        fun tee = (f : Fun) x -> (f x ; x)

        ## curry    : (('a, 'b) -> 'c) -> ('a -> 'b -> 'c)
        fun curry = (f : Fun) x y -> f (x, y)

        ## uncurry  : ('a -> 'b -> 'c) -> (('a, 'b) -> 'c)
        fun uncurry = (f : Fun) (x, y) -> f x y

        ## swap     : (('a, 'b) -> 'c) -> (('b, 'a) -> 'c)
        fun swap = (f : Fun) (x, y) -> f (y, x)

        ## flip     : ('a -> 'b -> 'c) -> ('b -> 'a -> 'c)
        fun flip = (f : Fun) x y -> f y x

        ## pair     : ('a -> 'b, 'a -> 'c) -> ('a -> ('b, 'c))
        fun pair = (f : Fun, g : Fun) x -> (f x, g x)

        ## cross    : ('a -> 'b, 'c -> 'd) -> (('a, 'c) -> ('b, 'd))
        fun cross = (f : Fun, g : Fun) ->
                        pair (fst >> f, snd >> g)
    }



    ######## Assertion ########

    structure Assert = struct {
        # unit : 'a -> ()
        fun unit = actual -> let {
            assert (actual kind-of? Unit)   (msg () actual)
        in
            ()
        }


        # bool : 'a -> Bool -> Bool
        fun bool =
                actual
                (expect : Bool)
        -> let {
            assert (actual kind-of? Bool)   "Bool"
            assert (actual == expect)       (msg expect actual)
        in
            actual
        }


        # bools : ['a] -> ('a -> 'b) -> [Bool] -> [Bool]
        fun bools =
                (sources : List)
                (f       : Fun)
                (expects : List)
        -> let {
            val results = sources |> map f
        in
            results |> zip expects |> map { (result, expect) ->
                bool result expect
            }
        }


        # true : 'a -> Bool
        fun true = actual -> bool actual TRUE


        # false : 'a -> Bool
        fun false = actual -> bool actual FALSE


        # integer : 'a -> Int -> Int
        fun integer =
                actual
                (expect : Int)
        -> let {
            assert (actual kind-of? Int)    "Int"
            assert (actual == expect)       (msg expect actual)
        in
            actual
        }


        # integers : ['a] -> ('a -> 'b) -> [Int] -> [Int]
        fun integers =
                (sources : List)
                (f       : Fun)
                (expects : List)
        -> let {
            val results = sources |> map f
        in
            results |> zip expects |> map { (result, expect) ->
                integer result expect
            }
        }


        # real : 'a -> Real -> Int -> Real
        fun real =
                actual
                (expect : Real)
                (n      : Int)
        -> let {
            assert (actual kind-of? Real)           "Real"
            assert (Math::equal? actual expect n)   (msg expect actual)
        in
            actual
        }


        # symbol : 'a -> Symbol -> Symbol
        fun symbol =
                actual
                (expect : Symbol)
        -> let {
            assert (actual kind-of? Symbol) "Symbol"
            assert (actual == expect)       (msg expect actual)
        in
            actual
        }


        # string : 'a -> String -> String
        fun string =
                actual
                (expect : String)
        -> let {
            assert (actual kind-of? String) "String"
            assert (actual == expect)       (msg expect actual)
        in
            actual
        }
    } where {
        import Prelude { fun (==) fun (^) }
        import Morph   { fun map  fun zip }

        fun msg = expect actual ->
            "Expected: " ^ expect.inspect ^ ", but: " ^ actual.inspect
    }
}


import Umu::Prelude
___EOS___

end # Umu::Commander::Prelude

end # Umu::Commander

end # Umu
