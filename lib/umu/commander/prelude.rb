module Umu

module Commander

module Prelude

FILE_NAME = format "<%s>", __FILE__

START_LINE_NUM = __LINE__ + 3

SOURCE_TEXT  = <<'___EOS___'
######################################
######## Umu Standard Library ########
######################################

module UMU = struct {
	######## Bool ########

	module BOOL = struct {
		# TRUE : Bool
		val TRUE = &Bool.make-true

		# FALSE : Bool
		val FALSE = &Bool.make-false
	}



	######## Datum ########
	# See SICP(Wizard Book), 2.4.2 Tagged data

	module DATUM = struct {
		#### Constructor ####

		# make : Atom -> 'a -> Datum 'a
		val make = &(Datum.make)


		#### Selector ####

		# tag-of : Datum 'a -> Atom
		val tag-of = &(Datum$tag)

		# contents : Datum 'a -> 'a
		val contents = &(Datum$contents)
	}



	######## Option ########

	module OPTION = struct {
		#### Constructor ####

		# Some : 'a -> Option 'a
		val Some = &(Option.make-some)

		# NONE : Option 'a
		val NONE = &Option.make-none


		#### Classifier ####

		# Some? : Option 'a -> Bool
		val Some? = &(Option$some?)

		# NONE? : Option 'a -> Bool
		val NONE? = &(Option$none?)


		#### Selector ####

		# contents : Option 'a -> 'a
		val contents = &(Option$contents)
	}



	#### Math ####

	module MATH = struct {
		# NAN 			: Float
		val NAN = &Float.make-nan

		# INFINITY	 	: Float
		val INFINITY = &Float.make-infinity

		# PI 			: Float
		val PI = &Float.make-pi

		# E 			: Float
		val E = &Float.make-e

		# nan?			: Float -> Bool
		val nan? = &(Float$nan?)

		# infinite?		: Float -> Bool
		val infinite? = &(Float$infinite?)

		# equal?		: Float -> Float -> Integer -> Bool
		fun equal? = x y n -> x.(truncate n).(== y.(truncate n))

		# finite?		: Float -> Bool
		val finite? = &(Float$finite?)

		# sin			: Float -> Float
		val sin = &(Float$sin)

		# cos			: Float -> Float
		val cos = &(Float$cos)

		# tan			: Float -> Float
		val tan = &(Float$tan)

		# asin			: Float -> Float
		val asin = &(Float$asin)

		# acos			: Float -> Float
		val acos = &(Float$acos)

		# atan			: Float -> Float
		val atan = &(Float$atan)

		# atan2			: Float -> Float -> Float
		val atan2 = &(Float$atan2)

		# sinh			: Float -> Float
		val sinh = &(Float$sinh)

		# cosh			: Float -> Float
		val cosh = &(Float$cosh)

		# tanh			: Float -> Float
		val tanh = &(Float$tanh)

		# exp			: Float -> Float
		val exp = &(Float$exp)

		# log			: Float -> Float
		val log = &(Float$log)

		# log10			: Float -> Float
		val log10 = &(Float$log10)

		# sqrt			: Float -> Float
		val sqrt = &(Float$sqrt)

		# truncate		: Float -> Integer -> Float
		val truncate = &(Float$truncate)

		# ceil			: Float -> Integer -> Float
		val ceil = &(Float$ceil)

		# floor			: Float -> Integer -> Float
		val floor = &(Float$floor)

		# ldexp			: Float -> Integer -> Float
		val ldexp = &(Float$ldexp)

		# frexp			: Float -> (Float, Float)
		val frexp = &(Float$frexp)

		# divmod		: Float -> Float -> (Float, Float)
		val divmod = &(Float$divmod)
	}



	#### I/O ####

	module IO = struct {
		# gets : () -> Option String 
		fun gets = () -> _STDIN.gets

		# puts : String -> ()
		fun puts = x -> _STDOUT.(puts x)

		# display : 'a -> ()
		fun display = x -> _STDOUT.(puts x.to-s)

		# tab : Integer -> ()
		fun rec tab = n ->
			if (0.(< n)) (
				_STDOUT.(puts " ")
			;	tab (n.(- 1))
			) else
				()

