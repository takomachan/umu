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
	val TRUE = &{Bool}.make-true

	# FALSE : Bool
	val FALSE = &{Bool}.make-false



	######## Option ########

	structure Option = struct {
		#### Constructor ####

		# Some : 'a -> Some 'a
		val Some = &{Some}.make

		# NONE : None
		val NONE = &{None}.make


		#### Classifier ####

		# Some? : Option 'a -> Bool
		fun Some? = x : Option -> x.some?

		# NONE? : Option 'a -> Bool
		fun NONE? = x : Option -> x.none?
	}



	#### Math ####

	structure Math = struct {
		# NAN 			: Float
		val NAN = &{Float}.make-nan

		# INFINITY	 	: Float
		val INFINITY = &{Float}.make-infinity

		# PI 			: Float
		val PI = &{Float}.make-pi

		# E 			: Float
		val E = &{Float}.make-e

		# nan?			: Float -> Bool
		fun nan? = x : Float -> x.nan?

		# infinite?		: Float -> Bool
		fun infinite? = x : Float -> x.infinite?

		# equal?		: Float -> Float -> Integer -> Bool
		fun equal? = (x : Float) (y : Float) (n : Integer) ->
			x.truncate n.== (y.truncate n)

		# finite?		: Float -> Bool
		fun finite? = x : Float -> x.finite?

		# sin			: Float -> Float
		fun sin = x : Float -> x.sin

		# cos			: Float -> Float
		fun cos = x : Float -> x.cos

		# tan			: Float -> Float
		fun tan = x : Float -> x.tan

		# asin			: Float -> Float
		fun asin = x : Float -> x.asin

		# acos			: Float -> Float
		fun acos = x : Float -> x.acos

		# atan			: Float -> Float
		fun atan = x : Float -> x.atan

		# atan2			: Float -> Float -> Float
		fun atan2 = x : Float -> x.atan2

		# sinh			: Float -> Float
		fun sinh = x : Float -> x.sinh

		# cosh			: Float -> Float
		fun cosh = x : Float -> x.cosh

		# tanh			: Float -> Float
		fun tanh = x : Float -> x.tanh

		# exp			: Float -> Float
		fun exp = x : Float -> x.exp

		# log			: Float -> Float
		fun log = x : Float -> x.log

		# log10			: Float -> Float
		fun log10 = x : Float -> x.log10

		# sqrt			: Float -> Float
		fun sqrt = x : Float -> x.sqrt

		# truncate		: Float -> Integer -> Float
		fun truncate = x : Float -> x.truncate

		# ceil			: Float -> Integer -> Float
		fun ceil = x : Float -> x.ceil

		# floor			: Float -> Integer -> Float
		fun floor = x : Float -> x.floor

		# ldexp			: Float -> Integer -> Float
		fun ldexp = x : Float -> x.ldexp

		# frexp			: Float -> (Float, Float)
		fun frexp = x : Float -> x.frexp

		# divmod		: Float -> Float -> (Float, Float)
		fun divmod = x : Float -> x.divmod
	}



	#### I/O ####

	structure IO = struct {
		# gets : () -> Option String 
		fun gets = () -> _STDIN.gets

		# puts : String -> ()
		fun puts = x -> _STDOUT.puts x

		# display : 'a -> ()
		fun display = x -> _STDOUT.puts (x.to-s)

		# tab : Integer -> ()
		fun rec tab = n ->
			if (0.< n) (
				_STDOUT.puts " " ;
				tab (n.- 1)
			) else
				()

		# nl : () -> ()
		fun nl = () -> _STDOUT.puts "\n"

		# print : 'a -> ()
		fun print = x -> _STDOUT.puts (x.to-s.^ "\n")

		# p : 'a -> ()
		fun p = x -> _STDOUT.puts (x.inspect.^ "\n")

		# msgout : 'a -> ()
		fun msgout = x -> _STDERR.puts (x.to-s.^ "\n")

		# random : 'a -> 'a	where { 'a <- Number }
		fun random = x : Number -> x.random
	} where {
		val _STDIN	= &{IO}.make-stdin
		val _STDOUT	= &{IO}.make-stdout
		val _STDERR	= &{IO}.make-stderr
	}



	######## List ########

	structure List = struct {
		# Nil : () -> ['a]
		fun Nil = () -> &{Nil}.make


		# Cons : 'a -> ['a] -> ['a]
		fun Cons = x (xs : List) -> &{Cons}.make x xs


		# Nil? : ['a] -> Bool
		fun Nil? = xs : List -> xs.nil?


		# Cons? : ['a] -> Bool
		fun Cons? = xs : List -> xs.cons?


		# des : ['a] -> ('a, ['a])
		fun des = xs : List -> xs.des


		# head : ['a] -> 'a
		fun head = xs : Cons -> xs.head


		# tail : ['a] -> ['a]
		fun tail = xs : Cons -> xs.tail


		# equal-with? : ('a -> 'b -> Bool) -> ['a] -> ['b] -> Bool
		fun rec equal-with? = eq? xs ys ->
			if (xs kind-of? List && ys kind-of? List)
				case xs {
				  []	  -> Nil? ys
				| [x|xs'] -> case ys {
					  []	  -> FALSE
					| [y|ys'] -> equal-with? eq? x   y &&
								 equal-with? eq? xs' ys'
					}
				}
			else
				FALSE


		# equal? : ['a] -> ['b] -> Bool
		val equal? = equal-with? { x y -> x.== y }


		# foldr : 'b -> ('a -> 'b -> 'b) -> ['a] -> 'b
		fun rec foldr = a f xs -> case xs {
		  []	  -> a
		| [x|xs'] -> f x (foldr a f xs')
		}


		# foldr1 : ('a -> 'a -> 'a) -> ['a] -> 'a
		fun foldr1 = f xs -> foldr x f xs'
							where { val [x|xs'] = xs }


		# foldl : 'b -> ('a -> 'b -> 'b) -> ['a] -> 'b
		fun rec foldl = a f xs -> case xs {
		  []	  -> a
		| [x|xs'] -> foldl (f x a) f xs'
		}


		# foldl1 : ('a -> 'a -> 'a) -> ['a] -> 'a
		fun foldl1 = f xs -> foldl x f xs'
							where { val [x|xs'] = xs }


		# length : ['a] -> Integer
		val length = foldl 0 { _ len -> len.+ 1 }


		# reverse : ['a] -> ['a]
		val reverse = foldl [] Cons


		# max : ['a] -> 'a
		val max = foldl1 { x y -> if (y.< x) x else y }


		# min : ['a] -> 'a
		val min = foldl1 { x y -> if (x.< y) x else y }


		# map : ('a -> 'b) -> ['a] -> ['b]
		#fun map = f -> foldr [] { x xs -> [f x | xs] }
		fun map = (f : Function) (xs : List) -> xs.map f


		# filter : ('a -> Bool) -> ['a] -> ['a]
		fun filter = f -> foldr [] { x xs -> if (f x) [x|xs] else xs }


		# append : ['a] -> ['a] -> ['a]
		fun append = xs ys -> foldr ys Cons xs


		# concat : [['a]] -> ['a]
		val concat = foldl [] { xs xss -> append xss xs }


		# zip-with : ('a -> 'b -> 'c) -> ['a] -> ['b] -> ['c]
		fun zip-with = f -> foldr e g
		where {
			fun e = _ -> []

			fun g = x h ys -> case ys {
			  []	  -> []
			| [y|ys'] -> [f x y | h ys']
			}
		}


		# zip : ['a] -> ['b] -> [('a, 'b)]
		val zip = zip-with { x y -> (x, y) }


		# unzip : [('a, 'b)] -> (['a], ['b])
		val unzip = foldr ([], []) { (y, z) (ys, zs) -> ([y|ys], [z|zs]) }


		# partition : ('a -> Bool) -> ['a] -> (['a], ['a])
		fun partition = f -> foldr ([], []) { x (ys, zs) ->
			if (f x)
				([x|ys],    zs)
			else
				(   ys,  [x|zs])
		}


		# sort : ('a -> 'a -> Bool) -> ['a] -> ['a]
		fun rec sort = f xs -> case xs {
		  []		  -> []
		| [pivot|xs'] ->
				concat [sort f littles, [pivot], sort f bigs]
			where val (littles, bigs) = partition { x -> f x pivot } xs'
		}
	}



	######## String ########

	structure String = struct {
		# abort : String -> ()
		fun abort = x : String -> x.abort


		# join : String -> [String] -> String
		fun join = j xs -> case xs {
		  []	  -> ""
		| [x|xs'] -> case xs' {
			  []   -> x
			  else -> x.^ xs''
				where val xs'' =
							List::foldl "" { x' s -> s.^ j.^ x' } xs'
			}
		}


		# concat : [String] -> String
		val concat = join ""
	}



	######## Prelude ########

	structure Prelude = struct {
		#### Top ####

		# inspect	: 'a -> String
		val inspect = &(inspect)

		# to-s		: 'a -> String
		val to-s = &(to-s)

		# (==)		: 'a -> 'b -> Bool
		fun (==) = x y -> x.== y

		# (<>)		: 'a -> 'b -> Bool
		fun (<>) = x y -> x.== y.not

		# (<)		: 'a -> 'a -> Bool
		fun (<) = x y -> x.< y

		# (>)		: 'a -> 'a -> Bool
		fun (>) = x y -> y.< x

		# (<=)		: 'a -> 'a -> Bool
		fun (<=) = x y -> y.< x.not

		# (>=)		: 'a -> 'a -> Bool
		fun (>=) = x y -> x.< y.not


		#### Bool ####

		# TRUE		: Bool
		val TRUE = TRUE

		# FALSE		: Bool
		val FALSE = FALSE

		# not		: Bool -> Bool
		fun not = x : Bool -> x.not


		#### Number ####

		# 	positive?	: Number -> Bool
		fun positive? = x : Number -> x.positive?

		# 	negative?	: Number -> Bool
		fun negative? = x : Number -> x.negative?

		# 	zero?		: Number -> Bool
		fun zero? = x : Number -> x.zero?

		# 	odd?		: Integer -> Bool
		fun odd? = x : Integer -> x.odd?

		# 	even?		: Integer -> Bool
		fun even? = x : Integer -> x.even?

		# abs			: 'a -> 'a	where { 'a <- Number }
		fun abs = x : Number -> x.abs

		# negate		: 'a -> 'a	where { 'a <- Number }
		fun negate = x : Number -> x.negate

		# to-i			: Number -> Integer
		fun to-i = x : Number -> x.to-i

		# to-f			: Number -> Float
		fun to-f = x : Number -> x.to-f

		# (+)			: 'a -> 'a -> 'a		where { 'a <- Number }
		fun (+) = (x : Number) (y : Number) -> x.+ y

		# (-)			: 'a -> 'a -> 'a		where { 'a <- Number }
		fun (-) = (x : Number) (y : Number) -> x.- y

		# (*)			: 'a -> 'a -> 'a		where { 'a <- Number }
		fun (*) = (x : Number) (y : Number) -> x.* y

		# (/)			: 'a -> 'a -> 'a		where { 'a <- Number }
		fun (/) = (x : Number) (y : Number) -> x./ y

		# (mod)			: 'a -> 'a -> 'a		where { 'a <- Number }
		fun (mod) = (x : Number) (y : Number) -> x.mod y

		# (pow)			: 'a -> 'a -> 'a		where { 'a <- Number }
		fun (pow) = (x : Number) (y : Number) -> x.pow y


		#### Math ####

		# NAN		: Float
		val NAN = Math::NAN

		# INFINITY	: Float
		val INFINITY = Math::INFINITY

		# nan?		: Float -> Bool
		val nan? = Math::nan?

		# infinite?	: Float -> Bool
		val infinite? = Math::infinite?

		# finite?	: Float -> Bool
		val finite? = Math::finite?


		#### String ####

		# abort		: String -> ()
		val abort = String::abort

		# (^)		: String -> String -> String
		fun (^) = (x : String) (y : String) -> x.^ y

		# join	 	: String -> [String] -> String
		val join = String::join


		#### I/O ####

		# gets		: () -> Option String 
		val gets = IO::gets

		# puts		: 'a -> ()
		val puts = IO::puts

		# display	: 'a -> ()
		val display = IO::display

		# tab		: Integer -> ()
		val tab = IO::tab

		# nl		: () -> ()
		val nl = IO::nl

		# print		: 'a -> ()
		val print = IO::print

		# p			: 'a -> ()
		val p = IO::p


		#### Tuple ####

		# (,)	: 'a -> 'b -> ('a, 'b)
		fun (,) = x y -> (x, y)

		# fst	: ('a, 'b) -> 'a
		fun fst = (f, _) -> f

		# snd	: ('a, 'b) -> 'b
		fun snd = (_, s) -> s


		#### Object ####

		# val-of : Object 'a -> Top
		fun val-of = x : Object -> x.contents


		#### Datum ####
		# See SICP(Wizard Book), 2.4.2 Tagged data

		# Datum : Symbol -> 'a -> Datum 'a
		fun Datum = x : Symbol -> &{Datum}.make x

		# tag-of : Datum 'a -> Symbol
		fun tag-of = x : Datum -> x.tag


		#### Option ####

		# Some	: 'a -> Option 'a
		val Some = Option::Some

		# NONE	: Option 'a
		val NONE = Option::NONE

		# Some?	: Option 'a -> Bool
		val Some? = Option::Some?

		# NONE?	: Option 'a -> Bool
		val NONE? = Option::NONE?


		#### List ####

		# (|)		: 'a -> ['a] -> ['a]
		val (|) = List::Cons

		# (++)		: ['a] -> ['a] -> ['a]
		val (++) = List::append

		# empty?	: ['a] -> Bool
		val empty? = List::Nil?

		# des		: ['a] -> ('a, ['a])
		val des = List::des

		# head		: ['a] -> 'a
		val head = List::head

		# tail		: ['a] -> ['a]
		val tail = List::tail

		# equal?	: 'a -> 'b -> Bool
		val equal? = List::equal?

		# foldr		: 'b -> ('a -> 'b -> 'b) -> ['a] -> 'b
		val foldr = List::foldr

		# foldr1	: ('a -> 'a -> 'a) -> ['a] -> 'a
		val foldr1 = List::foldr1

		# foldl		: 'b -> ('a -> 'b -> 'b) -> ['a] -> 'b
		val foldl = List::foldl

		# foldl1	: ('a -> 'a -> 'a) -> ['a] -> 'a
		val foldl1 = List::foldl1

		# length	: ['a] -> Integer
		val length = List::length

		# reverse	: ['a] -> ['a]
		val reverse = List::reverse

		# max		: ['a] -> 'a
		val max = List::max

		# min		: ['a] -> 'a
		val min = List::min

		# map		: ('a -> 'b) -> ['a] -> ['b]
		val map = List::map

		# filter	: ('a -> Bool) -> ['a] -> ['a]
		val filter = List::filter

		# concat	: [['a]] -> ['a]
		val concat = List::concat

		# zip		: ['a] -> ['b] -> (['a, 'b])
		val zip = List::zip

		# unzip		: [('a, 'b)] -> (['a], ['b])
		val unzip = List::unzip

		# partition	: ('a -> Bool) -> ['a] -> (['a], ['a])
		val partition = List::partition

		# sort		: ['a] -> ['a]
		val sort = List::sort


		#### Function application - Aka. "PIPE" ####

		## (|>)	: 'a -> ('a -> 'b) -> 'b
		fun (|>) = x (f : Function) -> f x

		## (<|)	: ('a -> 'b) -> 'a -> 'b
		fun (<|) = (f : Function) x -> f x


		#### Function composition ####

		## (>>)	: ('a -> 'b) -> ('b -> 'c) -> 'a -> 'c
		fun (>>) = (f : Function) (g : Function) -> {x -> g (f x)}

		## (<<)	: ('b -> 'c) -> ('a -> 'b) -> 'a -> 'c
		fun (<<) = (g : Function) (f : Function) -> {x -> g (f x)}


		#### High order Function ####

		## id		: 'a -> 'a
		fun id = x -> x

		## const	: 'a -> 'b -> 'a
		fun const = x _ -> x

		## tee      : ('a -> 'b) -> 'a -> 'a
		fun tee = f x -> (f x ; x)

		## curry	: (('a, 'b) -> 'c) -> ('a -> 'b -> 'c)
		fun curry = f x y -> f (x, y)

		## uncurry	: ('a -> 'b -> 'c) -> (('a, 'b) -> 'c)
		fun uncurry = f (x, y) -> f x y

		## swap		: (('a, 'b) -> 'c) -> (('b, 'a) -> 'c)
		fun swap = f (x, y) -> f (y, x)

		## flip		: ('a -> 'b -> 'c) -> ('b -> 'a -> 'c)
		fun flip = f x y -> f y x

		## pair		: ('a -> 'b, 'a -> 'c) -> ('a -> ('b, 'c))
		fun pair = (f, g) x -> (f x, g x)

		## cross	: ('a -> 'b, 'c -> 'd) -> (('a, 'c) -> ('b, 'd))
		fun cross = (f, g) -> pair (fst >> f, snd >> g)
	}



	######## Assertion ########

	structure Assert = struct {
		# unit : 'a -> ()
		fun unit = actual -> let {
			assert (actual kind-of? Unit)	(msg () actual)
		in
			()
		}


		# bool : 'a -> Bool -> Bool
		fun bool = actual expect -> let {
			assert (actual kind-of? Bool)	"Bool"
			assert (actual == expect)		(msg expect actual)
		in
			actual
		}


		# bools : ['a] -> ('a -> 'b) -> [Bool] -> [Bool]
		fun bools = sources f expects -> let {
			val results = sources |> map { source -> f source }
		in
			results |> zip expects |> map { (result, expect) ->
				bool result expect
			}
		}


		# true : 'a -> Bool
		fun true = actual -> bool actual TRUE


		# false : 'a -> Bool
		fun false = actual -> bool actual FALSE


		# integer : 'a -> Integer -> Integer
		fun integer = actual expect -> let {
			assert (actual kind-of? Integer)	"Integer"
			assert (actual == expect)			(msg expect actual)
		in
			actual
		}


		# integers : ['a] -> ('a -> 'b) -> [Integer] -> [Integer]
		fun integers = sources f expects -> let {
			val results = sources |> map { source -> f source }
		in
			results |> zip expects |> map { (result, expect) ->
				integer result expect
			}
		}


		# float : 'a -> Float -> Integer -> Float
		fun float = actual expect n -> let {
			assert (actual kind-of? Float)			"Float"
			assert (Math::equal? actual expect n)	(msg expect actual)
		in
			actual
		}


		# symbol : 'a -> Symbol -> Symbol
		fun symbol = actual expect -> let {
			assert (actual kind-of? Symbol)	"Symbol"
			assert (actual == expect)		(msg expect actual)
		in
			actual
		}


		# string : 'a -> String -> String
		fun string = actual expect -> let {
			assert (actual kind-of? String)	"String"
			assert (actual == expect)		(msg expect actual)
		in
			actual
		}
	} where {
		val (==) = Prelude::(==)
		val (^)  = Prelude::(^)
		val (|>) = Prelude::(|>)

		val map	= List::map
		val zip	= List::zip

		fun msg = expect actual ->
			"Expected: " ^ expect.inspect ^ ", but: " ^ actual.inspect
	}
}



######################################
######## Toplevel definiation ########
######################################

structure struct {
	#### Top ####
	val (
		inspect, to-s,
		(==), (<>), (<), (>), (<=), (>=)
	)

	#### Bool ####
	val (
		TRUE, FALSE,
		not
	)

	#### Number ####
	val (
		positive?, negative?, zero?, odd?, even?,
		negate, abs, to-i, to-f,
		(+), (-), (*), (/), (mod), (pow)
	)

	#### Math ####
	val (
		NAN, INFINITY,
		nan?, infinite?, finite?
	)

	#### String ####
	val (abort, (^), join)

	#### I/O ####
	val (gets, puts, display, tab, nl, print, p)

	## Tuple
	val ((,), fst, snd)

	#### Object ####
	val val-of

	#### Datum ####
	val (Datum, tag-of)

	#### Option ####
	val (
		Some, NONE,
		Some?, NONE?
	)

	#### List ####
	val (
		(|), (++),
		empty?,
		des, head, tail,
		foldr, foldr1, foldl, foldl1,
		length, reverse,
		max, min,
		map, filter, concat,
		zip, unzip,
		partition, sort
	)

	#### Function application ####
	val ((|>), (<|))

	#### Function composition ####
	val ((>>), (<<))

	#### High order Function ####
	val (
		id, const, tee,
		curry, uncurry,
		swap, flip,
		pair, cross
	)
} = Umu::Prelude
___EOS___

end # Umu::Commander::Prelude

end # Umu::Commander

end # Umu
