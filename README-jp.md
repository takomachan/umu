# Umu - 関数型スクリプト言語

## 特徴

- オブジェクト指向と関数型という二つのプログラミングスタイルが利用できます
- 貪欲(eager)で不純(impure)ですが、原則は不変(immutable)です
- 動的型付け(dynamic typing)です
- あらゆる関数と多くのメッセージは最初からカリー化されています
- インタプリタは標準ライブラリだけを使用して100% Rubyで実装されています
- 速度よりも表現力を




## 言語設計の背景

以下の言語から強い影響を受けており、いたるところで影響の形跡を見かけることができます。

- `Standard ML`
- `Ruby`
- `Smalltalk`

また以下の言語から弱い影響を受けており、選択的にアイデアを採用しています。

- `Swift`
    - 名前付きタプル
- `Haskell`
    - モナド(monad)の概念 --- 予定
- `Miranda`(`KRC`)
    - リスト内包表記、カリー化を想定した関数型ライブラリ設計
- `Lisp`
    - ハイフン `'-'` が使える識別子の字句定義
    - [データム](https://sicp.iijlab.net/fulltext/x242.html)の概念
    - 継続(continuation)の概念 --- 予定
- `Prolog`
    - アトム、シンボル、そしてタプルの概念
    - 縦棒 `'|'` を用いたリストの構成と分解操作に関する構文: `'[' x '|' xs ']' `
    - ファイル関連オブジェクト操作の命名: `see`、 `seen`、 `tell` そして `told`
- `Logo`
    - S式ではない具象構文で定義された関数型言語、という発想 --- 姿を変えて復活した[LISP 2](https://en.wikipedia.org/wiki/LISP_2)
    - タートルグラフィックス --- 予定
- `C`
    - 波かっこ `'{' ... '}'` を多用する具象構文(1980年代の `Pascal vs. C` 論争)
- 1980年代の非構造化`Basic`
    - リファレンスオブジェクト操作の命名: `peek` と `poke`




## インストール

$ git clone https://github.com/takomachan/umu

> [!NOTE]
> Umuという名称は暫定的なものであり、Gemパッケージが公開される時には新しい名前が与えられる予定です。
>
> 泳げる頃にはGemパッケージ版が見られるでしょう。




## REPLの使いかた

> [!NOTE]
> この章は別の文書「ユーザーガイド」に移行される予定です。

### 最初の一歩
```
$ umu/exe/umu -i
umu:1> print "Hello world"
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

#### :dump と :nodump

インタプリタは入力されたスクリプトを以下の流れで処理します。

```
/ソース(スクリプト)/ ->
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
0002: INT(3) SP '+' SP INT(4) NL("\n")

________ Concrete Syntax: #2 in "<stdin>" ________
(3 + 4)

________ Abstract Syntax: #2 in "<stdin>" ________
(+ 3 4)

val it : Int = 7
umu:3> :nodump
umu:4>
```

#### :trace と :notrace

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

#### ラムダ式
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

#### 関数定義

##### 単純な関数

宣言 `val` は値(value)を識別子(identifier)に束縛(bind)します。
ここで、その値は関数オブジェクト(function object)です。

```
umu:1> val add = { x y -> x + y }
fun add = #<{ x y -> (+ x y) }>
umu:2> add 3 4
val it : Int = 7
umu:3>
```

宣言 `fun` は関数オブジェクトの束縛に関する構文糖(syntactic sugar)です。

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


##### 再帰関数

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


### メッセージ

メッセージは以下のように分類されます。

- インスタンスメッセージ
    - 単純インスタンスメッセージ
        - 単項インスタンスメッセージ
            - [例] Int#to-s : String
            - [例] Bool#not : Bool
            - [例] List#join : String
        - 二項インスタンスメッセージ
            - [例] Int#+ : Int -> Int
            - [例] Int#to : Int -> Interval
            - [例] String#^ : String -> String
            - [例] List#cons : Top -> List
            - [例] List#join-by : String -> String
            - [例] Fun#apply : Top -> Top
        - 多項インスタンスメッセージ
            - [例] Int#to-by : Int -> Int -> Interval
            - [例] List#foldr : Top -> Fun -> Top
            - [例] Fun#apply-binary : Top -> Top -> Top
            - [例] Fun#apply-nary : Top -> Top -> Morph -> Top
    - キーワードインスタンスメッセージ
        - [例] Int#(to:Int) -> Interval
        - [例] Int#(to:Int by:Int) -> Interval
        - [例] List#(join:String) -> String
- クラスメッセージ
    - 単純クラスメッセージ
        - [例] &Bool.true : Bool
        - [例] &Float.nan : Float
        - [例] &Some.make : Top -> Some
        - [例] &Datum.make : Symbol -> Top -> Datum
        - [例] &List.cons : Top -> Morph -> Morph
        - [例] &Interval.make : Int -> Int -> Interval
        - [例] &Interval.make-by : Int -> Int -> Int -> Interval
    - キーワードクラスメッセージ
        - [例] &Datum.(tag:Symbol contents:Top) -> Datum
        - [例] &List.(head:Top tail:Morph) -> Morph
        - [例] &Interval.(from:Int to:Int) -> Interval
        - [例] &Interval.(from:Int to:Int by:Int) -> Interval


#### インスタンスメッセージとクラスメッセージ

インスタンスメッセージは普通のメッセージです。

クラスメッセージはクラス式 `&Foo` で生成されるクラスオブジェクトへのメッセージです。
これは多くの場合、以下の目的で用いられます。

- あるクラスからインスタンスを生成するオブジェクト構成子(object constructor)を提供
- 非オブジェクト指向な手続き型言語/関数型言語におけるライブラリ関数やシステムコールを提供

> [!NOTE]
> 現在、JavaやRubyで見かけるインスタンス生成の予約語 `new` は、定義されていますが使われていません。
> 将来、クラスのユーザー定義機能が提供される時、`new Foo x` という文法で使われるようになる予定です。


#### 単純メッセージとキーワードメッセージ

単純メッセージはカリー化されるメッセージであり、オブジェクト指向と関数型を混在したプログラミングスタイルに適しています。

キーワードメッセージはカリー化されないメッセージであり、複雑な引数を伴うメッセージでは単純メッセージよりも可読性が優れています。



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
umu:11> (+).[3, 4]       # もう一つの適用メッセージ記法(構文糖)
val it : Int = 7
```



### メッセージチェイン、パイプライン適用そして関数合成

ここで解説するプログラム表現の考察は、edvakfさんのブログ記事:
[PythonでもRubyみたいに配列をメソッドチェーンでつなげたい](https://edvakf.hatenadiary.org/entry/20090405/1238885788) 
を出発点としています。


#### (1) メッセージチェイン

オブジェクト指向プログラミングの標準的なスタイルであり、
複数のメッセージを送信式で繋ぐ(chain)ことによって、
左から右へと流れるようなコードが書けます。

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

F#, Ocaml, Scala, Elixir のように ...

関数型プログラミングのスタイルの一つであり、
一つの式と複数の関数をパイプライン演算子 `|>` で連結(concatenate)することによって、
左から右へと流れるようなコードが書けます。

```
umu:1> [1, 4, 3, 2] |> sort |> reverse |> map to-s |> join-by "-"
val it : String = "4-3-2-1"
umu:2>
```

#### (2') もう一つのパイプライン適用

(2) と似ていますが、こちらは値がパイプラインを右から左へと流れます。

このスタイルは、あまりに過剰なカッコに疲れ果てている全世界のプログラマーにとって、救いの手となるでしょう。

特に `Haskell` だとパイプライン演算子は標準演算子 `$` として定義され、好んで広く使われています。

```
umu:1> join-by "-" <| map to-s <| reverse <| sort [1, 4, 3, 2]
val it : String = "4-3-2-1"
umu:2>
```

#### (3) 関数合成

ここまで述べたメッセージチェインやパイプライン適用といったプログラミング技法よりも更に視点を上に向け、
設計技法として「コードの部品化と再利用」を推進するのが関数合成です。

以下の例では、４個の部品 `sort`、 `reverse`、 `map to-s` そして`join-by "-"` について、
関数合成演算子 `>>` で左から右へと合成し、完成した関数オブジェクトを `f` として定義しています。

```
umu:1> val f = sort >> reverse >> map to-s >> join-by "-"
fun f = #<{ %x -> (%x |> sort |> reverse |> (map to-s) |> (join-by "-")) }>
umu:2> f [1, 4, 3, 2]
val it : String = "4-3-2-1"
umu:3
```

#### (3') もう一つの関数合成

(3) と似ていますが、こちらは関数合成演算子 `<<` で部品を右から左へ合成します。

`Haskell` だと関数合成演算子は標準演算子 `.` として定義され、
このスタイルがポイントフリースタイル(point free style)と命名されるほど広く知られ、
好んで使われています。

```
umu:1> val f = join-by "-" << map to-s << reverse << sort
fun f = #<{ %x -> (%x |> sort |> reverse |> (map to-s) |> (join-by "-")) }>
umu:2> f [1, 4, 3, 2]
val it : String = "4-3-2-1"
umu:3>
```

#### (4) 伝統的な入れ子になった関数適用

Lisp, Python, Pascal, Fortran のように ...

科学技術計算のような数値関数ライブラリであれば、あえて伝統的なスタイルを採用することも検討すべきでしょう。

```
umu:1> join-by "-" (map to-s (reverse (sort [1, 4, 3, 2])))
val it : String = "4-3-2-1"
umu:2>
```



### インターバル

インターバル(interval, 間隔)は整数の列を表現するオブジェクトです。
リストと似ていますが、以下に示す違いがあります。

- リストの要素は任意のオブジェクトですが、インターバルの要素は整数に限られます。
- インターバルは以下の３つの属性だけから構成されているので、長い列ではメモリ効率が優れています。
    - current: 現在値
    - stop: 停止値
    - step: 間隔値
- インターバルは単なるデータ表現だけでなく、反復制御に用いることができます。たとえば、
    - C言語の `for (i = 1 ; i <= 10 ; i++) { ... }` という手続き型のループ処理は、
    - インターバルを使って `[1 .. 10].for-each { i -> ... }` と書きます。 


#### インターバルオブジェクトの生成

##### (1) インターバル式で

```
umu:1> [1 .. 10]
val it : Interval = [1 .. 10 (+1)]
umu:2> [1, 3 .. 10]
val it : Interval = [1 .. 10 (+2)]
umu:3> it.contents
val it : Named = (current:1 stop:10 step:2)
umu:4>
```

##### (2) インスタンスオブジェクトへの送信式で

###### (2-1) 二項インスタンスメッセージ

二項インスタンスメッセージ `Int#to : Int -> Interval` を送信

```
umu:1> 1.to 10
val it : Interval = [1 .. 10 (+1)]
umu:2> 1.to
fun it = #<{ %x_1 -> (%r).(to %x_1) }>
umu:3> it 10
val it : Interval = [1 .. 10 (+1)]
umu:4>
```

多項インスタンスメッセージ `Int#to-by : Int -> Int -> Interval` を送信

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

キーワードインスタンスメッセージ `Int#(to:Int) -> Interval` と `Int#(to:Int by:Int) -> Interval` を送信

```
umu:1> 1.(to:10)
val it : Interval = [1 .. 10 (+1)]
umu:2> 1.(to:10 by:2)
val it : Interval = [1 .. 10 (+2)]
umu:3>
```

##### (3) クラスオブジェクトへの送信式で

###### (3-1) 単純クラスメッセージ

単純クラスメッセージ `&Interval.make : Int -> Int -> Interval` を送信

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

単純クラスメッセージ `&Interval.make-by : Int -> Int -> Int -> Interval` を送信

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

キーワードクラスメッセージ `&Interval.(from:Int to:Int) -> Interval` と
`&Interval.(from:Int to:Int by:Int) -> Interval` を送信

```
umu:1> &Interval.(from:1 to:10)
val it : Interval = [1 .. 10 (+1)]
umu:2> &Interval.(from:1 to:10 by:2)
val it : Interval = [1 .. 10 (+2)]
umu:3>
```

#### インターバルオブジェクトの操作

インターバルはリストと同じくモルフ(morph)と呼ばれるコレクションの一種ですから、
リストと同様なメッセージに応答できます。

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

リスト内包表記の高度な使いかたは
[データベースの例](example/database)
を参照してください。


### リファレンス

リファレンス(reference, 参照)は可変(mutable)なメモリ領域を表現するオブジェクトです。
ここまで、ある変数に値を割り当てる操作を束縛(binding)と呼んできました。
これは関数型言語では一般的ですが、手続き型言語では以下に示す別の視点で変数に値を割り当てます。

- 「変数」とは、メモリ領域へ紐付けた名札(label, ラベル)である
- 「変数の値」とは、変数で指定されるメモリ領域から保存されている値を読み出す操作である
- 「変数に値を割り当てる」とは、値を変数で指定されるメモリ領域へ書き込む操作である

この仕組みは破壊的代入(destructive assignment)と呼ばれています。

この破壊的代入をオブジェクト指向で実装したものがリファンスオブジェクトであり、
以下のメッセージに対して応答します。

- &Ref.make : Top -> Ref    --- 引数を初期値とするメモリ領域を１つ確保し、それをリファレンスで返す
- Ref#peek! : Top           --- リファレンスが持つメモリ領域に保存されている値を読み出し、それを返す
- Ref#poke! : Top -> Unit   --- 引数の値をリファレンスが持つメモリ領域へ書き込む

```
umu:1> val rx = &Ref.make 3        # 3 を初期値とするリファレンスを定義
val rx : Ref = #Ref<3>
umu:2> rx.peek!                    # リファレンスから現在の値を読み出す ==> 3
val it : Int = 3
umu:3> rx.peek!.+ 4 |> rx.poke!    # 現在の値に 4 を足し、その結果をリファレンスへ書き込む
val it : Unit = ()
umu:4> rx.peek!                    # リファレンスから現在の値を読み出す ==> 7
val it : Int = 7
umu:5>
```

単純な機能(service)ですが、冗長です。
そこで、これらのメッセージを抽象化した標準関数 `ref` および標準演算子 `!!` と `:=` を提供します。

```
umu:1> val rx = ref 3                # 3 を初期値とするリファレンスを定義
val rx : Ref = #Ref<3>
umu:2> !!rx                          # リファレンスから現在の値を読み出す ==> 3
val it : Int = 3
umu:3> rx := !!rx + 4                # 現在の値に 4 を足し、その結果をリファレンスへ書き込む
val it : Unit = ()
umu:4> !!rx                          # リファレンスから現在の値を読み出す ==> 7
val it : Int = 7
umu:5>
```

```
umu:1> val rx = ref 3                # 3 を初期値とするリファレンス rx を定義
val rx : Ref = #Ref<3>
umu:2> val ry = ref 4                # 4 を初期値とするリファレンス ry を定義
val ry : Ref = #Ref<4>
umu:3> !!rx + !!ry                   # リファレンス rx から読み出した値と同 ry から読み出した値を足す
val it : Int = 7
umu:4>
```

破壊的代入に興味を持たれたなら、`Lisp` を使ったコンピュータサイエンスの教科書である
[SICP](https://sicp.iijlab.net/) の [節 3.1 代入と局所状態](https://sicp.iijlab.net/fulltext/x310.html)
を参照してください。
またリファレンスを使うよう書き改めたコードが [SICPの例](example/sicp//sicp-ch3.umu)　にあります。



## インタプリタ実装の内部

[TmDoc](http://xtmlab.com/umu/tmdoc/html/)を参照





## ライセンス

The gem is available as open source under the terms of
the [MIT License](https://opensource.org/licenses/MIT).