		# nl : () -> ()
		fun nl = () -> _STDOUT.(puts "\n")

		# print : 'a -> ()
		fun print = x -> _STDOUT.(puts x.to-s.(^ "\n"))

		# p : 'a -> ()
		fun p = x -> _STDOUT.(puts x.inspect.(^ "\n"))

		# msgout : 'a -> ()
		fun msgout = x -> _STDERR.(puts x.to-s.(^ "\n"))

		# random : 'a -> 'a	where { 'a <- Number }
		val random = &(Number$random)
	} where {
		val _STDIN	= &IO.make-stdin
		val _STDOUT	= &IO.make-stdout
		val _STDERR	= &IO.make-stderr
	}



	######## List ########

	module LIST = struct {
		# Nil : () -> ['a]
		val Nil = &(List.make-nil)


		# Cons : 'a -> ['a] -> ['a]
		val Cons = &(List.make-cons)


		# Nil? : ['a] -> Bool
		val Nil? = &(List$nil?)


		# Cons? : ['a] -> Bool
		val Cons? = &(List$cons?)


		# des : ['a] -> ('a, ['a])
		val des = &(List$des)


		# hd : ['a] -> 'a
		fun hd = xs -> (des xs).1


		# tl : ['a] -> ['a]
		fun tl = xs -> (des xs).2


