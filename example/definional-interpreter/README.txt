Implementation of REYNOLDS's Definional Interpreter

レイノルズ氏による意味定義用インタプリタの実装


 Reynolds, J. C. :
   Definitional Interpreters
   for Higher-Oreder Programming Languages,
   Higer-Order and Symbolic Computation, 11, 363-397 (1998),
   Proceedings of 25h ACM National Conference, 1971, pp. 717-740

   https://homepages.inf.ed.ac.uk/wadler/papers/papers-we-love/reynolds-definitional-interpreters-1998.pdf
   https://homepages.inf.ed.ac.uk/wadler/papers/papers-we-love/reynolds-definitional-interpreters-1972.pdf

 木村泉, 米澤明憲 :
   第9章 算法表現(プログラム)の意味論,
   算法表現論, 岩波講座情報科学12, 岩波書店, 1982
       上記論文のInterpreter I と II を元にして
       プログラミング言語の古典的な意味論を解説している

    [岩波書店] https://www.iwanami.co.jp/book/b475566.html
    [Amazon]   https://www.amazon.co.jp/dp/B000J7P0KY


The current Umu language processing system (interpreter) was
designed based on this Interpreter II.

現在のUmu言語処理系(インタプリタ)は
この Interpreter II を元に設計された


Exanple execution :
実行例 :
    $ rake repl
      ^^^^^^^^^
    [CONSTANT]
    <SRC> : 100
    <EXP> : Const 100
    -> <VAL> : Integer 100
            :
            :
            :  (running tests)
            :
            :
    umu:1> run-I [ADD, 3, 4]
           ^^^^^^^^^^^^^^^^^
    <SRC> : [@ADD, 3, 4]
    <EXP> : Appl (Appl (Var @ADD, Const 3), Const 4)
    -> <VAL> : Integer 7
    
    -> Integer 7 : Datum
    umu:2>

