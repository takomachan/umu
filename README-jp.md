# Umu - 関数型スクリプト言語

## インストール

$ git clone https://github.com/takomachan/umu

> [!NOTE]
> Umuという名称は暫定的なものであり、公式のGemパッケージが公開される時には新しい名前が与えられる予定です。
>
> 泳げる頃にはGemパッケージ版が見られるでしょう。


## REPLの使いかた

> [!NOTE]
> この章は別の文書「ユーザーガイド」に移行される予定です。

### 最初の一歩
```
$ umu/exe/umu -i
umu:1> print "Hello world\n"
Hello world

val it : Unit = ()
umu:2>                  # [Ctrl]+[D]を入力
$
```

### スクリプトを付けてREPLを起動
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

### REPLのサブコマンド

#### :class

##### 概要

クラス間の継承(インヘリタンス)関係を階層的に表示します。

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

##### 詳細

指定されたクラスの情報とそのクラスが応答できるメッセージの一覧を表示します。

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

インタプリタは入力されたスクリプトを以下の流れで処理します。

```
/ソース・スクリプト/ ->
    <字句解析> -> [トークンの並び] ->
    <構文解析> -> [具象構文木] ->
    <脱糖化>   -> [抽象構文木] ->
    <評価> ->
/結果(環境と値)/
```

この処理の過程で生成される中間オブジェクトである：
- トークンの並び(tokens)
- 具象構文木(soncrete syntax tree)
- 抽象構文木(abstract syntax tree)

を表示します。

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

インタプリタ内部の脱糖化(desugaring)処理と評価(evaluation)処理について、
その過程を階層的な軌跡(trace)で表示します。

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


## 実行例

> [!NOTE]
> この章は別の文書「プログラミングガイド」に移行される予定です。

### 式と値

#### アトム

##### 整数
```
umu:1> 3
val it : Int = 3
umu:2> 3 + 4
val it : Int = 7
umu:3>
```

##### 小数
```
umu:1> 3.0
val it : Float = 3.0
umu:2> 3.0 + 4.0
val it : Float = 7.0
umu:3>
```

##### 文字列
```
umu:1> "Hello"
val it : String = "Hello"
umu:2> "Hello" ^ " world"
val it : String = "Hello world"
umu:3>
```

##### シンボル
```
umu:1> @hello
val it : Symbol = @hello
umu:2> to-s @hello
val it : String = "hello"
umu:3> show @hello
val it : String = "@hello"
umu:4>
```

##### 論理値
```
umu:1> TRUE
val it : Bool = TRUE
umu:2> 3 == 3
val it : Bool = TRUE
umu:3> 3 == 4
val it : Bool = FALSE
umu:4>
```

### ラムダ式と関数定義

### ラムダ式
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

### 関数定義

#### 単純な関数

宣言 `val` は値(value)を識別子(identifier)に束縛(bind)します。
ここで、その値は関数オブジェクト(function object)です。

```
umu:1> val add = { x y -> x + y }
fun add = #<{ x y -> (+ x y) }>
umu:2> add 3 4
val it : Int = 7
umu:3>
```

宣言 `fun` は関数オブジェクトの束縛に関する構文糖(syntax sugar)です。

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


#### 再帰関数

再帰関数(recursive function)は宣言 `fun rec` で定義します。

