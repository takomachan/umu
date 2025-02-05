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
        val Some? = &(Option.some?)

        # None? : Option 'a -> Bool
        val None? = &(Option.none?)
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
        val Ok? = &(Result.ok?)

        # Err? : Result 'a -> Bool
        val Err? = &(Result.err?)
    }



    #### Math ####

    structure Math = struct {
        # NAN           : Float
        val NAN = &Float.nan

        # INFINITY      : Float
        val INFINITY = &Float.infinity

        # PI            : Float
        val PI = &Float.pi

        # E             : Float
        val E = &Float.e

        # nan?          : Float -> Bool
        val nan? = &(Float.nan?)

        # infinite?     : Float -> Bool
        val infinite? = &(Float.infinite?)

        # equal?        : Float -> Float -> Int -> Bool
        fun equal? = (x : Float) (y : Float) (n : Int) ->
            x.truncate n.== (y.truncate n)

        # finite?       : Float -> Bool
        val finite? = &(Float.finite?)

        # sin           : Float -> Float
        fun sin = x : Float -> &Float.sin x

        # cos           : Float -> Float
        fun cos = x : Float -> &Float.cos x

        # tan           : Float -> Float
        fun tan = x : Float -> &Float.tan x

        # asin          : Float -> Float
        fun asin = x : Float -> &Float.asin x

        # acos          : Float -> Float
        fun acos = x : Float -> &Float.acos x

        # atan          : Float -> Float
        fun atan = x : Float -> &Float.atan x

        # atan2         : Float -> Float -> Float
        fun atan2 = (y : Float, x : Float) -> &Float.(atan2-y:y x:)

        # sinh          : Float -> Float
        fun sinh = x : Float -> &Float.sinh x

        # cosh          : Float -> Float
        fun cosh = x : Float -> &Float.cosh x

        # tanh          : Float -> Float
        fun tanh = x : Float -> &Float.tanh x

        # exp           : Float -> Float
        fun exp = x : Float -> &Float.exp x

        # log           : Float -> Float
        fun log = x : Float -> &Float.log x

        # log10         : Float -> Float
        fun log10 = x : Float -> &Float.log10 x

        # sqrt          : Float -> Float
        fun sqrt = x : Float -> &Float.sqrt x

        # truncate      : Float -> Int -> Float
        fun truncate = (x : Float) (n : Int) -> x.truncate n

        # ceil          : Float -> Int -> Float
        fun ceil = (x : Float) (n : Int) -> x.ceil n

        # floor         : Float -> Int -> Float
        fun floor = (x : Float) (n : Int) -> x.floor n

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


        # dest : %['a] -> Option ('a, %['a])
        val dest = &(Morph.dest)


        # head : %['a] -> 'a or EmptyError
        fun head = xs : Morph -> xs.head


        # tail : %['a] -> %['a] or EmptyError
        fun tail = xs : Morph -> xs.tail


        # to-list : %['a] -> ['a]
        fun to-list = xs : Morph -> xs.to-list


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
        # unfoldr : 'b -> ('b -> Option ('a, 'b)) -> ['a]
        fun unfoldr = x (f : Fun) -> &List.unfoldr x f


        # unfoldl : 'b -> ('b -> Option ('a, 'b)) -> ['a]
        fun unfoldl = x (f : Fun) -> &List.unfoldl x f
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


        #### Math ####

        # NAN       : Float
        val NAN = Math::NAN

        # INFINITY  : Float
        val INFINITY = Math::INFINITY

        # nan?      : Float -> Bool
        val nan? = Math::nan?

        # infinite? : Float -> Bool
        val infinite? = Math::infinite?

        # finite?   : Float -> Bool
        val finite? = Math::finite?


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

        # head      : %['a] -> 'a
        val head = Morph::head

        # tail      : %['a] -> ['a]
        val tail = Morph::tail

        # to-list : %['a] -> ['a]
        val to-list = Morph::to-list

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

        # unfoldr : 'b -> ('b -> Option ('a, 'b)) -> ['a]
        val unfoldr = List::unfoldr

        # unfoldl : 'b -> ('b -> Option ('a, 'b)) -> ['a]
        val unfoldl = List::unfoldl


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
            assert Math::equal? actual expect n -> msg expect actual
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
    } where {
        import Prelude
        structure SE = SExpr


        ###     assoc : Symbol -> SExpr -> Option SExpr
        fun rec assoc = (key : Symbol) (records : SExpr) ->
            cond records of {
            | SE::Nil?   -> NONE
            | SE::Value? -> NONE
            | SE::Cons?  -> let {
                    val (car: cdr:) = records.contents
                in
                    if SE::Cons? car && key == (val-of <| SE::car car)
                        then Some car
                        else assoc key cdr
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
                        | &Some record -> Some <| SE::cdr record
                        | &None        -> NONE
                        }
                    }
                | &None -> NONE
                }
            }


            fun insert! = (key-1 : Symbol) (key-2 : Symbol) value -> let {
                val opt-subtable = assoc key-1 <| SE::cdr local-table
            in
                case opt-subtable of {
                | &Some subtable -> let {
                        val opt-record = assoc key-2 <| SE::cdr subtable
                    in
                        case opt-record of {
                        | &Some record ->
                            SE::set-cdr! record value
                        | &None ->
                            SE::set-cdr! subtable %S(
                                (%{SE::Value key-2} .  %{value})
                            .
                                %{SE::cdr subtable}
                            )
                        }
                    }
                | &None -> SE::set-cdr! local-table %S(
                        (
                            %{SE::Value key-1}
                            (%{SE::Value key-2} . %{value})
                        )
                    .
                        %{SE::cdr local-table}
                    )
                }
            }


            fun pp-table = () -> pp local-table


            fun dispatch = m -> case m of {
            | @lookup-proc  -> lookup
            | @insert-proc! -> insert!
            | @pp-proc      -> pp-table
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
