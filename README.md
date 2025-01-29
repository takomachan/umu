# Umu - Functional Scripting Language

## Features

- Two programming styles are available: object-oriented and functional
- Eager evaluation, impure, principles are immutable
- Dynamic typing
- Every function and many messages are curried from the start
- The interpreter is implemented 100% in Ruby using only standard libraries
- Expressiveness over speed



## Installation

$ git clone https://github.com/takomachan/umu

> [!NOTE]
> The name Umu is preliminary and will be given a new name when the official Gem package is released.
>
> By the time you can swim, you will be able to see the Gem package.


## How to Play REPL

> [!NOTE]
> This chapter will be moved to a separate document, the User Guide.

### First Step
```
$ umu/exe/umu -i
umu:1> print "Hello world\n"
Hello world

val it : Unit = ()
umu:2>                  # Enter [Ctrl]+[D]
$
```

### Play REPL with Script
```
$ cat umu/example/factorial.umu 
fun rec factorial = x -> (
    if x <= 1 then
        1
    else
        x * factorial (x - 1)
)
$ umu/exe/umu -i umu/example/factorial.umu 
umu:1> factorial 3
val it : Int = 6
umu:2>
```

### REPL's Subcommand

#### :class

##### Summary

Displays inheritance relationships between classes hierarchically.

```
umu:1> :class
Top/
    Class
    Object/
        Atom/
            Bool
            Number/
                Float
                Int
            String
            Symbol
    :
    :
    :
umu:2>
```

##### Detail

Displays information about the specified class and
a list of messages to which the class can respond.

```
umu:1> :class Bool
ABSTRACT CLASS?: No, this is a concrete class
SUPERCLASS: Atom
ANCESTORS: Atom, Object, Top
CLASS MESSAGES:
    &Bool.false : Bool
    &Bool.true : Bool
INSTANCE MESSAGES:
    Bool#< : Bool -> Bool
    Bool#== : Object -> Bool
    Bool#contents : Top
    Bool#not : Bool
    Bool#show : String
    Bool#to-s : String
umu:2>
```

#### :dump and :nodump


The interpreter processes the input script as follows.

```
/Source(Script)/ ->
    <Lexical analysis> -> [Tokens] ->
    <Parse>    -> [Concrete Syntax Tree] ->
    <Desugar>  -> [Abstract Syntax Tree] ->
    <Evaluate> ->
/Result(environment and value)/
```

Displays the intermediate objects generated in this process as follows.

- Tokens
- Concrete syntax tree
- Abstract syntax tree

```
umu:1> :dump
umu:2> 3 + 4
________ Source: '<stdin>' ________
0002: 3 + 4

________ Tokens: '<stdin>' ________
0002: INT(3) WHITE(" ") '+' WHITE(" ") INT(4) NEWLINE("\n")

________ Concrete Syntax: #2 in "<stdin>" ________
(3 + 4)

________ Abstract Syntax: #2 in "<stdin>" ________
(+ 3 4)

val it : Int = 7
umu:3> :nodump
umu:4>
```

#### :trace and :notrace

The process of desugaring and evaluation inside the interpreter is
displayed in a hierarchical trace.


```
umu:1> :trace
umu:2> 3 + 4
________ Source: '<stdin>' ________
0002: 3 + 4

________ Desugar Trace ________
[Desu] Redefinable (CSCEB::Infix): (3 + 4)
| [Desu] Int (CSCEUA::Number): 3 --> Int (ASCEUA::Number): 3
| [Desu] Int (CSCEUA::Number): 4 --> Int (ASCEUA::Number): 4
--> Apply (ASCEB): (+ 3 4)

________ Evaluator Trace ________
[Eval(Expr)] Apply (ASCEB): (+ 3 4)
| [Eval(Expr)] Short (ASCEU::Identifier): +
| --> Fun (VC): #<+: {x : Number y : Number -> (x).(+ y)}>
| [Eval(Expr)] Int (ASCEUA::Number): 3 --> Int (VCAN): 3
| [Eval(Expr)] Int (ASCEUA::Number): 4 --> Int (VCAN): 4
| [Apply] Fun (VC): (#<+: {x : Number y : Number -> (x).(+ y)}> 3 4)
| | [Eval(Expr)] Entry (ASCEB::Send): (x).(+ y)
| | | [Eval(Expr)] Short (ASCEU::Identifier): x
| | | --> Int (VCAN): 3
| | | [Eval(Expr)] Short (ASCEU::Identifier): y
| | | --> Int (VCAN): 4
| | | [Invoke] Int (VCAN): (3).meth_add(4 : Int) -> Int
| | | --> Int (VCAN): 7
| | --> Int (VCAN): 7
| --> Int (VCAN): 7
--> Int (VCAN): 7

val it : Int = 7
umu:3> :notrace
umu:4>
```


