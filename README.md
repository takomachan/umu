# Umu - Functional Scripting Language

## Installation

$ git clone https://github.com/takomachan/umu



## How to Use

### REPL
```
$ umu/exe/umu -i
umu:1> print "Hello world\n"
Hello world

val it : Unit = ()
umu:2>                  # Enter [Ctrl]+[D]
$
```

### REPL with script
```
$ cat umu/factorial.umu 
fun rec factorial = x -> (
    if x <= 1 then
        1
    else
        x * factorial (x - 1)
)
$ umu/exe/umu -i umu/factorial.umu 
umu:1> factorial 3
val it : Int = 6
umu:2>
```

### REPL's Subcommand

#### :class

##### Summary
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
```

##### Detail
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
umu:3>
```

#### :dump
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

#### :trace
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
| [Eval(Expr)] Int (ASCEUA::Number): 3 --> Int (VCBA::Number): 3
| [Eval(Expr)] Int (ASCEUA::Number): 4 --> Int (VCBA::Number): 4
| [Apply] Fun (VC): (#<+: {x : Number y : Number -> (x).(+ y)}> 3 4)
| | [Eval(Expr)] Entry (ASCEB::Send): (x).(+ y)
| | | [Eval(Expr)] Short (ASCEU::Identifier): x
| | | --> Int (VCBA::Number): 3
| | | [Eval(Expr)] Short (ASCEU::Identifier): y
| | | --> Int (VCBA::Number): 4
| | | [Invoke] Int (VCBA::Number): (3).meth_add(4 : Int) -> Int
| | | --> Int (VCBA::Number): 7
| | --> Int (VCBA::Number): 7
| --> Int (VCBA::Number): 7
--> Int (VCBA::Number): 7

val it : Int = 7
umu:3> :notrace
umu:4>
```


## Example

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
```
umu:1> val add = { x y -> x + y }
fun add = #<{ x y -> (+ x y) }>
umu:2> add 3 4
val it : Int = 7
umu:3>
```

```
umu:1> fun add' = x y -> x + y
fun add' = #<add': { x y -> (+ x y) }>
umu:2> add' 3 4
val it : Int = 7
umu:3>
```


#### Recursive function
```
umu:1> fun rec factorial = x -> (        # Copy&Paste: 'umu/factorial.umu'
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


### Function application and Sending message
```
umu:1> 3 + 4             # Infix orepator expression
val it : Int = 7
umu:2> (+) 3 4           # Infix operator as function object
val it : Int = 7
umu:3> ((+) 3) 4         # Partial application for fist parameter
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
umu:9> (&(+) 3) 4        # Partial application for fist parameter
val it : Int = 7
```

```
umu:10> (+).apply-binary 3 4    # Send apply message to function object
val it : Int = 7
umu:11> (+).[3, 4]       # Another apply message notation (syntax sugar)
val it : Int = 7
```


### Message chaining, Pipelined application and Function composition

See [PythonでもRubyみたいに配列をメソッドチェーンでつなげたい](https://edvakf.hatenadiary.org/entry/20090405/1238885788).

#### Message Chaining

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

#### Pipelined Application

like F#, Ocaml, Elixir

```
umu:1> [1, 4, 3, 2] |> sort |> reverse |> map to-s |> join-by "-"
val it : String = "4-3-2-1"
umu:2>
```

#### Another Pipelined Application

like a Haskell's $-operator

```
umu:1> join-by "-" <| map to-s <| reverse <| sort [1, 4, 3, 2]
val it : String = "4-3-2-1"
umu:2>
```

#### Function Composition

```
umu:1> (sort >> reverse >> map to-s >> join-by "-") [1, 4, 3, 2]
val it : String = "4-3-2-1"
umu:2> [1, 4, 3, 2] |> sort >> reverse >> map to-s >> join-by "-"
val it : String = "4-3-2-1"
umu:3>
```

#### Another Function Composition

like a Haskell's point-free style

```
umu:1> (join-by "-" << map to-s << reverse << sort) [1, 4, 3, 2]
val it : String = "4-3-2-1"
umu:2> join-by "-" << map to-s << reverse << sort <| [1, 4, 3, 2]
val it : String = "4-3-2-1"
umu:3>
```

#### Classical Nested Application

like LISP, Python, ... etc

```
umu:1> join-by "-" (map to-s (reverse (sort [1, 4, 3, 2])))
val it : String = "4-3-2-1"
umu:2>
```


### Interval

#### Makeing interval object

##### By interval expression

```
umu:1> [1 .. 10]
val it : Interval = [1 .. 10 (+1)]
umu:2> [1, 3 .. 10]
val it : Interval = [1 .. 10 (+2)]
```

##### By binary message expression: Interval#to

sending binary message '.to Int' to integer object

```
umu:1> 1.to 10
val it : Interval = [1 .. 10 (+1)]
umu:2> 1.to-by 10 2
val it : Interval = [1 .. 10 (+2)]
```

##### By keyword message expression: Interval#(to:)

```
umu:1> 1.(to:10)
val it : Interval = [1 .. 10 (+1)]
umu:2> 1.(to:10 by:2)
val it : Interval = [1 .. 10 (+2)]
umu:3>
```

#### Operation to interval object

Interval object is kind of collection that same to List object 

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
umu:6>
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


## Inside of Interpreter

See [TmDoc](http://xtmlab.com/umu/tmdoc/html/).



## License

The gem is available as open source under the terms of
the [MIT License](https://opensource.org/licenses/MIT).
