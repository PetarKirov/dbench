# DBench

A workbench for measuring compile-time, run-time and binary size of D programs.

Examples:
```
dub run -q -- --test-dir=./benchmarks/dbg_log/ --compilers=dmd,ldc2
Name,Semantic,Compile,Compile & Link,Run Time,Size,Compiler,Flags
dbg_log.ex1,214ms,239ms,307ms,1292ms,307728,dmd 2.085.1,-defaultlib=libphobos2.so -debug=my_domain -I./benchmarks/ -i
dbg_log.ex2,299ms,345ms,427ms,491ms,685056,dmd 2.085.1,-defaultlib=libphobos2.so -debug=my_domain -I./benchmarks/ -i
dbg_log.ex3,211ms,237ms,305ms,596ms,326248,dmd 2.085.1,-defaultlib=libphobos2.so -debug=my_domain -I./benchmarks/ -i
dbg_log.ex4,212ms,250ms,307ms,576ms,334152,dmd 2.085.1,-defaultlib=libphobos2.so -debug=my_domain -I./benchmarks/ -i
dbg_log.ex1,240ms,496ms,533ms,1181ms,322696,ldc2 1.16.0,-link-defaultlib-shared -d-debug=my_domain -I./benchmarks/ -i
dbg_log.ex2,338ms,1145ms,1236ms,377ms,487344,ldc2 1.16.0,-link-defaultlib-shared -d-debug=my_domain -I./benchmarks/ -i
dbg_log.ex3,241ms,671ms,708ms,477ms,434864,ldc2 1.16.0,-link-defaultlib-shared -d-debug=my_domain -I./benchmarks/ -i
dbg_log.ex4,241ms,976ms,1034ms,501ms,655544,ldc2 1.16.0,-link-defaultlib-shared -d-debug=my_domain -I./benchmarks/ -i
```

|Name       |Semantic|Compile|Compile & Link|Run Time|Size  |Compiler   |Flags                                                        |
|-----------|--------|-------|--------------|--------|------|-----------|-------------------------------------------------------------|
|dbg_log.ex1|214ms   |239ms  |307ms         |1292ms  |307728|dmd 2.085.1|-defaultlib=libphobos2.so -debug=my_domain -I./benchmarks/ -i|
|dbg_log.ex2|299ms   |345ms  |427ms         |491ms   |685056|dmd 2.085.1|-defaultlib=libphobos2.so -debug=my_domain -I./benchmarks/ -i|
|dbg_log.ex3|211ms   |237ms  |305ms         |596ms   |326248|dmd 2.085.1|-defaultlib=libphobos2.so -debug=my_domain -I./benchmarks/ -i|
|dbg_log.ex4|212ms   |250ms  |307ms         |576ms   |334152|dmd 2.085.1|-defaultlib=libphobos2.so -debug=my_domain -I./benchmarks/ -i|
|dbg_log.ex1|240ms   |496ms  |533ms         |1181ms  |322696|ldc2 1.16.0|-link-defaultlib-shared -d-debug=my_domain -I./benchmarks/ -i|
|dbg_log.ex2|338ms   |1145ms |1236ms        |377ms   |487344|ldc2 1.16.0|-link-defaultlib-shared -d-debug=my_domain -I./benchmarks/ -i|
|dbg_log.ex3|241ms   |671ms  |708ms         |477ms   |434864|ldc2 1.16.0|-link-defaultlib-shared -d-debug=my_domain -I./benchmarks/ -i|
|dbg_log.ex4|241ms   |976ms  |1034ms        |501ms   |655544|ldc2 1.16.0|-link-defaultlib-shared -d-debug=my_domain -I./benchmarks/ -i|


```
env CC=clang dub run -q -- --test-dir=./benchmarks/dbg_log/ --compilers=$REPOS/d/dlang/dmd/generated/linux/release/64/dmd,$REPOS/d/install-ldc/bin/ldc2 > out.txt
```