## Example

> [!NOTE]
> This chapter will be moved to a separate document, the Programming Guide.

### Atom

#### Integer
```
umu:1> 3
val it : Int = 3
umu:2> 3 + 4
val it : Int = 7
umu:3>
```

#### Float
```
umu:1> 3.0
val it : Float = 3.0
umu:2> 3.0 + 4.0
val it : Float = 7.0
umu:3>
```

#### String
```
umu:1> "Hello"
val it : String = "Hello"
umu:2> "Hello" ^ " world"
val it : String = "Hello world"
umu:3>
```

#### Symbol
```
umu:1> @hello
val it : Symbol = @hello
umu:2> to-s @hello
val it : String = "hello"
umu:3> show @hello
val it : String = "@hello"
umu:4>
```

#### Bool
```
umu:1> TRUE
val it : Bool = TRUE
umu:2> 3 == 3
val it : Bool = TRUE
umu:3> 3 == 4
val it : Bool = FALSE
umu:4>
```

### Lambda expression and Function definition

### Lambda expression
```
umu:1> { x y -> x + y }
fun it = #<{ x y -> (+ x y) }>
umu:2> it 3 4
val it : Int = 7
umu:3>
```

```
umu:1> { x y -> x + y } 3
fun it = #<{ y -> (+ x y) }>
umu:2> it 4
val it : Int = 7
umu:3>
```

```
umu:1> { (x, y) -> 3 + 4 }
fun it = #<{ %a1 : Product -> %LET { %VAL x = (%a1)$1 %VAL y = (%a1)$2 %IN (+ 3 4) } }>
umu:2> it (3, 4)
val it : Int = 7
umu:3>
```

### Function definition

#### Simple function

The declaration `val` binds a value to an identifier.
Here, the value is a function object.

```
umu:1> val add = { x y -> x + y }
fun add = #<{ x y -> (+ x y) }>
umu:2> add 3 4
val it : Int = 7
umu:3>
```

The declaration `fun` is syntactic sugar for binding function objects.

```
umu:1> fun add' = x y -> x + y
fun add' = #<add': { x y -> (+ x y) }>
umu:2> add' 3 4
val it : Int = 7
umu:3>
```

```
umu:1> fun add'' = (x, y) -> x + y
fun add'' = #<add'': { %a1 : Product
    -> %LET { %VAL x = (%a1)$1 %VAL y = (%a1)$2 %IN (+ x y) }
    }>
umu:2> add'' (3, 4)
val it : Int = 7
umu:3>
```


#### Recursive function

A recursive function is defined with the declaration `fun rec`.

```
umu:1> fun rec factorial = x -> (    # Copy&Paste: 'umu/example/factorial.umu'
umu:2*     if x <= 1 then
umu:3*         1   
umu:4*     else
umu:5*         x * factorial (x - 1)
umu:6* )
fun factorial = #<factorial: { x -> (%IF (<= x 1) %THEN 1 %ELSE (* x (factorial (- x 1)))) }>
umu:7> factorial 3
val it : Int = 6
umu:8>
```


### Function application and Message sending
```
umu:1> 3 + 4             # Infix orepator expression
val it : Int = 7
umu:2> (+) 3 4           # Infix operator as function object
val it : Int = 7
umu:3> ((+) 3) 4         # Partial application for first parameter
val it : Int = 7
umu:4> (+ 4) 3           # Partial application for second parameter
val it : Int = 7
```

```
umu:5> 3.(+ 4)           # Send binary message '+ 4' to integer object 3
val it : Int = 7
umu:6> 3.+ 4             # Brakets are optional
val it : Int = 7
umu:7> (3.+) 4           # Send only binary message keyword '+'
val it : Int = 7
umu:8> &(+) 3 4          # Binary message as function object
val it : Int = 7
umu:9> (&(+) 3) 4        # Partial application for first parameter
val it : Int = 7
```

```
umu:10> (+).apply-binary 3 4    # Send apply message to function object
val it : Int = 7
umu:11> (+).[3, 4]       # Another apply message notation (syntactic sugar)
val it : Int = 7
```


### Message chaining, Pipelined application and Function composition

See edvakf's blog article: [PythonでもRubyみたいに配列をメソッドチェーンでつなげたい](https://edvakf.hatenadiary.org/entry/20090405/1238885788)」.

#### (1) Message Chaining

OOP(Object oriented programming) style

```
umu:1> [1, 4, 3, 2]
val it : Cons = [1, 4, 3, 2]
umu:2> [1, 4, 3, 2].sort
val it : Cons = [1, 2, 3, 4]
umu:3> [1, 4, 3, 2].sort.reverse
val it : Cons = [4, 3, 2, 1]
umu:4> [1, 4, 3, 2].sort.reverse.map to-s
val it : Cons = ["4", "3", "2", "1"]
umu:5> [1, 4, 3, 2].sort.reverse.map to-s.join-by "-"
val it : String = "4-3-2-1"
umu:6>
```

