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
		val TRUE = @(Bool.make-true) ()

		# FALSE : Bool
		val FALSE = @(Bool.make-false) ()
	}



	######## Datum ########
	# See SICP(Wizard Book), 2.4.2 Tagged data

	module DATUM = struct {
		# make : Symbol -> 'a -> Datum 'a
		val make = @(Datum.make)

		# tag : Datum 'a -> Symbol
		val tag = @(Datum$tag)

		# content : Datum 'a -> 'a
		val content = @(Datum$content)
	}



	######## Option ########

	module OPTION = struct {
		#### Constructor ####

		# Some : 'a -> Option 'a
		val Some = @(Option.make-some)

		# NONE : Option 'a
		val NONE = @(Option.make-none) ()


		#### Classifier ####

		# Some? : Option 'a -> Bool
		val Some? = @(Option$some?)

		# NONE? : Option 'a -> Bool
		val NONE? = @(Option$none?)


		#### Accessor ####

		# content : Option 'a -> 'a
		val content = @(Option$content)
	}



	#### Math ####

	module MATH = struct {
		# NAN 			: Real
		val NAN = @(Real.make-nan) ()

		# INFINITY	 	: Real
		val INFINITY = @(Real.make-infinity) ()

		# PI 			: Real
		val PI = @(Real.make-pi) ()

		# E 			: Real
		val E = @(Real.make-e) ()

		# nan?			: Real -> Bool
		val nan? = @(Real$nan?)

		# infinite?		: Real -> Bool
		val infinite? = @(Real$infinite?)

		# finite?		: Real -> Bool
		val finite? = @(Real$finite?)

		# sin			: Real -> Real
		val sin = @(Real$sin)

		# cos			: Real -> Real
		val cos = @(Real$cos)

		# tan			: Real -> Real
		val tan = @(Real$tan)

		# asin			: Real -> Real
		val asin = @(Real$asin)

		# acos			: Real -> Real
		val acos = @(Real$acos)

		# atan			: Real -> Real
		val atan = @(Real$atan)

		# atan2			: Real -> Real -> Real
		val atan2 = @(Real$atan2)

		# sinh			: Real -> Real
		val sinh = @(Real$sinh)

		# cosh			: Real -> Real
		val cosh = @(Real$cosh)

		# tanh			: Real -> Real
		val tanh = @(Real$tanh)

		# exp			: Real -> Real
		val exp = @(Real$exp)

		# log			: Real -> Real
		val log = @(Real$log)

		# log10			: Real -> Real
		val log10 = @(Real$log10)

		# sqrt			: Real -> Real
		val sqrt = @(Real$sqrt)

		# ceil			: Real -> Real
		val ceil = @(Real$ceil)

		# floor			: Real -> Real
		val floor = @(Real$floor)

		# ldexp			: Real -> Int -> Real
		val ldexp = @(Real$ldexp)

		# frexp			: Real -> (Real, Real)
		val frexp = @(Real$frexp)

		# divmod		: Real -> Real -> (Real, Real)
		val divmod = @(Real$divmod)
	}



	#### I/O ####

	module IO = struct {
		# gets : () -> Option String 
		fun gets = () -> @(IO$fgets) _STDIN

		# puts : String -> ()
		fun puts = x -> @(IO$fputs) _STDOUT x

		# display : 'a -> ()
		fun display = x -> @(IO$fputs) _STDOUT (@(Top$to-s) x)

		# tab : Int -> ()
		fun rec tab = n ->
			if (@(Int$<) 0 n) (
				@(IO$fputs) _STDOUT " "
			;	tab (@(Int$-) n 1)
			) else
				()

		# nl : () -> ()
		fun nl = () -> @(IO$fputs) _STDOUT "\n"

		# print : 'a -> ()
		fun print = x -> @(IO$fputs)
								_STDOUT
								(@(String$^) (@(Top$to-s) x) "\n")

		# p : 'a -> ()
		fun p = x -> @(IO$fputs)
								_STDOUT
								(@(String$^) (@(Top$inspect) x) "\n")

		# msgout : 'a -> ()
		fun msgout = x -> @(IO$fputs)
								_STDERR
								(@(String$^) (@(Top$to-s) x) "\n")
						

		# random : 'a -> 'a	where { 'a <- Number }
		val random = @(Number$random)
	} where {
		val _STDIN	= @(IO.make-stdin) ()
		val _STDOUT	= @(IO.make-stdout) ()
		val _STDERR	= @(IO.make-stderr) ()
	}



	######## List ########

	module LIST = struct {
		# Empty : () -> ['a]
		val Empty = @(List.make-empty)


		# Cons : 'a -> ['a] -> ['a]
		val Cons = @(List.make-cons)


		# Empty? : ['a] -> Bool
		val Empty? = @(List$empty?)


		# Cons? : ['a] -> Bool
		val Cons? = @(List$cons?)


		# des : ['a] -> ('a, ['a])
		val des = @(List$des)


		# hd : ['a] -> 'a
		fun hd = xs -> (des xs).1


		# tl : ['a] -> ['a]
		fun tl = xs -> (des xs).2


		# equal-with? : ('a -> 'b -> Bool) -> ['a] -> ['b] -> Bool
		fun rec equal-with? = eq? xs ys ->
			if (xs ako? List andalso ys ako? List)
				cond xs {
					Empty?	=> Empty? ys
					else	=> cond ys {
				  		Empty?	=> BOOL::FALSE
						else	=> eq? x y andalso equal-with? eq? xs' ys'
									where val [x|xs'] = xs
										  val [y|ys'] = ys
					}
				}
			else
				BOOL::FALSE


		# equal? : ['a] -> ['b] -> Bool
		val equal? = equal-with? @(Top$==)


		# fold : 'b -> ('a -> 'b -> 'b) -> ['a] -> 'b
		fun rec fold = a f xs -> cond xs {
			Empty?	=> a
			else	=> fold (f x a) f xs'
						where val [x|xs'] = xs
		}


		# fold1 : ('a -> 'a -> 'a) -> ['a] -> 'a
		fun rec fold1 = f xs -> cond xs {
			Empty?	=> @(String$error) "Empty list"
			else	=> fold x f xs'
						where val [x|xs'] = xs
		}


		# foldr : 'b -> ('a -> 'b -> 'b) -> ['a] -> 'b
		fun rec foldr = a f xs -> cond xs {
			Empty?	=> a
			else	=> f x (foldr a f xs')
						where val [x|xs'] = xs
		}


		# foldl : 'b -> ('b -> 'a -> 'b) -> ['a] -> 'b
		fun rec foldl = a f xs -> cond xs {
			Empty?	=> a
			else	=> foldl (f a x) f xs'
						where val [x|xs'] = xs
		}


		# length : ['a] -> Int
		val length = fold 0 { _ len -> @(Number$+) len 1 }


		# reverse : ['a] -> ['a]
		val reverse = fold [] Cons


		# max : ['a] -> 'a
		val max = fold1 { x y -> if (@(Top$<) y x) x else y }


		# min : ['a] -> 'a
		val min = fold1 { x y -> if (@(Top$<) x y) x else y }


		# map : ('a -> 'b) -> ['a] -> ['b]
		fun map = f -> foldr [] { x xs -> [f x | xs] }


		# filter : ('a -> Bool) -> ['a] -> ['a]
		fun filter = f -> foldr [] { x xs -> if (f x) [x|xs] else xs }


		# append : ['a] -> ['a] -> ['a]
		fun append = xs ys -> foldr ys Cons xs


		# concat : [['a]] -> ['a]
		val concat = fold [] { xs xss -> append xss xs }


		# zip-with : ('a -> 'b -> 'c) -> ['a] -> ['b] -> ['c]
		fun zip-with = f -> foldr e g
		where {
			fun e = _ -> []

			fun g = x h ys -> cond ys {
				Empty?	=> []
				else	=> [f x y | h ys']
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


		# sort-with : ('a -> 'a -> Bool) -> ['a] -> ['a]
		fun rec sort-with = f xs -> cond xs {
			Empty?	=> []
			else	=>
				concat [sort-with f littles, [pivot], sort-with f bigs]
				where val [pivot|xs']	  = xs
					  val (littles, bigs) = partition { x -> f x pivot } xs'
		}


		# sort : ['a] -> ['a]
		val sort = sort-with @(Top$<)
	}



	######## String ########

	module STRING = struct {
		# error : String -> ()
		val error = @(String$error)


		# join : String -> [String] -> String
		fun join = j xs -> cond xs {
			LIST::Empty?	=> ""
			else			=> cond xs' {
				LIST::empty?	=> x
				else			=> @(String$^) x xs''
					where val [x|xs'] = xs
						  val xs'' = LIST::fold
								""
								{ x' s -> @(String$^) (@(String$^) s j) x' }
			}
		}


		# concat : [String] -> String
		val concat = join ""
	}



	######## Prelude ########

	module PRELUDE = struct {
		#### Top ####

		# inspect	: 'a -> String
		val inspect = @(Top$inspect)

		# to-s		: 'a -> String
		val to-s = @(Top$to-s)

		# (==)		: 'a -> 'b -> Bool
		val (==) = @(Top$==)

		# (\=)		: 'a -> 'b -> Bool
		fun (\=) = x y -> @(Bool$not) (@(Top$==) x y)

		# (<)		: 'a -> 'a -> Bool
		val (<) = @(Top$<)

		# (>)		: 'a -> 'a -> Bool
		fun (>) = x y -> @(Top$<) y x

		# (<=)		: 'a -> 'a -> Bool
		fun (<=) = x y -> @(Bool$not) (@(Top$<) y x)

		# (>=)		: 'a -> 'a -> Bool
		fun (>=) = x y -> @(Bool$not) (@(Top$<) x y)


		#### Bool ####

		# TRUE		: Bool
		val TRUE = BOOL::TRUE

		# FALSE		: Bool
		val FALSE = BOOL::FALSE

		# not		: Bool -> Bool
		val not = @(Bool$not)

		# otherwise	: 'a -> Bool
		fun otherwise = _ -> TRUE


		#### Number ####

		# 	positive?	: Number -> Bool
		val positive? = @(Number$positive?)

		# 	negative?	: Number -> Bool
		val negative? = @(Number$negative?)

		# 	odd?		: Int -> Bool
		val odd? = @(Int$odd?)

		# 	even?		: Int -> Bool
		val even? = @(Int$even?)

		# ~				: 'a -> 'a	where { 'a <- Number }
		val ~ = @(Number$~)

		# abs			: 'a -> 'a	where { 'a <- Number }
		val abs = @(Number$abs)

		# to-i			: Number -> Int
		val to-i = @(Number$to-i)

		# to-r			: Number -> Real
		val to-r = @(Number$to-r)

		# (+)			: 'a -> 'a -> 'a		where { 'a <- Number }
		val (+) = @(Number$+)

		# (-)			: 'a -> 'a -> 'a		where { 'a <- Number }
		val (-) = @(Number$-)

		# (*)			: 'a -> 'a -> 'a		where { 'a <- Number }
		val (*) = @(Number$*)

		# (/)			: 'a -> 'a -> 'a		where { 'a <- Number }
		val (/) = @(Number$/)

		# (mod)			: 'a -> 'a -> 'a		where { 'a <- Number }
		val (mod) = @(Number$mod)

		# (pow)			: 'a -> 'a -> 'a		where { 'a <- Number }
		val (pow) = @(Number$pow)


		#### Math ####

		# NAN		: Real
		val NAN = MATH::NAN

		# INFINITY	: Real
		val INFINITY = MATH::INFINITY

		# nan?		: Real -> Bool
		val nan? = MATH::nan?

		# infinite?	: Real -> Bool
		val infinite? = MATH::infinite?

		# finite?	: Real -> Bool
		val finite? = MATH::finite?


		#### String ####

		# error		: String -> ()
		val error = STRING::error

		# (^)		: String -> String -> String
		val (^) = @(String$^)

		# join	 	: String -> [String] -> String
		val join = STRING::join


		#### I/O ####

		# gets		: () -> Option String 
		val gets = IO::gets

		# puts		: 'a -> ()
		val puts = IO::puts

		# display	: 'a -> ()
		val display = IO::display

		# tab		: Int -> ()
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
		val val-of = @(Union$content)


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
		val empty? = LIST::Empty?

		# des		: ['a] -> ('a, ['a])
		val des = LIST::des

		# hd		: ['a] -> 'a
		val hd = LIST::hd

		# tl		: ['a] -> ['a]
		val tl = LIST::tl

		# equal?	: 'a -> 'b -> Bool
		val equal? = LIST::equal?

		# fold		: 'b -> ('a -> 'b -> 'b) -> ['a] -> 'b
		val fold = LIST::fold

		# fold1		: ('a -> 'a -> 'a) -> ['a] -> 'a
		val fold1 = LIST::fold1

		# foldr		: 'b -> ('a -> 'b -> 'b) -> ['a] -> 'b
		val foldr = LIST::foldr

		# foldl		: 'b -> ('b -> 'a -> 'b) -> ['a] -> 'b
		val foldl = LIST::foldl

		# length	: ['a] -> Int
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
}



######################################
######## Toplevel definiation ########
######################################

module struct {
	#### Top ####
	val (
		inspect, to-s,
		(==), (\=), (<), (>), (<=), (>=)
	)

	#### Bool ####
	val (
		TRUE, FALSE,
		not, otherwise
	)

	#### Number ####
	val (
		positive?, negative?, odd?, even?,
		~, abs, to-i, to-r,
		(+), (-), (*), (/), (mod), (pow)
	)

	#### Math ####
	val (
		NAN, INFINITY,
		nan?, infinite?, finite?
	)

	#### String ####
	val (error, (^), join)

	#### I/O ####
	val (gets, puts, display, tab, nl, print, p)

	## Tuple
	val ((,), fst, snd)

	#### Datum ####
	val val-of

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
		fold, fold1, foldr, foldl,
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
		id, const,
		curry, uncurry,
		swap, flip,
		pair, cross
	)
} = UMU::PRELUDE
___EOS___

end # Umu::Commander::Prelude

end # Umu::Commander

end # Umu