		# equal-with? : ('a -> 'b -> Bool) -> ['a] -> ['b] -> Bool
		fun rec equal-with? = eq? xs ys ->
			if (xs isa? List andalso ys isa? List)
				cond xs {
					Nil?	-> Nil? ys
					else	-> cond ys {
				  		Nil?	-> BOOL::FALSE
						else	-> eq? x y andalso equal-with? eq? xs' ys'
									where val [x|xs'] = xs
										  val [y|ys'] = ys
					}
				}
			else
				BOOL::FALSE


		# equal? : ['a] -> ['b] -> Bool
		val equal? = equal-with? &(Top$==)


		# foldr : 'b -> ('a -> 'b -> 'b) -> ['a] -> 'b
		fun rec foldr = a f xs -> cond xs {
			Nil?	-> a
			else	-> f x (foldr a f xs')
						where val [x|xs'] = xs
		}


		# foldr1 : ('a -> 'a -> 'a) -> ['a] -> 'a
		fun foldr1 = f xs -> foldr x f xs'
							where { val [x|xs'] = xs }


		# foldl : 'b -> ('a -> 'b -> 'b) -> ['a] -> 'b
		fun rec foldl = a f xs -> cond xs {
			Nil?	-> a
			else	-> foldl (f x a) f xs'
						where val [x|xs'] = xs
		}


		# foldl1 : ('a -> 'a -> 'a) -> ['a] -> 'a
		fun foldl1 = f xs -> foldl x f xs'
							where { val [x|xs'] = xs }


		# length : ['a] -> Integer
		val length = foldl 0 { _ len -> len.(+ 1) }


		# reverse : ['a] -> ['a]
		val reverse = foldl [] Cons


		# max : ['a] -> 'a
		val max = foldl1 { x y -> if (y.(< x)) x else y }


		# min : ['a] -> 'a
		val min = foldl1 { x y -> if (x.(< y)) x else y }


		# map : ('a -> 'b) -> ['a] -> ['b]
		fun map = f -> foldr [] { x xs -> [f x | xs] }


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

			fun g = x h ys -> cond ys {
				Nil?	-> []
				else	-> [f x y | h ys']
							where val [y|ys'] = ys
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
		fun rec sort = f xs -> cond xs {
			Nil?	-> []
			else	->
				concat [sort f littles, [pivot], sort f bigs]
				where val [pivot|xs']	  = xs
					  val (littles, bigs) = partition { x -> f x pivot } xs'
		}
	}



	######## String ########

	module STRING = struct {
		# abort : String -> ()
		val abort = &(String$abort)


		# join : String -> [String] -> String
		fun join = j xs -> cond xs {
			LIST::Nil?	-> ""
			else		-> cond xs' {
				LIST::Nil?	-> x
				else		-> x.(^ xs'')
					where val [x|xs'] = xs
						  val xs'' = LIST::foldl
											""
											{ x' s -> s.(^ j).(^ x') }
			}
		}


		# concat : [String] -> String
		val concat = join ""
	}



	######## Prelude ########

	module PRELUDE = struct {
		#### Top ####

		# inspect	: 'a -> String
		val inspect = &(Top$inspect)

		# to-s		: 'a -> String
		val to-s = &(Top$to-s)

		# (==)		: 'a -> 'b -> Bool
		val (==) = &(Top$==)

		# (<>)		: 'a -> 'b -> Bool
		fun (<>) = x y -> x.(== y).not

		# (<)		: 'a -> 'a -> Bool
		val (<) = &(Top$<)

		# (>)		: 'a -> 'a -> Bool
		fun (>) = x y -> y.(< x)

		# (<=)		: 'a -> 'a -> Bool
		fun (<=) = x y -> y.(< x).not

		# (>=)		: 'a -> 'a -> Bool
		fun (>=) = x y -> x.(< y).not


		#### Bool ####

		# TRUE		: Bool
		val TRUE = BOOL::TRUE

		# FALSE		: Bool
		val FALSE = BOOL::FALSE

		# not		: Bool -> Bool
		val not = &(Bool$not)


		#### Number ####

		# 	positive?	: Number -> Bool
		val positive? = &(Number$positive?)

		# 	negative?	: Number -> Bool
		val negative? = &(Number$negative?)

		# 	odd?		: Integer -> Bool
		val odd? = &(Integer$odd?)

		# 	even?		: Integer -> Bool
		val even? = &(Integer$even?)

		# ~				: 'a -> 'a	where { 'a <- Number }
		val ~ = &(Number$~)

		# abs			: 'a -> 'a	where { 'a <- Number }
		val abs = &(Number$abs)

		# to-i			: Number -> Integer
		val to-i = &(Number$to-i)

		# to-f			: Number -> Float
		val to-f = &(Number$to-f)

		# (+)			: 'a -> 'a -> 'a		where { 'a <- Number }
		val (+) = &(Number$+)

		# (-)			: 'a -> 'a -> 'a		where { 'a <- Number }
		val (-) = &(Number$-)

		# (*)			: 'a -> 'a -> 'a		where { 'a <- Number }
		val (*) = &(Number$*)

		# (/)			: 'a -> 'a -> 'a		where { 'a <- Number }
		val (/) = &(Number$/)

		# (mod)			: 'a -> 'a -> 'a		where { 'a <- Number }
		val (mod) = &(Number$mod)

		# (pow)			: 'a -> 'a -> 'a		where { 'a <- Number }
		val (pow) = &(Number$pow)


		#### Math ####

		# NAN		: Float
		val NAN = MATH::NAN

		# INFINITY	: Float
		val INFINITY = MATH::INFINITY

		# nan?		: Float -> Bool
		val nan? = MATH::nan?

		# infinite?	: Float -> Bool
		val infinite? = MATH::infinite?

		# finite?	: Float -> Bool
		val finite? = MATH::finite?


		#### String ####

		# abort		: String -> ()
		val abort = STRING::abort

		# (^)		: String -> String -> String
		val (^) = &(String$^)

		# join	 	: String -> [String] -> String
		val join = STRING::join


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


		#### Union ####

		# val-of : Union 'a -> 'a
		val val-of = &(Union$contents)


		#### Datum ####

		# tag-of : Datum 'a -> Atom
		val tag-of = DATUM::tag-of


		#### Option ####

		# Some	: 'a -> Option 'a
		val Some = OPTION::Some

		# NONE	: Option 'a
		val NONE = OPTION::NONE

		# Some?	: Option 'a -> Bool
		val Some? = OPTION::Some?

		# NONE?	: Option 'a -> Bool
		val NONE? = OPTION::NONE?


		#### List ####

		# (|)		: 'a -> ['a] -> ['a]
		val (|) = LIST::Cons

		# (++)		: ['a] -> ['a] -> ['a]
		val (++) = LIST::append

		# empty?	: ['a] -> Bool
		val empty? = LIST::Nil?

		# des		: ['a] -> ('a, ['a])
		val des = LIST::des

		# hd		: ['a] -> 'a
		val hd = LIST::hd

		# tl		: ['a] -> ['a]
		val tl = LIST::tl

		# equal?	: 'a -> 'b -> Bool
		val equal? = LIST::equal?

		# foldr		: 'b -> ('a -> 'b -> 'b) -> ['a] -> 'b
		val foldr = LIST::foldr

		# foldr1	: ('a -> 'a -> 'a) -> ['a] -> 'a
		val foldr1 = LIST::foldr1

		# foldl		: 'b -> ('a -> 'b -> 'b) -> ['a] -> 'b
		val foldl = LIST::foldl

		# foldl1	: ('a -> 'a -> 'a) -> ['a] -> 'a
		val foldl1 = LIST::foldl1

		# length	: ['a] -> Integer
		val length = LIST::length

		# reverse	: ['a] -> ['a]
		val reverse = LIST::reverse

		# max		: ['a] -> 'a
		val max = LIST::max

		# min		: ['a] -> 'a
		val min = LIST::min

		# map		: ('a -> 'b) -> ['a] -> ['b]
		val map = LIST::map

		# filter	: ('a -> Bool) -> ['a] -> ['a]
		val filter = LIST::filter

		# concat	: [['a]] -> ['a]
		val concat = LIST::concat

		# zip		: ['a] -> ['b] -> (['a, 'b])
		val zip = LIST::zip

		# unzip		: [('a, 'b)] -> (['a], ['b])
		val unzip = LIST::unzip

		# partition	: ('a -> Bool) -> ['a] -> (['a], ['a])
		val partition = LIST::partition

		# sort		: ['a] -> ['a]
		val sort = LIST::sort


		#### Function application - Aka. "PIPE" ####

		## (|>)	: 'a -> ('a -> 'b) -> 'b
		fun (|>) = x f -> f x

		## (<|)	: ('a -> 'b) -> 'a -> 'b
		fun (<|) = f x -> f x


		#### Function composition ####

		## (>>)	: ('a -> 'b) -> ('b -> 'c) -> 'a -> 'c
		fun (>>) = f g -> {x -> g (f x)}

		## (<<)	: ('b -> 'c) -> ('a -> 'b) -> 'a -> 'c
		fun (<<) = g f -> {x -> g (f x)}


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

	module ASSERT = struct {
		# unit : 'a -> ()
		fun unit = actual -> let {
			assert (actual isa? Unit)	(msg () actual)
		in
			()
		}


		# bool : 'a -> Bool -> Bool
		fun bool = actual expect -> let {
			assert (actual isa? Bool)	"Bool"
			assert (actual == expect)	(msg expect actual)
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
			assert (actual isa? Integer)	"Integer"
			assert (actual == expect)		(msg expect actual)
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
			assert (actual isa? Float)				"Float"
			assert (MATH::equal? actual expect n)	(msg expect actual)
		in
			actual
		}


		# atom : 'a -> Atom -> Atom
		fun atom = actual expect -> let {
			assert (actual isa? Atom)	"Atom"
			assert (actual == expect)	(msg expect actual)
		in
			actual
		}


		# string : 'a -> String -> String
		fun string = actual expect -> let {
			assert (actual isa? String)	"String"
			assert (actual == expect)	(msg expect actual)
		in
			actual
		}
	} where {
		val (==) = PRELUDE::(==)
		val (^)  = PRELUDE::(^)
		val (|>) = PRELUDE::(|>)

		val map	= LIST::map
		val zip	= LIST::zip

		fun msg = expect actual ->
			"Expected: " ^ expect.inspect ^ ", but: " ^ actual.inspect
	}
}



######################################
######## Toplevel definiation ########
######################################

module struct {
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
		positive?, negative?, odd?, even?,
		~, abs, to-i, to-f,
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

	#### Union ####
	val val-of

	#### Datum ####
	val tag-of

	#### Option ####
	val (
		Some, NONE,
		Some?, NONE?
	)

	#### List ####
	val (
		(|), (++),
		empty?,
		des, hd, tl,
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
} = UMU::PRELUDE
___EOS___

end # Umu::Commander::Prelude

end # Umu::Commander

end # Umu