#### (2) Pipelined Application

Like F#, Ocaml, Scala, Elixir ... etc

```
umu:1> [1, 4, 3, 2] |> sort |> reverse |> map to-s |> join-by "-"
val it : String = "4-3-2-1"
umu:2>
```

#### (2') Another Pipelined Application

Like a Haskell's $-operator

```
umu:1> join-by "-" <| map to-s <| reverse <| sort [1, 4, 3, 2]
val it : String = "4-3-2-1"
umu:2>
```

#### (3) Function Composition

```
umu:1> (sort >> reverse >> map to-s >> join-by "-") [1, 4, 3, 2]
val it : String = "4-3-2-1"
umu:2> [1, 4, 3, 2] |> sort >> reverse >> map to-s >> join-by "-"
val it : String = "4-3-2-1"
umu:3>
```

#### (3') Another Function Composition

Like a Haskell's point-free style

```
umu:1> (join-by "-" << map to-s << reverse << sort) [1, 4, 3, 2]
val it : String = "4-3-2-1"
umu:2> join-by "-" << map to-s << reverse << sort <| [1, 4, 3, 2]
val it : String = "4-3-2-1"
umu:3>
```

#### (4) Traditional nested function application

like Lisp, Python, Pascal, Fortran, ... etc

```
umu:1> join-by "-" (map to-s (reverse (sort [1, 4, 3, 2])))
val it : String = "4-3-2-1"
umu:2>
```



### Message

Messages are classified as follows:

- Instance message
    - Simple instance message
        - Unary Instance message
            - [Example] Int#to-s : String
            - [Example] Bool#not : Bool
            - [Example] List#join : String
        - Binary instance message
            - [Example] Int#+ : Int -> Int
            - [Example] Int#to : Int -> Interval
            - [Example] String#^ : String -> String
            - [Example] List#join-by : String -> String
            - [Example] Fun#apply : Top -> Top
        - N-ary instance message
            - [Example] Int#to-by : Int -> Int -> Interval
            - [Example] List#foldr : Top -> Fun -> Top
            - [Example] Fun#apply-binary : Top -> Top -> Top
            - [Example] Fun#apply-nary : Top -> Top -> Morph -> Top
    - Keyword instance message
        - [Example] Int#(to:Int) -> Interval
        - [Example] Int#(to:Int by:Int) -> Interval
        - [Example] List#(join:String) -> String
- Class message
    - Simple class message
        - [Example] &Bool.true : Bool
        - [Example] &Float.nan : Float
        - [Example] &Some.make : Top -> Some
        - [Example] &Datum.make : Symbol -> Top -> Datum
        - [Example] &Interval.make : Int -> Int -> Interval
        - [Example] &Interval.make-by : Int -> Int -> Int -> Interval
    - Keyword class message
        - [Example] &Datum.(tag:Symbol contents:Top) -> Datum
        - [Example] &Interval.(from:Int to:Int) -> Interval
        - [Example] &Interval.(from:Int to:Int by:Int) -> Interval


#### Instance message and Class message

Instance messages are ordinary messages.

A class message is a message to the class object created by the class expression `&Foo`.
This is often used to create an instance of a class.

> [!NOTE]
> Currently, the reserved word `new` for instantiation found in Java and Ruby is defined but not used.
> In the future, when user-defined functionality for classes is provided, the syntax will be `new Foo x`.


#### Simple message and Keyword message

Simple messages are messages that are curried and
are suitable for mixed object-oriented and functional programming styles.


Keyword messages are non-curried messages and
are more readable than simple messages when they involve complex arguments.





### Interval

An interval is an object that represents a sequence of integers.
Similar to list, but with the following differences:

- The elements of a list can be any objects, but the elements of an interval can only be integers.
- Intervals are memory efficient for long columns because they consist of only three attributes:
    - `current`: current value
    - `stop`: stop value
    - `step`: step value
- Intervals can be used not only to represent data, but also to control repetition. for example,
    - The procedural loop processing `for (i = 1 ; i <= 10 ; i++) { ... }` in C language
    - uses intervals to `[1 .. 10].for-each { i -> ... }` is written.



#### Makeing interval object

##### (1) By interval-expression

```
umu:1> [1 .. 10]
val it : Interval = [1 .. 10 (+1)]
umu:2> [1, 3 .. 10]
val it : Interval = [1 .. 10 (+2)]
umu:3> it.contents
val it : Named = (current:1 stop:10 step:2)
```

##### (2) By send-expression to instance object

###### (2-1) Binary instance message

Send binary instance message 'Int#to : Int -> Interval'

