# coding: utf-8
# frozen_string_literal: true

module Umu

module Commander

module Prelude

FILE_NAME = '<prelude>'

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
        val Some? = &(Option.Some?)

        # None? : Option 'a -> Bool
        val None? = &(Option.None?)
    }



    ######## Result ########

    structure Result = struct {
        #### Constructor ####

        # Ok : 'a -> Ok 'a
        val Ok = &Ok.make

        # Err : 'a -> Err 'a
        val Err = &Err.make


        #### Classifier ####

        # Ok? : Result 'a -> Bool
        val Ok? = &(Result.Ok?)

        # Err? : Result 'a -> Bool
        val Err? = &(Result.Err?)
    }



    #### Float ####

    structure Float = struct {
        # NAN       : Float
        val NAN = &Float.nan

        # INFINITY      : Float
        val INFINITY = &Float.infinity

        # nan?      : Float -> Bool
        val nan? = &(Float.nan?)

        # infinite? : Float -> Bool
        val infinite? = &(Float.infinite?)

        # finite?   : Float -> Bool
        val finite? = &(Float.finite?)

        # equal?    : Float -> Float -> Int -> Bool
        fun equal? = (x : Float) (y : Float) (n : Int) ->
            x.truncate n.== (y.truncate n)

        # truncate      : Float -> Int -> Float
        fun truncate = (x : Float) (n : Int) -> x.truncate n

        # ceil          : Float -> Int -> Float
        fun ceil = (x : Float) (n : Int) -> x.ceil n

        # floor         : Float -> Int -> Float
        fun floor = (x : Float) (n : Int) -> x.floor n
    }



    #### Math ####

    structure Math = struct {
        # PI            : Float
        val PI = &Math.pi

        # E             : Float
        val E = &Math.e

        # sin           : Float -> Float
        fun sin = x : Float -> &Math.sin x

        # cos           : Float -> Float
        fun cos = x : Float -> &Math.cos x

        # tan           : Float -> Float
        fun tan = x : Float -> &Math.tan x

        # asin          : Float -> Float
        fun asin = x : Float -> &Math.asin x

        # acos          : Float -> Float
        fun acos = x : Float -> &Math.acos x

        # atan          : Float -> Float
        fun atan = x : Float -> &Math.atan x

        # atan2         : Float -> Float -> Float
        fun atan2 = (y : Float, x : Float) -> &Math.(atan2-y:y x:)

        # sinh          : Float -> Float
        fun sinh = x : Float -> &Math.sinh x

        # cosh          : Float -> Float
        fun cosh = x : Float -> &Math.cosh x

        # tanh          : Float -> Float
        fun tanh = x : Float -> &Math.tanh x

        # exp           : Float -> Float
        fun exp = x : Float -> &Math.exp x

        # log           : Float -> Float
        fun log = x : Float -> &Math.log x

        # log10         : Float -> Float
        fun log10 = x : Float -> &Math.log10 x

        # sqrt          : Float -> Float
        fun sqrt = x : Float -> &Math.sqrt x

        # ldexp         : Float -> Int -> Float
        fun ldexp = (x : Float) (y : Int) -> x.ldexp y

        # frexp         : Float -> (Float, Float)
        fun frexp = (x : Float) (y : Int) -> x.frexp y

        # divmod        : Float -> Float -> (Float, Float)
        fun divmod = (x : Float) (y : Int) -> x.divmod y
    }



    #### I/O ####

    structure IO = struct {
        val STDIN  : Input  = &Device.stdin
        val STDOUT : Output = &Device.stdout
        val STDERR : Output = &Device.stderr


        # see : String -> Input
        fun see = file-path : String -> &Device.see file-path

        # seen : Input -> ()
        fun seen = io : Input -> io.seen

        # see-with : String -> Fun -> ()
        fun see-with = (file-path : String) (f : Fun) ->
             &Device.see-with file-path f


        # tell : String -> Output
        fun tell = file-path : String -> &Device.tell file-path

        # told : Output -> ()
        fun told = io : Output -> io.told

        # tell-with : String -> Fun -> ()
        fun tell-with = (file-path : String) (f : Fun) ->
             &Device.tell-with file-path f


        # gets : () -> Option String 
        fun gets = () -> STDIN.gets

        # fgets : Input -> Option String 
        fun fgets = io : Input -> io.gets

        # each-line : Input -> Enum
        fun each-line = io : Input -> io.each-line

        # puts : String -> ()
        fun puts = (s : String) -> STDOUT.puts s

        # fputs : Output -> String -> ()
        fun fputs = (io : Output) (s : String) -> io.puts s

        # flush : Output -> ()
        fun flush = (io : Output) -> io.flush

        # display : 'a -> ()
        fun display = x -> do (
            ! STDOUT.puts (x.to-s)
            ! STDOUT.flush
        )

        # tab : Int -> ()
        fun rec tab = n ->
            if 0.< n then
                do (
                    ! [1 .. n].for-each { _ -> STDOUT.puts " " }
                    ! STDOUT.flush
                )
            else
                ()

        # nl : () -> ()
        fun nl = () -> do (
            ! STDOUT.puts "\n"
            ! STDOUT.flush
        )

        # print : 'a -> ()
        fun print = x -> do (
            ! STDOUT.puts (x.to-s.^ "\n")
            ! STDOUT.flush
        )

        # p : 'a -> ()
        fun p = x -> do (
            ! STDOUT.puts (x.show.^ "\n")
            ! STDOUT.flush
        )

        # pp : 'a -> ()
        fun pp = x -> STDOUT.pp x

        # msgout : 'a -> ()
        fun msgout = x -> do (
            ! STDERR.puts (x.to-s.^ "\n")
            ! STDERR.flush
        )

        # random : 'a -> 'a where { 'a <- Number }
        fun random = x : Number -> x.random
    }



    #### Reference ####

    structure Ref = struct {
        # ref : Top -> Ref
        val ref = &Ref.make

        # peek! : Ref -> Top
        fun peek! = r : Ref -> r.peek!

        # poke! : Ref -> Top -> Unit
        fun poke! = (r : Ref) x -> r.poke! x
    }



    ######## Morph ########

    structure Morph = struct {
        # cons : 'a -> %['a] -> %['a]
        fun cons = x (xs : Morph) -> xs.cons x


        # empty? : %['a] -> Bool
        val empty? = &(Morph.empty?)


        # exists? : %['a] -> Bool
        val exists? = &(Morph.exists?)


        # dest : %['a] -> Option ('a, %['a])
        val dest = &(Morph.dest)


        # head : %['a] -> 'a or EmptyError
        fun head = xs : Morph -> xs.head


        # tail : %['a] -> %['a] or EmptyError
        fun tail = xs : Morph -> xs.tail


        # to-list : %['a] -> ['a]
        fun to-list = xs : Morph -> xs.to-list


        # susp : %['a] -> <Stream> 'a
        fun susp = xs : Morph -> xs.susp


        # to-s-expr : %['a] -> %s('a)
        fun to-s-expr = xs : Morph -> xs.to-s-expr


        # equal-with? : ('a -> 'b -> Bool) -> %['a] -> %['b] -> Bool
        fun rec equal-with? = eq? xs ys ->
            if xs kind-of? Morph then
                if ys kind-of? Morph then
                    case xs of {
                    [x|xs'] -> case ys of {
                        [y|ys'] -> equal-with? eq? x   y &&
                                   equal-with? eq? xs' ys'
                        else    -> FALSE
                        }
                    else -> empty? ys
                    }
                else
                    FALSE
            else
                if ys kind-of? Morph then
                    FALSE
                else
                    eq? xs ys


        # equal? : %['a] -> %['b] -> Bool
        val equal? = equal-with? { x y -> x.== y }


        # foldr : 'b -> ('a -> 'b -> 'b) -> %['a] -> 'b
        (#
        fun rec foldr = a f xs -> case xs of {
        [x|xs'] -> f x (foldr a f xs')
        else    -> a
        }
        #)
        fun foldr = a (f : Fun) (xs : Morph) -> xs.foldr a f


        # foldl : 'b -> ('a -> 'b -> 'b) -> %['a] -> 'b
        (#
        fun rec foldl = a f xs -> case xs of {
        [x|xs'] -> foldl (f x a) f xs'
        else    -> a
        }
        #)
        fun foldl = a (f : Fun) (xs : Morph) -> xs.foldl a f


        # count : %['a] -> Int
        # val count = foldl 0 { _ len -> len.+ 1 }
        # fun count = xs : Morph -> xs.foldl 0 { _ len -> len.+ 1 }
        fun count = xs : Morph -> xs.count


        # sum : %['a] -> 'a  where { 'a <- Number }
        fun sum = xs : Morph -> xs.sum


        # avg : %['a] -> 'a  where { 'a <- Number }
        fun avg = xs : Morph -> xs.avg


        # max : %['a] -> 'a  where { 'a <- Number } or EmptyError
        (#
        fun max = xs : Morph -> case xs of {
        [init|xs'] -> xs'.foldl init { x y -> if y.< x then x else y }
        else       -> "max: Empty Error".panic!
        }
        #)
        fun max = xs : Morph -> xs.max


        # min : %['a] -> 'a  where { 'a <- Number } or EmptyError
        (#
        fun min = xs : Morph -> case xs of {
        [init|xs'] -> xs'.foldl init { x y -> if x.< y then x else y }
        else       -> "min: Empty Error".panic!
        }
        #)
        fun min = xs : Morph -> xs.min


        # all? : ('a -> Bool) -> %['a] -> Bool
        fun all? = (f : Fun) (xs : Morph) -> xs.all? f


        # any? : ('a -> Bool) -> %['a] -> Bool
        fun any? = (f : Fun) (xs : Morph) -> xs.any? f


        # include? : 'a -> %['a] -> Bool
        fun include? = x (xs : Morph) -> xs.include? x


        # reverse : %['a] -> %['a]
        # val reverse = foldl [] cons
        fun reverse = xs : Morph -> xs.reverse


        # nth : Int -> %['a] -> 'a or ArgumentError or IndexError
        fun nth = (i : Int) (xs : Morph) -> xs.[i]


        # for-each : ('a -> 'b) -> %['a] -> ()
        fun for-each = (f : Fun) (xs : Morph) -> xs.for-each f


        # map : ('a -> 'b) -> %['a] -> %['b]
        # fun map = f -> foldr [] { x xs -> [f x | xs] }
        fun map = (f : Fun) (xs : Morph) -> xs.map f


        # filter : ('a -> Bool) -> %['a] -> %['a]
        # fun filter = f -> foldr [] { x xs -> if f x then [x|xs] else xs }
        fun filter = (f : Fun) (xs : Morph) -> xs.select f


        # concat : %[%['a]] -> %['a]
        # val concat = foldl [] { xs xss -> xss ++ xs }
        val concat = &(Morph.concat)


        # concat-map : ('a -> %['b]) -> %['a] -> %['b]
        fun concat-map = (f : Fun) (xs : Morph) -> xs.concat-map f


        # zip-with : ('a -> 'b -> 'c) -> %['a] -> %['b] -> %['c]
        fun zip-with = f -> foldr e g
        where {
            fun e = _ -> []

            fun g = x h ys -> case ys of {
            [y|ys'] -> [f x y | h ys']
            else    -> []
            }
        }


        # zip : %['a] -> %['b] -> %[('a, 'b)]
        # val zip = zip-with { x y -> (x, y) }
        fun zip = (xs : Morph) (ys : Morph) -> xs.zip ys


        # unzip : %[('a, 'b)] -> (%['a], %['b])
        # val unzip = foldr ([], []) { (y, z) (ys, zs) -> ([y|ys], [z|zs]) }
        val unzip = &(Morph.unzip)


        # uniq : %['a] -> %['a]
        val uniq = &(Morph.uniq)


        # partition : ('a -> Bool) -> %['a] -> (%['a], %['a])
        (#
        fun partition = (f : Fun) (xs : Morph) -> foldr ([], []) {
            x (ys, zs)
        ->
            if f x then
                ([x|ys],    zs)
            else
                (   ys,  [x|zs])
        } xs
        #)
        fun partition = (f : Fun) (xs : Morph) -> xs.partition f


        # sort : %['a] -> %['a]
        (#
        fun rec sort = xs -> case xs of {
        [pivot|xs'] ->
            concat [sort littles, [pivot], sort bigs]

            where val (littles, bigs) = partition (< pivot) xs'
        else -> []
        }
        #)
        val sort = &(Morph.sort)


        # sort-with : ('a -> Int) -> %['a] -> %['a]
        fun sort-with = (f : Fun) (xs : Morph) -> xs.sort-with f
    }



    ######## List ########

    structure List = struct {
        # unfold : 'b -> ('b -> Option (['a], 'b)) -> ['a]
        fun unfold = x (f : Fun) -> &List.unfold x f
    }



    ######## Stream ########

    structure Stream = struct {
        # map : ('a -> 'b) -> <Stream> 'a -> <Stream> 'b
        fun map = (f : Fun) (xs : Stream) -> xs.map f


        # filter : ('a -> Bool) -> <Stream> 'a -> <Stream> 'a
        fun filter = (f : Fun) (xs : Stream) -> xs.select f


        # append : <Stream> 'a -> <Stream> 'a -> <Stream> 'a
        fun append = (xs : Stream) (ys : Stream) -> xs.++ ys


        # concat-map : ('a -> <Stream> 'b) -> <Stream> 'a -> <Stream> 'b
        fun concat-map = (f : Fun) (xs : Stream) -> xs.concat-map f


        # take-to-list : Int -> <Stream> 'a -> ['a]
        fun take-to-list = (n : Int) (xs : Stream) -> xs.take-to-list n


        # to-list : <Stream> 'a -> ['a]
        fun to-list = xs : Stream -> xs.to-list
    }



    ######## S-Expression ########

    structure SExpr = struct {
        #### Constructor

        # NIL : SExprNil
        val NIL = &SExpr.nil

        # Value : 'a -> SExprValue
        fun Value = x -> &SExpr.value x

        # Cons : SExpr -> SExpr -> SExpr
        fun Cons = (car : SExpr) (cdr : SExpr) -> &SExpr.cons car cdr

        # list : %[SExpr] -> SExpr
        fun list = xs : Morph -> &SExpr.make xs


        #### Classifier

        # Nil?  : SExpr -> Bool
        fun Nil?  = this : SExpr -> this.nil?

        # Value? : SExpr -> Bool
        fun Value? = this : SExpr -> this.value?

        # Cons? : SExpr -> Bool
        fun Cons? = this : SExpr -> this.cons?


        #### Selector

        # car : SExprCons -> SExpr
        fun car = this : SExprCons -> this.car

        # cdr : SExprCons -> SExpr
        fun cdr = this : SExprCons -> this.cdr


        #### Mutator

        # set-car! : SExprCons -> SExpr -> Unit
        fun set-car! = (this : SExprCons) (car : SExpr) ->
             this.set-car! car

        # set-cdr! : SExprCons -> SExpr -> Unit
        fun set-cdr! = (this : SExprCons) (cdr : SExpr) ->
             this.set-cdr! cdr
    }



    ######## String ########

    structure String = struct {
        # panic! : String -> ()
        val panic! = &(String.panic!)


        # join : %[String] -> String
        fun join = (sep : String) (xs : Morph) -> xs.join


        # join-by : String -> %[String] -> String
        (#
        fun join-by = j xs -> case xs of {
        [x|xs'] -> case xs' of {
            []   -> x
            else -> x.^ (xs'.foldl "" { x' s -> s.^ j.^ x' })
            }
        else -> ""
        }
        #)
        fun join-by = (sep : String) (xs : Morph) -> xs.join-by sep
    }



    ######## Prelude ########

    structure Prelude = struct {
        #### Top ####

        # show   : 'a -> String
        val show = &(show)

        # to-s      : 'a -> String
        val to-s = &(to-s)

        # val-of : 'a -> Top
        fun val-of = x -> x.contents

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
        fun (<=>) = x y -> if x.< y then
                                -1
                            elsif x.== y then
                                0
                            else
                                1

        # force     : 'a -> 'a
        val force = &(force)


        #### Bool ####

        # TRUE      : Bool
        val TRUE = TRUE

        # FALSE     : Bool
        val FALSE = FALSE

        # not       : Bool -> Bool
        val not = &(Bool.not)


        #### Number ####

        #   zero        : Number -> Number
        val zero = &(Number.zero)

        #   zero?       : Number -> Bool
        val zero? = &(Number.zero?)

        #   positive?   : Number -> Bool
        val positive? = &(Number.positive?)

        #   negative?   : Number -> Bool
        val negative? = &(Number.negative?)

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

        # to-f          : Number -> Float
        val to-f = &(Number.to-f)

        # succ          : Number -> Number
        val succ = &(Number.succ)

        # pred          : Number -> Number
        val pred = &(Number.pred)

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


        #### Float ####

        # NAN       : Float
        val NAN = Float::NAN

        # INFINITY  : Float
        val INFINITY = Float::INFINITY

        # nan?      : Float -> Bool
        val nan? = Float::nan?

        # infinite? : Float -> Bool
        val infinite? = Float::infinite?

        # finite?   : Float -> Bool
        val finite? = Float::finite?


        #### String ####

        # panic!    : String -> ()
        val panic! = String::panic!

        # (^)       : String -> String -> String
        fun (^) = (x : String) (y : String) -> x.^ y

        # join      : [String] -> String
        val join = String::join

        # join-by   : String -> [String] -> String
        val join-by = String::join-by


        #### I/O ####

        val STDIN  = IO::STDIN
        val STDOUT = IO::STDOUT
        val STDERR = IO::STDERR


        # see      : String -> Input
        val see = IO::see

        # seen     : Input -> ()
        val seen = IO::seen

        # see-with : String -> Fun -> ()
        val see-with = IO::see-with


        # tell      : String -> Output
        val tell = IO::tell

        # told      : Output -> ()
        val told = IO::told

        # tell-with : String -> Fun -> ()
        val tell-with = IO::tell-with


        # gets    : () -> Option String 
        val gets = IO::gets

        # fgets   : Input -> Option String 
        val fgets = IO::fgets

        # each-line : Input -> Enum
        val each-line = IO::each-line

        # puts    : String -> ()
        val puts = IO::puts

        # fputs   : Output -> String -> ()
        val fputs = IO::fputs

        # flush : Output -> ()
        val flush = IO::flush

        # display : 'a -> ()
        val display = IO::display

        # tab     : Int -> ()
        val tab = IO::tab

        # nl      : () -> ()
        val nl = IO::nl

        # print   : 'a -> ()
        val print = IO::print

        # p       : 'a -> ()
        val p = IO::p

        # pp      : 'a -> ()
        val pp = IO::pp


        #### Reference ####

        # ref : Top -> Ref
        val ref  = Ref::ref

        # !! : Ref -> Top
        val !! = Ref::peek!

        # (:=) : Ref -> Top -> Unit
        val (:=) = Ref::poke!


        #### Tuple ####

        # (,)   : 'a -> 'b -> ('a, 'b)
        fun (,) = x y -> (x, y)

        # fst   : ('a, 'b) -> 'a
        fun fst = (f, _) -> f

        # snd   : ('a, 'b) -> 'b
        fun snd = (_, s) -> s


        #### Datum ####
        # See SICP(Wizard Book), 2.4.2 Tagged data

        # Datum : Symbol -> 'a -> Datum 'a
        fun Datum = (t : Symbol) x -> &Datum.(tag:t contents:x)

        # tag-of : Datum 'a -> Symbol
        val tag-of = &(Datum.tag)


        #### Option ####

        # Some  : 'a -> Some 'a
        val Some = Option::Some

        # NONE  : None 'a
        val NONE = Option::NONE

        # Some? : Option 'a -> Bool
        val Some? = Option::Some?

        # None? : Option 'a -> Bool
        val None? = Option::None?


        #### Result ####

        # Ok   : 'a -> Ok 'a
        val Ok = Result::Ok

        # Err  : 'a -> Err 'a
        val Err = Result::Err

        # Ok?  : Result 'a -> Bool
        val Ok? = Result::Ok?

        # Err? : Result 'a -> Bool
        val Err? = Result::Err?


        #### Morph ####

        # (|)       : 'a -> %['a] -> %['a]
        val (|) = Morph::cons

        # (++)      : %['a] -> %['a] -> %['a]
        fun (++) = (xs : Morph) (ys : Morph) -> xs.++ ys

        # cons : 'a -> %['a] -> %['a]
        val cons = Morph::cons

        # empty?    : %['a] -> Bool
        val empty? = Morph::empty?

        # exists?   : %['a] -> Bool
        val exists? = Morph::exists?

        # head      : %['a] -> 'a
        val head = Morph::head

        # tail      : %['a] -> ['a]
        val tail = Morph::tail

        # to-list : %['a] -> ['a]
        val to-list = Morph::to-list

        # susp : %['a] -> <Stream> 'a
        val susp = Morph::susp

        # to-s-expr : %['a] -> %s('a)
        val to-s-expr = Morph::to-s-expr

        # equal?    : 'a -> 'b -> Bool
        val equal? = Morph::equal?

        # foldr     : 'b -> ('a -> 'b -> 'b) -> %['a] -> 'b
        val foldr = Morph::foldr

        # foldl     : 'b -> ('a -> 'b -> 'b) -> %['a] -> 'b
        val foldl = Morph::foldl

        # length    : %['a] -> Int
        val length = Morph::count

        # sum       : %['a] -> 'a  where { 'a <- Number }
        val sum = Morph::sum

        # avg       : %['a] -> 'a  where { 'a <- Number }
        val avg = Morph::avg

        # max       : %['a] -> 'a  where { 'a <- Number }
        val max = Morph::max

        # min       : %['a] -> 'a  where { 'a <- Number }
        val min = Morph::min

        # all?      : ('a -> Bool) -> %['a] -> Bool
        val all? = Morph::all?

        # any?      : ('a -> Bool) -> %['a] -> Bool
        val any? = Morph::any?

        # include?  : 'a -> %['a] -> Bool
        val include? = Morph::include?

        # reverse   : %['a] -> ['a]
        val reverse = Morph::reverse

        # nth : Int -> %['a] -> 'a or IndexError
        val nth = Morph::nth

        # for-each  : ('a -> 'b) -> %['a] -> ()
        val for-each = Morph::for-each

        # map       : ('a -> 'b) -> %['a] -> %['b]
        val map = Morph::map

        # filter    : ('a -> Bool) -> %['a] -> %['a]
        val filter = Morph::filter

        # concat    : %[%['a]] -> %['a]
        val concat = Morph::concat

        # concat-map : ('a -> %['b]) -> %['a] -> %['b]
        val concat-map = Morph::concat-map

        # zip       : %['a] -> %['b] -> (%['a, 'b])
        val zip = Morph::zip

        # unzip     : %[('a, 'b)] -> (%['a], %['b])
        val unzip = Morph::unzip

        # uniq : %['a] -> %['a]
        val uniq = Morph::uniq

        # partition : ('a -> Bool) -> %['a] -> (%['a], %['a])
        val partition = Morph::partition

        # sort      : %['a] -> %['a]
        val sort = Morph::sort

        # sort-with : ('a -> Int) -> %['a] -> %['a]
        val sort-with = Morph::sort-with


        #### List ####

        # unfold : 'b -> ('b -> Option (['a], 'b)) -> ['a]
        val unfold = List::unfold


        #### High order Function ####

        ## id       : 'a -> 'a
        fun id = x -> x

        ## const    : 'a -> 'b -> 'a
        fun const = x _ -> x

        ## tee      : ('a -> 'b) -> 'a -> 'a
        fun tee = (f : Fun) x -> let { val _ = f x in x }

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
            assert actual kind-of? Unit -> msg () actual
        in
            ()
        }


        # bool : 'a -> Bool -> Bool
        fun bool =
                actual
                (expect : Bool)
        -> let {
            assert actual kind-of? Bool -> "Bool"
            assert actual == expect     -> msg expect actual
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
            assert actual kind-of? Int -> "Int"
            assert actual == expect    -> msg expect actual
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


        # float : 'a -> Float -> Int -> Float
        fun float =
                actual
                (expect : Float)
                (n      : Int)
        -> let {
            assert actual kind-of? Float         -> "Float"
            assert Float::equal? actual expect n -> msg expect actual
        in
            actual
        }


        # symbol : 'a -> Symbol -> Symbol
        fun symbol =
                actual
                (expect : Symbol)
        -> let {
            assert actual kind-of? Symbol -> "Symbol"
            assert actual == expect       -> msg expect actual
        in
            actual
        }


        # string : 'a -> String -> String
        fun string =
                actual
                (expect : String)
        -> let {
            assert actual kind-of? String -> "String"
            assert actual == expect       -> msg expect actual
        in
            actual
        }
    } where {
        import Prelude { fun (==) fun (^) }
        import Morph   { fun map  fun zip }

        fun msg = expect actual ->
            "Expected: " ^ expect.show ^ ", but: " ^ actual.show
    }



    ######## SICP ########
    (#
     # Structure and Implementation of Computer Programs -- 2nd ed.
     #
     # - Original (English)
     #       https://web.mit.edu/6.001/6.037/
     # - Japanease translated
     #       https://sicp.iijlab.net/
     #)

    structure SICP = struct {
        val get = operation-table @lookup-proc

        val put = operation-table @insert-proc!

        val pp = operation-table @pp-proc

        val print = operation-table @print-proc
    } where {
        import Prelude
        structure SE = SExpr


        ###     assoc : Symbol -> SExpr -> Option SExpr
        fun rec assoc = (target-key : Symbol) (records : SExpr) ->
            case records of {
            | &SExprNil   -> NONE
            | &SExprValue -> NONE
            | &SExprCons (
                    car:record-cons : SExprCons
                    cdr:next-records
                ) -> let {
                    val (
                        car:record-key-value : SExprValue
                    ) = val-of record-cons
                in
                    if (val-of record-key-value) == target-key
                        then Some record-cons
                        else assoc target-key next-records
                }
            }


        fun make-table = records : List -> %S(
            ("*table*" . ())
        .
            %{records |>
                Morph::foldr SE::NIL {
                    (k : Symbol, v : SExpr) (se : SExpr)
                ->
                    %S(
                        (%{SE::Value k} . %{v})
                    .
                        %{se}
                    )
                }
            }
        )


        fun make-table' = records -> let {
            val local-table = make-table records


            fun lookup = (key-1 : Symbol) (key-2 : Symbol) -> let {
                val opt-subtable = assoc key-1 <| SE::cdr local-table
            in
                case opt-subtable of {
                | &Some subtable -> let {
                        val opt-record = assoc key-2 <| SE::cdr subtable
                    in
                        case opt-record of {
                        | &Some (record-cons : SExprCons) ->
                                (Some << val-of << SE::cdr) record-cons
                        | &None ->
                                NONE
                        }
                    }
                | &None -> NONE
                }
            }


            fun insert! = (key-1 : Symbol) (key-2 : Symbol)
                           (value : Object) -> let {
                val opt-subtable = assoc key-1 <| SE::cdr local-table
            in
                case opt-subtable of {
                | &Some subtable -> let {
                        val opt-record = assoc key-2 <| SE::cdr subtable
                    in
                        case opt-record of {
                        | &Some record -> SE::set-cdr!
                                                 record
                                                 (SE::Value value)
                        | &None        -> SE::set-cdr! subtable %S(
                                              (
                                                  %{SE::Value key-2}
                                              .
                                                  %{SE::Value value}
                                              )
                                          .
                                              %{SE::cdr subtable}
                                          )
                        }
                    }
                | &None -> SE::set-cdr! local-table %S(
                               (
                                   %{SE::Value key-1}
                                   (
                                       %{SE::Value key-2}
                                   .
                                       %{SE::Value value}
                                   )
                               )
                           .
                               %{SE::cdr local-table}
                           )
                }
            }


            fun pp-table = () -> pp local-table


            fun print-table = () -> (
                print-table' local-table
            ) where {
                fun print-entry = cons : SExprCons -> let {
                    val (
                            car:key-1-value : SExprValue
                            cdr:
                        ) = val-of cons
                    val key-1-sym = val-of key-1-value
                in
                    case cdr of {
                    | &SExprNil ->
                         ()
                    | &SExprValue v ->
                         panic! <| "Unexpectd value: " ^ v.show
                    | &SExprCons (car:entry cdr:) -> let {
                            val (
                                    car:key-2-value : SExprValue
                                    cdr:
                                ) = val-of entry
                            val key-2-sym = val-of key-2-value
                        in
                            do (
                                ! print <| "- key-1:" ^ key-1-sym.show
                                ! print <| "  key-2:" ^ key-2-sym.show
                            )
                        }
                    }
                }

                fun rec print-table' = table : SExpr -> (
                    case table of {
                    | &SExprNil -> NONE
                    | &SExprValue v -> do (
                            #! print "== Value(1) =="
                            ! print-table' v
                            ! NONE
                        )
                    | &SExprCons (car: cdr: records) -> do (
                        #! print "== Cons(1) =="
                        ! print-entry car
                        #! pp car
                        ! &List.unfold records { cell : SExpr ->
                                case cell of {
                                | &SExprNil -> NONE
                                | &SExprValue v -> do (
                                        #! print "== Value(2) =="
                                        ! print-table' v
                                        ! NONE
                                    )
                                | &SExprCons (car: cdr:) -> do (
                                        #! print "== Cons(2) =="
                                        ! print-entry car
                                        #! pp car
                                        ! Some ([()], cdr)
                                    )
                                }
                            }
                        )
                    }
                )
            }


            fun dispatch = m -> case m of {
            | @lookup-proc  -> lookup
            | @insert-proc! -> insert!
            | @pp-proc      -> pp-table
            | @print-proc   -> print-table
            else            -> panic! <|
                                 "Unknown operation -- TABLE: " ^ show m
            }
        in
            dispatch
        }

        val operation-table = make-table' []
    }
}


import Umu::Prelude
___EOS___

end # Umu::Commander::Prelude

end # Umu::Commander

end # Umu