```
umu:1> fun rec factorial = x -> (    # 'umu/example/factorial.umu'をコピー＆ペースト
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


### 関数適用とメッセージ送信

```
umu:1> 3 + 4             # 中置演算子式
val it : Int = 7
umu:2> (+) 3 4           # 関数オブジェクトとしての中置演算子
val it : Int = 7
umu:3> ((+) 3) 4         # 第一引数の部分適用
val it : Int = 7
umu:4> (+ 4) 3           # 第二引数の部分適用
val it : Int = 7
```

```
umu:5> 3.(+ 4)           # 二項メッセージ '+4' を整数オブジェクト 3 へ送信
val it : Int = 7
umu:6> 3.+ 4             # カッコは省略できます
val it : Int = 7
umu:7> (3.+) 4           # 二項メッセージのキーワード '+' だけを送信
val it : Int = 7
umu:8> &(+) 3 4          # 関数オブジェクトとしての二項メッセージ
val it : Int = 7
umu:9> (&(+) 3) 4        # 第一引数の部分適用
val it : Int = 7
```

```
umu:10> (+).apply-binary 3 4    # 関数オブジェクトに適用メッセージを送信
val it : Int = 7
umu:11> (+).[3, 4]       # 別の適用メッセージ記法(構文糖)
val it : Int = 7
```


### メッセージチェイン、パイプライン適用そして関数合成

edvakf様のブログ記事「[PythonでもRubyみたいに配列をメソッドチェーンでつなげたい](https://edvakf.hatenadiary.org/entry/20090405/1238885788)」を参照。

#### (1) メッセージチェイン

オブジェクト指向プログラミング(object oriented programming, OOP)スタイル

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

#### (2) パイプライン適用

F#, Ocaml, Scala, Elixir ... のように

```
umu:1> [1, 4, 3, 2] |> sort |> reverse |> map to-s |> join-by "-"
val it : String = "4-3-2-1"
umu:2>
```

#### (2') もう一つのパイプライン適用

Haskellの $-演算子のように

```
umu:1> join-by "-" <| map to-s <| reverse <| sort [1, 4, 3, 2]
val it : String = "4-3-2-1"
umu:2>
```

#### (3) 関数合成

```
umu:1> (sort >> reverse >> map to-s >> join-by "-") [1, 4, 3, 2]
val it : String = "4-3-2-1"
umu:2> [1, 4, 3, 2] |> sort >> reverse >> map to-s >> join-by "-"
val it : String = "4-3-2-1"
umu:3>
```

#### (3') もう一つの関数合成

Haskellのポイントフリースタイル(point free style)のように

```
umu:1> (join-by "-" << map to-s << reverse << sort) [1, 4, 3, 2]
val it : String = "4-3-2-1"
umu:2> join-by "-" << map to-s << reverse << sort <| [1, 4, 3, 2]
val it : String = "4-3-2-1"
umu:3>
```

#### (4) 伝統的な入れ子になった関数適用

LISP, Python, ... のように

```
umu:1> join-by "-" (map to-s (reverse (sort [1, 4, 3, 2])))
val it : String = "4-3-2-1"
umu:2>
```


### インターバル

#### インターバルオブジェクトの生成

##### (1) インターバル式で

```
umu:1> [1 .. 10]
val it : Interval = [1 .. 10 (+1)]
umu:2> [1, 3 .. 10]
val it : Interval = [1 .. 10 (+2)]
```

##### (2) インスタンスオブジェクトへの送信式で

###### (2-1) 二項インスタンスメッセージ

二項インスタンスメッセージ `Int#to` を送信

```
umu:1> 1.to 10
val it : Interval = [1 .. 10 (+1)]
umu:2> 1.to
fun it = #<{ %x_1 -> (%r).(to %x_1) }>
umu:3> it 10
val it : Interval = [1 .. 10 (+1)]
umu:4>
```

二項インスタンスメッセージ `Int#to-by` を送信

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

###### (2-2) キーワードインスタンスメッセージ

キーワードインスタンスメッセージ `Int#(to:)` と `Int#(to:by:)` を送信

```
umu:1> 1.(to:10)
val it : Interval = [1 .. 10 (+1)]
umu:2> 1.(to:10 by:2)
val it : Interval = [1 .. 10 (+2)]
umu:3>
```

##### (3) クラスオブジェクトへの送信式で

###### (3-1) 二項クラスメッセージ

二項クラスメッセージ `Interval.make` を送信

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

二項クラスメッセージ `Interval.make-by` を送信

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

###### (3-2) キーワードクラスメッセージ

キーワードクラスメッセージ `Interval.(from:to:)` と `Interval.(from:to:by:)` を送信

```
umu:1> &Interval.(from:1 to:10)
val it : Interval = [1 .. 10 (+1)]
umu:2> &Interval.(from:1 to:10 by:2)
val it : Interval = [1 .. 10 (+2)]
umu:3>
```

#### インターバルオブジェクトの操作

インターバルはリストと同じくコレクションの一種です。

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

### リスト内包表記

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

リスト内包表記の高度な使いかたは：
- [データベースの例](https://github.com/takomachan/umu/tree/main/example/database)
を参照してください。


## インタプリタの内部実装

[TmDoc](http://xtmlab.com/umu/tmdoc/html/)を参照



## ライセンス

The gem is available as open source under the terms of
the [MIT License](https://opensource.org/licenses/MIT).