```
umu:1> 1.to 10
val it : Interval = [1 .. 10 (+1)]
umu:2> 1.to
fun it = #<{ %x_1 -> (%r).(to %x_1) }>
umu:3> it 10
val it : Interval = [1 .. 10 (+1)]
umu:4>
```

Send binary instance message 'Int#to-by : Int -> Int -> Interval'

```
umu:1> 1.to-by 10 2
val it : Interval = [1 .. 10 (+2)]
umu:2> 1.to-by
fun it = #<{ %x_1 %x_2 -> (%r).(to-by %x_1 %x_2) }>
umu:3> it 10
fun it = #<{ %x_2 -> (%r).(to-by %x_1 %x_2) }>
umu:4> it 2
val it : Interval = [1 .. 10 (+2)]
umu:5>
```

###### (2-2) Keyword instance message

Send keyword instance message 'Int#(to:Int) -> Interval' and
'Int#(to:Int by:Int) -> Interval'

```
umu:1> 1.(to:10)
val it : Interval = [1 .. 10 (+1)]
umu:2> 1.(to:10 by:2)
val it : Interval = [1 .. 10 (+2)]
umu:3>
```

##### (3) By send-expression to class object

###### (3-1) Binary class message

Send binary class message '&Interval.make : Int -> Int -> Interval'

```
umu:1> &Interval.make 1 10
val it : Interval = [1 .. 10 (+1)]
umu:2> &Interval.make
fun it = #<{ %x_1 %x_2 -> (%r).(make %x_1 %x_2) }>
umu:3> it 1
fun it = #<{ %x_2 -> (%r).(make %x_1 %x_2) }>
umu:4> it 10
val it : Interval = [1 .. 10 (+1)]
umu:5>
```

Send binary class message '&Interval.make-by : Int -> Int -> Int -> Interval'

```
umu:1> &Interval.make-by 1 10 2
val it : Interval = [1 .. 10 (+2)]
umu:2> &Interval.make-by
fun it = #<{ %x_1 %x_2 %x_3 -> (%r).(make-by %x_1 %x_2 %x_3) }>
umu:3> it 1
fun it = #<{ %x_2 %x_3 -> (%r).(make-by %x_1 %x_2 %x_3) }>
umu:4> it 10
fun it = #<{ %x_3 -> (%r).(make-by %x_1 %x_2 %x_3) }>
umu:5> it 2
val it : Interval = [1 .. 10 (+2)]
umu:6>
```

###### (3-2) Keyword class message

Send keyword class message '&Interval.(from:Int to:Int) -> Interval' and
'&Interval.(from:Int to:Int by:Int) -> Interval'

```
umu:1> &Interval.(from:1 to:10)
val it : Interval = [1 .. 10 (+1)]
umu:2> &Interval.(from:1 to:10 by:2)
val it : Interval = [1 .. 10 (+2)]
umu:3>
```

#### Operation to interval object

Like lists, intervals are a type of collection called morphs,
so they can respond to the same messages as lists.

```
umu:1> [1 .. 10].to-list
val it : Cons = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
umu:2> [1, 3 .. 10].to-list
val it : Cons = [1, 3, 5, 7, 9]
umu:3> [1 .. 10].select odd?
val it : Cons = [1, 3, 5, 7, 9]
umu:4> [1 .. 10].map to-s
val it : Cons = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
umu:5> [1 .. 10].select odd?.map to-s
val it : Cons = ["1", "3", "5", "7", "9"]
umu:6> [1 .. 3].for-each print
1
2
3
val it : Unit = ()
umu:7>
```

### List Comprehension

```
umu:1> [|x| val x <- [1 .. 10]]
val it : Cons = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
umu:2> [|x| val x <- [1 .. 10] if odd? x]
val it : Cons = [1, 3, 5, 7, 9]
umu:3> [|to-s x| val x <- [1 .. 10] ]
val it : Cons = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
umu:4> [|to-s x| val x <- [1 .. 10] if odd? x]
val it : Cons = ["1", "3", "5", "7", "9"]
```

```
umu:1> [|k, v| val k <- [@a, @b] val v <- [1 .. 3]]
val it : Cons = [(@a, 1), (@a, 2), (@a, 3), (@b, 1), (@b, 2), (@b, 3)]
umu:2> [|k: v:| val k <- [@a, @b] val v <- [1 .. 3]]
val it : Cons = [(k:@a v:1), (k:@a v:2), (k:@a v:3), (k:@b v:1), (k:@b v:2), (k:@b v:3)]
umu:3>
```

For  advanced usage of the list comprehension,
please refer to the [database examples](https://github.com/takomachan/umu/tree/main/example/database).



## Inside of Interpreter

See [TmDoc](http://xtmlab.com/umu/tmdoc/html/).



## License

The gem is available as open source under the terms of
the [MIT License](https://opensource.org/licenses/MIT).
