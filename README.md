# DBench

A workbench for measuring compile-time, run-time and binary size of D programs.

Example:
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
