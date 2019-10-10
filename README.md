# DBench

A workbench for measuring compile-time, run-time and binary size of D programs.

## 1. Getting started

### 1.1 Adding new benchmarks
0. Clone to your computer: `git clone https://github.com/ZombineDev/dbench.git`
1. Create a folder inside `./benchmarks/`.
2. Add one more D source files named in the format `ex<num>.d` (where `<num>`
   should be replaced by some non-negative integer).
3. Create a `runner.d` (or `ctfe_runner.d` for CTFE-only tests), similar to the
   existing runners in the `./benchmarks/` folder.

### 1.2 Running benchmarks
1. Build `DBench`: `dub build`
2. Run the newly built executable from the `./build/` folder.
  2.1. Use the `--test-dir=` option to specify a folder containing the benchmark
  to be ran
  2.2 Use the `--compilers=` option to specify one or more compilers to test
  with:
   ```
   ./build/dbench --test-dir=./benchmarks/dbg_log --compiler=dmd,ldc
   ```
3. Optionally save the CSV output for later inspection by piping the program to
   a file.

The above can be performed with a one-liner:

```
dub run -q -- --test-dir=./benchmarks/dbg_log/ --compilers=dmd,ldc2 > out.csv
cat out.csv
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


## Misc features

### Use compilers available on the $PATH or test with custom ones

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

```
dub run -q -- --test-dir=./benchmarks/log_prefix/ --compilers=dmd | tablize
+----------------+----------+---------+----------------+----------+------+-------------+-------+
| Name           | Semantic | Compile | Compile & Link | Run Time | Size | Compiler    | Flags |
+----------------+----------+---------+----------------+----------+------+-------------+-------+
| log_prefix.ex0 | 1519ms   | 0ms     | 0ms            | 0ms      | 0    | dmd 2.085.1 |       |
| log_prefix.ex1 | 877ms    | 0ms     | 0ms            | 0ms      | 0    | dmd 2.085.1 |       |
| log_prefix.ex2 | 751ms    | 0ms     | 0ms            | 0ms      | 0    | dmd 2.085.1 |       |
| log_prefix.ex3 | 731ms    | 0ms     | 0ms            | 0ms      | 0    | dmd 2.085.1 |       |
| log_prefix.ex4 | 745ms    | 0ms     | 0ms            | 0ms      | 0    | dmd 2.085.1 |       |
| log_prefix.ex5 | 779ms    | 0ms     | 0ms            | 0ms      | 0    | dmd 2.085.1 |       |
+----------------+----------+---------+----------------+----------+------+-------------+-------+
```

### Per-column visibility control

* Use the `--cmdline-visibility=` option to tune the output of the 'Command
  Line' column. Available options: `full`, `lite`, `none`.
* Use the `--hide-columns=` option to list zero or more columns to be omitted
  from the CSV output.

```
dub run -q -- --test-dir=./benchmarks/log_prefix/ --compilers=dmd --cmdline-visibility=full --hide-columns='Compile,Compile & Link,Run Time,Binary Size' | tablize
+----------------+----------+-------------+-------------------------------------------------------------------------------------------------------------------+
| Name           | Semantic | Compiler    | Command Line                                                                                                      |
+----------------+----------+-------------+-------------------------------------------------------------------------------------------------------------------+
| log_prefix.ex0 | 1641ms   | dmd 2.085.1 | dmd ./benchmarks/log_prefix/ex0.d ./benchmarks/log_prefix/ctfe_runner.d -version=ex0 -of./build/log_prefix/runner |
| log_prefix.ex1 | 876ms    | dmd 2.085.1 | dmd ./benchmarks/log_prefix/ex1.d ./benchmarks/log_prefix/ctfe_runner.d -version=ex1 -of./build/log_prefix/runner |
| log_prefix.ex2 | 774ms    | dmd 2.085.1 | dmd ./benchmarks/log_prefix/ex2.d ./benchmarks/log_prefix/ctfe_runner.d -version=ex2 -of./build/log_prefix/runner |
| log_prefix.ex3 | 737ms    | dmd 2.085.1 | dmd ./benchmarks/log_prefix/ex3.d ./benchmarks/log_prefix/ctfe_runner.d -version=ex3 -of./build/log_prefix/runner |
| log_prefix.ex4 | 679ms    | dmd 2.085.1 | dmd ./benchmarks/log_prefix/ex4.d ./benchmarks/log_prefix/ctfe_runner.d -version=ex4 -of./build/log_prefix/runner |
| log_prefix.ex5 | 700ms    | dmd 2.085.1 | dmd ./benchmarks/log_prefix/ex5.d ./benchmarks/log_prefix/ctfe_runner.d -version=ex5 -of./build/log_prefix/runner |
+----------------+----------+-------------+-------------------------------------------------------------------------------------------------------------------+
```