| Name        | Semantic | Compile | Compile & Link | Run Time | Size   | Compiler                          | Flags                                                            |
|-------------|----------|---------|----------------|----------|--------|-----------------------------------|------------------------------------------------------------------|
| dbg_log.ex1 | 228ms    | 256ms   | 368ms          | 1447ms   | 271216 | dmd 2.088.1-beta.1-269-g663a22e2a | -defaultlib=libphobos2.so -debug=my_domain -I./benchmarks/ -i    |
| dbg_log.ex2 | 326ms    | 373ms   | 456ms          | 513ms    | 594760 | dmd 2.088.1-beta.1-269-g663a22e2a | -defaultlib=libphobos2.so -debug=my_domain -I./benchmarks/ -i    |
| dbg_log.ex3 | 202ms    | 226ms   | 326ms          | 583ms    | 276832 | dmd 2.088.1-beta.1-269-g663a22e2a | -defaultlib=libphobos2.so -debug=my_domain -I./benchmarks/ -i    |
| dbg_log.ex4 | 198ms    | 228ms   | 327ms          | 581ms    | 276528 | dmd 2.088.1-beta.1-269-g663a22e2a | -defaultlib=libphobos2.so -debug=my_domain -I./benchmarks/ -i    |
| dbg_log.ex1 | 205ms    | 297ms   | 397ms          | 1333ms   | 271216 | dmd 2.088.1-beta.1-269-g663a22e2a | -O -defaultlib=libphobos2.so -debug=my_domain -I./benchmarks/ -i |
| dbg_log.ex2 | 291ms    | 409ms   | 522ms          | 494ms    | 602952 | dmd 2.088.1-beta.1-269-g663a22e2a | -O -defaultlib=libphobos2.so -debug=my_domain -I./benchmarks/ -i |
| dbg_log.ex3 | 220ms    | 332ms   | 431ms          | 556ms    | 276832 | dmd 2.088.1-beta.1-269-g663a22e2a | -O -defaultlib=libphobos2.so -debug=my_domain -I./benchmarks/ -i |
| dbg_log.ex4 | 212ms    | 315ms   | 424ms          | 525ms    | 276528 | dmd 2.088.1-beta.1-269-g663a22e2a | -O -defaultlib=libphobos2.so -debug=my_domain -I./benchmarks/ -i |
| dbg_log.ex1 | 219ms    | 1256ms  | 1310ms         | 682ms    | 268304 | ldc2 1.18.0-git-ad400ff           | -O -link-defaultlib-shared -d-debug=my_domain -I./benchmarks/ -i |
| dbg_log.ex2 | 310ms    | 2238ms  | 2320ms         | 383ms    | 315368 | ldc2 1.18.0-git-ad400ff           | -O -link-defaultlib-shared -d-debug=my_domain -I./benchmarks/ -i |
| dbg_log.ex3 | 228ms    | 19574ms | 20261ms        | 393ms    | 372912 | ldc2 1.18.0-git-ad400ff           | -O -link-defaultlib-shared -d-debug=my_domain -I./benchmarks/ -i |
| dbg_log.ex4 | 221ms    | 11998ms | 13279ms        | 353ms    | 323640 | ldc2 1.18.0-git-ad400ff           | -O -link-defaultlib-shared -d-debug=my_domain -I./benchmarks/ -i |
| dbg_log.ex1 | 215ms    | 440ms   | 499ms          | 1182ms   | 282832 | ldc2 1.18.0-git-ad400ff           | -link-defaultlib-shared -d-debug=my_domain -I./benchmarks/ -i    |
| dbg_log.ex2 | 314ms    | 1044ms  | 1117ms         | 385ms    | 398912 | ldc2 1.18.0-git-ad400ff           | -link-defaultlib-shared -d-debug=my_domain -I./benchmarks/ -i    |
| dbg_log.ex3 | 215ms    | 617ms   | 687ms          | 474ms    | 378960 | ldc2 1.18.0-git-ad400ff           | -link-defaultlib-shared -d-debug=my_domain -I./benchmarks/ -i    |
| dbg_log.ex4 | 217ms    | 914ms   | 992ms          | 526ms    | 591680 | ldc2 1.18.0-git-ad400ff           | -link-defaultlib-shared -d-debug=my_domain -I./benchmarks/ -i    |

